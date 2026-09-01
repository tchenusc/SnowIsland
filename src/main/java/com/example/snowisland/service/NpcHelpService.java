package com.example.snowisland.service;

import com.example.snowisland.entity.*;
import com.example.snowisland.repository.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class NpcHelpService {

    private static final Logger logger = LoggerFactory.getLogger(NpcHelpService.class);

    @Autowired
    private NpcHelpConfigRepository helpConfigRepository;

    @Autowired
    private NpcHelpRecordRepository helpRecordRepository;

    @Autowired
    private PlayerItemRepository playerItemRepository;

    @Autowired
    private LocationNpcRepository npcRepository;

    @Autowired
    private NpcFavorRepository npcFavorRepository;

    @Autowired
    private GameStateService gameStateService;

    /** 好感度等级与字符串映射 */
    private static final Map<String, Integer> FAVOR_LEVEL_MAP = new HashMap<>();
    static {
        FAVOR_LEVEL_MAP.put("hostile", -100);
        FAVOR_LEVEL_MAP.put("unfriendly", -60);
        FAVOR_LEVEL_MAP.put("neutral", -20);
        FAVOR_LEVEL_MAP.put("friendly", 20);
        FAVOR_LEVEL_MAP.put("close", 60);
    }

    /**
     * 获取NPC的可求助配置列表（根据玩家好感度过滤）
     */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAvailableHelpOptions(Integer npcId, Integer playerId) {
        List<Map<String, Object>> result = new ArrayList<>();

        try {
            Optional<LocationNpc> npcOpt = npcRepository.findById(npcId);
            if (npcOpt.isPresent()) {
                String status = npcOpt.get().getStatus() != null ? npcOpt.get().getStatus() : "正常";
                if ("死亡".equals(status) || "失踪".equals(status) || "被捕".equals(status)) {
                    return result;
                }
            }
            List<NpcHelpConfig> configs = helpConfigRepository.findByNpcId(npcId);
            int playerFavor = getPlayerFavor(npcId, playerId);

            for (NpcHelpConfig config : configs) {
                Map<String, Object> option = configToMap(config);

                boolean canRequest = checkFavorRequirement(playerFavor, config.getMinFavorLevel());
                option.put("canRequest", canRequest);
                option.put("playerFavor", playerFavor);

                int actualCost = calculateActualCost(config);
                option.put("actualCost", actualCost);

                int playerHas = getPlayerStock(playerId, config.getBaseCostType(), config.getBaseCostItemId());
                option.put("playerHas", playerHas);
                option.put("canAfford", playerHas >= actualCost);

                if (!canRequest) {
                    option.put("reason", "好感度不足，需要" + getFavorLevelDisplayName(config.getMinFavorLevel()) + "及以上");
                } else if (playerHas < actualCost) {
                    option.put("reason", "报酬不足，需要" + actualCost + "个" + getItemName(config.getBaseCostType(), config.getBaseCostItemId()));
                }

                result.add(option);
            }
        } catch (Exception e) {
            logger.error("获取求助选项失败: {}", e.getMessage());
        }

        return result;
    }

    /**
     * 请求NPC帮助
     */
    @Transactional
    public Map<String, Object> requestHelp(Integer playerId, Integer npcId, String helpType) {
        Map<String, Object> result = new LinkedHashMap<>();

        try {
            Optional<LocationNpc> npcOpt = npcRepository.findById(npcId);
            if (!npcOpt.isPresent()) {
                result.put("success", false);
                result.put("message", "NPC不存在");
                return result;
            }

            LocationNpc npc = npcOpt.get();
            String status = npc.getStatus() != null ? npc.getStatus() : "正常";
            if ("死亡".equals(status) || "失踪".equals(status) || "被捕".equals(status)) {
                result.put("success", false);
                result.put("message", "死亡".equals(status) ? "对方已经死去，无法求助"
                        : "失踪".equals(status) ? "找不到此人，无法求助" : "对方已被捕，无法求助");
                return result;
            }
            List<NpcHelpConfig> configs = helpConfigRepository.findByNpcIdAndHelpType(npcId, helpType);
            if (configs.isEmpty()) {
                result.put("success", false);
                result.put("message", "该NPC不提供此类型的帮助");
                return result;
            }

            NpcHelpConfig config = configs.get(0);
            int playerFavor = getPlayerFavor(npcId, playerId);

            // 检查好感度要求（必须中立及以上）
            if (!checkFavorRequirement(playerFavor, config.getMinFavorLevel())) {
                result.put("success", false);
                result.put("message", "当前好感度无法请求此帮助（需要" + getFavorLevelDisplayName(config.getMinFavorLevel()) + "及以上）");
                result.put("currentFavor", playerFavor);
                result.put("requiredFavor", FAVOR_LEVEL_MAP.get(config.getMinFavorLevel()));
                return result;
            }

            // 检查是否中立及以上（需求要求）
            if (!isAtLeastNeutral(playerFavor)) {
                result.put("success", false);
                result.put("message", "NPC态度为" + getFavorLevelDisplayName(playerFavor) + "，只有态度为中立及以上的NPC才会响应求助");
                return result;
            }

            // 计算实际报酬
            int actualCost = calculateActualCost(config);

            // 检查玩家是否有足够物资
            int playerHas = getPlayerStock(playerId, config.getBaseCostType(), config.getBaseCostItemId());
            if (playerHas < actualCost) {
                result.put("success", false);
                result.put("message", "报酬不足：需要" + actualCost + "个" + getItemName(config.getBaseCostType(), config.getBaseCostItemId()) + "，当前有" + playerHas + "个");
                return result;
            }

            // 扣减报酬
            if (!reducePlayerItem(playerId, config.getBaseCostType(), config.getBaseCostItemId(), actualCost)) {
                result.put("success", false);
                result.put("message", "扣除报酬失败");
                return result;
            }

            // 创建求助记录
            NpcHelpRecord record = new NpcHelpRecord();
            record.setNpcId(npcId);
            record.setPlayerId(playerId);
            record.setHelpType(helpType);
            record.setHelpName(config.getHelpName());
            record.setCostType(config.getBaseCostType());
            record.setCostItemId(config.getBaseCostItemId());
            record.setCostQuantity(actualCost);
            record.setStatus("pending");
            record.setStartTime(LocalDateTime.now());
            record.setGameDay(gameStateService.getCurrentDay());
            helpRecordRepository.save(record);

            // 增加少量好感度
            int favorChange = 2;
            updateFavor(npcId, playerId, playerFavor + favorChange);

            result.put("success", true);
            result.put("message", "求助请求已提交！" + npc.getName() + "正在处理中...");
            result.put("helpName", config.getHelpName());
            result.put("helpDescription", config.getHelpDescription());
            result.put("costQuantity", actualCost);
            result.put("costItemName", getItemName(config.getBaseCostType(), config.getBaseCostItemId()));
            result.put("durationMinutes", config.getDurationMinutes());
            result.put("successRate", config.getSuccessRate());
            result.put("recordId", record.getId());
            result.put("favorChange", favorChange);

            logger.info("玩家{}向NPC{}请求帮助: type={}, cost={}", playerId, npcId, helpType, actualCost);

        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            logger.error("请求帮助失败: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("message", "请求帮助失败: " + e.getMessage());
        }

        return result;
    }

    /**
     * 获取玩家求助历史记录
     */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getHelpHistory(Integer playerId, Integer npcId) {
        List<NpcHelpRecord> records;
        if (npcId != null) {
            records = helpRecordRepository.findByPlayerIdAndNpcIdOrderByCreatedAtDesc(playerId, npcId);
        } else {
            records = helpRecordRepository.findByPlayerIdOrderByCreatedAtDesc(playerId);
        }

        return records.stream().map(this::recordToMap).collect(java.util.stream.Collectors.toList());
    }

    /**
     * 获取玩家进行中的求助
     */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getPendingHelps(Integer playerId) {
        List<NpcHelpRecord> records = helpRecordRepository.findByPlayerIdAndStatusOrderByCreatedAtDesc(playerId, "pending");
        return records.stream().map(this::recordToMap).collect(java.util.stream.Collectors.toList());
    }

    /**
     * 完成求助（DM操作或自动完成）
     */
    @Transactional
    public Map<String, Object> completeHelp(Integer recordId, boolean success, String resultDescription) {
        Map<String, Object> result = new LinkedHashMap<>();

        try {
            Optional<NpcHelpRecord> recordOpt = helpRecordRepository.findById(recordId);
            if (!recordOpt.isPresent()) {
                result.put("success", false);
                result.put("message", "求助记录不存在");
                return result;
            }

            NpcHelpRecord record = recordOpt.get();
            if (!"pending".equals(record.getStatus())) {
                result.put("success", false);
                result.put("message", "该求助已处理");
                return result;
            }

            record.setStatus(success ? "completed" : "failed");
            record.setEndTime(LocalDateTime.now());
            record.setResultDescription(resultDescription);

            if (success) {
                record.setFavorChange(3);
                updateFavor(record.getNpcId(), record.getPlayerId(),
                        getPlayerFavor(record.getNpcId(), record.getPlayerId()) + 3);
            } else {
                record.setFavorChange(-2);
                updateFavor(record.getNpcId(), record.getPlayerId(),
                        getPlayerFavor(record.getNpcId(), record.getPlayerId()) - 2);
            }

            helpRecordRepository.save(record);

            result.put("success", true);
            result.put("message", success ? "求助成功！" : "求助失败");
            result.put("recordId", recordId);
            result.put("status", record.getStatus());
            result.put("favorChange", record.getFavorChange());

        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            logger.error("完成求助失败: {}", e.getMessage());
            result.put("success", false);
            result.put("message", "完成求助失败: " + e.getMessage());
        }

        return result;
    }

    /**
     * DM保存求助配置
     */
    @Transactional
    public Map<String, Object> saveHelpConfig(Integer npcId, List<Map<String, Object>> helpConfigs) {
        Map<String, Object> result = new LinkedHashMap<>();

        try {
            helpConfigRepository.deleteByNpcId(npcId);

            int savedCount = 0;
            for (Map<String, Object> configMap : helpConfigs) {
                NpcHelpConfig config = new NpcHelpConfig();
                config.setNpcId(npcId);
                config.setHelpType((String) configMap.get("helpType"));
                config.setHelpName((String) configMap.get("helpName"));
                config.setHelpDescription((String) configMap.get("helpDescription"));
                config.setBaseCostType((String) configMap.get("baseCostType"));
                config.setBaseCostItemId(((Number) configMap.get("baseCostItemId")).intValue());
                config.setBaseCostQuantity(((Number) configMap.get("baseCostQuantity")).intValue());
                config.setCostMinModifier(((Number) configMap.get("costMinModifier")).doubleValue());
                config.setCostMaxModifier(((Number) configMap.get("costMaxModifier")).doubleValue());
                config.setMinFavorLevel((String) configMap.get("minFavorLevel"));
                config.setDurationMinutes(((Number) configMap.get("durationMinutes")).intValue());
                config.setSuccessRate(((Number) configMap.get("successRate")).doubleValue());

                helpConfigRepository.save(config);
                savedCount++;
            }

            result.put("success", true);
            result.put("message", "保存成功，共" + savedCount + "条配置");
            result.put("savedCount", savedCount);

        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            logger.error("保存求助配置失败: {}", e.getMessage());
            result.put("success", false);
            result.put("message", "保存失败: " + e.getMessage());
        }

        return result;
    }

    /**
     * 获取所有求助配置（DM管理用）
     */
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllHelpConfigs() {
        return helpConfigRepository.findAll().stream().map(config -> {
            Map<String, Object> map = configToMap(config);
            npcRepository.findById(config.getNpcId()).ifPresent(npc -> {
                map.put("npcName", npc.getName());
            });
            return map;
        }).collect(java.util.stream.Collectors.toList());
    }

    /**
     * 删除求助配置
     */
    @Transactional
    public Map<String, Object> deleteHelpConfig(Integer configId) {
        Map<String, Object> result = new LinkedHashMap<>();
        try {
            helpConfigRepository.deleteById(configId);
            result.put("success", true);
            result.put("message", "删除成功");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "删除失败: " + e.getMessage());
        }
        return result;
    }

    /**
     * 检查好感度是否满足要求
     */
    private boolean checkFavorRequirement(int playerFavor, String minFavorLevel) {
        Integer requiredMin = FAVOR_LEVEL_MAP.get(minFavorLevel);
        if (requiredMin == null) return true;
        return playerFavor >= requiredMin;
    }

    /**
     * 检查是否中立及以上
     */
    private boolean isAtLeastNeutral(int playerFavor) {
        return playerFavor >= FAVOR_LEVEL_MAP.get("neutral");
    }

    /**
     * 计算实际报酬（带浮动）
     */
    private int calculateActualCost(NpcHelpConfig config) {
        double modifier = config.getCostMinModifier() + 
            Math.random() * (config.getCostMaxModifier() - config.getCostMinModifier());
        int actualCost = (int) Math.round(config.getBaseCostQuantity() * modifier);
        return Math.max(1, actualCost);
    }

    /**
     * 获取玩家物资数量
     */
    private int getPlayerStock(Integer playerId, String itemType, Integer itemId) {
        try {
            TradeItem.ItemType typeEnum = TradeItem.ItemType.valueOf(itemType.toLowerCase());
            return playerItemRepository.findByPlayerIdAndItemTypeAndItemId(playerId, typeEnum, itemId)
                    .map(PlayerItem::getQuantity)
                    .orElse(0);
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * 减少玩家物资
     */
    private boolean reducePlayerItem(Integer playerId, String itemType, Integer itemId, Integer quantity) {
        try {
            TradeItem.ItemType typeEnum = TradeItem.ItemType.valueOf(itemType.toLowerCase());
            Optional<PlayerItem> existing = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(playerId, typeEnum, itemId);
            if (!existing.isPresent()) return false;

            PlayerItem item = existing.get();
            if (item.getQuantity() < quantity) return false;

            item.setQuantity(item.getQuantity() - quantity);
            playerItemRepository.save(item);
            return true;
        } catch (Exception e) {
            logger.error("减少玩家物资失败: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 获取玩家好感度
     */
    private int getPlayerFavor(Integer npcId, Integer playerId) {
        return npcFavorRepository.findByNpcIdAndPlayerId(npcId, playerId)
                .map(NpcFavor::getFavorValue)
                .orElse(0);
    }

    /**
     * 更新好感度
     */
    private void updateFavor(Integer npcId, Integer playerId, Integer favorValue) {
        favorValue = Math.max(-100, Math.min(100, favorValue));
        Optional<NpcFavor> existing = npcFavorRepository.findByNpcIdAndPlayerId(npcId, playerId);
        if (existing.isPresent()) {
            existing.get().setFavorValue(favorValue);
            npcFavorRepository.save(existing.get());
        } else {
            NpcFavor favor = new NpcFavor();
            favor.setNpcId(npcId);
            favor.setPlayerId(playerId);
            favor.setFavorValue(favorValue);
            npcFavorRepository.save(favor);
        }
    }

    /**
     * 获取物品名称
     */
    private String getItemName(String itemType, Integer itemId) {
        Map<Integer, String> itemNames = new HashMap<>();
        itemNames.put(1, "医疗资源");
        itemNames.put(2, "手电筒");
        itemNames.put(3, "绳索");
        itemNames.put(4, "哨子");
        itemNames.put(5, "食物");
        itemNames.put(8, "燃料");
        itemNames.put(10, "发动机");
        return itemNames.getOrDefault(itemId, "物资");
    }

    /**
     * 获取好感度等级显示名称
     */
    private String getFavorLevelDisplayName(String level) {
        Map<String, String> displayNames = new HashMap<>();
        displayNames.put("hostile", "敌视");
        displayNames.put("unfriendly", "冷漠");
        displayNames.put("neutral", "中立");
        displayNames.put("friendly", "友善");
        displayNames.put("close", "亲近");
        return displayNames.getOrDefault(level, level);
    }

    /**
     * 根据好感度值获取等级名称
     */
    private String getFavorLevelDisplayName(int favorValue) {
        if (favorValue <= -60) return "敌视";
        if (favorValue <= -20) return "冷漠";
        if (favorValue <= 20) return "中立";
        if (favorValue <= 60) return "友善";
        return "亲近";
    }

    /**
     * 配置转Map
     */
    private Map<String, Object> configToMap(NpcHelpConfig config) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", config.getId());
        map.put("npcId", config.getNpcId());
        map.put("helpType", config.getHelpType());
        map.put("helpName", config.getHelpName());
        map.put("helpDescription", config.getHelpDescription());
        map.put("baseCostType", config.getBaseCostType());
        map.put("baseCostItemId", config.getBaseCostItemId());
        map.put("baseCostQuantity", config.getBaseCostQuantity());
        map.put("costMinModifier", config.getCostMinModifier());
        map.put("costMaxModifier", config.getCostMaxModifier());
        map.put("minFavorLevel", config.getMinFavorLevel());
        map.put("durationMinutes", config.getDurationMinutes());
        map.put("successRate", config.getSuccessRate());
        map.put("costItemName", getItemName(config.getBaseCostType(), config.getBaseCostItemId()));
        map.put("minFavorDisplayName", getFavorLevelDisplayName(config.getMinFavorLevel()));
        return map;
    }

    /**
     * 记录转Map
     */
    private Map<String, Object> recordToMap(NpcHelpRecord record) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", record.getId());
        map.put("npcId", record.getNpcId());
        map.put("playerId", record.getPlayerId());
        map.put("helpType", record.getHelpType());
        map.put("helpName", record.getHelpName());
        map.put("costType", record.getCostType());
        map.put("costItemId", record.getCostItemId());
        map.put("costQuantity", record.getCostQuantity());
        map.put("status", record.getStatus());
        map.put("startTime", record.getStartTime());
        map.put("endTime", record.getEndTime());
        map.put("resultDescription", record.getResultDescription());
        map.put("favorChange", record.getFavorChange());
        map.put("gameDay", record.getGameDay());
        map.put("costItemName", getItemName(record.getCostType(), record.getCostItemId()));
        npcRepository.findById(record.getNpcId()).ifPresent(npc -> {
            map.put("npcName", npc.getName());
        });
        return map;
    }
}