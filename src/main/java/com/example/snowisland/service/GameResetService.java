package com.example.snowisland.service;

import com.example.snowisland.entity.EventPack;
import com.example.snowisland.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class GameResetService {

    private static final Logger logger = LoggerFactory.getLogger(GameResetService.class);

    @Autowired
    private PlayerRepository playerRepository;

    @Autowired
    private PlayerActionRepository playerActionRepository;

    @Autowired
    private PlayerDailyConsumptionRepository playerDailyConsumptionRepository;

    @Autowired
    private PlayerExplorationRepository playerExplorationRepository;

    @Autowired
    private PlayerItemRepository playerItemRepository;

    @Autowired
    private PlayerNpcRecognitionRepository playerNpcRecognitionRepository;

    @Autowired
    private PlayerStealthRepository playerStealthRepository;

    @Autowired
    private GameStateRepository gameStateRepository;

    @Autowired
    private GameDaySettingsRepository gameDaySettingsRepository;

    @Autowired
    private GameActivityLogRepository gameActivityLogRepository;

    @Autowired
    private ArkConstructionRepository arkConstructionRepository;

    @Autowired
    private ArkConstructionLogRepository arkConstructionLogRepository;

    @Autowired
    private ArkSailRepository arkSailRepository;

    @Autowired
    private ArkVoyageRepository arkVoyageRepository;

    @Autowired
    private CatastropheProgressRepository catastropheProgressRepository;

    @Autowired
    private CatastropheDeckRepository catastropheDeckRepository;

    @Autowired
    private DrawnCardsRepository drawnCardsRepository;

    @Autowired
    private SelectedCatastropheRepository selectedCatastropheRepository;

    @Autowired
    private ShelterDailyLaborRepository shelterDailyLaborRepository;

    @Autowired
    private ShelterLaborDayRepository shelterLaborDayRepository;

    @Autowired
    private ShelterStockRepository shelterStockRepository;

    @Autowired
    private TradeRepository tradeRepository;

    @Autowired
    private TradeItemRepository tradeItemRepository;

    @Autowired
    private FactionActionRepository factionActionRepository;

    @Autowired
    private NightActionRepository nightActionRepository;

    @Autowired
    private QuickInteractionRepository quickInteractionRepository;

    @Autowired
    private LorePlayerGrantRepository lorePlayerGrantRepository;

    @Autowired
    private ClueTriggerLogRepository clueTriggerLogRepository;

    @Autowired
    private MilestoneRepository milestoneRepository;

    @Autowired
    private LocationGovernanceRepository locationGovernanceRepository;

    @Autowired
    private NpcDailyDialogueCountRepository npcDailyDialogueCountRepository;

    @Autowired
    private NpcDailyTradeCountRepository npcDailyTradeCountRepository;

    @Autowired
    private NpcFavorRepository npcFavorRepository;

    @Autowired
    private NpcHelpRecordRepository npcHelpRecordRepository;

    @Autowired
    private NpcTradeRecordRepository npcTradeRecordRepository;

    @Autowired
    private NpcTradeProposalRepository npcTradeProposalRepository;

    @Autowired
    private NpcItemRepository npcItemRepository;

    @Autowired
    private NpcDailyConsumptionRepository npcDailyConsumptionRepository;

    @Autowired
    private PlayerNotebookRepository playerNotebookRepository;

    @Autowired
    private NpcDialogueRepository npcDialogueRepository;

    @Autowired
    private NpcFavorAdjustmentRepository npcFavorAdjustmentRepository;

    @Autowired
    private PlayerMarkerRepository playerMarkerRepository;

    @Autowired
    private IslandEventRepository islandEventRepository;

    @Autowired
    private EventPackRepository eventPackRepository;

    @Autowired
    private NpcInventoryService npcInventoryService;

    @Autowired
    private NpcRosterService npcRosterService;

    @Autowired
    private ArkRequiredSkillRepository arkRequiredSkillRepository;

    @Autowired
    private ArkService arkService;

    @Autowired
    private CatastropheService catastropheService;

    @Autowired
    private WarehouseService warehouseService;

    @PersistenceContext
    private EntityManager entityManager;

    @Transactional
    public Map<String, Object> resetToInitialState(String userRole) {
        Map<String, Object> result = new LinkedHashMap<>();

        if (!"dm".equalsIgnoreCase(userRole)) {
            result.put("success", false);
            result.put("message", "只有DM可以执行此操作");
            return result;
        }

        logger.info("=== 开始执行游戏数据重置 ===");
        LocalDateTime startTime = LocalDateTime.now();

        Map<String, Object> deletedCounts = new LinkedHashMap<>();

        setForeignKeyChecks(false);
        try {
            unlinkUsersFromPlayers();
            deleteFirstLevel(deletedCounts);
            deleteSecondLevel(deletedCounts);
            deleteThirdLevel(deletedCounts);
            deleteFourthLevel(deletedCounts);
            deleteFifthLevel(deletedCounts);
            entityManager.flush();
            entityManager.clear();
        } finally {
            setForeignKeyChecks(true);
        }

        initializeInitialData(deletedCounts);

        LocalDateTime endTime = LocalDateTime.now();

        result.put("success", true);
        result.put("message", "游戏数据已成功恢复至初始状态");
        result.put("deletedCounts", deletedCounts);
        result.put("startTime", startTime.toString());
        result.put("endTime", endTime.toString());
        result.put("durationMs", java.time.Duration.between(startTime, endTime).toMillis());

        logger.info("=== 游戏数据重置完成 ===");
        return result;
    }

    private void unlinkUsersFromPlayers() {
        int updated = entityManager.createNativeQuery(
                "UPDATE user SET player_id = NULL WHERE player_id IS NOT NULL"
        ).executeUpdate();
        logger.info("已解除 user.player_id 关联: {} 行", updated);
    }

    private void setForeignKeyChecks(boolean enabled) {
        entityManager.createNativeQuery("SET FOREIGN_KEY_CHECKS = " + (enabled ? "1" : "0"))
                .executeUpdate();
    }

    private void deleteFirstLevel(Map<String, Object> deletedCounts) {
        deleteTable("player_action", playerActionRepository);
        deleteTable("player_exploration", playerExplorationRepository);
        deleteTable("player_stealth", playerStealthRepository);
        deleteTable("player_npc_recognition", playerNpcRecognitionRepository);

        deleteTable("game_activity_log", gameActivityLogRepository);
        deleteTable("clue_trigger_log", clueTriggerLogRepository);

        deleteTable("faction_action", factionActionRepository);
        deleteTable("night_action", nightActionRepository);
        deleteTable("quick_interaction", quickInteractionRepository);
        deleteTable("player_notebook", playerNotebookRepository);
        deleteTable("npc_dialogue", npcDialogueRepository);
        deleteTable("npc_favor_adjustment", npcFavorAdjustmentRepository);
        deleteTable("player_marker", playerMarkerRepository);

        deleteTable("trade_items", tradeItemRepository);
        deleteTable("trade", tradeRepository);

        deleteTable("npc_help_record", npcHelpRecordRepository);
        deleteTable("npc_trade_proposal", npcTradeProposalRepository);
        deleteTable("npc_trade_record", npcTradeRecordRepository);

        deleteTable("lore_player_grant", lorePlayerGrantRepository);

        deleteTable("ark_required_skill", arkRequiredSkillRepository);

        deletedCounts.put("第一级（无外键依赖表）", "已清除");
    }

    private void deleteSecondLevel(Map<String, Object> deletedCounts) {
        deleteTable("player_daily_consumption", playerDailyConsumptionRepository);
        deleteTable("player_items", playerItemRepository);

        deleteTable("drawn_cards", drawnCardsRepository);
        deleteTable("selected_catastrophe", selectedCatastropheRepository);

        deleteTable("shelter_daily_labor", shelterDailyLaborRepository);
        deleteTable("shelter_labor_day", shelterLaborDayRepository);

        deleteTable("location_governance", locationGovernanceRepository);

        deleteTable("npc_daily_dialogue_count", npcDailyDialogueCountRepository);
        deleteTable("npc_daily_trade_count", npcDailyTradeCountRepository);
        deleteTable("npc_favor", npcFavorRepository);
        deleteTable("npc_items", npcItemRepository);
        deleteTable("npc_daily_consumption", npcDailyConsumptionRepository);

        deletedCounts.put("第二级（依赖player或无关键依赖）", "已清除");
    }

    private void deleteThirdLevel(Map<String, Object> deletedCounts) {
        deleteTable("player", playerRepository);
        deletedCounts.put("第三级（player表）", "已清除");
    }

    private void deleteFourthLevel(Map<String, Object> deletedCounts) {
        deleteTable("catastrophe_deck", catastropheDeckRepository);
        deleteTable("shelter_stock", shelterStockRepository);

        deleteTable("ark_construction", arkConstructionRepository);
        deleteTable("ark_construction_log", arkConstructionLogRepository);
        deleteTable("ark_sail", arkSailRepository);
        deleteTable("ark_voyage", arkVoyageRepository);

        executeNativeDelete("warehouse_ark");
        executeNativeDelete("warehouse_armory");
        executeNativeDelete("warehouse_dock");
        executeNativeDelete("warehouse_fuel");
        executeNativeDelete("warehouse_general");
        executeNativeDelete("warehouse_rebel");
        executeNativeDelete("shelter_progress");
        executeNativeDelete("milestone_player_status");

        deletedCounts.put("第四级（其他可清除表）", "已清除");
    }

    private void deleteFifthLevel(Map<String, Object> deletedCounts) {
        deleteTable("game_state", gameStateRepository);
        deleteTable("game_day_settings", gameDaySettingsRepository);
        deleteTable("catastrophe_progress", catastropheProgressRepository);

        deletedCounts.put("第五级（游戏状态表）", "已清除");
    }

    private <T> void deleteTable(String tableName, org.springframework.data.jpa.repository.JpaRepository<T, ?> repository) {
        try {
            repository.deleteAllInBatch();
            logger.info("已清除表: {}", tableName);
        } catch (Exception e) {
            logger.warn("清除表 {} 时发生异常: {}", tableName, e.getMessage());
            executeNativeDelete(tableName);
        }
    }

    private void executeNativeDelete(String tableName) {
        try {
            entityManager.createNativeQuery("DELETE FROM " + tableName).executeUpdate();
            logger.info("已通过原生SQL清除表: {}", tableName);
        } catch (Exception e) {
            logger.error("通过原生SQL清除表 {} 失败: {}", tableName, e.getMessage());
        }
    }

    private void initializeInitialData(Map<String, Object> deletedCounts) {
        logger.info("开始初始化初始数据...");

        try {
            int milestones = milestoneRepository.resetAllCompletion();
            deletedCounts.put("重置里程碑完成状态", "完成（" + milestones + "）");
        } catch (Exception e) {
            logger.warn("重置里程碑完成状态失败: {}", e.getMessage());
        }

        try {
            int events = islandEventRepository.resetAllTriggered();
            deletedCounts.put("重置探索事件触发标记", "完成（" + events + "）");
        } catch (Exception e) {
            logger.warn("重置探索事件触发标记失败: {}", e.getMessage());
        }

        try {
            resetEventPackEnabledDefaults();
            deletedCounts.put("重置事件包启用状态", "完成（仅基础包开启）");
        } catch (Exception e) {
            logger.warn("重置事件包启用状态失败: {}", e.getMessage());
        }

        try {
            arkService.initializeProgress();
            deletedCounts.put("初始化方舟建造进度", "完成");
        } catch (Exception e) {
            logger.warn("初始化方舟建造进度失败: {}", e.getMessage());
        }

        try {
            executeNativeDelete("shelter_stock");
            entityManager.createNativeQuery("INSERT INTO shelter_stock (item_type, item_id, quantity) VALUES ('material', 1, 500), ('material', 2, 200), ('material', 3, 100), ('material', 4, 50), ('item', 1, 50), ('item', 2, 10), ('material', 5, 200)").executeUpdate();
            deletedCounts.put("初始化避难所库存", "完成");
        } catch (Exception e) {
            logger.warn("初始化避难所库存失败: {}", e.getMessage());
        }

        try {
            int seeded = warehouseService.seedInitialInventories();
            deletedCounts.put("初始化仓库数据", "完成（" + seeded + " 种物资）");
        } catch (Exception e) {
            logger.warn("初始化仓库数据失败: {}", e.getMessage());
        }

        try {
            catastropheService.clearAndReloadCards("dm");
            deletedCounts.put("初始化天灾牌组", "完成");
        } catch (Exception e) {
            logger.warn("初始化天灾牌组失败: {}", e.getMessage());
        }

        try {
            int synced = npcRosterService.resetToCanonical();
            int seeded = npcInventoryService.seedAllEmptyInventories();
            deletedCounts.put("初始化NPC", "完成（" + synced + " 人，背包 " + seeded + " 种物资）");
        } catch (Exception e) {
            logger.warn("初始化NPC失败: {}", e.getMessage());
        }

        logger.info("初始数据初始化完成");
    }

    private void resetEventPackEnabledDefaults() {
        List<EventPack> packs = eventPackRepository.findAll();
        for (EventPack pack : packs) {
            boolean enable = EventPack.PACK_BASE.equals(pack.getName());
            pack.setEnabled(enable);
            eventPackRepository.save(pack);
        }
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getResetPreview() {
        Map<String, Object> result = new LinkedHashMap<>();

        result.put("clearedTables", getClearedTableList());
        result.put("preservedTables", getPreservedTableList());

        Map<String, Long> tableCounts = new LinkedHashMap<>();
        long totalRecords = 0;

        totalRecords += addTableCount(tableCounts, "player", playerRepository.count());
        totalRecords += addTableCount(tableCounts, "player_action", playerActionRepository.count());
        totalRecords += addTableCount(tableCounts, "player_item", playerItemRepository.count());
        totalRecords += addTableCount(tableCounts, "game_state", gameStateRepository.count());
        totalRecords += addTableCount(tableCounts, "ark_construction", arkConstructionRepository.count());
        totalRecords += addTableCount(tableCounts, "shelter_stock", shelterStockRepository.count());
        totalRecords += addTableCount(tableCounts, "catastrophe_deck", catastropheDeckRepository.count());
        totalRecords += addTableCount(tableCounts, "trade", tradeRepository.count());
        totalRecords += addTableCount(tableCounts, "faction_action", factionActionRepository.count());
        totalRecords += addTableCount(tableCounts, "npc_favor", npcFavorRepository.count());

        result.put("tableCounts", tableCounts);
        result.put("totalRecords", totalRecords);

        return result;
    }

    private long addTableCount(Map<String, Long> counts, String tableName, long count) {
        counts.put(tableName, count);
        return count;
    }

    private String[] getClearedTableList() {
        return new String[]{
                "player", "player_action", "player_daily_consumption", "player_exploration",
                "player_item", "player_npc_recognition", "player_stealth",
                "game_state", "game_day_settings", "game_activity_log",
                "ark_construction", "ark_construction_log", "ark_sail", "ark_voyage",
                "catastrophe_progress", "catastrophe_deck", "drawn_cards", "selected_catastrophe",
                "shelter_daily_labor", "shelter_labor_day", "shelter_progress", "shelter_stock",
                "warehouse_ark", "warehouse_armory", "warehouse_dock", "warehouse_fuel",
                "warehouse_general", "warehouse_rebel",
                "trade", "trade_item", "faction_action", "night_action", "quick_interaction",
                "lore_player_grant", "clue_trigger_log", "milestone_player_status",
                "location_governance", "npc_daily_dialogue_count", "npc_daily_trade_count",
                "npc_favor", "npc_help_record", "npc_trade_proposal", "npc_trade_record", "ark_required_skill",
                "npc_items", "npc_daily_consumption", "player_notebook",
                "npc_dialogue", "npc_favor_adjustment", "player_marker",
                "milestone.is_completed", "island_event.triggered", "event_pack.enabled"
        };
    }

    private String[] getPreservedTableList() {
        return new String[]{
                "user", "item", "weapon", "ammo", "material", "skill", "job", "job_initial_items",
                "rule_book", "island_event", "island_event_reward", "special_clue",
                "location", "location_facility", "location_npc",
                "npc_help_config", "npc_trade_config",
                "warehouse_config", "ark_config", "milestone", "catastrophe_card",
                "event_pack", "endgame_ark_event", "endgame_shelter_event"
        };
    }
}