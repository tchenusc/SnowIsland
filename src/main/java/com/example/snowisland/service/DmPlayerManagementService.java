package com.example.snowisland.service;

import com.example.snowisland.entity.*;
import com.example.snowisland.entity.TradeItem.ItemType;
import com.example.snowisland.entity.Player.Faction;
import com.example.snowisland.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class DmPlayerManagementService {

    private static final String DEFAULT_PASSWORD = "test123";
    private static final int USERNAME_MAX_LENGTH = 50;
    private static final int PASSWORD_MAX_LENGTH = 100;
    private static final int PLAYER_NAME_MAX_LENGTH = 50;

    @Autowired
    private PlayerRepository playerRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    private SkillRepository skillRepository;

    @Autowired
    private JobInitialItemsRepository jobInitialItemsRepository;

    @Autowired
    private DmPlayerInventoryService dmPlayerInventoryService;

    @Autowired
    private PlayerSupplyService playerSupplyService;

    @Autowired
    private PlayerItemRepository playerItemRepository;

    @Autowired
    private PlayerService playerService;

    @Autowired
    private GameStateService gameStateService;

    @Autowired
    private PlayerDailyConsumptionRepository playerDailyConsumptionRepository;

    @Autowired
    private TradeRestrictionService tradeRestrictionService;

    @Autowired
    private PlayerMarkerRepository playerMarkerRepository;

    public Map<String, Object> listPlayersForDm(String userRole) {
        Map<String, Object> result = new LinkedHashMap<>();
        if (!isDm(userRole)) {
            return deny(result, "只有DM可以查看玩家列表");
        }

        Map<Integer, String> jobNames = new HashMap<>();
        for (Job job : jobRepository.findAll()) {
            jobNames.put(job.getId(), job.getName());
        }
        Map<Integer, String> skillNames = new HashMap<>();
        for (Skill skill : skillRepository.findAll()) {
            skillNames.put(skill.getId(), skill.getName());
        }

        int currentGameDay = gameStateService.getCurrentDay();
        Map<Integer, Boolean> consumptionStatus = new HashMap<>();
        for (PlayerDailyConsumption c : playerDailyConsumptionRepository.findByGameDay(currentGameDay)) {
            consumptionStatus.put(c.getPlayerId(), PlayerConsumptionService.isDailyRequirementsMet(c));
        }

        List<Map<String, Object>> rows = new ArrayList<>();
        for (Player player : playerRepository.findAll()) {
            rows.add(toDmPlayerRow(player, jobNames, skillNames, consumptionStatus));
        }
        result.put("success", true);
        result.put("players", rows);
        return result;
    }

    public Map<String, Object> previewJobStartingInventory(Integer jobId, Integer hiddenJobId, String userRole) {
        Map<String, Object> result = new LinkedHashMap<>();
        if (!isDm(userRole)) {
            return deny(result, "只有DM可以预览初始背包");
        }
        boolean hasPublic = jobId != null && jobRepository.findById(jobId).isPresent();
        boolean hasHidden = hiddenJobId != null && jobRepository.findById(hiddenJobId).isPresent();
        if (!hasPublic && !hasHidden) {
            return deny(result, "职业不存在");
        }
        List<Map<String, Object>> rows = new ArrayList<>();
        if (hasPublic) {
            rows.addAll(buildStartingItemRows(jobId));
        }
        if (hasHidden && !hiddenJobId.equals(jobId)) {
            rows.addAll(buildStartingItemRows(hiddenJobId));
        }
        result.put("success", true);
        result.put("items", mergeItemRows(rows));
        return result;
    }

    @Transactional
    public Map<String, Object> createPlayerForDm(Map<String, Object> body, String userRole) {
        Map<String, Object> result = new LinkedHashMap<>();
        if (!isDm(userRole)) {
            return deny(result, "只有DM可以创建玩家");
        }

        String name = stringVal(body.get("name"));
        if (name == null || name.trim().isEmpty()) {
            return deny(result, "请输入玩家姓名");
        }
        name = name.trim();
        try {
            validatePlayerName(name);
        } catch (IllegalArgumentException e) {
            return deny(result, e.getMessage());
        }

        String factionStr = stringVal(body.get("faction"));
        if (factionStr == null || factionStr.trim().isEmpty()) {
            return deny(result, "请选择阵营");
        }

        Integer jobId = intOrNull(body.get("jobId"));
        if (jobId == null || !jobRepository.findById(jobId).isPresent()) {
            return deny(result, "请选择职业");
        }

        Integer skillId = intOrNull(body.get("skillId"));
        if (skillId == null || !skillRepository.findById(skillId).isPresent()) {
            return deny(result, "请选择特性");
        }

        String loginUsername = stringVal(body.get("loginUsername"));
        try {
            validateLoginUsername(loginUsername);
        } catch (IllegalArgumentException e) {
            return deny(result, e.getMessage());
        }
        loginUsername = loginUsername.trim();

        String loginPassword = stringVal(body.get("loginPassword"));
        try {
            validateLoginPassword(loginPassword);
        } catch (IllegalArgumentException e) {
            return deny(result, e.getMessage());
        }

        try {
            Player player = new Player();
            player.setName(name);
            applyPlayerFieldsFromBody(player, body, true);
            player.setJobId(jobId);
            player.setSkillId(skillId);

            Player saved = playerRepository.save(player);

            if (userRepository.existsByUsername(loginUsername)) {
                throw new IllegalArgumentException("登录账号已存在: " + loginUsername);
            }

            User user = new User();
            user.setUsername(loginUsername);
            user.setPassword(loginPassword);
            user.setRole(User.Role.PLAYER);
            user.setPlayerId(saved.getId());
            userRepository.save(user);

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> customItems = (List<Map<String, Object>>) body.get("startingItems");
            if (customItems != null && !customItems.isEmpty()) {
                applyInventoryItems(saved.getId(), customItems, "set", userRole);
            } else {
                List<Map<String, Object>> starting = buildStartingItemRowsForPlayer(saved);
                if (!starting.isEmpty()) {
                    applyInventoryItems(saved.getId(), starting, "set", userRole);
                }
            }

            result.put("success", true);
            result.put("player", saved);
            result.put("username", loginUsername);
            result.put("password", loginPassword);
            result.put("playerId", saved.getId());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "创建玩家失败: " + e.getMessage());
        }
        return result;
    }

    @Transactional
    public Map<String, Object> updatePlayerForDm(Integer playerId, Map<String, Object> body, String userRole) {
        Map<String, Object> result = new LinkedHashMap<>();
        if (!isDm(userRole)) {
            return deny(result, "只有DM可以更新玩家");
        }

        Player existing = playerRepository.findById(playerId).orElse(null);
        if (existing == null) {
            return deny(result, "玩家不存在");
        }

        try {
            if (body.containsKey("name")) {
                String name = stringVal(body.get("name"));
                if (name != null && !name.trim().isEmpty()) {
                    existing.setName(name.trim());
                }
            }
            applyPlayerFieldsFromBody(existing, body, false);

            if (body.containsKey("isBound") && !boolVal(body.get("isBound"))) {
                clearBindingMarkers(existing.getId());
            }

            playerRepository.save(existing);

            if (body.containsKey("loginUsername") || body.containsKey("loginPassword")) {
                updateCredentials(playerId, body, result);
                if (Boolean.FALSE.equals(result.get("success"))) {
                    return result;
                }
            }

            result.put("success", true);
            result.put("message", "已保存");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "更新失败: " + e.getMessage());
        }
        return result;
    }

    @Transactional
    public Map<String, Object> grantJobStartingInventory(Integer playerId, String mode, String userRole) {
        Map<String, Object> result = new LinkedHashMap<>();
        if (!isDm(userRole)) {
            return deny(result, "只有DM可以发放初始背包");
        }
        Player player = playerRepository.findById(playerId).orElse(null);
        if (player == null) {
            return deny(result, "玩家不存在");
        }
        if (player.getJobId() == null && player.getHiddenJobId() == null) {
            return deny(result, "玩家未分配职业");
        }
        String applyMode = "replace".equalsIgnoreCase(mode) ? "set" : "add";
        return applyInventoryItems(playerId, buildStartingItemRowsForPlayer(player), applyMode, userRole);
    }

    @Transactional
    public Map<String, Object> applyInventoryItems(
            Integer playerId,
            List<Map<String, Object>> items,
            String mode,
            String userRole
    ) {
        Map<String, Object> result = new LinkedHashMap<>();
        if (!isDm(userRole)) {
            return deny(result, "只有DM可以修改背包");
        }
        if (!playerRepository.findById(playerId).isPresent()) {
            return deny(result, "玩家不存在");
        }
        if (items == null) {
            items = Collections.emptyList();
        }

        boolean replace = "set".equalsIgnoreCase(mode) || "replace".equalsIgnoreCase(mode);

        try {
            for (Map<String, Object> row : items) {
                String itemType = stringVal(row.get("itemType"));
                Integer itemId = intOrNull(row.get("itemId"));
                Integer quantity = intOrNull(row.get("quantity"));
                if (itemType == null || itemId == null || quantity == null) {
                    continue;
                }
                if (quantity < 0) {
                    return deny(result, "数量不能为负数");
                }
                NormalizedItem normalized = normalizeItemType(itemType, itemId);
                applyOneItem(playerId, normalized.type, normalized.itemId, quantity, replace);
            }
            result.put("success", true);
            result.put("message", replace ? "已设置背包" : "已添加物品");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    public Map<String, Object> deletePlayerForDm(Integer playerId, String userRole) {
        Map<String, Object> result = new LinkedHashMap<>();
        if (!isDm(userRole)) {
            return deny(result, "只有DM可以删除玩家");
        }
        return playerService.deletePlayer(playerId);
    }

    private List<Map<String, Object>> buildStartingItemRowsForPlayer(Player player) {
        List<Map<String, Object>> rows = new ArrayList<>();
        if (player.getJobId() != null) {
            rows.addAll(buildStartingItemRows(player.getJobId()));
        }
        if (player.getHiddenJobId() != null && !player.getHiddenJobId().equals(player.getJobId())) {
            rows.addAll(buildStartingItemRows(player.getHiddenJobId()));
        }
        return mergeItemRows(rows);
    }

    private List<Map<String, Object>> mergeItemRows(List<Map<String, Object>> rows) {
        Map<String, Map<String, Object>> merged = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            String key = row.get("itemType") + ":" + row.get("itemId");
            Map<String, Object> existing = merged.get(key);
            if (existing == null) {
                merged.put(key, new LinkedHashMap<>(row));
            } else {
                Integer a = intOrNull(existing.get("quantity"));
                Integer b = intOrNull(row.get("quantity"));
                existing.put("quantity", (a != null ? a : 0) + (b != null ? b : 0));
            }
        }
        return new ArrayList<>(merged.values());
    }

    private List<Map<String, Object>> buildStartingItemRows(Integer jobId) {
        List<JobInitialItems> initialItems = jobInitialItemsRepository.findByJobIdOrderByItemType(jobId);
        List<Map<String, Object>> rows = new ArrayList<>();
        for (JobInitialItems item : initialItems) {
            Map<String, Object> row = new LinkedHashMap<>();
            String type = item.getItemType().name().toLowerCase(Locale.ROOT);
            int id = item.getItemId();
            NormalizedItem normalized = normalizeItemType(type, id);
            row.put("itemType", normalized.type);
            row.put("itemId", normalized.itemId);
            row.put("quantity", item.getQuantity());
            row.put("unit", item.getUnit());
            rows.add(row);
        }
        return rows;
    }

    private void applyOneItem(Integer playerId, String itemType, Integer itemId, int quantity, boolean replace) {
        ItemType type = ItemType.valueOf(itemType.toLowerCase(Locale.ROOT));
        Optional<PlayerItem> opt = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(playerId, type, itemId);
        int target = quantity;
        if (!replace && opt.isPresent()) {
            target = opt.get().getQuantity() + quantity;
        }
        dmPlayerInventoryService.setPlayerItemQuantity(playerId, type.name(), itemId, target, "dm");
    }

    private NormalizedItem normalizeItemType(String itemType, int itemId) {
        return new NormalizedItem(itemType.toLowerCase(Locale.ROOT), itemId);
    }

    private void applyPlayerFieldsFromBody(Player player, Map<String, Object> body, boolean isCreate) {
        if (body.containsKey("faction") || isCreate) {
            String factionStr = stringVal(body.get("faction"));
            if (factionStr != null && !factionStr.trim().isEmpty()) {
                player.setFaction(Faction.valueOf(factionStr.trim()));
            } else if (isCreate && player.getFaction() == null) {
                player.setFaction(Faction.平民);
            }
        }
        if (body.containsKey("jobId")) {
            player.setJobId(intOrNull(body.get("jobId")));
        }
        if (body.containsKey("skillId")) {
            player.setSkillId(intOrNull(body.get("skillId")));
        }
        if (body.containsKey("isWeak")) {
            player.setIsWeak(boolVal(body.get("isWeak")));
        }
        if (body.containsKey("isOverworked")) {
            player.setIsOverworked(boolVal(body.get("isOverworked")));
        }
        if (body.containsKey("isInjured")) {
            Integer val = intOrNull(body.get("isInjured"));
            player.setIsInjured(val != null ? val : 0);
        }
        if (body.containsKey("isSeverelyInjured")) {
            player.setIsSeverelyInjured(boolVal(body.get("isSeverelyInjured")));
        }
        if (body.containsKey("isDead")) {
            player.setIsDead(boolVal(body.get("isDead")));
        }
        if (body.containsKey("dmNotes")) {
            player.setDmNotes(stringVal(body.get("dmNotes")));
        }
        if (body.containsKey("hiddenJobId")) {
            player.setHiddenJobId(intOrNull(body.get("hiddenJobId")));
        }
        if (body.containsKey("tradeBanned")) {
            player.setTradeBanned(boolVal(body.get("tradeBanned")));
        }
        if (body.containsKey("tradeBanExempt")) {
            player.setTradeBanExempt(boolVal(body.get("tradeBanExempt")));
        }
        if (body.containsKey("isBound")) {
            player.setIsBound(boolVal(body.get("isBound")));
        }
        normalizeInjuryFieldsFromBody(player, body);
    }

    /**
     * Align isInjured / isSeverelyInjured / isDead from fields present in this request only.
     * DM dropdowns send the integer; combat assist may send 1 plus a severe/dead boolean.
     */
    private void normalizeInjuryFieldsFromBody(Player player, Map<String, Object> body) {
        boolean hasInjured = body.containsKey("isInjured");
        boolean hasSevere = body.containsKey("isSeverelyInjured");
        boolean hasDead = body.containsKey("isDead");
        if (!hasInjured && !hasSevere && !hasDead) {
            return;
        }
        int level = 0;
        if (hasInjured) {
            Integer val = intOrNull(body.get("isInjured"));
            if (val != null) {
                level = Math.max(level, val);
            }
        }
        if (hasSevere && boolVal(body.get("isSeverelyInjured"))) {
            level = Math.max(level, 2);
        }
        if (hasDead && boolVal(body.get("isDead"))) {
            level = Math.max(level, 3);
        }
        player.setIsInjured(level);
        player.setIsSeverelyInjured(level >= 2);
        player.setIsDead(level >= 3);
    }

    private void clearBindingMarkers(Integer playerId) {
        if (playerId == null) {
            return;
        }
        List<PlayerMarker> toDelete = new ArrayList<>();
        for (PlayerMarker marker : playerMarkerRepository.findByPlayerIdOrderByIdAsc(playerId)) {
            String name = marker.getName();
            if (name != null && name.contains("束缚")) {
                toDelete.add(marker);
            }
        }
        if (!toDelete.isEmpty()) {
            playerMarkerRepository.deleteAll(toDelete);
        }
    }

    private void updateCredentials(Integer playerId, Map<String, Object> body, Map<String, Object> result) {
        User user = userRepository.findByPlayerId(playerId).orElse(null);
        if (user == null) {
            user = new User();
            user.setRole(User.Role.PLAYER);
            user.setPlayerId(playerId);
            user.setPassword(DEFAULT_PASSWORD);
            user.setUsername("player" + playerId);
        }

        if (body.containsKey("loginUsername")) {
            String username = stringVal(body.get("loginUsername"));
            if (username != null && !username.trim().isEmpty()) {
                username = username.trim();
                if (!username.equals(user.getUsername()) && userRepository.existsByUsername(username)) {
                    result.put("success", false);
                    result.put("message", "登录账号已存在");
                    return;
                }
                user.setUsername(username);
            }
        }
        if (body.containsKey("loginPassword")) {
            String password = stringVal(body.get("loginPassword"));
            if (password != null && !password.trim().isEmpty()) {
                user.setPassword(password);
            }
        }
        userRepository.save(user);
    }

    private Map<String, Object> toDmPlayerRow(Player player, Map<Integer, String> jobNames, Map<Integer, String> skillNames, Map<Integer, Boolean> consumptionStatus) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("id", player.getId());
        row.put("name", player.getName());
        row.put("faction", player.getFaction() != null ? player.getFaction().name() : null);
        row.put("jobId", player.getJobId());
        row.put("jobName", player.getJobId() != null ? jobNames.getOrDefault(player.getJobId(), "—") : "—");
        row.put("skillId", player.getSkillId());
        row.put("skillName", player.getSkillId() != null ? skillNames.getOrDefault(player.getSkillId(), "—") : "—");
        row.put("isWeak", Boolean.TRUE.equals(player.getIsWeak()));
        row.put("isOverworked", Boolean.TRUE.equals(player.getIsOverworked()));
        row.put("isInjured", player.getIsInjured() != null ? player.getIsInjured() : 0);
        row.put("isSeverelyInjured", Boolean.TRUE.equals(player.getIsSeverelyInjured()));
        row.put("isDead", Boolean.TRUE.equals(player.getIsDead()));
        row.put("dmNotes", player.getDmNotes());
        row.put("hiddenJobId", player.getHiddenJobId());
        row.put("hiddenJobName", player.getHiddenJobId() != null ? jobNames.getOrDefault(player.getHiddenJobId(), "—") : null);
        row.put("tradeBanned", Boolean.TRUE.equals(player.getTradeBanned()));
        row.put("tradeBanExempt", Boolean.TRUE.equals(player.getTradeBanExempt()));
        row.put("isBound", Boolean.TRUE.equals(player.getIsBound()));
        List<String> tradeBanReasons = tradeRestrictionService.reasonsFor(player);
        row.put("tradeBanReasons", tradeBanReasons);
        row.put("tradeBanActive", !tradeBanReasons.isEmpty());
        boolean boundActive = tradeRestrictionService.isBoundActive(player);
        row.put("statuses", com.example.snowisland.util.PlayerStatusCatalog.buildStatusList(player, boundActive));
        row.put("dailyConsumptionMet", consumptionStatus.getOrDefault(player.getId(), false));

        userRepository.findByPlayerId(player.getId()).ifPresent(user -> {
            row.put("loginUsername", user.getUsername());
            row.put("loginPassword", user.getPassword());
        });
        return row;
    }

    private static void validatePlayerName(String name) {
        if (name.length() > PLAYER_NAME_MAX_LENGTH) {
            throw new IllegalArgumentException("玩家姓名不能超过 " + PLAYER_NAME_MAX_LENGTH + " 个字符");
        }
        if (name.contains("\n") || name.contains("\r") || name.contains("\t")) {
            throw new IllegalArgumentException("玩家姓名不能包含换行或制表符");
        }
    }

    private static void validateLoginUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            throw new IllegalArgumentException("请填写登录账号");
        }
        String trimmed = username.trim();
        if (trimmed.length() > USERNAME_MAX_LENGTH) {
            throw new IllegalArgumentException("登录账号不能超过 " + USERNAME_MAX_LENGTH + " 个字符");
        }
        if (!trimmed.equals(username) || trimmed.contains(" ") || trimmed.contains("\n")
                || trimmed.contains("\r") || trimmed.contains("\t")) {
            throw new IllegalArgumentException("登录账号不能包含首尾或中间空白");
        }
    }

    private static void validateLoginPassword(String password) {
        if (password == null || password.trim().isEmpty()) {
            throw new IllegalArgumentException("请填写登录密码");
        }
        if (password.length() > PASSWORD_MAX_LENGTH) {
            throw new IllegalArgumentException("登录密码不能超过 " + PASSWORD_MAX_LENGTH + " 个字符");
        }
    }

    private static Map<String, Object> deny(Map<String, Object> result, String message) {
        result.put("success", false);
        result.put("message", message);
        return result;
    }

    private static boolean isDm(String userRole) {
        return userRole != null && "dm".equalsIgnoreCase(userRole.trim());
    }

    private static String stringVal(Object o) {
        return o == null ? null : String.valueOf(o);
    }

    private static Integer intOrNull(Object o) {
        if (o == null || "".equals(o)) {
            return null;
        }
        if (o instanceof Number) {
            return ((Number) o).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(o));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static boolean boolVal(Object o) {
        if (o instanceof Boolean) {
            return (Boolean) o;
        }
        return Boolean.parseBoolean(String.valueOf(o));
    }

    private static final class NormalizedItem {
        final String type;
        final int itemId;

        NormalizedItem(String type, int itemId) {
            this.type = type;
            this.itemId = itemId;
        }
    }
}
