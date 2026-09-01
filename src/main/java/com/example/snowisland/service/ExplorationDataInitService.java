package com.example.snowisland.service;

import com.example.snowisland.entity.EventPack;
import com.example.snowisland.entity.IslandEvent;
import com.example.snowisland.entity.IslandEventReward;
import com.example.snowisland.entity.TradeItem;
import com.example.snowisland.repository.EventPackRepository;
import com.example.snowisland.repository.IslandEventRepository;
import com.example.snowisland.repository.IslandEventRewardRepository;
import com.example.snowisland.util.SafeText;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.PostConstruct;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class ExplorationDataInitService {

    private static final Logger logger = LoggerFactory.getLogger(ExplorationDataInitService.class);

    @Autowired
    private IslandEventRepository islandEventRepository;

    @Autowired
    private IslandEventRewardRepository islandEventRewardRepository;

    @Autowired
    private EventPackRepository eventPackRepository;

    @PersistenceContext
    private EntityManager entityManager;

    /** Loot-text aliases applied before exact 图鉴 name lookup. */
    private static final Map<String, String> REWARD_NAME_ALIASES = rewardNameAliases();

    private static final Map<String, TradeItem.ItemType> FALLBACK_TYPE_MAP = fallbackTypeMap();
    private static final Map<String, Integer> FALLBACK_ID_MAP = fallbackIdMap();

    private static class CatalogHit {
        final TradeItem.ItemType itemType;
        final int itemId;
        CatalogHit(TradeItem.ItemType itemType, int itemId) {
            this.itemType = itemType;
            this.itemId = itemId;
        }
    }

    /** Nested parse-batch cache: one UNION query per parseBraceFormat / parseRewards. */
    private final ThreadLocal<Map<String, CatalogHit>> catalogByName = new ThreadLocal<>();
    private final ThreadLocal<Integer> catalogCacheDepth = ThreadLocal.withInitial(() -> 0);

    @PostConstruct
    public void init() {
        try {
            long count = islandEventRepository.count();
            if (count == 0) {
                logger.info("探索事件表为空，开始初始化数据...");
                importEventsFromFile();
            } else {
                logger.info("探索事件表已有 {} 条记录，跳过全量初始化（缺失文件事件由启动迁移补齐）", count);
            }
        } catch (Exception e) {
            logger.error("初始化探索事件数据失败: {}", e.getMessage(), e);
        }
    }

    private List<String> readEventLines() {
        List<String> lines = readFromClasspath("exploration_events.txt");
        if (!lines.isEmpty()) {
            logger.info("从classpath读取探索事件数据");
            return lines;
        }

        String filePath = "tansuo.txt";
        Path path = Paths.get(filePath);
        logger.info("尝试从文件系统读取: {}", path.toAbsolutePath());
        if (Files.exists(path)) {
            lines = readFileWithEncoding(path, "UTF-8");
            if (lines.isEmpty()) {
                lines = readFileWithEncoding(path, "GBK");
            }
        }
        return lines;
    }

    private List<String> readFromClasspath(String resourceName) {
        List<String> lines = new ArrayList<>();
        try (InputStream is = getClass().getClassLoader().getResourceAsStream(resourceName);
             BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            if (is == null) {
                return lines;
            }
            String line;
            while ((line = reader.readLine()) != null) {
                lines.add(line);
            }
        } catch (Exception e) {
            logger.warn("从classpath读取 {} 失败: {}", resourceName, e.getMessage());
        }
        return lines;
    }

    private List<String> readFileWithEncoding(Path path, String encoding) {
        try {
            long size = Files.size(path);
            logger.info("文件大小: {} 字节, 尝试编码: {}", size, encoding);
            List<String> lines = Files.readAllLines(path, java.nio.charset.Charset.forName(encoding));
            logger.info("使用编码 {} 读取到 {} 行", encoding, lines.size());
            if (!lines.isEmpty()) {
                logger.info("第一行内容: {}", lines.get(0));
            }
            return lines;
        } catch (Exception e) {
            logger.warn("使用编码 {} 读取文件失败: {}", encoding, e.getMessage());
            return new ArrayList<>();
        }
    }

    @Transactional
    public void importEventsFromFile() {
        try {
            List<String> lines = readEventLines();
            if (lines.isEmpty()) {
                logger.warn("未找到探索事件数据");
                return;
            }
            logger.info("读取到 {} 行文本", lines.size());
            ensureSeedPacks();
            List<ExplorationEventData> events = parseEvents(lines);
            logger.info("解析到 {} 个事件", events.size());

            int eventNum = 1;
            for (ExplorationEventData eventData : events) {
                EventPack pack = resolvePackForEventNumber(eventData.eventNumber);
                IslandEvent savedEvent = persistParsedEvent(eventData, pack);
                if (savedEvent != null) {
                    logger.info("导入事件 #{}: {} (难度: {}, 包: {})", eventNum, eventData.name, eventData.difficulty,
                            pack != null ? pack.getName() : "无");
                }
                eventNum++;
            }

            logger.info("成功导入 {} 个探索事件", events.size());
        } catch (Exception e) {
            logger.error("导入探索事件失败: {}", e.getMessage(), e);
        }
    }

    private String getRarityByDifficulty(int difficulty) {
        if (difficulty >= 18) return "legendary";
        if (difficulty >= 14) return "epic";
        if (difficulty >= 10) return "rare";
        if (difficulty >= 6) return "uncommon";
        return "common";
    }

    public static class ExplorationEventData {
        public String name;
        public String locationDesc;
        public String loreFragment;
        public String rewardsText;
        public String fullText;
        public int difficulty;
        public boolean isSpecial;
        public Integer eventNumber;
        public List<RewardData> rewards = new ArrayList<>();
        public List<String> unmatchedRewards = new ArrayList<>();
        public List<String> qtyFallbackWarnings = new ArrayList<>();
    }

    static class RewardData {
        TradeItem.ItemType itemType;
        int itemId;
        int quantity;
        String displayName;
    }

    private List<ExplorationEventData> parseEvents(List<String> lines) {
        beginCatalogCache();
        try {
            return parseEventsBody(lines);
        } finally {
            endCatalogCache();
        }
    }

    private List<ExplorationEventData> parseEventsBody(List<String> lines) {
        List<ExplorationEventData> events = new ArrayList<>();
        ExplorationEventData currentEvent = null;
        
        for (String line : lines) {
            line = line.trim();
            if (line.isEmpty()) continue;
            
            if (line.matches("^事件\\d+.*")) {
                if (currentEvent != null) {
                    events.add(currentEvent);
                }
                currentEvent = new ExplorationEventData();
                Matcher numMatcher = Pattern.compile("^事件(\\d+)").matcher(line);
                if (numMatcher.find()) {
                    currentEvent.eventNumber = Integer.parseInt(numMatcher.group(1));
                }
                Matcher matcher = Pattern.compile("^事件\\d+[（(]?[^）)]*[）)]?[：:]\\s*(.*)").matcher(line);
                if (matcher.find()) {
                    currentEvent.name = matcher.group(1).trim();
                } else {
                    String[] parts = line.split("：", 2);
                    if (parts.length > 1) {
                        currentEvent.name = parts[1].trim();
                    } else {
                        currentEvent.name = line;
                    }
                }
            } else if (currentEvent != null) {
                parseFieldLine(currentEvent, line);
                if (currentEvent.fullText == null) {
                    currentEvent.fullText = line;
                } else {
                    currentEvent.fullText += "\n" + line;
                }
            }
        }
        
        if (currentEvent != null) {
            events.add(currentEvent);
        }
        
        return events;
    }

    /**
     * Parse `{难度}{正文}` or optional `{编号}{难度}{正文}` blocks. TEXT must not contain `}`.
     * First line of TEXT is the event name; remaining lines reuse 地点描述 / 可获得物资 / 历史碎片 parsers.
     */
    public List<ExplorationEventData> parseBraceFormat(String rawText) {
        List<ExplorationEventData> events = new ArrayList<>();
        if (rawText == null || rawText.trim().isEmpty()) {
            return events;
        }
        beginCatalogCache();
        try {
            return parseBraceFormatBody(rawText);
        } finally {
            endCatalogCache();
        }
    }

    private List<ExplorationEventData> parseBraceFormatBody(String rawText) {
        List<ExplorationEventData> events = new ArrayList<>();
        Pattern pattern = Pattern.compile("\\{(\\d+)\\}(?:\\{(\\d+)\\})?\\{([^}]*)\\}", Pattern.DOTALL);
        Matcher matcher = pattern.matcher(rawText);
        while (matcher.find()) {
            ExplorationEventData data = new ExplorationEventData();
            if (matcher.group(2) != null) {
                data.eventNumber = Integer.parseInt(matcher.group(1));
                data.difficulty = Integer.parseInt(matcher.group(2));
            } else {
                data.eventNumber = null;
                data.difficulty = Integer.parseInt(matcher.group(1));
            }
            String body = matcher.group(3) != null ? matcher.group(3) : "";
            String[] lines = body.split("\\r?\\n");
            boolean firstContent = true;
            StringBuilder full = new StringBuilder();
            for (String rawLine : lines) {
                String line = rawLine.trim();
                if (line.isEmpty()) {
                    continue;
                }
                if (firstContent) {
                    data.name = line;
                    firstContent = false;
                } else {
                    parseFieldLine(data, line);
                }
                if (full.length() > 0) {
                    full.append("\n");
                }
                full.append(line);
            }
            data.fullText = full.toString();
            data.isSpecial = data.isSpecial || data.difficulty == 20;
            events.add(data);
        }
        return events;
    }

    public List<ExplorationEventData> parseEventsFromFile() {
        List<String> lines = readEventLines();
        if (lines.isEmpty()) {
            return new ArrayList<>();
        }
        return parseEvents(lines);
    }

    void parseFieldLine(ExplorationEventData currentEvent, String line) {
        if (line.startsWith("地点描述")) {
            currentEvent.locationDesc = fieldValue(line);
        } else if (line.startsWith("可获得物资") || line.startsWith("物资奖励")
                || line.startsWith("物品：") || line.startsWith("物品:")) {
            String rewardsStr = fieldValue(line);
            currentEvent.rewardsText = rewardsStr;
            currentEvent.rewards = parseRewards(rewardsStr, currentEvent);
        } else if (line.startsWith("历史秘密碎片") || line.startsWith("历史碎片") || line.startsWith("秘密碎片")) {
            currentEvent.loreFragment = fieldValue(line);
        } else if (line.startsWith("难度")) {
            String value = fieldValue(line);
            if (!value.isEmpty()) {
                try {
                    currentEvent.difficulty = Integer.parseInt(value.trim());
                } catch (NumberFormatException e) {
                    currentEvent.difficulty = 1;
                }
            }
        } else if (line.startsWith("特殊")) {
            if ("是".equals(fieldValue(line))) {
                currentEvent.isSpecial = true;
            }
        }
    }

    private static String fieldValue(String line) {
        String[] parts = line.split("[：:]", 2);
        return parts.length > 1 ? parts[1].trim() : "";
    }

    @Transactional
    public void ensureSeedPacks() {
        seedPackIfMissing(EventPack.PACK_BASE, true, 1);
        seedPackIfMissing(EventPack.PACK_OLD_WORLD, false, 2);
        seedPackIfMissing(EventPack.PACK_FOURTH_ERA, false, 3);
        seedPackIfMissing(EventPack.PACK_HIDDEN_DWELLING, false, 4);
    }

    private void seedPackIfMissing(String name, boolean enabled, int sortOrder) {
        if (eventPackRepository.findByName(name).isPresent()) {
            return;
        }
        EventPack pack = new EventPack();
        pack.setName(name);
        pack.setEnabled(enabled);
        pack.setSortOrder(sortOrder);
        pack.setParentId(null);
        eventPackRepository.save(pack);
        logger.info("创建事件包: {} (enabled={})", name, enabled);
    }

    /**
     * Insert events from exploration_events.txt whose names are not already in the table.
     * Does not wipe or update existing rows (custom packs stay).
     */
    @Transactional
    public int insertMissingEventsFromFile() {
        ensureSeedPacks();
        List<ExplorationEventData> parsed = parseEventsFromFile();
        if (parsed.isEmpty()) {
            return 0;
        }
        int inserted = 0;
        for (ExplorationEventData data : parsed) {
            if (data == null || data.name == null || data.name.trim().isEmpty()) {
                continue;
            }
            String name = data.name.trim();
            if (islandEventRepository.findByName(name).isPresent()) {
                continue;
            }
            EventPack pack = resolvePackForEventNumber(data.eventNumber);
            IslandEvent saved = persistParsedEvent(data, pack);
            if (saved != null) {
                inserted++;
                logger.info("补入缺失事件: {} (包: {})", name, pack != null ? pack.getName() : "无");
            }
        }
        return inserted;
    }

    /**
     * Idempotent: refresh file-matched events that belong to a seed pack
     * or already have the matching source_number. Custom imported packs stay.
     */
    @Transactional
    public int refreshSeedEventsFromFile() {
        ensureSeedPacks();
        List<ExplorationEventData> parsed = parseEventsFromFile();
        if (parsed.isEmpty()) {
            return 0;
        }
        Set<Integer> seedPackIds = seedPackIds();
        int refreshed = 0;
        for (ExplorationEventData data : parsed) {
            if (data == null || data.name == null || data.name.trim().isEmpty()) {
                continue;
            }
            String name = data.name.trim();
            Optional<IslandEvent> existing = islandEventRepository.findByName(name);
            if (!existing.isPresent()) {
                continue;
            }
            IslandEvent event = existing.get();
            boolean inSeedPack = event.getPackId() != null && seedPackIds.contains(event.getPackId());
            boolean sourceMatch = event.getSourceNumber() != null
                    && data.eventNumber != null
                    && event.getSourceNumber().equals(data.eventNumber);
            if (!inSeedPack && !sourceMatch) {
                continue;
            }
            event.setLocationDesc(SafeText.cleanLimit(data.locationDesc, SafeText.FIELD_MAX));
            event.setLoreFragment(SafeText.cleanLimit(data.loreFragment, SafeText.FIELD_MAX));
            event.setDescription(SafeText.cleanLimit(
                    data.fullText != null ? data.fullText : "", SafeText.FIELD_MAX));
            event.setEventDifficulty(data.difficulty);
            event.setRarity(getRarityByDifficulty(data.difficulty));
            event.setIsSpecial(data.isSpecial || data.difficulty == 20);
            if (event.getSourceNumber() == null && data.eventNumber != null) {
                event.setSourceNumber(data.eventNumber);
            }
            islandEventRepository.save(event);
            List<String> unmatched = replaceRewardsFromText(event.getId(), data.rewardsText);
            if (unmatched != null && !unmatched.isEmpty()) {
                logger.warn("刷新种子事件「{}」时有未匹配物资，已保留原奖励: {}", name, unmatched);
            }
            refreshed++;
            logger.info("已刷新种子事件: {} (难度: {})", name, data.difficulty);
        }
        return refreshed;
    }

    private Set<Integer> seedPackIds() {
        List<String> seedNames = Arrays.asList(
                EventPack.PACK_BASE,
                EventPack.PACK_OLD_WORLD,
                EventPack.PACK_FOURTH_ERA,
                EventPack.PACK_HIDDEN_DWELLING);
        Set<Integer> ids = new HashSet<>();
        for (EventPack pack : eventPackRepository.findByNameIn(seedNames)) {
            ids.add(pack.getId());
        }
        return ids;
    }

    private EventPack resolvePackForEventNumber(Integer eventNumber) {
        String packName = EventPack.nameForEventNumber(eventNumber);
        return eventPackRepository.findByName(packName).orElse(null);
    }

    @Transactional
    public IslandEvent persistParsedEvent(ExplorationEventData eventData, EventPack pack) {
        if (eventData == null || eventData.name == null || eventData.name.trim().isEmpty()) {
            return null;
        }
        String safeName = SafeText.cleanLimit(eventData.name.trim(), SafeText.EVENT_NAME_MAX);
        if (safeName == null || safeName.trim().isEmpty()) {
            return null;
        }
        IslandEvent event = new IslandEvent();
        event.setName(safeName.trim());
        event.setDescription(SafeText.cleanLimit(
                eventData.fullText != null ? eventData.fullText : "", SafeText.FIELD_MAX));
        event.setLocationDesc(SafeText.cleanLimit(eventData.locationDesc, SafeText.FIELD_MAX));
        event.setLoreFragment(SafeText.cleanLimit(eventData.loreFragment, SafeText.FIELD_MAX));
        event.setEventDifficulty(eventData.difficulty);
        event.setTriggered(false);
        event.setRarity(getRarityByDifficulty(eventData.difficulty));
        event.setIsSpecial(eventData.isSpecial || eventData.difficulty == 20);
        event.setSourceNumber(eventData.eventNumber);
        if (pack != null) {
            event.setPackId(pack.getId());
            event.setPackName(pack.getName());
        }
        IslandEvent savedEvent = islandEventRepository.save(event);
        if (eventData.rewards != null) {
            for (RewardData reward : eventData.rewards) {
                IslandEventReward eventReward = new IslandEventReward();
                eventReward.setEventId(savedEvent.getId());
                eventReward.setItemType(reward.itemType);
                eventReward.setItemId(reward.itemId);
                eventReward.setQuantity(reward.quantity);
                islandEventRewardRepository.save(eventReward);
            }
        }
        return savedEvent;
    }

    /**
     * Replace event rewards from free-text. Empty / intentional-none leaves no rewards.
     * If any token cannot be mapped, existing rewards are left untouched and those names are returned.
     */
    @Transactional
    public List<String> replaceRewardsFromText(Integer eventId, String rewardsText) {
        if (eventId == null) {
            return Collections.emptyList();
        }
        String cleaned = SafeText.cleanLimit(rewardsText, SafeText.FIELD_MAX);
        ExplorationEventData parsed = new ExplorationEventData();
        List<RewardData> rewards = parseRewards(cleaned, parsed);
        if (!parsed.unmatchedRewards.isEmpty()) {
            return parsed.unmatchedRewards;
        }
        islandEventRewardRepository.deleteByEventId(eventId);
        for (RewardData reward : rewards) {
            IslandEventReward eventReward = new IslandEventReward();
            eventReward.setEventId(eventId);
            eventReward.setItemType(reward.itemType);
            eventReward.setItemId(reward.itemId);
            eventReward.setQuantity(reward.quantity);
            islandEventRewardRepository.save(eventReward);
        }
        return Collections.emptyList();
    }

    private List<RewardData> parseRewards(String rewardsStr, ExplorationEventData data) {
        beginCatalogCache();
        try {
            return parseRewardsBody(rewardsStr, data);
        } finally {
            endCatalogCache();
        }
    }

    private List<RewardData> parseRewardsBody(String rewardsStr, ExplorationEventData data) {
        List<RewardData> rewards = new ArrayList<>();
        List<String> unmatched = new ArrayList<>();
        List<String> qtyWarnings = new ArrayList<>();
        if (data != null) {
            data.unmatchedRewards = unmatched;
            data.qtyFallbackWarnings = qtyWarnings;
        }
        if (rewardsStr == null || rewardsStr.isEmpty()) return rewards;
        if (rewardsStr.contains("无直接物资") || rewardsStr.contains("无物资")) return rewards;
        if (rewardsStr.contains("请私信dm") || rewardsStr.contains("私信dm")) return rewards;

        String[] items = splitRewardsOutsideParens(rewardsStr);
        for (String item : items) {
            item = item.trim();
            if (item.isEmpty()) continue;
            if (item.contains("随机一份") || item.contains("未被揭示")) continue;

            RewardData reward = parseSingleReward(item, unmatched, qtyWarnings);
            if (reward != null) {
                rewards.add(reward);
            }
        }

        return rewards;
    }

    /** Split reward entries on delimiters outside both （） and () parentheses. */
    private String[] splitRewardsOutsideParens(String rewardsStr) {
        List<String> parts = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        int parenDepth = 0;
        for (int i = 0; i < rewardsStr.length(); i++) {
            char c = rewardsStr.charAt(i);
            if (c == '（' || c == '(') {
                parenDepth++;
                current.append(c);
            } else if (c == '）' || c == ')') {
                parenDepth--;
                current.append(c);
            } else if (parenDepth == 0 && (c == '，' || c == ',' || c == '、')) {
                String part = current.toString().trim();
                if (!part.isEmpty()) {
                    parts.add(part);
                }
                current = new StringBuilder();
            } else {
                current.append(c);
            }
        }
        String part = current.toString().trim();
        if (!part.isEmpty()) {
            parts.add(part);
        }
        return parts.toArray(new String[0]);
    }

    private RewardData parseSingleReward(String itemStr, List<String> unmatched, List<String> qtyWarnings) {
        itemStr = itemStr.trim();
        RewardData reward = new RewardData();

        Pattern pattern = Pattern.compile("(.+?)\\s*[（(]([^）)]+?)[）)]");
        Matcher matcher = pattern.matcher(itemStr);
        
        String itemName;
        int quantity = 1;
        boolean qtyFallbackToOne = false;

        if (matcher.find()) {
            itemName = matcher.group(1).trim();
            String qtyStr = matcher.group(2).trim();

            Pattern qtyPattern = Pattern.compile("(\\d+\\.?\\d*)\\s*(吨|千克|kg|公斤|个|把|瓶|米|升|份|单位|盒|张|支|发|枚)");
            Matcher qtyMatcher = qtyPattern.matcher(qtyStr);

            if (qtyMatcher.find()) {
                double qty = Double.parseDouble(qtyMatcher.group(1));
                String unit = qtyMatcher.group(2);

                if (unit.equals("吨")) {
                    qty = qty * 1000;
                } else if (unit.equals("千克") || unit.equals("公斤")) {

                }

                quantity = (int) Math.ceil(qty);
            } else {
                try {
                    quantity = Integer.parseInt(qtyStr.replaceAll("[^0-9]", ""));
                } catch (NumberFormatException e) {
                    quantity = 1;
                    qtyFallbackToOne = true;
                }
            }
        } else {
            itemName = itemStr;
            quantity = 1;
        }

        CatalogHit hit = resolveRewardName(itemName);

        if (hit != null) {
            reward.itemType = hit.itemType;
            reward.itemId = hit.itemId;
            reward.quantity = quantity;
            reward.displayName = itemName + " ×" + quantity;
            if (qtyFallbackToOne && qtyWarnings != null) {
                qtyWarnings.add("「" + itemName + "」数量无法解析，将按 1 处理");
            }
            return reward;
        }

        logger.warn("无法识别的物资: {}", itemName);
        if (unmatched != null) {
            unmatched.add(itemName);
        }
        return null;
    }

    private void beginCatalogCache() {
        int depth = catalogCacheDepth.get();
        if (depth == 0) {
            catalogByName.set(loadCatalogByName());
        }
        catalogCacheDepth.set(depth + 1);
    }

    private void endCatalogCache() {
        int depth = catalogCacheDepth.get() - 1;
        if (depth <= 0) {
            catalogByName.remove();
            catalogCacheDepth.remove();
        } else {
            catalogCacheDepth.set(depth);
        }
    }

    /**
     * Alias → exact catalog name, then live 图鉴, then hardcoded fallback.
     * 「医疗包」and「医疗资源」both resolve to item id 1; exploration_events.txt rewards
     * already worded as 医疗资源 keep their quantities, kit-worded lines are ×10 in the file.
     */
    private CatalogHit resolveRewardName(String itemName) {
        String lookupName = REWARD_NAME_ALIASES.getOrDefault(itemName, itemName);
        Map<String, CatalogHit> live = catalogByName.get();
        if (live != null && !live.isEmpty()) {
            CatalogHit hit = live.get(lookupName);
            if (hit != null) {
                return hit;
            }
        }
        TradeItem.ItemType type = FALLBACK_TYPE_MAP.get(lookupName);
        Integer id = FALLBACK_ID_MAP.get(lookupName);
        if (type != null && id != null) {
            return new CatalogHit(type, id);
        }
        if (!lookupName.equals(itemName)) {
            type = FALLBACK_TYPE_MAP.get(itemName);
            id = FALLBACK_ID_MAP.get(itemName);
            if (type != null && id != null) {
                return new CatalogHit(type, id);
            }
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    private Map<String, CatalogHit> loadCatalogByName() {
        if (entityManager == null) {
            return Collections.emptyMap();
        }
        try {
            List<Object[]> raw = entityManager.createNativeQuery(
                    "SELECT 'item' as itemType, id, name, unit, NULL as threatLevel, remark, tag, image_url FROM item " +
                    "UNION ALL SELECT 'weapon', id, name, unit, threat_level, remark, tag, image_url FROM weapon " +
                    "UNION ALL SELECT 'ammo', id, name, unit, NULL, remark, tag, image_url FROM ammo " +
                    "UNION ALL SELECT 'material', id, name, unit, NULL, remark, tag, image_url FROM material " +
                    "ORDER BY itemType, id"
            ).getResultList();
            Map<String, CatalogHit> byName = new HashMap<>();
            for (Object[] row : raw) {
                if (row == null || row[0] == null || row[1] == null || row[2] == null) {
                    continue;
                }
                String typeName = String.valueOf(row[0]).trim();
                String name = String.valueOf(row[2]).trim();
                if (name.isEmpty()) {
                    continue;
                }
                TradeItem.ItemType type;
                try {
                    type = TradeItem.ItemType.valueOf(typeName);
                } catch (IllegalArgumentException ex) {
                    continue;
                }
                byName.putIfAbsent(name, new CatalogHit(type, ((Number) row[1]).intValue()));
            }
            return byName;
        } catch (RuntimeException e) {
            logger.warn("加载图鉴物资失败，回退硬编码映射: {}", e.getMessage());
            return Collections.emptyMap();
        }
    }

    private static Map<String, String> rewardNameAliases() {
        Map<String, String> aliases = new HashMap<>();
        aliases.put("酒精", "医用酒精");
        aliases.put("维修包", "维修工具包");
        aliases.put("油箱", "飞机部件·油箱");
        aliases.put("飞机部件油箱", "飞机部件·油箱");
        aliases.put("起落架", "飞机部件·起落架");
        aliases.put("点火工具", "火柴");
        aliases.put("黑祭·灾厄降临仪式记物", "黑祭·灾厄降临记物");
        aliases.put("黑祭·灾厄降临记物", "黑祭·灾厄降临记物");
        aliases.put("命运之轮·星轨逆转仪式记物", "命运之轮·星轨逆转记物");
        aliases.put("记载物命运之轮·星轨逆转仪式记物", "命运之轮·星轨逆转记物");
        aliases.put("灵魂摆渡·亡者回响仪式记物", "灵魂摆渡·亡者回响记物");
        aliases.put("记载物灵魂摆渡·亡者回响仪式记物", "灵魂摆渡·亡者回响记物");
        aliases.put("轻制银币", "银币");
        aliases.put("医疗包", "医疗资源");
        aliases.put("医疗资源", "医疗包");
        return Collections.unmodifiableMap(aliases);
    }

    private static Map<String, TradeItem.ItemType> fallbackTypeMap() {
        Map<String, TradeItem.ItemType> typeMap = new HashMap<>();
        typeMap.put("医疗包", TradeItem.ItemType.item);
        typeMap.put("手电筒", TradeItem.ItemType.item);
        typeMap.put("维修工具包", TradeItem.ItemType.item);
        typeMap.put("哨子", TradeItem.ItemType.item);
        typeMap.put("朗姆酒", TradeItem.ItemType.item);
        typeMap.put("渔网", TradeItem.ItemType.item);
        typeMap.put("点火工具", TradeItem.ItemType.item);
        typeMap.put("蜡烛", TradeItem.ItemType.item);
        typeMap.put("铅笔", TradeItem.ItemType.item);
        typeMap.put("火柴", TradeItem.ItemType.item);
        typeMap.put("火把", TradeItem.ItemType.item);
        typeMap.put("草药", TradeItem.ItemType.item);
        typeMap.put("医疗资源", TradeItem.ItemType.item);
        typeMap.put("祭坛石", TradeItem.ItemType.item);
        typeMap.put("银币", TradeItem.ItemType.item);
        typeMap.put("轻制银币", TradeItem.ItemType.item);
        typeMap.put("情绪抑制器", TradeItem.ItemType.item);
        typeMap.put("共鸣石", TradeItem.ItemType.item);
        typeMap.put("协议书", TradeItem.ItemType.item);
        typeMap.put("医用酒精", TradeItem.ItemType.item);
        typeMap.put("黑祭·灾厄降临记物", TradeItem.ItemType.item);
        typeMap.put("命运之轮·星轨逆转记物", TradeItem.ItemType.item);
        typeMap.put("灵魂摆渡·亡者回响记物", TradeItem.ItemType.item);
        typeMap.put("猎弓", TradeItem.ItemType.weapon);
        typeMap.put("制式手枪", TradeItem.ItemType.weapon);
        typeMap.put("旧式手枪", TradeItem.ItemType.weapon);
        typeMap.put("猎枪", TradeItem.ItemType.weapon);
        typeMap.put("信号枪", TradeItem.ItemType.weapon);
        typeMap.put("十字镐", TradeItem.ItemType.weapon);
        typeMap.put("猎枪弹", TradeItem.ItemType.ammo);
        typeMap.put("手枪弹", TradeItem.ItemType.ammo);
        typeMap.put("信号弹", TradeItem.ItemType.ammo);
        typeMap.put("金属制品", TradeItem.ItemType.material);
        typeMap.put("木材", TradeItem.ItemType.material);
        typeMap.put("绳索", TradeItem.ItemType.material);
        typeMap.put("食物", TradeItem.ItemType.material);
        typeMap.put("帆布", TradeItem.ItemType.material);
        typeMap.put("煤油", TradeItem.ItemType.material);
        typeMap.put("沥青", TradeItem.ItemType.material);
        typeMap.put("燃料", TradeItem.ItemType.material);
        typeMap.put("石料", TradeItem.ItemType.material);
        typeMap.put("炸药", TradeItem.ItemType.material);
        typeMap.put("发动机", TradeItem.ItemType.material);
        typeMap.put("发电机", TradeItem.ItemType.material);
        typeMap.put("木板", TradeItem.ItemType.material);
        typeMap.put("铜质线缆", TradeItem.ItemType.material);
        return Collections.unmodifiableMap(typeMap);
    }

    private static Map<String, Integer> fallbackIdMap() {
        Map<String, Integer> idMap = new HashMap<>();
        idMap.put("医疗包", 1);
        idMap.put("手电筒", 2);
        idMap.put("维修工具包", 8);
        idMap.put("哨子", 4);
        idMap.put("朗姆酒", 10);
        idMap.put("渔网", 12);
        idMap.put("点火工具", 15);
        idMap.put("蜡烛", 13);
        idMap.put("铅笔", 16);
        idMap.put("火柴", 15);
        idMap.put("火把", 25);
        idMap.put("草药", 11);
        idMap.put("医疗资源", 1);
        idMap.put("祭坛石", 27);
        idMap.put("银币", 50);
        idMap.put("轻制银币", 50);
        idMap.put("情绪抑制器", 51);
        idMap.put("共鸣石", 52);
        idMap.put("协议书", 9);
        idMap.put("医用酒精", 14);
        idMap.put("黑祭·灾厄降临记物", 34);
        idMap.put("命运之轮·星轨逆转记物", 36);
        idMap.put("灵魂摆渡·亡者回响记物", 35);
        idMap.put("猎弓", 5);
        idMap.put("制式手枪", 1);
        idMap.put("旧式手枪", 6);
        idMap.put("猎枪", 2);
        idMap.put("信号枪", 7);
        idMap.put("十字镐", 15);
        idMap.put("猎枪弹", 2);
        idMap.put("手枪弹", 1);
        idMap.put("信号弹", 3);
        idMap.put("金属制品", 1);
        idMap.put("木材", 2);
        idMap.put("绳索", 3);
        idMap.put("食物", 5);
        idMap.put("帆布", 9);
        idMap.put("煤油", 8);
        idMap.put("沥青", 6);
        idMap.put("燃料", 8);
        idMap.put("石料", 7);
        idMap.put("炸药", 14);
        idMap.put("发动机", 10);
        idMap.put("发电机", 12);
        idMap.put("木板", 4);
        idMap.put("铜质线缆", 3);
        return Collections.unmodifiableMap(idMap);
    }

    @Transactional
    public void reimportEvents() {
        ensureSeedPacks();
        Set<Integer> seedPackIds = seedPackIds();
        Set<String> fileNames = new HashSet<>();
        for (ExplorationEventData data : parseEventsFromFile()) {
            if (data.name != null) {
                fileNames.add(data.name);
            }
        }
        List<IslandEvent> toDelete = new ArrayList<>();
        for (IslandEvent event : islandEventRepository.findAll()) {
            boolean inSeedPack = event.getPackId() != null && seedPackIds.contains(event.getPackId());
            boolean unmatchedFileEvent = event.getPackId() == null && fileNames.contains(event.getName());
            if (inSeedPack || unmatchedFileEvent) {
                toDelete.add(event);
            }
        }
        for (IslandEvent event : toDelete) {
            islandEventRewardRepository.deleteByEventId(event.getId());
            islandEventRepository.delete(event);
        }
        importEventsFromFile();
    }
}
