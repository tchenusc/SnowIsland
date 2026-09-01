package com.example.snowisland.service;

import com.example.snowisland.entity.*;
import com.example.snowisland.entity.PlayerExploration.ExplorationStatus;
import com.example.snowisland.entity.TradeItem.ItemType;
import com.example.snowisland.repository.*;
import com.example.snowisland.util.PlayerStatusCatalog;
import com.example.snowisland.util.SafeText;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class IslandExplorationService {

    private static final ObjectMapper JSON = new ObjectMapper();

    /** 事件难度最小值（含） */
    public static final int MIN_DIFFICULTY = 0;
    /** 事件难度最大值（含） */
    public static final int MAX_DIFFICULTY = 20;

    public static final int MAX_INVEST_POINTS = 15;

    /** Shown to players until DM releases the computed outcome. */
    public static final String PENDING_PLAYER_MESSAGE = "已提交，等待主持人确认。";

    public static final Map<Integer, Integer> EXPLORATION_ITEM_BONUS = new HashMap<>();
    /** 每种探索物资一次投入消耗的数量（未列出的按 1） */
    public static final Map<Integer, Integer> EXPLORATION_ITEM_CONSUME = new HashMap<>();
    static {
        EXPLORATION_ITEM_BONUS.put(3, 2);
        EXPLORATION_ITEM_BONUS.put(25, 7);
        EXPLORATION_ITEM_BONUS.put(13, 2);
        EXPLORATION_ITEM_BONUS.put(2, 5);
        EXPLORATION_ITEM_CONSUME.put(3, 10);
    }

    /**
     * 探索物品ID到物品类型的映射
     */
    public static final Map<Integer, ItemType> EXPLORATION_ITEM_TYPE = new HashMap<>();
    static {
        EXPLORATION_ITEM_TYPE.put(3, ItemType.material);
        EXPLORATION_ITEM_TYPE.put(25, ItemType.item);
        EXPLORATION_ITEM_TYPE.put(13, ItemType.item);
        EXPLORATION_ITEM_TYPE.put(2, ItemType.item);
    }

    /**
     * 验证事件难度值是否在合法范围内
     */
    public static boolean isValidDifficulty(Integer difficulty) {
        return difficulty != null && difficulty >= MIN_DIFFICULTY && difficulty <= MAX_DIFFICULTY;
    }

    public static int consumeQuantity(int itemId) {
        Integer qty = EXPLORATION_ITEM_CONSUME.get(itemId);
        return (qty != null && qty > 0) ? qty : 1;
    }

    /**
     * Each exploration item type contributes at most one unit of bonus,
     * regardless of requested quantity (qty &gt;= 1 → bonus once).
     */
    public static int investBonusOnce(int itemId, int quantity) {
        if (quantity < 1) {
            return 0;
        }
        Integer bonus = EXPLORATION_ITEM_BONUS.get(itemId);
        return (bonus != null && bonus > 0) ? bonus : 0;
    }

    @Autowired
    private PlayerExplorationRepository playerExplorationRepository;

    @Autowired
    private IslandEventRepository islandEventRepository;

    @Autowired
    private IslandEventRewardRepository islandEventRewardRepository;

    @Autowired
    private EventPackRepository eventPackRepository;

    @Autowired
    private ExplorationDataInitService explorationDataInitService;

    @Autowired
    private PlayerRepository playerRepository;

    @Autowired
    private PlayerItemRepository playerItemRepository;

    @Autowired
    private ActivityLogService activityLogService;

    @Autowired
    private GameStateService gameStateService;

    @Autowired
    private NightActionRepository nightActionRepository;

    @Autowired
    private TradeRestrictionService tradeRestrictionService;

    @Transactional
    public Map<String, Object> submitExploration(Integer playerId, Integer gameDay, Map<Integer, Integer> investItems) {
        Map<String, Object> result = new HashMap<>();
        try {
            Optional<Player> optPlayer = playerRepository.findById(playerId);
            if (!optPlayer.isPresent()) {
                result.put("success", false);
                result.put("message", "玩家不存在");
                return result;
            }
            Player player = optPlayer.get();
            if (gameDay == null || gameDay < 1) {
                gameDay = gameStateService.getCurrentDay();
            }
            String editDeny = gameStateService.denyNightSubmit(gameDay);
            if (editDeny != null) {
                result.put("success", false);
                result.put("message", editDeny);
                return result;
            }
            if (tradeRestrictionService.isBoundActive(player)) {
                result.put("success", false);
                result.put("message", PlayerStatusCatalog.BOUND_DENY_MESSAGE);
                return result;
            }

            Optional<PlayerExploration> existing = playerExplorationRepository.findByPlayerIdAndGameDay(playerId, gameDay);
            if (existing.isPresent()) {
                result.put("success", false);
                result.put("message", "今日已提交探索行动");
                return result;
            }

            boolean unlimitedNight = player.getFaction() == Player.Faction.统治者;
            if (!unlimitedNight) {
                List<NightAction> nightActions =
                        nightActionRepository.findByPlayerIdAndGameDayOrderByCreatedAtDesc(playerId, gameDay);
                if (!nightActions.isEmpty()) {
                    result.put("success", false);
                    result.put("message", "今日已提交夜晚行动，每天仅可执行一次");
                    return result;
                }
            }

            // 验证探索投入：必须投入至少1点探索值
            int investPoints = 0;
            List<String> consumedItems = new ArrayList<>();

            if (investItems == null || investItems.isEmpty()) {
                result.put("success", false);
                result.put("message", "探索必须投入至少1点探索值，请添加探索物资（火把、手电筒、蜡烛或绳索）");
                return result;
            }

            for (Map.Entry<Integer, Integer> entry : investItems.entrySet()) {
                int itemId = entry.getKey();
                int quantity = entry.getValue();
                if (quantity <= 0) continue;

                Integer bonus = EXPLORATION_ITEM_BONUS.get(itemId);
                if (bonus == null || bonus <= 0) {
                    // 记录无效物品，便于调试
                    continue;
                }

                ItemType itemType = EXPLORATION_ITEM_TYPE.get(itemId);
                if (itemType == null) {
                    continue;
                }

                Optional<PlayerItem> optItem = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(playerId, itemType, itemId);
                int consumeQty = consumeQuantity(itemId);
                if (optItem.isPresent() && optItem.get().getQuantity() >= consumeQty) {
                    PlayerItem item = optItem.get();
                    item.setQuantity(item.getQuantity() - consumeQty);
                    playerItemRepository.save(item);
                    investPoints += investBonusOnce(itemId, quantity);
                    consumedItems.add(getItemName(itemType.name(), itemId) + " x" + consumeQty);
                }
            }

            // 再次验证：确保投入了有效探索值
            if (investPoints <= 0) {
                result.put("success", false);
                result.put("message", "探索必须投入至少1点探索值，请检查物品是否有效或库存是否充足");
                return result;
            }

            if (investPoints > MAX_INVEST_POINTS) {
                investPoints = MAX_INVEST_POINTS;
            }

            int diceResult = new Random().nextInt(6) + 1;
            int totalExplorationValue = investPoints + diceResult;
            int targetDifficulty = Math.min(totalExplorationValue, MAX_DIFFICULTY);

            PlayerExploration exploration = new PlayerExploration();
            exploration.setPlayerId(playerId);
            exploration.setPlayerName(player.getName());
            exploration.setGameDay(gameDay);
            exploration.setInvestPoints(investPoints);
            exploration.setDiceResult(diceResult);
            exploration.setTotalExplorationValue(totalExplorationValue);
            exploration.setStatus(ExplorationStatus.pending);

            StringBuilder resultText = new StringBuilder();
            resultText.append("✓ 已提交【探索岛屿】\n\n");
            if (!consumedItems.isEmpty()) {
                resultText.append("【投入物资】\n");
                for (String item : consumedItems) {
                    resultText.append("- ").append(item).append("\n");
                }
                resultText.append("投入探索值: ").append(investPoints).append("/").append(MAX_INVEST_POINTS).append("\n\n");
            }
            resultText.append("等待主持人在夜晚阶段结算探索结果。");
            exploration.setResult(resultText.toString());
            playerExplorationRepository.save(exploration);

            activityLogService.log(
                    gameDay, playerId, player.getName(),
                    ActivityLogService.factionOf(player),
                    ActivityLogService.CAT_NIGHT,
                    "探索岛屿",
                    "玩家提交了岛屿探索行动，投入探索值: " + investPoints);

            Map<String, Object> triggerResult = triggerRandomEvent(exploration.getId());
            PlayerExploration stored = playerExplorationRepository.findById(exploration.getId()).orElse(exploration);
            result.put("success", true);
            result.put("message", "探索行动提交成功");
            result.put("data", toMapForPlayer(stored));
            if (!Boolean.TRUE.equals(triggerResult.get("success"))) {
                result.put("triggerError", triggerResult.get("message"));
            }
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "提交探索失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    public Map<String, Object> getPlayerExplorations(Integer playerId) {
        Map<String, Object> result = new HashMap<>();
        try {
            List<PlayerExploration> explorations = playerExplorationRepository.findByPlayerIdOrderByGameDayDesc(playerId);
            List<Map<String, Object>> list = explorations.stream()
                    .map(this::toMapForPlayer)
                    .collect(Collectors.toList());
            result.put("success", true);
            result.put("explorations", list);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "获取探索记录失败: " + e.getMessage());
        }
        return result;
    }

    public Map<String, Object> getPendingExplorations(Integer gameDay) {
        Map<String, Object> result = new HashMap<>();
        try {
            List<PlayerExploration> explorations = playerExplorationRepository.findByGameDay(gameDay);
            List<Map<String, Object>> list = explorations.stream()
                    .map(this::toMapWithPlayer)
                    .collect(Collectors.toList());
            result.put("success", true);
            result.put("pendingCount", explorations.size());
            result.put("explorations", list);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "获取待结算探索失败: " + e.getMessage());
        }
        return result;
    }

    public List<Map<String, Object>> getAllIslandEvents() {
        Map<Integer, EventPack> packMap = loadPackMap();
        return islandEventRepository.findAllByOrderByIdAsc().stream()
                .map(e -> eventToMap(e, packMap))
                .collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> createEvent(Map<String, Object> payload) {
        Map<String, Object> result = new HashMap<>();
        try {
            String name = SafeText.cleanLimit(String.valueOf(payload.get("name")), SafeText.EVENT_NAME_MAX);
            String description = SafeText.cleanLimit(
                    payload.get("description") != null ? String.valueOf(payload.get("description")) : "",
                    SafeText.FIELD_MAX);
            String rarity = payload.get("rarity") != null ? String.valueOf(payload.get("rarity")) : "normal";
            Integer difficulty = toInteger(payload.get("eventDifficulty"));
            if (difficulty == null) difficulty = toInteger(payload.get("difficulty"));
            String locationDesc = payload.get("locationDesc") != null
                    ? SafeText.cleanLimit(String.valueOf(payload.get("locationDesc")), SafeText.FIELD_MAX) : null;
            String loreFragment = payload.get("loreFragment") != null
                    ? SafeText.cleanLimit(String.valueOf(payload.get("loreFragment")), SafeText.FIELD_MAX) : null;
            Boolean isSpecial = payload.get("isSpecial") != null ? (Boolean) payload.get("isSpecial") : false;

            if (name == null || name.trim().isEmpty() || "null".equals(name)) {
                result.put("success", false);
                result.put("message", "事件名称不能为空");
                return result;
            }
            if (description == null || "null".equals(description)) description = "";
            if (!isValidDifficulty(difficulty)) {
                result.put("success", false);
                result.put("message", "事件难度必须在 " + MIN_DIFFICULTY + "-" + MAX_DIFFICULTY + " 之间");
                return result;
            }

            if (islandEventRepository.findByName(name).isPresent()) {
                result.put("success", false);
                result.put("message", "事件名称已存在");
                return result;
            }

            IslandEvent event = new IslandEvent();
            event.setName(name.trim());
            event.setDescription(description);
            event.setRarity(rarity);
            event.setEventDifficulty(difficulty);
            event.setTriggered(false);
            event.setLocationDesc(locationDesc);
            event.setLoreFragment(loreFragment);
            event.setIsSpecial(isSpecial);
            applyPackFromPayload(event, payload, true);
            IslandEvent saved = islandEventRepository.save(event);
            if (payload.containsKey("rewardsText")) {
                List<String> unmatched = explorationDataInitService.replaceRewardsFromText(saved.getId(),
                        payload.get("rewardsText") != null ? String.valueOf(payload.get("rewardsText")) : "");
                if (unmatched != null && !unmatched.isEmpty()) {
                    TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                    result.put("success", false);
                    result.put("message", "物资无法识别：" + String.join("、", unmatched));
                    return result;
                }
            }

            result.put("success", true);
            result.put("message", "事件创建成功");
            result.put("event", eventToMap(saved));
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "创建事件失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    @Transactional
    public Map<String, Object> updateEvent(Integer eventId, Map<String, Object> payload) {
        Map<String, Object> result = new HashMap<>();
        try {
            Optional<IslandEvent> opt = islandEventRepository.findById(eventId);
            if (!opt.isPresent()) {
                result.put("success", false);
                result.put("message", "事件不存在");
                return result;
            }
            IslandEvent event = opt.get();

            if (payload.containsKey("name")) {
                String name = SafeText.cleanLimit(String.valueOf(payload.get("name")), SafeText.EVENT_NAME_MAX);
                if (name != null && !name.trim().isEmpty() && !"null".equals(name)) {
                    event.setName(name.trim());
                }
            }
            if (payload.containsKey("description")) {
                String desc = SafeText.cleanLimit(String.valueOf(payload.get("description")), SafeText.FIELD_MAX);
                event.setDescription(desc == null || "null".equals(desc) ? "" : desc);
            }
            if (payload.containsKey("rarity")) {
                event.setRarity(String.valueOf(payload.get("rarity")));
            }
            if (payload.containsKey("eventDifficulty") || payload.containsKey("difficulty")) {
                Integer difficulty = toInteger(payload.get("eventDifficulty"));
                if (difficulty == null) difficulty = toInteger(payload.get("difficulty"));
                if (!isValidDifficulty(difficulty)) {
                    result.put("success", false);
                    result.put("message", "事件难度必须在 " + MIN_DIFFICULTY + "-" + MAX_DIFFICULTY + " 之间");
                    return result;
                }
                event.setEventDifficulty(difficulty);
            }
            if (payload.containsKey("locationDesc")) {
                String locationDesc = SafeText.cleanLimit(String.valueOf(payload.get("locationDesc")), SafeText.FIELD_MAX);
                event.setLocationDesc("null".equals(locationDesc) ? null : locationDesc);
            }
            if (payload.containsKey("loreFragment")) {
                String loreFragment = SafeText.cleanLimit(String.valueOf(payload.get("loreFragment")), SafeText.FIELD_MAX);
                event.setLoreFragment("null".equals(loreFragment) ? null : loreFragment);
            }
            if (payload.containsKey("isSpecial")) {
                event.setIsSpecial((Boolean) payload.get("isSpecial"));
            }
            if (payload.containsKey("packId") || payload.containsKey("packName")) {
                Integer packId = toInteger(payload.get("packId"));
                boolean hasPackName = payload.get("packName") != null
                        && !"null".equals(String.valueOf(payload.get("packName")))
                        && !String.valueOf(payload.get("packName")).trim().isEmpty();
                if (packId == null && !hasPackName) {
                    event.setPackId(null);
                    event.setPackName(null);
                } else {
                    applyPackFromPayload(event, payload, false);
                }
            }

            IslandEvent saved = islandEventRepository.save(event);
            if (payload.containsKey("rewardsText")) {
                List<String> unmatched = explorationDataInitService.replaceRewardsFromText(saved.getId(),
                        payload.get("rewardsText") != null ? String.valueOf(payload.get("rewardsText")) : "");
                if (unmatched != null && !unmatched.isEmpty()) {
                    TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                    result.put("success", false);
                    result.put("message", "物资无法识别：" + String.join("、", unmatched));
                    return result;
                }
            }
            result.put("success", true);
            result.put("message", "事件更新成功");
            result.put("event", eventToMap(saved));
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "更新事件失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    @Transactional
    public Map<String, Object> deleteEvent(Integer eventId) {
        Map<String, Object> result = new HashMap<>();
        try {
            if (!islandEventRepository.existsById(eventId)) {
                result.put("success", false);
                result.put("message", "事件不存在");
                return result;
            }
            islandEventRepository.deleteById(eventId);
            result.put("success", true);
            result.put("message", "事件删除成功");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "删除事件失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    private Map<Integer, EventPack> loadPackMap() {
        Map<Integer, EventPack> packMap = new HashMap<>();
        for (EventPack pack : eventPackRepository.findAll()) {
            packMap.put(pack.getId(), pack);
        }
        return packMap;
    }

    private void applyPackFromPayload(IslandEvent event, Map<String, Object> payload, boolean defaultToBase) {
        EventPack pack = null;
        Integer packId = toInteger(payload.get("packId"));
        if (packId != null) {
            pack = eventPackRepository.findById(packId).orElse(null);
        }
        if (pack == null && payload.get("packName") != null) {
            String packName = String.valueOf(payload.get("packName"));
            if (!packName.isEmpty() && !"null".equals(packName)) {
                pack = eventPackRepository.findByName(packName.trim()).orElse(null);
            }
        }
        if (pack == null && defaultToBase) {
            pack = eventPackRepository.findByName(EventPack.PACK_BASE).orElse(null);
        }
        if (pack != null) {
            event.setPackId(pack.getId());
            event.setPackName(pack.getName());
        }
    }

    private Integer toInteger(Object v) {
        if (v == null) return null;
        if (v instanceof Number) return ((Number) v).intValue();
        try { return Integer.parseInt(v.toString()); } catch (NumberFormatException e) { return null; }
    }

    @Transactional
    public Map<String, Object> triggerEvent(Integer explorationId, Integer eventId) {
        Map<String, Object> result = new HashMap<>();
        try {
            Optional<PlayerExploration> opt = playerExplorationRepository.findById(explorationId);
            if (!opt.isPresent()) {
                result.put("success", false);
                result.put("message", "探索记录不存在");
                return result;
            }
            PlayerExploration exploration = opt.get();
            if (exploration.getStatus() != ExplorationStatus.pending) {
                result.put("success", false);
                result.put("message", "探索状态不允许触发事件");
                return result;
            }

            Optional<IslandEvent> optEvent = islandEventRepository.findById(eventId);
            if (!optEvent.isPresent()) {
                result.put("success", false);
                result.put("message", "事件不存在");
                return result;
            }
            IslandEvent event = optEvent.get();

            Optional<Player> optPlayer = playerRepository.findById(exploration.getPlayerId());
            if (!optPlayer.isPresent()) {
                result.put("success", false);
                result.put("message", "玩家不存在");
                return result;
            }
            Player player = optPlayer.get();

            exploration.setEventId(eventId);

            StringBuilder sb = new StringBuilder();
            sb.append("✓ 已提交【探索岛屿】\n\n");
            sb.append("投入探索值: ").append(exploration.getInvestPoints()).append("\n");
            sb.append("骰子: ").append(exploration.getDiceResult()).append("\n");
            sb.append("总探索值: ").append(exploration.getTotalExplorationValue()).append("\n\n");
            sb.append("【探索结果】\n");
            sb.append("发现：").append(event.getName()).append("\n");
            sb.append(event.getDescription()).append("\n\n");

            sb.append("【探索奖励】\n");
            List<Map<String, Object>> plannedRewards = new ArrayList<>();

            List<IslandEventReward> rewards = islandEventRewardRepository.findByEventId(eventId);
            if (rewards != null && !rewards.isEmpty()) {
                for (IslandEventReward reward : rewards) {
                    ItemType itemType = reward.getItemType();
                    int itemId = reward.getItemId();
                    int quantity = reward.getQuantity();
                    if (quantity <= 0) continue;

                    String itemName = getItemName(itemType.name(), itemId);
                    String unit = getItemUnit(itemType.name(), itemId);

                    sb.append("+").append(quantity).append(unit).append(" ").append(itemName).append("\n");

                    Map<String, Object> planned = new LinkedHashMap<>();
                    planned.put("itemType", itemType.name());
                    planned.put("itemId", itemId);
                    planned.put("quantity", quantity);
                    planned.put("name", itemName);
                    planned.put("unit", unit);
                    plannedRewards.add(planned);
                }
            } else {
                sb.append("无奖励\n");
            }

            exploration.setResult(sb.toString());
            exploration.setStatus(ExplorationStatus.explored);

            event.setTriggered(true);
            islandEventRepository.save(event);
            playerExplorationRepository.save(exploration);

            activityLogService.log(
                    exploration.getGameDay(),
                    exploration.getPlayerId(),
                    player.getName(),
                    ActivityLogService.factionOf(player),
                    ActivityLogService.CAT_NIGHT,
                    "探索岛屿",
                    "结果已生成，等待主持人发布");

            result.put("success", true);
            result.put("message", "探索结果已生成，等待主持人发布");
            result.put("data", toMapWithEvent(exploration));
            result.put("rewards", plannedRewards);
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "触发事件失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    @Transactional
    public Map<String, Object> triggerRandomEvent(Integer explorationId) {
        Map<String, Object> result = new HashMap<>();
        try {
            Optional<PlayerExploration> opt = playerExplorationRepository.findById(explorationId);
            if (!opt.isPresent()) {
                result.put("success", false);
                result.put("message", "探索记录不存在");
                return result;
            }
            PlayerExploration exploration = opt.get();
            if (exploration.getStatus() != ExplorationStatus.pending) {
                result.put("success", false);
                result.put("message", "探索状态不允许触发事件");
                return result;
            }

            int totalValue = exploration.getTotalExplorationValue() != null ?
                exploration.getTotalExplorationValue() : 0;
            int targetDifficulty = Math.min(totalValue, MAX_DIFFICULTY);

            Optional<IslandEvent> optEvent = Optional.empty();

            // 探索值超过20时，优先从难度20的特殊事件中抽取
            if (totalValue > MAX_DIFFICULTY) {
                optEvent = islandEventRepository.findRandomSpecialByDifficulty(MAX_DIFFICULTY);
            }

            // 如果没有找到特殊事件或探索值不超过20，则按正常难度抽取
            if (!optEvent.isPresent()) {
                optEvent = drawEventByDifficulty(targetDifficulty);
            }

            if (!optEvent.isPresent()) {
                optEvent = islandEventRepository.findRandom();
            }

            if (!optEvent.isPresent()) {
                result.put("success", false);
                result.put("message", "没有可用事件");
                return result;
            }

            IslandEvent event = optEvent.get();
            return triggerEvent(explorationId, event.getId());
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "随机触发事件失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    public Optional<IslandEvent> drawEventByDifficulty(int targetDifficulty) {
        if (targetDifficulty < MIN_DIFFICULTY) targetDifficulty = MIN_DIFFICULTY;
        if (targetDifficulty > MAX_DIFFICULTY) targetDifficulty = MAX_DIFFICULTY;

        for (int diff = targetDifficulty; diff <= MAX_DIFFICULTY; diff++) {
            Optional<IslandEvent> event = islandEventRepository.findRandomByDifficulty(diff);
            if (event.isPresent()) {
                return event;
            }
        }

        return Optional.empty();
    }

    @Transactional
    public Map<String, Object> settleExploration(Integer explorationId, List<Map<String, Object>> rewards) {
        Map<String, Object> result = new HashMap<>();
        try {
            Optional<PlayerExploration> opt = playerExplorationRepository.findById(explorationId);
            if (!opt.isPresent()) {
                result.put("success", false);
                result.put("message", "探索记录不存在");
                return result;
            }
            PlayerExploration exploration = opt.get();
            
            if (exploration.getStatus() == ExplorationStatus.settled) {
                result.put("success", false);
                result.put("message", "探索已发布，奖励已发放");
                result.put("data", toMapWithEvent(exploration));
                return result;
            }
            
            if (exploration.getStatus() != ExplorationStatus.explored) {
                result.put("success", false);
                result.put("message", "探索结果尚未生成，无法发布");
                return result;
            }

            Optional<Player> optPlayer = playerRepository.findById(exploration.getPlayerId());
            if (!optPlayer.isPresent()) {
                result.put("success", false);
                result.put("message", "玩家不存在");
                return result;
            }
            Player player = optPlayer.get();

            if (rewards == null || rewards.isEmpty()) {
                rewards = getEventRewards(exploration.getEventId());
            }

            List<Map<String, Object>> grantedRewards = new ArrayList<>();

            if (rewards != null) {
                for (Map<String, Object> reward : rewards) {
                    String itemTypeStr = String.valueOf(reward.get("itemType"));
                    int itemId = ((Number) reward.get("itemId")).intValue();
                    int quantity = ((Number) reward.get("quantity")).intValue();
                    if (quantity <= 0) continue;

                    ItemType itemType = ItemType.valueOf(itemTypeStr);

                    addPlayerItem(exploration.getPlayerId(), itemType, itemId, quantity);

                    String itemName = getItemName(itemTypeStr, itemId);
                    String unit = getItemUnit(itemTypeStr, itemId);

                    Map<String, Object> granted = new LinkedHashMap<>();
                    granted.put("itemType", itemTypeStr);
                    granted.put("itemId", itemId);
                    granted.put("quantity", quantity);
                    granted.put("name", itemName);
                    granted.put("unit", unit);
                    grantedRewards.add(granted);
                }
            }

            exploration.setStatus(ExplorationStatus.settled);
            playerExplorationRepository.save(exploration);

            activityLogService.log(
                    exploration.getGameDay(),
                    exploration.getPlayerId(),
                    player.getName(),
                    ActivityLogService.factionOf(player),
                    ActivityLogService.CAT_NIGHT,
                    "探索岛屿结算",
                    "获得奖励: " + grantedRewards.stream()
                            .map(r -> String.valueOf(r.get("quantity")) + String.valueOf(r.get("unit")) + " " + String.valueOf(r.get("name")))
                            .collect(Collectors.joining(", ")));

            result.put("success", true);
            result.put("message", "探索结果已发布给玩家");
            result.put("data", toMapWithEvent(exploration));
            result.put("grantedRewards", grantedRewards);
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "结算探索失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    private int addPlayerItem(Integer playerId, ItemType itemType, Integer itemId, Integer quantity) {
        Optional<PlayerItem> existingOpt = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(playerId, itemType, itemId);
        if (existingOpt.isPresent()) {
            PlayerItem item = existingOpt.get();
            item.setQuantity(item.getQuantity() + quantity);
            playerItemRepository.save(item);
            return 1;
        } else {
            PlayerItem newItem = new PlayerItem();
            newItem.setPlayerId(playerId);
            newItem.setItemType(itemType);
            newItem.setItemId(itemId);
            newItem.setQuantity(quantity);
            playerItemRepository.save(newItem);
            return 1;
        }
    }

    private Map<String, Object> toMap(PlayerExploration exploration) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", exploration.getId());
        map.put("playerId", exploration.getPlayerId());
        map.put("gameDay", exploration.getGameDay());
        map.put("eventId", exploration.getEventId());
        map.put("investPoints", exploration.getInvestPoints());
        map.put("diceResult", exploration.getDiceResult());
        map.put("totalExplorationValue", exploration.getTotalExplorationValue());
        map.put("status", exploration.getStatus().name());
        map.put("result", exploration.getResult());
        map.put("createdAt", exploration.getCreatedAt());
        map.put("updatedAt", exploration.getUpdatedAt());
        return map;
    }

    private Map<String, Object> toMapForPlayer(PlayerExploration exploration) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", exploration.getId());
        map.put("playerId", exploration.getPlayerId());
        map.put("gameDay", exploration.getGameDay());
        map.put("status", exploration.getStatus().name());
        map.put("createdAt", exploration.getCreatedAt());
        map.put("updatedAt", exploration.getUpdatedAt());
        boolean released = exploration.getStatus() == ExplorationStatus.settled;
        map.put("resultPending", !released);
        if (!released) {
            map.put("result", PENDING_PLAYER_MESSAGE);
            return map;
        }
        map.put("eventId", exploration.getEventId());
        map.put("investPoints", exploration.getInvestPoints());
        map.put("diceResult", exploration.getDiceResult());
        map.put("totalExplorationValue", exploration.getTotalExplorationValue());
        map.put("result", exploration.getResult());
        if (exploration.getEventId() != null) {
            islandEventRepository.findById(exploration.getEventId()).ifPresent(event -> {
                map.put("event", eventToMap(event));
                map.put("rewards", getEventRewards(exploration.getEventId()));
            });
        }
        return map;
    }

    private Map<String, Object> toMapWithEvent(PlayerExploration exploration) {
        Map<String, Object> map = toMap(exploration);
        if (exploration.getEventId() != null) {
            islandEventRepository.findById(exploration.getEventId()).ifPresent(event -> {
                map.put("event", eventToMap(event));
                map.put("rewards", getEventRewards(exploration.getEventId()));
            });
        }
        return map;
    }

    private Map<String, Object> toMapWithPlayer(PlayerExploration exploration) {
        Map<String, Object> map = toMap(exploration);
        playerRepository.findById(exploration.getPlayerId()).ifPresent(player -> {
            map.put("playerName", player.getName());
            map.put("faction", player.getFaction() != null ? player.getFaction().name() : null);
        });
        if (exploration.getEventId() != null) {
            islandEventRepository.findById(exploration.getEventId()).ifPresent(event -> {
                map.put("event", eventToMap(event));
                map.put("rewards", getEventRewards(exploration.getEventId()));
            });
        }
        return map;
    }

    private Map<String, Object> eventToMap(IslandEvent event) {
        return eventToMap(event, loadPackMap());
    }

    private Map<String, Object> eventToMap(IslandEvent event, Map<Integer, EventPack> packMap) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", event.getId());
        map.put("name", event.getName());
        map.put("description", event.getDescription());
        map.put("triggered", event.getTriggered());
        map.put("rarity", event.getRarity());
        map.put("eventDifficulty", event.getEventDifficulty());
        map.put("locationDesc", event.getLocationDesc());
        map.put("loreFragment", event.getLoreFragment());
        map.put("isSpecial", event.getIsSpecial());
        map.put("packId", event.getPackId());
        map.put("sourceNumber", event.getSourceNumber());
        EventPack pack = null;
        if (event.getPackId() != null && packMap != null) {
            pack = packMap.get(event.getPackId());
        }
        String packName = event.getPackName();
        if (packName == null && pack != null) {
            packName = pack.getName();
        }
        map.put("packName", packName);
        map.put("packEnabled", pack != null && Boolean.TRUE.equals(pack.getEnabled()));
        map.put("rewards", getEventRewards(event.getId()));
        return map;
    }

    private List<Map<String, Object>> getEventRewards(Integer eventId) {
        if (eventId == null) {
            return Collections.emptyList();
        }
        return islandEventRewardRepository.findByEventId(eventId).stream()
                .map(r -> {
                    Map<String, Object> map = new LinkedHashMap<>();
                    map.put("id", r.getId());
                    map.put("eventId", r.getEventId());
                    map.put("itemType", r.getItemType().name());
                    map.put("itemId", r.getItemId());
                    map.put("quantity", r.getQuantity());
                    map.put("conditionDesc", r.getConditionDesc());
                    map.put("name", getItemName(r.getItemType().name(), r.getItemId()));
                    map.put("unit", getItemUnit(r.getItemType().name(), r.getItemId()));
                    return map;
                })
                .collect(Collectors.toList());
    }

    private String getItemName(String itemType, Integer itemId) {
        Map<String, Map<Integer, String>> itemNames = new HashMap<>();
        itemNames.put("item", new HashMap<>());
        itemNames.get("item").put(1, "医疗资源");
        itemNames.get("item").put(2, "手电筒");
        itemNames.get("item").put(3, "手铐");
        itemNames.get("item").put(4, "哨子");
        itemNames.get("item").put(5, "防弹衣");
        itemNames.get("item").put(6, "复合盾");
        itemNames.get("item").put(7, "信号枪");
        itemNames.get("item").put(8, "维修工具包");
        itemNames.get("item").put(9, "协议书");
        itemNames.get("item").put(10, "朗姆酒");
        itemNames.get("item").put(11, "草药");
        itemNames.get("item").put(12, "渔网");
        itemNames.get("item").put(13, "蜡烛");
        itemNames.get("item").put(14, "医用酒精");
        itemNames.get("item").put(15, "火柴");
        itemNames.get("item").put(16, "铅笔");
        itemNames.get("item").put(17, "破损海图");
        itemNames.get("item").put(18, "面包");
        itemNames.get("item").put(19, "矿场仓库钥匙");
        itemNames.get("item").put(20, "燃料仓库钥匙");
        itemNames.get("item").put(21, "镇武库钥匙");
        itemNames.get("item").put(22, "码头集换站钥匙");
        itemNames.get("item").put(23, "反叛者基地钥匙");
        itemNames.get("item").put(24, "方舟钥匙");
        itemNames.get("item").put(25, "火把");
        itemNames.get("item").put(26, "诅咒硬币");
        itemNames.get("item").put(27, "祭坛石");
        itemNames.get("item").put(28, "通灵笔记");
        itemNames.get("item").put(29, "发光矿石碎片");
        itemNames.get("item").put(30, "鱼鳞外套");
        itemNames.get("item").put(31, "契约铁卷");
        itemNames.get("item").put(32, "革命宣言");
        itemNames.get("item").put(33, "古老龙骨图");
        itemNames.get("item").put(34, "灰烬预言书");
        itemNames.get("item").put(35, "人皮册子残页");
        itemNames.get("item").put(36, "星象观测手稿");
        itemNames.get("item").put(37, "尸油蜡烛");
        itemNames.get("item").put(38, "深海鱼油蜡烛");
        itemNames.get("item").put(39, "旧地图");
        itemNames.get("item").put(40, "飞机部件·油箱");
        itemNames.get("item").put(41, "飞机部件·起落架");
        itemNames.get("item").put(42, "笔记本");
        itemNames.get("item").put(43, "钢笔");
        itemNames.get("item").put(44, "归墟罗盘");
        itemNames.get("item").put(45, "龙骨刻刀");
        itemNames.get("item").put(46, "灾厄之眼");
        itemNames.get("item").put(47, "引魂烛台");
        itemNames.get("item").put(48, "星轨轮盘");
        itemNames.get("item").put(49, "烬火旗");
        itemNames.get("item").put(50, "银币");
        itemNames.get("item").put(51, "情绪抑制器");
        itemNames.get("item").put(52, "共鸣石");
        itemNames.put("weapon", new HashMap<>());
        itemNames.get("weapon").put(1, "制式手枪");
        itemNames.get("weapon").put(2, "猎枪");
        itemNames.get("weapon").put(3, "警棍");
        itemNames.get("weapon").put(4, "刺刀");
        itemNames.get("weapon").put(5, "水手刀");
        itemNames.get("weapon").put(6, "鱼叉/矛");
        itemNames.get("weapon").put(7, "猎弓");
        itemNames.get("weapon").put(8, "十字镐");
        itemNames.get("weapon").put(9, "斧头");
        itemNames.get("weapon").put(10, "电锯");
        itemNames.get("weapon").put(11, "手术刀");
        itemNames.get("weapon").put(12, "炸药");
        itemNames.get("weapon").put(13, "电钻");
        itemNames.get("weapon").put(14, "匕首");
        itemNames.get("weapon").put(15, "铁镐");
        itemNames.put("ammo", new HashMap<>());
        itemNames.get("ammo").put(1, "手枪弹");
        itemNames.get("ammo").put(2, "猎枪弹");
        itemNames.get("ammo").put(3, "信号弹");
        itemNames.get("ammo").put(4, "箭矢");
        itemNames.put("material", new HashMap<>());
        itemNames.get("material").put(1, "金属制品");
        itemNames.get("material").put(2, "木材");
        itemNames.get("material").put(3, "绳索");
        itemNames.get("material").put(4, "木板");
        itemNames.get("material").put(5, "食物");
        itemNames.get("material").put(6, "沥青");
        itemNames.get("material").put(7, "石料");
        itemNames.get("material").put(8, "燃料");
        itemNames.get("material").put(9, "帆布");
        itemNames.get("material").put(10, "发动机");
        itemNames.get("material").put(11, "螺旋桨");
        itemNames.get("material").put(12, "发电机");

        String type = itemType != null ? itemType.toLowerCase() : "item";
        int id = itemId != null ? itemId : 0;
        return itemNames.getOrDefault(type, Collections.emptyMap()).getOrDefault(id, "未知物品");
    }

    private String getItemUnit(String itemType, Integer itemId) {
        Map<String, Map<Integer, String>> itemUnits = new HashMap<>();
        itemUnits.put("item", new HashMap<>());
        itemUnits.get("item").put(1, "份");
        itemUnits.get("item").put(2, "个");
        itemUnits.get("item").put(3, "个");
        itemUnits.get("item").put(4, "个");
        itemUnits.get("item").put(5, "件");
        itemUnits.get("item").put(6, "个");
        itemUnits.get("item").put(7, "把");
        itemUnits.get("item").put(8, "个");
        itemUnits.get("item").put(9, "个");
        itemUnits.get("item").put(10, "瓶");
        itemUnits.get("item").put(11, "个");
        itemUnits.get("item").put(12, "张");
        itemUnits.get("item").put(13, "根");
        itemUnits.get("item").put(14, "升");
        itemUnits.get("item").put(15, "盒");
        itemUnits.get("item").put(16, "盒");
        itemUnits.get("item").put(17, "张");
        itemUnits.get("item").put(18, "份");
        itemUnits.get("item").put(19, "把");
        itemUnits.get("item").put(20, "把");
        itemUnits.get("item").put(21, "把");
        itemUnits.get("item").put(22, "把");
        itemUnits.get("item").put(23, "把");
        itemUnits.get("item").put(24, "把");
        itemUnits.get("item").put(25, "把");
        itemUnits.get("item").put(26, "个");
        itemUnits.get("item").put(27, "枚");
        itemUnits.get("item").put(28, "本");
        itemUnits.get("item").put(29, "枚");
        itemUnits.get("item").put(30, "件");
        itemUnits.get("item").put(31, "卷");
        itemUnits.get("item").put(32, "份");
        itemUnits.get("item").put(33, "卷");
        itemUnits.get("item").put(34, "本");
        itemUnits.get("item").put(35, "页");
        itemUnits.get("item").put(36, "份");
        itemUnits.get("item").put(37, "支");
        itemUnits.get("item").put(38, "支");
        itemUnits.get("item").put(39, "张");
        itemUnits.get("item").put(40, "个");
        itemUnits.get("item").put(41, "个");
        itemUnits.get("item").put(42, "本");
        itemUnits.get("item").put(43, "支");
        itemUnits.get("item").put(44, "个");
        itemUnits.get("item").put(45, "把");
        itemUnits.get("item").put(46, "枚");
        itemUnits.get("item").put(47, "座");
        itemUnits.get("item").put(48, "个");
        itemUnits.get("item").put(49, "面");
        itemUnits.get("item").put(50, "枚");
        itemUnits.get("item").put(51, "个");
        itemUnits.get("item").put(52, "枚");
        itemUnits.put("weapon", new HashMap<>());
        itemUnits.get("weapon").put(1, "把");
        itemUnits.get("weapon").put(2, "把");
        itemUnits.get("weapon").put(3, "个");
        itemUnits.get("weapon").put(4, "把");
        itemUnits.get("weapon").put(5, "把");
        itemUnits.get("weapon").put(6, "个");
        itemUnits.get("weapon").put(7, "张");
        itemUnits.get("weapon").put(8, "把");
        itemUnits.get("weapon").put(9, "把");
        itemUnits.get("weapon").put(10, "把");
        itemUnits.get("weapon").put(11, "把");
        itemUnits.get("weapon").put(12, "kg");
        itemUnits.get("weapon").put(13, "把");
        itemUnits.get("weapon").put(14, "把");
        itemUnits.get("weapon").put(15, "把");
        itemUnits.put("ammo", new HashMap<>());
        itemUnits.get("ammo").put(1, "枚");
        itemUnits.get("ammo").put(2, "枚");
        itemUnits.get("ammo").put(3, "枚");
        itemUnits.get("ammo").put(4, "枝");
        itemUnits.put("material", new HashMap<>());
        itemUnits.get("material").put(1, "kg");
        itemUnits.get("material").put(2, "kg");
        itemUnits.get("material").put(3, "米");
        itemUnits.get("material").put(4, "kg");
        itemUnits.get("material").put(5, "kg");
        itemUnits.get("material").put(6, "kg");
        itemUnits.get("material").put(7, "kg");
        itemUnits.get("material").put(8, "升");
        itemUnits.get("material").put(9, "米");
        itemUnits.get("material").put(10, "个");
        itemUnits.get("material").put(11, "个");
        itemUnits.get("material").put(12, "个");

        String type = itemType != null ? itemType.toLowerCase() : "item";
        int id = itemId != null ? itemId : 0;
        return itemUnits.getOrDefault(type, Collections.emptyMap()).getOrDefault(id, "个");
    }
}