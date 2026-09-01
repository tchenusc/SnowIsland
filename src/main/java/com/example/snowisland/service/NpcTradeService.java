package com.example.snowisland.service;

import com.example.snowisland.entity.*;
import com.example.snowisland.repository.*;
import com.example.snowisland.util.NpcSurvivalMath;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class NpcTradeService {

    private static final Logger logger = LoggerFactory.getLogger(NpcTradeService.class);

    @Autowired
    private NpcTradeConfigRepository tradeConfigRepository;

    @Autowired
    private NpcTradeRecordRepository tradeRecordRepository;

    @Autowired
    private NpcDailyTradeCountRepository dailyTradeCountRepository;

    @Autowired
    private LocationNpcRepository npcRepository;

    @Autowired
    private PlayerItemRepository playerItemRepository;

    @Autowired
    private PlayerRepository playerRepository;

    @Autowired
    private GameStateService gameStateService;

    @Autowired
    private NpcFavorRepository npcFavorRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private NpcInventoryService npcInventoryService;

    @Autowired
    private PlayerConsumptionService playerConsumptionService;

    @Autowired
    private ActivityLogService activityLogService;

    @Autowired
    @Lazy
    private NpcTradeProposalService npcTradeProposalService;

    private static final String CONFIG_TYPE_DEMAND = "demand";
    private static final String CONFIG_TYPE_SUPPLY = "supply";

    /** 好感度档位定义 */
    public static final String FAVOR_TIER_HOSTILE = "敌视";
    public static final String FAVOR_TIER_UNFRIENDLY = "冷漠";
    public static final String FAVOR_TIER_NEUTRAL = "中立";
    public static final String FAVOR_TIER_FRIENDLY = "友善";
    public static final String FAVOR_TIER_CLOSE = "亲近";
    public static final String FAVOR_TIER_MAX = "挚友";

    /** 每日最大好感度特殊奖励次数 */
    private static final int MAX_FREE_REWARD_PER_DAY = 1;
    /** 赠予换算：2 食物 = 1 好感，25 木材 = 1 好感，25 燃料 = 1 好感 */
    public static final int GIFT_FOOD_PER_FAVOR = 2;
    public static final int GIFT_WOOD_PER_FAVOR = 25;
    public static final int GIFT_FUEL_PER_FAVOR = 25;
    /** 同一 NPC 送礼加好感全程上限 */
    public static final int MAX_GIFT_FAVOR = 15;

    /**
     * 获取好感度档位
     */
    public static String getFavorTier(int favorValue) {
        if (favorValue <= -60) return FAVOR_TIER_HOSTILE;
        if (favorValue < -20) return FAVOR_TIER_UNFRIENDLY;
        if (favorValue < 20) return FAVOR_TIER_NEUTRAL;
        if (favorValue < 60) return FAVOR_TIER_FRIENDLY;
        if (favorValue < 100) return FAVOR_TIER_CLOSE;
        return FAVOR_TIER_MAX;
    }

    /**
     * 根据好感度档位计算需求物资折扣率
     * 折扣率：玩家需要付出的物资 = 原始需求 * (1 - discountRate)
     * 越高的好感度，玩家需要付出的物资越少（供给数量不再随好感加成）
     *
     * 好感度档位与折扣规则：
     * - 敌视（≤-60）：禁止交易
     * - 冷漠 / 中立（-60~20）：0%折扣
     * - 友善（20~60）：10%折扣
     * - 亲近（60~100）：25%折扣
     * - 挚友（=100）：100%折扣，免费（供给仍为图鉴配置的 1× 基础量）
     */
    public static double getDemandDiscountRate(int favorValue) {
        if (favorValue >= 100) return 1.0;   // 挚友：免费
        if (favorValue >= 60) return 0.25;   // 亲近：25% 折扣
        if (favorValue >= 20) return 0.1;    // 友善：10% 折扣
        if (favorValue >= -60) return 0.0;   // 中立/冷漠：无折扣
        return 0.0;                          // 敌视：禁止交易
    }

    /**
     * 供给加成已取消（Phase 1 平衡）：好感只影响需求折扣，不增加 NPC 给出的数量。
     * 保留方法供 UI / 旧调用兼容，始终返回 0。
     */
    public static double getSupplyBonusRate(int favorValue) {
        return 0.0;
    }

    /**
     * 检查好感度是否为敌视状态
     * @param favorValue 好感度数值
     * @return true表示敌视状态，禁止交易
     */
    public static boolean isHostile(int favorValue) {
        return favorValue <= -60;
    }

    /**
     * 检查是否可以进行交易（非敌视状态）
     * @param favorValue 好感度数值
     * @return true表示可以交易
     */
    public static boolean canTrade(int favorValue) {
        return !isHostile(favorValue);
    }

    /**
     * 计算应用折扣后的实际需求数量
     * 使用四舍五入取整
     * @param originalQuantity 原始需求数量
     * @param discountRate 折扣率（0.0-1.0）
     * @return 折扣后的实际需求数量，最小为0
     */
    public static int calculateDiscountedDemand(int originalQuantity, double discountRate) {
        if (originalQuantity <= 0) {
            return 0;
        }
        if (discountRate >= 1.0) {
            return 0;
        }
        double discounted = originalQuantity * (1.0 - discountRate);
        int result = (int) Math.round(discounted);
        return Math.max(0, result);
    }

    /**
     * 计算应用加成后的实际供给数量
     * 使用四舍五入取整
     * @param originalQuantity 原始供给数量
     * @param bonusRate 加成率（0.0-1.0）
     * @return 加成后的实际供给数量，最小为1
     */
    public static int calculateBonusSupply(int originalQuantity, double bonusRate) {
        if (originalQuantity <= 0) {
            return 1;
        }
        double bonus = originalQuantity * (1.0 + bonusRate);
        int result = (int) Math.round(bonus);
        return Math.max(1, result);
    }

    /**
     * 获取好感度档位的详细描述信息
     */
    public static Map<String, Object> getFavorTierInfo(int favorValue) {
        Map<String, Object> info = new LinkedHashMap<>();
        String tier = getFavorTier(favorValue);
        double demandDiscount = getDemandDiscountRate(favorValue);
        double supplyBonus = getSupplyBonusRate(favorValue);

        info.put("tier", tier);
        info.put("favorValue", favorValue);
        info.put("demandDiscount", demandDiscount);
        info.put("supplyBonus", supplyBonus);
        info.put("canFreeReward", favorValue >= 100);
        info.put("color", getFavorColor(favorValue));
        info.put("description", getFavorTierDescription(tier, favorValue));

        return info;
    }

    private static String getFavorColor(int favorValue) {
        if (favorValue <= -60) return "#ef4444";
        if (favorValue <= -20) return "#f59e0b";
        if (favorValue <= 20) return "#6b7280";
        if (favorValue <= 60) return "#3b82f6";
        if (favorValue < 100) return "#22c55e";
        return "#fbbf24"; // 金色 - 最高级
    }

    private static String getFavorTierDescription(String tier, int favorValue) {
        switch (tier) {
            case FAVOR_TIER_HOSTILE: return "敌视状态，禁止交易";
            case FAVOR_TIER_UNFRIENDLY: return "冷漠关系，标准价格，无折扣";
            case FAVOR_TIER_NEUTRAL: return "中立关系，标准价格，无折扣";
            case FAVOR_TIER_FRIENDLY: return "友善关系，需求享10%折扣（供给数量固定）";
            case FAVOR_TIER_CLOSE: return "亲近关系，需求享25%折扣（供给数量固定）";
            case FAVOR_TIER_MAX: return "挚友！免费交易；每日可另领一次基础量免费物资";
            default: return "未知关系";
        }
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getTradeConfig(Integer npcId, Integer playerId) {
        Map<String, Object> result = new LinkedHashMap<>();
        try {
            Optional<LocationNpc> npcOpt = npcRepository.findById(npcId);
            if (!npcOpt.isPresent()) {
                result.put("success", false);
                result.put("message", "NPC不存在");
                return result;
            }

            LocationNpc npc = npcOpt.get();
            String unavailable = unavailableReason(npc);
            if (unavailable != null) {
                result.put("success", false);
                result.put("message", unavailable);
                result.put("npcStatus", npc.getStatus());
                result.put("unavailable", true);
                return result;
            }

            int currentDay = gameStateService.getCurrentDay();
            int favorValue = getFavorValue(npcId, playerId);
            int[] need = currentRequirements();
            int requiredFood = need[0];
            int requiredHeat = need[1];
            
            if (isHostile(favorValue)) {
                result.put("success", false);
                result.put("message", "交易不可用：该NPC对你抱有敌意，拒绝与你交易");
                result.put("hostile", true);
                result.put("favorValue", favorValue);
                result.put("favorTier", getFavorTierInfo(favorValue));
                result.put("proposal", npcTradeProposalService.getOpenProposalMap(npcId, playerId));
                result.put("giftAllowed", false);
                return result;
            }
            
            Map<String, Object> favorTierInfo = getFavorTierInfo(favorValue);
            boolean freeRewardUsed = checkFreeRewardUsed(npcId, playerId, currentDay);
            List<Map<String, Object>> freeReward = npcTradeProposalService.surplusForFreeReward(
                    npcId, requiredFood, requiredHeat);
            Map<String, Object> proposal = npcTradeProposalService.getOpenProposalMap(npcId, playerId);

            result.put("success", true);
            result.put("npcId", npcId);
            result.put("npcName", npc.getName());
            result.put("npcJob", npc.getJob());
            result.put("demandItems", new ArrayList<>());
            result.put("supplyItems", new ArrayList<>());
            result.put("proposal", proposal);
            result.put("favorValue", favorValue);
            result.put("favorTier", favorTierInfo);
            result.put("canTrade", proposal != null && "open".equals(proposal.get("status")));
            result.put("canFreeReward", favorValue >= 100 && !freeRewardUsed && !freeReward.isEmpty());
            result.put("freeReward", freeReward);
            result.put("freeRewardUsed", freeRewardUsed);
            result.put("npcStatus", npc.getStatus());
            result.put("giftAllowed", true);
            result.putAll(npcInventoryService.survivalSnapshot(npcId, requiredFood, requiredHeat));
            result.put("playerFoodKg", getPlayerStock(playerId, TradeItem.ItemType.material,
                    com.example.snowisland.util.ItemCatalog.FOOD_MATERIAL_ID));
            result.put("playerWoodKg", getPlayerStock(playerId, TradeItem.ItemType.material,
                    com.example.snowisland.util.ItemCatalog.WOOD_MATERIAL_ID));
            result.put("playerFuelKg", getPlayerStock(playerId, TradeItem.ItemType.material,
                    com.example.snowisland.util.ItemCatalog.FUEL_MATERIAL_ID));
            putGiftFavorCaps(result, npcId, playerId);

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "获取交易配置失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    @Transactional
    public Map<String, Object> executeTrade(Integer playerId, Integer npcId) {
        Map<String, Object> result = new LinkedHashMap<>();
        logger.info("开始执行交易: playerId={}, npcId={}", playerId, npcId);
        
        try {
            int currentDay = gameStateService.getCurrentDay();
            logger.debug("交易检查: 当前游戏天数={}", currentDay);

            Optional<LocationNpc> npcOpt = npcRepository.findById(npcId);
            if (!npcOpt.isPresent()) {
                logger.warn("交易失败: NPC不存在, npcId={}", npcId);
                result.put("success", false);
                result.put("message", "NPC不存在");
                return result;
            }

            LocationNpc npc = npcOpt.get();
            String unavailable = unavailableReason(npc);
            if (unavailable != null) {
                result.put("success", false);
                result.put("message", unavailable);
                result.put("npcStatus", npc.getStatus());
                return result;
            }

            int dailyLimit = npc.getDailyTradeLimit() != null ? npc.getDailyTradeLimit() : 1;
            
            long todayTrades = tradeRecordRepository.countTodayTrades(npcId, playerId, currentDay);
            logger.debug("交易检查: 今日已交易次数={}, 每日上限={}", todayTrades, dailyLimit);
            
            if (todayTrades >= dailyLimit) {
                logger.warn("交易失败: 今日交易次数已用完, playerId={}, npcId={}, todayTrades={}, dailyLimit={}", 
                        playerId, npcId, todayTrades, dailyLimit);
                result.put("success", false);
                result.put("message", "今日交易次数已用完，明日再来吧");
                result.put("remainingTrades", 0);
                return result;
            }

            int favorValue = getFavorValue(npcId, playerId);
        
            if (isHostile(favorValue)) {
                logger.warn("交易失败: NPC与玩家处于敌视状态, playerId={}, npcId={}, favorValue={}", 
                        playerId, npcId, favorValue);
                result.put("success", false);
                result.put("message", "交易不可用：该NPC对你抱有敌意，拒绝与你交易");
                result.put("hostile", true);
                return result;
            }
            
            double demandDiscount = getDemandDiscountRate(favorValue);
            double supplyBonus = getSupplyBonusRate(favorValue);
            int[] need = currentRequirements();
            int requiredFood = need[0];
            int requiredHeat = need[1];
            logger.debug("交易参数: 好感度={}, 需求折扣率={}, 供给加成率={}", favorValue, demandDiscount, supplyBonus);
            
            List<NpcTradeConfig> demandConfigs = tradeConfigRepository.findByNpcIdAndConfigType(npcId, CONFIG_TYPE_DEMAND);
            List<NpcTradeConfig> supplyConfigs = tradeConfigRepository.findByNpcIdAndConfigType(npcId, CONFIG_TYPE_SUPPLY);
            logger.debug("交易配置: 需求配置数={}, 供给配置数={}", demandConfigs.size(), supplyConfigs.size());

            List<NpcTradeConfig> validDemand = demandConfigs.stream()
                    .filter(c -> isFavorValid(c, favorValue))
                    .collect(Collectors.toList());

            List<NpcTradeConfig> validSupply = supplyConfigs.stream()
                    .filter(c -> isFavorValid(c, favorValue) && rollProbability(c.getProbability()))
                    .collect(Collectors.toList());

            logger.debug("有效配置: 有效需求数={}, 有效供给数={}", validDemand.size(), validSupply.size());

            if (validDemand.isEmpty()) {
                logger.warn("交易失败: 当前好感度无法进行交易, playerId={}, npcId={}, favorValue={}", 
                        playerId, npcId, favorValue);
                result.put("success", false);
                result.put("message", "当前好感度无法进行交易");
                return result;
            }

            List<NpcTradeConfig> stockedSupply = new ArrayList<>();
            List<Integer> stockedQty = new ArrayList<>();
            int[] working = currentSurvivalStock(npcId);
            for (NpcTradeConfig config : validSupply) {
                TradeItem.ItemType supplyType = parseItemType(config.getItemType());
                int stock = npcInventoryService.getQuantity(npcId, supplyType, config.getItemId());
                int sellable = sellableFromWorking(supplyType, config.getItemId(), stock,
                        working[0], working[1], working[2], requiredFood, requiredHeat);
                int actualQuantity = Math.min(calculateBonusSupply(config.getQuantity(), supplyBonus), sellable);
                if (actualQuantity <= 0) {
                    continue;
                }
                deductWorking(working, supplyType, config.getItemId(), actualQuantity);
                stockedSupply.add(config);
                stockedQty.add(actualQuantity);
            }

            if (stockedSupply.isEmpty()) {
                logger.warn("交易失败: NPC存货不足, playerId={}, npcId={}", playerId, npcId);
                result.put("success", false);
                result.put("message", "NPC存货不足，或剩余食物/燃料需留给自己过活");
                return result;
            }

            // 检查玩家资源是否足够（使用折扣后的实际需求）
            List<Map<String, Object>> actualDemandItems = new ArrayList<>();
            for (NpcTradeConfig config : validDemand) {
                int actualQuantity = calculateDiscountedDemand(config.getQuantity(), demandDiscount);
                int playerStock = getPlayerStockSmart(playerId, config.getItemType(), config.getItemId());
                logger.debug("物资校验: itemType={}, itemId={}, 需要={}, 拥有={}",
                        config.getItemType(), config.getItemId(), actualQuantity, playerStock);

                if (playerStock < actualQuantity) {
                    TradeItem.ItemType demandType = parseItemType(config.getItemType());
                    logger.warn("交易失败: 玩家物资不足, playerId={}, itemType={}, itemId={}, 当前={}, 需要={}",
                            playerId, config.getItemType(), config.getItemId(), playerStock, actualQuantity);
                    result.put("success", false);
                    result.put("message", "您的" + getItemName(demandType, config.getItemId()) +
                        "不足，需要" + actualQuantity + "（原价" + config.getQuantity() +
                        "，因好感度" + (int)(demandDiscount * 100) + "%折扣减免）");
                    return result;
                }
                Map<String, Object> item = configToMap(config);
                item.put("originalQuantity", config.getQuantity());
                item.put("actualQuantity", actualQuantity);
                item.put("discountRate", demandDiscount);
                actualDemandItems.add(item);
            }

            logger.info("开始转移玩家物资...");
            for (NpcTradeConfig config : validDemand) {
                int actualQuantity = calculateDiscountedDemand(config.getQuantity(), demandDiscount);
                if (actualQuantity <= 0) {
                    continue;
                }
                TradeItem.ItemType demandType = parseItemType(config.getItemType());
                reducePlayerItem(playerId, demandType, config.getItemId(), actualQuantity);
                npcInventoryService.addItem(npcId, demandType, config.getItemId(), actualQuantity);
            }

            logger.info("开始给予玩家物资...");
            List<Map<String, Object>> actualSupplyItems = new ArrayList<>();
            for (int i = 0; i < stockedSupply.size(); i++) {
                NpcTradeConfig config = stockedSupply.get(i);
                int actualQuantity = stockedQty.get(i);
                TradeItem.ItemType supplyType = parseItemType(config.getItemType());
                npcInventoryService.deductItem(npcId, supplyType, config.getItemId(), actualQuantity);
                addPlayerItem(playerId, supplyType, config.getItemId(), actualQuantity);
                Map<String, Object> item = configToMap(config);
                item.put("originalQuantity", config.getQuantity());
                item.put("actualQuantity", actualQuantity);
                item.put("bonusRate", supplyBonus);
                actualSupplyItems.add(item);
            }

            int favorChange = calculateTradeFavorChange(favorValue);
            int newFavor = Math.max(-100, Math.min(100, favorValue + favorChange));
            updateOrCreateFavor(npcId, playerId, newFavor);
            logger.info("好感度更新: playerId={}, npcId={}, 旧值={}, 变化={}, 新值={}", 
                    playerId, npcId, favorValue, favorChange, newFavor);

            NpcTradeRecord record = new NpcTradeRecord();
            record.setNpcId(npcId);
            record.setPlayerId(playerId);
            record.setGameDay(currentDay);
            record.setDemandItems(toJson(actualDemandItems));
            record.setSupplyItems(toJson(actualSupplyItems));
            record.setFavorChange(favorChange);
            tradeRecordRepository.save(record);
            logger.info("交易记录保存成功: tradeId={}", record.getId());

            incrementDailyTradeCount(npcId, playerId, currentDay);

            result.put("success", true);
            result.put("message", "交易成功！" + (favorValue >= 100 ? "（挚友特权：免成本交易）" : 
                (demandDiscount > 0 ? "（好感度" + (int)(demandDiscount*100) + "%折扣）" : "")));
            result.put("demandItems", actualDemandItems);
            result.put("supplyItems", actualSupplyItems);
            result.put("favorChange", favorChange);
            result.put("newFavor", newFavor);
            result.put("favorTier", getFavorTierInfo(newFavor));
            result.put("tradeId", record.getId());
            result.put("remainingTrades", Math.max(0, dailyLimit - (int) (todayTrades + 1)));
            logger.info("交易完成: playerId={}, npcId={}, tradeId={}", playerId, npcId, record.getId());

        } catch (RuntimeException e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            logger.error("交易运行时异常: playerId={}, npcId={}, 错误: {}", playerId, npcId, e.getMessage(), e);
            result.put("success", false);
            result.put("message", e.getMessage());
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            logger.error("交易失败: playerId={}, npcId={}, 错误: {}", playerId, npcId, e.getMessage(), e);
            result.put("success", false);
            result.put("message", "交易失败: " + e.getMessage());
        }
        return result;
    }

    /**
     * 最大好感度特殊奖励：免费领取物资
     */
    @Transactional
    public Map<String, Object> claimFreeReward(Integer playerId, Integer npcId) {
        Map<String, Object> result = new LinkedHashMap<>();
        try {
            int currentDay = gameStateService.getCurrentDay();

            Optional<LocationNpc> npcOpt = npcRepository.findById(npcId);
            if (!npcOpt.isPresent()) {
                result.put("success", false);
                result.put("message", "NPC不存在");
                return result;
            }

            LocationNpc npc = npcOpt.get();
            String unavailable = unavailableReason(npc);
            if (unavailable != null) {
                result.put("success", false);
                result.put("message", unavailable);
                return result;
            }

            int favorValue = getFavorValue(npcId, playerId);

            // 验证好感度达到最大
            if (favorValue < 100) {
                result.put("success", false);
                result.put("message", "好感度未达最大值，无法领取免费奖励（当前：" + favorValue + "/100）");
                return result;
            }

            // 检查今日是否已领取
            if (checkFreeRewardUsed(npcId, playerId, currentDay)) {
                result.put("success", false);
                result.put("message", "今日已领取过免费奖励，明日再来吧");
                return result;
            }

            int[] need = currentRequirements();
            List<Map<String, Object>> freeLines = npcTradeProposalService.surplusForFreeReward(
                    npcId, need[0], need[1]);
            if (freeLines.isEmpty()) {
                result.put("success", false);
                result.put("message", "该NPC暂无可领取的物资");
                return result;
            }

            List<Map<String, Object>> rewardItems = new ArrayList<>();
            for (Map<String, Object> line : freeLines) {
                TradeItem.ItemType supplyType = parseItemType(String.valueOf(line.get("itemType")));
                int itemId = ((Number) line.get("itemId")).intValue();
                int rewardQuantity = ((Number) line.get("quantity")).intValue();
                npcInventoryService.deductItem(npcId, supplyType, itemId, rewardQuantity);
                addPlayerItem(playerId, supplyType, itemId, rewardQuantity);
                Map<String, Object> item = new LinkedHashMap<>();
                item.put("itemType", supplyType.name());
                item.put("itemId", itemId);
                item.put("itemName", getItemName(supplyType, itemId));
                item.put("quantity", rewardQuantity);
                item.put("actualQuantity", rewardQuantity);
                rewardItems.add(item);
            }

            // 记录特殊奖励到交易记录
            NpcTradeRecord record = new NpcTradeRecord();
            record.setNpcId(npcId);
            record.setPlayerId(playerId);
            record.setGameDay(currentDay);
            record.setDemandItems(toJson(new ArrayList<>()));
            record.setSupplyItems(toJson(rewardItems));
            record.setFavorChange(0);
            tradeRecordRepository.save(record);

            // 记录今日免费奖励已使用
            markFreeRewardUsed(npcId, playerId, currentDay);

            result.put("success", true);
            result.put("message", "恭喜！作为挚友，您免费领取了基础数量物资！");
            result.put("rewardItems", rewardItems);
            result.put("isFreeReward", true);
            result.put("favorValue", favorValue);

        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "领取失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    /**
     * 检查免费奖励今日是否已使用
     */
    private boolean checkFreeRewardUsed(Integer npcId, Integer playerId, Integer gameDay) {
        return tradeRecordRepository.countFreeRewardToday(npcId, playerId, gameDay) > 0;
    }

    private int sumGiftFavor(Integer npcId, Integer playerId) {
        return Math.max(0, tradeRecordRepository.sumGiftFavor(npcId, playerId));
    }

    private void putGiftFavorCaps(Map<String, Object> result, Integer npcId, Integer playerId) {
        int total = sumGiftFavor(npcId, playerId);
        result.put("giftFavorTotal", total);
        result.put("giftFavorCap", MAX_GIFT_FAVOR);
        result.put("giftFavorRemaining", Math.max(0, MAX_GIFT_FAVOR - total));
        result.put("giftFoodPerFavor", GIFT_FOOD_PER_FAVOR);
        result.put("giftWoodPerFavor", GIFT_WOOD_PER_FAVOR);
        result.put("giftFuelPerFavor", GIFT_FUEL_PER_FAVOR);
    }

    /**
     * 标记免费奖励已使用
     */
    private void markFreeRewardUsed(Integer npcId, Integer playerId, Integer gameDay) {
        // 通过保存一条标记记录实现（已在claimFreeReward中记录）
        // 此方法保留作为未来扩展
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getTradeHistory(Integer playerId) {
        List<NpcTradeRecord> records = tradeRecordRepository.findByPlayerIdOrderByCreatedAtDesc(playerId);
        return records.stream().map(this::recordToMap).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getTradeHistoryByNpc(Integer playerId, Integer npcId) {
        List<NpcTradeRecord> records = tradeRecordRepository.findByPlayerIdAndNpcIdOrderByCreatedAtDesc(playerId, npcId);
        return records.stream().map(this::recordToMap).collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> saveTradeConfig(Integer npcId, List<Map<String, Object>> demandItems, List<Map<String, Object>> supplyItems) {
        Map<String, Object> result = new LinkedHashMap<>();
        try {
            if (!npcRepository.existsById(npcId)) {
                result.put("success", false);
                result.put("message", "NPC不存在");
                return result;
            }

            tradeConfigRepository.deleteByNpcId(npcId);

            List<NpcTradeConfig> configs = new ArrayList<>();

            if (demandItems != null) {
                for (Map<String, Object> item : demandItems) {
                    NpcTradeConfig config = createConfigFromMap(npcId, CONFIG_TYPE_DEMAND, item);
                    configs.add(config);
                }
            }

            if (supplyItems != null) {
                for (Map<String, Object> item : supplyItems) {
                    NpcTradeConfig config = createConfigFromMap(npcId, CONFIG_TYPE_SUPPLY, item);
                    configs.add(config);
                }
            }

            tradeConfigRepository.saveAll(configs);

            result.put("success", true);
            result.put("message", "交易配置已保存");
            result.put("configCount", configs.size());

        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "保存失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    @Transactional
    public Map<String, Object> setDailyTradeLimit(Integer npcId, Integer limit) {
        Map<String, Object> result = new LinkedHashMap<>();
        try {
            Optional<LocationNpc> npcOpt = npcRepository.findById(npcId);
            if (!npcOpt.isPresent()) {
                result.put("success", false);
                result.put("message", "NPC不存在");
                return result;
            }

            if (limit < 0) {
                result.put("success", false);
                result.put("message", "交易上限不能为负数");
                return result;
            }

            LocationNpc npc = npcOpt.get();
            npc.setDailyTradeLimit(limit);
            npcRepository.save(npc);

            result.put("success", true);
            result.put("message", "每日交易上限已设置为" + limit + "次");
            result.put("dailyTradeLimit", limit);

        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "设置失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllTradeConfigs() {
        List<LocationNpc> npcs = npcRepository.findAll();
        List<Map<String, Object>> result = new ArrayList<>();
        for (LocationNpc npc : npcs) {
            Map<String, Object> npcMap = new LinkedHashMap<>();
            npcMap.put("npcId", npc.getId());
            npcMap.put("npcName", npc.getName());
            npcMap.put("npcJob", npc.getJob());
            npcMap.put("dailyTradeLimit", npc.getDailyTradeLimit());
            
            List<NpcTradeConfig> demandConfigs = tradeConfigRepository.findByNpcIdAndConfigType(npc.getId(), CONFIG_TYPE_DEMAND);
            List<NpcTradeConfig> supplyConfigs = tradeConfigRepository.findByNpcIdAndConfigType(npc.getId(), CONFIG_TYPE_SUPPLY);
            
            npcMap.put("demandItems", demandConfigs.stream().map(this::configToMap).collect(Collectors.toList()));
            npcMap.put("supplyItems", supplyConfigs.stream().map(this::configToMap).collect(Collectors.toList()));
            
            result.add(npcMap);
        }
        return result;
    }

    private boolean isFavorValid(NpcTradeConfig config, int favorValue) {
        int min = config.getMinFavor() != null ? config.getMinFavor() : -100;
        int max = config.getMaxFavor() != null ? config.getMaxFavor() : 100;
        return favorValue >= min && favorValue <= max;
    }

    private boolean rollProbability(Double probability) {
        if (probability == null || probability >= 1.0) return true;
        if (probability <= 0) return false;
        return Math.random() < probability;
    }

    private int getFavorValue(Integer npcId, Integer playerId) {
        return npcFavorRepository.findByNpcIdAndPlayerId(npcId, playerId)
                .map(NpcFavor::getFavorValue)
                .orElse(0);
    }

    private void updateOrCreateFavor(Integer npcId, Integer playerId, Integer favorValue) {
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

    private TradeItem.ItemType parseItemType(String itemType) throws IllegalArgumentException {
        if (itemType == null || itemType.trim().isEmpty()) {
            logger.error("物资类型为空, 有效值: item, weapon, ammo, material");
            throw new IllegalArgumentException("物资类型不能为空");
        }
        try {
            return TradeItem.ItemType.valueOf(itemType.trim().toLowerCase());
        } catch (IllegalArgumentException e) {
            logger.error("无效的物资类型: '{}', 有效值: item, weapon, ammo, material", itemType);
            throw new IllegalArgumentException("无效的物资类型: " + itemType + ", 有效值: item, weapon, ammo, material");
        }
    }

    /**
     * 智能解析itemType - 如果直接解析失败，尝试根据itemId推断正确的itemType
     * 这样可以处理DM端配置错误的情况
     */
    private TradeItem.ItemType smartParseItemType(String itemType, Integer itemId) {
        try {
            return parseItemType(itemType);
        } catch (IllegalArgumentException e) {
            if (itemId != null) {
                TradeItem.ItemType inferred = inferItemTypeById(itemId);
                if (inferred != null) {
                    logger.warn("itemType '{}' 无效, 根据itemId={} 推断为 '{}'", itemType, itemId, inferred);
                    return inferred;
                }
            }
            throw e;
        }
    }

    /**
     * 根据itemId推断itemType
     * 根据系统已知的物品分类：
     * - item类: 1-医疗资源, 2-手电筒, 4-哨子, 8-维修工具包, 10-朗姆酒, 12-渔网, 15-点火工具, 18-食物补给
     * - material类: 1-金属制品, 2-木材, 3-绳索, 4-木板, 5-食物, 6-沥青, 7-石料, 8-燃料, 9-帆布, 10-发动机, 11-螺旋桨, 12-发电机
     */
    private TradeItem.ItemType inferItemTypeById(Integer itemId) {
        Map<Integer, TradeItem.ItemType> itemTypeMap = new HashMap<>();
        itemTypeMap.put(1, TradeItem.ItemType.item);  // 医疗资源
        itemTypeMap.put(2, TradeItem.ItemType.item);  // 手电筒
        itemTypeMap.put(4, TradeItem.ItemType.item);  // 哨子
        itemTypeMap.put(8, TradeItem.ItemType.item);  // 维修工具包
        itemTypeMap.put(10, TradeItem.ItemType.item); // 朗姆酒
        itemTypeMap.put(12, TradeItem.ItemType.item); // 渔网
        itemTypeMap.put(15, TradeItem.ItemType.item); // 点火工具
        itemTypeMap.put(18, TradeItem.ItemType.item); // 食物补给
        return itemTypeMap.get(itemId);
    }

    private int getPlayerStock(Integer playerId, TradeItem.ItemType itemType, Integer itemId) {
        try {
            Optional<PlayerItem> itemOpt = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(playerId, itemType, itemId);
            int stock = itemOpt.map(PlayerItem::getQuantity).orElse(0);
            logger.debug("获取玩家物资: playerId={}, itemType={}, itemId={}, 记录存在={}, stock={}",
                    playerId, itemType, itemId, itemOpt.isPresent(), stock);
            return stock;
        } catch (Exception e) {
            logger.error("获取玩家物资失败: playerId={}, itemType={}, itemId={}, 错误: {}",
                    playerId, itemType, itemId, e.getMessage());
            return 0;
        }
    }

    /**
     * 智能获取玩家物资 - 当指定itemType找不到时，尝试其他itemType
     * 这样可以避免DM端配置错误导致的物资识别失败
     */
    private int getPlayerStockSmart(Integer playerId, String rawItemType, Integer itemId) {
        try {
            TradeItem.ItemType itemType = smartParseItemType(rawItemType, itemId);
            int stock = getPlayerStock(playerId, itemType, itemId);

            if (stock == 0 && itemId != null) {
                List<PlayerItem> allItems = playerItemRepository.findByPlayerId(playerId);
                for (PlayerItem item : allItems) {
                    if (item.getItemId().equals(itemId) && item.getQuantity() != null && item.getQuantity() > 0) {
                        logger.warn("物资类型不匹配: 配置itemType={}, 实际itemType={}, itemId={}, 实际数量={}",
                                rawItemType, item.getItemType(), itemId, item.getQuantity());
                        return item.getQuantity();
                    }
                }
            }
            return stock;
        } catch (Exception e) {
            logger.error("智能获取玩家物资失败: playerId={}, itemType={}, itemId={}, 错误: {}",
                    playerId, rawItemType, itemId, e.getMessage());
            return 0;
        }
    }

    private int reducePlayerItem(Integer playerId, TradeItem.ItemType itemType, Integer itemId, Integer quantity) {
        try {
            Optional<PlayerItem> existing = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(playerId, itemType, itemId);
            
            if (!existing.isPresent()) {
                logger.error("玩家物资不存在: playerId={}, itemType={}, itemId={}", playerId, itemType, itemId);
                throw new RuntimeException("玩家物资不存在: " + getItemName(itemType, itemId));
            }
            
            PlayerItem item = existing.get();
            int current = item.getQuantity();
            if (current < quantity) {
                logger.error("玩家物资不足: playerId={}, itemType={}, itemId={}, 当前={}, 需要={}", 
                        playerId, itemType, itemId, current, quantity);
                throw new RuntimeException("玩家物资不足: " + getItemName(itemType, itemId) + " 当前" + current + "，需要" + quantity);
            }
            
            item.setQuantity(current - quantity);
            playerItemRepository.save(item);
            logger.info("减少玩家物资成功: playerId={}, itemType={}, itemId={}, 减少数量={}, 剩余数量={}", 
                    playerId, itemType, itemId, quantity, item.getQuantity());
            return 1;
        } catch (Exception e) {
            logger.error("减少玩家物资失败: playerId={}, itemType={}, itemId={}, 数量={}, 错误: {}", 
                    playerId, itemType, itemId, quantity, e.getMessage());
            throw e;
        }
    }

    private int addPlayerItem(Integer playerId, TradeItem.ItemType itemType, Integer itemId, Integer quantity) {
        try {
            Optional<PlayerItem> existing = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(playerId, itemType, itemId);
            
            if (existing.isPresent()) {
                PlayerItem item = existing.get();
                item.setQuantity(item.getQuantity() + quantity);
                playerItemRepository.save(item);
                logger.info("增加玩家物资成功(更新): playerId={}, itemType={}, itemId={}, 增加数量={}, 新数量={}", 
                        playerId, itemType, itemId, quantity, item.getQuantity());
                return 1;
            } else {
                PlayerItem newItem = new PlayerItem();
                newItem.setPlayerId(playerId);
                newItem.setItemType(itemType);
                newItem.setItemId(itemId);
                newItem.setQuantity(quantity);
                PlayerItem saved = playerItemRepository.save(newItem);
                logger.info("增加玩家物资成功(新增): playerId={}, itemType={}, itemId={}, 数量={}, 新记录ID={}", 
                        playerId, itemType, itemId, quantity, saved.getId());
                return 1;
            }
        } catch (Exception e) {
            logger.error("增加玩家物资失败: playerId={}, itemType={}, itemId={}, 数量={}, 错误: {}", 
                    playerId, itemType, itemId, quantity, e.getMessage());
            throw e;
        }
    }

    private void incrementDailyTradeCount(Integer npcId, Integer playerId, Integer gameDay) {
        Optional<NpcDailyTradeCount> existing = dailyTradeCountRepository.findByNpcIdAndPlayerIdAndGameDay(npcId, playerId, gameDay);
        if (existing.isPresent()) {
            existing.get().setTradeCount(existing.get().getTradeCount() + 1);
            dailyTradeCountRepository.save(existing.get());
        } else {
            NpcDailyTradeCount count = new NpcDailyTradeCount();
            count.setNpcId(npcId);
            count.setPlayerId(playerId);
            count.setGameDay(gameDay);
            count.setTradeCount(1);
            dailyTradeCountRepository.save(count);
        }
    }

    public static int calculateTradeFavorChange(int currentFavor) {
        if (currentFavor >= 60) return 1;
        if (currentFavor >= 20) return 2;
        if (currentFavor >= -20) return 3;
        if (currentFavor >= -60) return 2;
        return 1;
    }

    private Map<String, Object> configToMap(NpcTradeConfig config) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", config.getId());
        map.put("npcId", config.getNpcId());
        map.put("configType", config.getConfigType());
        map.put("itemType", config.getItemType());
        map.put("itemId", config.getItemId());
        TradeItem.ItemType type = parseItemType(config.getItemType());
        map.put("itemName", getItemName(type, config.getItemId()));
        map.put("quantity", config.getQuantity());
        map.put("minFavor", config.getMinFavor());
        map.put("maxFavor", config.getMaxFavor());
        map.put("probability", config.getProbability());
        return map;
    }

    private NpcTradeConfig createConfigFromMap(Integer npcId, String configType, Map<String, Object> map) {
        NpcTradeConfig config = new NpcTradeConfig();
        config.setNpcId(npcId);
        config.setConfigType(configType);
        config.setItemType(String.valueOf(map.get("itemType")));
        config.setItemId(((Number) map.get("itemId")).intValue());
        config.setQuantity(((Number) map.get("quantity")).intValue());
        
        if (map.containsKey("minFavor")) {
            config.setMinFavor(((Number) map.get("minFavor")).intValue());
        }
        if (map.containsKey("maxFavor")) {
            config.setMaxFavor(((Number) map.get("maxFavor")).intValue());
        }
        if (map.containsKey("probability")) {
            config.setProbability(((Number) map.get("probability")).doubleValue());
        }
        
        return config;
    }

    private Map<String, Object> recordToMap(NpcTradeRecord record) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", record.getId());
        map.put("npcId", record.getNpcId());
        map.put("playerId", record.getPlayerId());
        map.put("gameDay", record.getGameDay());
        map.put("demandItems", fromJson(record.getDemandItems()));
        map.put("supplyItems", fromJson(record.getSupplyItems()));
        map.put("favorChange", record.getFavorChange());
        map.put("tradeTime", record.getTradeTime());
        
        String npcName = npcRepository.findById(record.getNpcId())
                .map(LocationNpc::getName)
                .orElse("未知NPC");
        map.put("npcName", npcName);
        
        return map;
    }

    private String getItemName(TradeItem.ItemType itemType, Integer itemId) {
        switch (itemType) {
            case weapon: return getWeaponName(itemId);
            case ammo: return getAmmoName(itemId);
            case material: return getMaterialName(itemId);
            default: return getItemNameById(itemId);
        }
    }

    private String getItemNameById(Integer itemId) {
        Map<Integer, String> names = new HashMap<>();
        names.put(1, "医疗资源");
        names.put(2, "手电筒");
        names.put(4, "哨子");
        names.put(8, "维修工具包");
        names.put(10, "朗姆酒");
        names.put(12, "渔网");
        names.put(15, "点火工具");
        names.put(18, "食物补给");
        return names.getOrDefault(itemId, "道具" + itemId);
    }

    private String getWeaponName(Integer itemId) {
        Map<Integer, String> names = new HashMap<>();
        names.put(1, "制式手枪");
        names.put(2, "猎枪");
        names.put(3, "警棍");
        names.put(4, "刺刀");
        names.put(9, "斧头");
        names.put(11, "手术刀");
        return names.getOrDefault(itemId, "武器" + itemId);
    }

    private String getAmmoName(Integer itemId) {
        Map<Integer, String> names = new HashMap<>();
        names.put(1, "手枪弹");
        names.put(2, "猎枪弹");
        names.put(3, "信号弹");
        return names.getOrDefault(itemId, "弹药" + itemId);
    }

    private String getMaterialName(Integer itemId) {
        Map<Integer, String> names = new HashMap<>();
        names.put(1, "金属制品");
        names.put(2, "木材");
        names.put(3, "绳索");
        names.put(4, "木板");
        names.put(5, "食物");
        names.put(6, "沥青");
        names.put(7, "石料");
        names.put(8, "燃料");
        names.put(9, "帆布");
        names.put(10, "发动机");
        names.put(11, "螺旋桨");
        names.put(12, "发电机");
        return names.getOrDefault(itemId, "物资" + itemId);
    }

    private String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> fromJson(String json) {
        if (json == null || json.isEmpty()) return new ArrayList<>();
        try {
            return objectMapper.readValue(json, List.class);
        } catch (JsonProcessingException e) {
            return new ArrayList<>();
        }
    }

    /**
     * 诊断玩家物资识别问题
     * 检查交易配置中的每个itemType是否正确，识别可能的itemType错误
     */
    @Transactional(readOnly = true)
    public Map<String, Object> diagnoseTradeConfig(Integer npcId, Integer playerId) {
        Map<String, Object> result = new LinkedHashMap<>();
        List<Map<String, Object>> issues = new ArrayList<>();
        List<Map<String, Object>> fixed = new ArrayList<>();

        try {
            List<NpcTradeConfig> demandConfigs = tradeConfigRepository.findByNpcIdAndConfigType(npcId, CONFIG_TYPE_DEMAND);
            List<NpcTradeConfig> supplyConfigs = tradeConfigRepository.findByNpcIdAndConfigType(npcId, CONFIG_TYPE_SUPPLY);

            List<PlayerItem> playerItems = playerItemRepository.findByPlayerId(playerId);

            for (NpcTradeConfig config : demandConfigs) {
                Map<String, Object> issue = checkItemTypeMatch(config, playerItems, "demand");
                if (issue != null) {
                    issues.add(issue);
                    TradeItem.ItemType correctType = (TradeItem.ItemType) issue.get("correctType");
                    if (correctType != null) {
                        Map<String, Object> fix = new LinkedHashMap<>();
                        fix.put("configId", config.getId());
                        fix.put("currentType", config.getItemType());
                        fix.put("correctType", correctType.name());
                        fix.put("itemId", config.getItemId());
                        fix.put("actualQuantity", issue.get("actualQuantity"));
                        fixed.add(fix);
                    }
                }
            }

            for (NpcTradeConfig config : supplyConfigs) {
                Map<String, Object> issue = checkItemTypeMatch(config, playerItems, "supply");
                if (issue != null) {
                    issues.add(issue);
                }
            }

            result.put("success", true);
            result.put("npcId", npcId);
            result.put("playerId", playerId);
            result.put("issues", issues);
            result.put("suggestedFixes", fixed);
            result.put("issueCount", issues.size());
            result.put("playerItemCount", playerItems.size());
        } catch (Exception e) {
            logger.error("诊断交易配置失败: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("message", "诊断失败: " + e.getMessage());
        }
        return result;
    }

    private Map<String, Object> checkItemTypeMatch(NpcTradeConfig config, List<PlayerItem> playerItems, String configType) {
        try {
            TradeItem.ItemType configTypeEnum = parseItemType(config.getItemType());
            int configStock = getPlayerStockByType(playerItems, configTypeEnum, config.getItemId());

            if (configStock == 0) {
                for (PlayerItem item : playerItems) {
                    if (item.getItemId().equals(config.getItemId()) && item.getQuantity() != null && item.getQuantity() > 0) {
                        Map<String, Object> issue = new LinkedHashMap<>();
                        issue.put("configId", config.getId());
                        issue.put("configType", configType);
                        issue.put("itemId", config.getItemId());
                        issue.put("configItemType", config.getItemType());
                        issue.put("actualItemType", item.getItemType().name());
                        issue.put("actualQuantity", item.getQuantity());
                        issue.put("description", "交易配置中itemType='" + config.getItemType() +
                            "'，但玩家物资实际存储为itemType='" + item.getItemType().name() +
                            "'，导致物资识别为0");
                        issue.put("correctType", item.getItemType());
                        return issue;
                    }
                }
            }
        } catch (IllegalArgumentException e) {
            Map<String, Object> issue = new LinkedHashMap<>();
            issue.put("configId", config.getId());
            issue.put("configType", configType);
            issue.put("itemId", config.getItemId());
            issue.put("configItemType", config.getItemType());
            issue.put("description", "交易配置中itemType='" + config.getItemType() + "'无效");
            return issue;
        }
        return null;
    }

    private int getPlayerStockByType(List<PlayerItem> playerItems, TradeItem.ItemType itemType, Integer itemId) {
        for (PlayerItem item : playerItems) {
            if (item.getItemType() == itemType && item.getItemId().equals(itemId)) {
                return item.getQuantity() != null ? item.getQuantity() : 0;
            }
        }
        return 0;
    }

    /**
     * 自动修复交易配置中错误的itemType
     * 根据玩家实际拥有的物资数据，自动修正itemType
     */
    @Transactional
    public Map<String, Object> autoFixTradeConfig(Integer npcId, Integer playerId) {
        Map<String, Object> result = new LinkedHashMap<>();
        List<Map<String, Object>> fixedItems = new ArrayList<>();
        List<Map<String, Object>> failedItems = new ArrayList<>();

        try {
            List<NpcTradeConfig> demandConfigs = tradeConfigRepository.findByNpcIdAndConfigType(npcId, CONFIG_TYPE_DEMAND);
            List<PlayerItem> playerItems = playerItemRepository.findByPlayerId(playerId);

            for (NpcTradeConfig config : demandConfigs) {
                try {
                    TradeItem.ItemType configTypeEnum = parseItemType(config.getItemType());
                    int configStock = getPlayerStockByType(playerItems, configTypeEnum, config.getItemId());

                    if (configStock == 0) {
                        for (PlayerItem item : playerItems) {
                            if (item.getItemId().equals(config.getItemId()) && item.getQuantity() != null && item.getQuantity() > 0) {
                                config.setItemType(item.getItemType().name().toLowerCase());
                                tradeConfigRepository.save(config);
                                Map<String, Object> fix = new LinkedHashMap<>();
                                fix.put("configId", config.getId());
                                fix.put("itemId", config.getItemId());
                                fix.put("oldType", configTypeEnum.name());
                                fix.put("newType", item.getItemType().name());
                                fix.put("actualQuantity", item.getQuantity());
                                fixedItems.add(fix);
                                logger.info("自动修复交易配置: configId={}, itemType: {} -> {}",
                                        config.getId(), configTypeEnum, item.getItemType());
                                break;
                            }
                        }
                    }
                } catch (IllegalArgumentException e) {
                    Map<String, Object> fail = new LinkedHashMap<>();
                    fail.put("configId", config.getId());
                    fail.put("itemType", config.getItemType());
                    fail.put("reason", "itemType无效");
                    failedItems.add(fail);
                }
            }

            result.put("success", true);
            result.put("npcId", npcId);
            result.put("playerId", playerId);
            result.put("fixedCount", fixedItems.size());
            result.put("failedCount", failedItems.size());
            result.put("fixedItems", fixedItems);
            result.put("failedItems", failedItems);
            result.put("message", "修复完成: 成功" + fixedItems.size() + "项, 失败" + failedItems.size() + "项");
        } catch (Exception e) {
            logger.error("自动修复交易配置失败: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("message", "修复失败: " + e.getMessage());
        }
        return result;
    }

    /**
     * 获取玩家所有物资（用于诊断）
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getPlayerItemDiagnosis(Integer playerId) {
        Map<String, Object> result = new LinkedHashMap<>();
        try {
            List<PlayerItem> items = playerItemRepository.findByPlayerId(playerId);
            List<Map<String, Object>> itemList = new ArrayList<>();

            for (PlayerItem item : items) {
                Map<String, Object> itemMap = new LinkedHashMap<>();
                itemMap.put("id", item.getId());
                itemMap.put("itemType", item.getItemType().name());
                itemMap.put("itemId", item.getItemId());
                itemMap.put("itemName", getItemName(item.getItemType(), item.getItemId()));
                itemMap.put("quantity", item.getQuantity());
                itemList.add(itemMap);
            }

            result.put("success", true);
            result.put("playerId", playerId);
            result.put("totalItems", items.size());
            result.put("items", itemList);
        } catch (Exception e) {
            logger.error("获取玩家物资诊断信息失败: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("message", "获取失败: " + e.getMessage());
        }
        return result;
    }

    /**
     * Gift food / wood / fuel that is not on the demand list, to keep the NPC alive.
     * Does not consume the daily trade slot.
     */
    @Transactional
    public Map<String, Object> giftSurvival(Integer playerId, Integer npcId,
                                            int foodUnits, int woodKg, int fuelKg) {
        Map<String, Object> result = new LinkedHashMap<>();
        try {
            if (playerId == null || npcId == null) {
                result.put("success", false);
                result.put("message", "参数无效");
                return result;
            }
            Optional<LocationNpc> npcOpt = npcRepository.findById(npcId);
            if (!npcOpt.isPresent()) {
                result.put("success", false);
                result.put("message", "NPC不存在");
                return result;
            }
            LocationNpc npc = npcOpt.get();
            String unavailable = unavailableReason(npc);
            if (unavailable != null) {
                result.put("success", false);
                result.put("message", unavailable);
                return result;
            }
            foodUnits = Math.max(0, foodUnits);
            woodKg = Math.max(0, woodKg);
            fuelKg = Math.max(0, fuelKg);
            if (foodUnits == 0 && woodKg == 0 && fuelKg == 0) {
                result.put("success", false);
                result.put("message", "请至少赠送一项食物、木材或燃料");
                return result;
            }

            int favorValue = getFavorValue(npcId, playerId);
            if (isHostile(favorValue)) {
                result.put("success", false);
                result.put("message", "该NPC对你抱有敌意，拒绝接受赠予");
                return result;
            }

            if (foodUnits > 0) {
                int have = getPlayerStock(playerId, TradeItem.ItemType.material,
                        com.example.snowisland.util.ItemCatalog.FOOD_MATERIAL_ID);
                if (have < foodUnits) {
                    result.put("success", false);
                    result.put("message", "食物不足（需要 " + foodUnits + "，当前 " + have + "）");
                    return result;
                }
            }
            if (woodKg > 0) {
                int have = getPlayerStock(playerId, TradeItem.ItemType.material,
                        com.example.snowisland.util.ItemCatalog.WOOD_MATERIAL_ID);
                if (have < woodKg) {
                    result.put("success", false);
                    result.put("message", "木材不足（需要 " + woodKg + "，当前 " + have + "）");
                    return result;
                }
            }
            if (fuelKg > 0) {
                int have = getPlayerStock(playerId, TradeItem.ItemType.material,
                        com.example.snowisland.util.ItemCatalog.FUEL_MATERIAL_ID);
                if (have < fuelKg) {
                    result.put("success", false);
                    result.put("message", "燃料不足（需要 " + fuelKg + "，当前 " + have + "）");
                    return result;
                }
            }

            if (foodUnits > 0) {
                reducePlayerItem(playerId, TradeItem.ItemType.material,
                        com.example.snowisland.util.ItemCatalog.FOOD_MATERIAL_ID, foodUnits);
                npcInventoryService.addItem(npcId, TradeItem.ItemType.material,
                        com.example.snowisland.util.ItemCatalog.FOOD_MATERIAL_ID, foodUnits);
            }
            if (woodKg > 0) {
                reducePlayerItem(playerId, TradeItem.ItemType.material,
                        com.example.snowisland.util.ItemCatalog.WOOD_MATERIAL_ID, woodKg);
                npcInventoryService.addItem(npcId, TradeItem.ItemType.material,
                        com.example.snowisland.util.ItemCatalog.WOOD_MATERIAL_ID, woodKg);
            }
            if (fuelKg > 0) {
                reducePlayerItem(playerId, TradeItem.ItemType.material,
                        com.example.snowisland.util.ItemCatalog.FUEL_MATERIAL_ID, fuelKg);
                npcInventoryService.addItem(npcId, TradeItem.ItemType.material,
                        com.example.snowisland.util.ItemCatalog.FUEL_MATERIAL_ID, fuelKg);
            }

            int currentDay = gameStateService.getCurrentDay();
            NpcTradeRecord record = new NpcTradeRecord();
            record.setNpcId(npcId);
            record.setPlayerId(playerId);
            record.setGameDay(currentDay);
            List<Map<String, Object>> given = new ArrayList<>();
            if (foodUnits > 0) {
                given.add(giftLine("material", com.example.snowisland.util.ItemCatalog.FOOD_MATERIAL_ID,
                        "食物", foodUnits));
            }
            if (woodKg > 0) {
                given.add(giftLine("material", com.example.snowisland.util.ItemCatalog.WOOD_MATERIAL_ID,
                        "木材", woodKg));
            }
            if (fuelKg > 0) {
                given.add(giftLine("material", com.example.snowisland.util.ItemCatalog.FUEL_MATERIAL_ID,
                        "燃料", fuelKg));
            }
            int fromQty = (foodUnits / GIFT_FOOD_PER_FAVOR)
                    + (woodKg / GIFT_WOOD_PER_FAVOR)
                    + (fuelKg / GIFT_FUEL_PER_FAVOR);
            int alreadyGiftFavor = sumGiftFavor(npcId, playerId);
            int remainingCap = Math.max(0, MAX_GIFT_FAVOR - alreadyGiftFavor);
            int roomToMax = Math.max(0, 100 - favorValue);
            int favorChange = Math.min(fromQty, Math.min(remainingCap, roomToMax));
            int newFavor = favorValue;
            if (favorChange > 0) {
                newFavor = Math.min(100, favorValue + favorChange);
                updateOrCreateFavor(npcId, playerId, newFavor);
            }

            record.setDemandItems(toJson(given));
            record.setSupplyItems(toJson(new ArrayList<>()));
            record.setFavorChange(favorChange);
            tradeRecordRepository.save(record);

            Optional<Player> playerOpt = playerRepository.findById(playerId);
            String playerName = playerOpt.map(Player::getName).orElse("玩家" + playerId);
            activityLogService.log(currentDay, playerId, playerName,
                    ActivityLogService.factionOf(playerOpt.orElse(null)),
                    ActivityLogService.CAT_TRADE,
                    "赠予 " + npc.getName() + " 食" + foodUnits + " 木" + woodKg + " 燃" + fuelKg
                            + (favorChange > 0 ? " 好感+" + favorChange : ""),
                    null);

            String message = "已将物资交给" + npc.getName();
            if (favorChange > 0) {
                message += "（好感+" + favorChange + "）";
            } else if (fromQty > 0 && remainingCap <= 0) {
                message += "（送礼好感已达上限，物资仍已转交）";
            }

            result.put("success", true);
            result.put("message", message);
            result.put("giftItems", given);
            result.put("favorChange", favorChange);
            result.put("newFavor", newFavor);
            result.putAll(npcInventoryService.survivalSnapshot(npcId, currentRequirements()[0], currentRequirements()[1]));
            putGiftFavorCaps(result, npcId, playerId);
        } catch (RuntimeException e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    private static Map<String, Object> giftLine(String itemType, int itemId, String name, int qty) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("itemType", itemType);
        row.put("itemId", itemId);
        row.put("itemName", name);
        row.put("quantity", qty);
        row.put("actualQuantity", qty);
        return row;
    }

    private String unavailableReason(LocationNpc npc) {
        String status = npc.getStatus() != null ? npc.getStatus() : NpcSurvivalMath.STATUS_NORMAL;
        if (NpcSurvivalMath.STATUS_DEAD.equals(status)) {
            return "对方已经死去，无法交易";
        }
        if (NpcSurvivalMath.STATUS_MISSING.equals(status)) {
            return "找不到此人，无法交易";
        }
        if (NpcSurvivalMath.STATUS_ARRESTED.equals(status)) {
            return "对方已被捕，无法交易";
        }
        return null;
    }

    private int[] currentRequirements() {
        int day = gameStateService.getCurrentDay();
        GameDaySettings settings = playerConsumptionService.getOrCreateDaySettings(Math.max(1, day));
        int food = settings.getRequiredFoodUnits() != null
                ? settings.getRequiredFoodUnits() : PlayerConsumptionService.DEFAULT_FOOD_UNITS;
        int heat = settings.getRequiredFuelKg() != null
                ? settings.getRequiredFuelKg() : PlayerConsumptionService.DEFAULT_FUEL_KG;
        return new int[]{food, heat};
    }

    private int[] currentSurvivalStock(Integer npcId) {
        return new int[]{
                npcInventoryService.getMaterialKg(npcId, com.example.snowisland.util.ItemCatalog.FOOD_MATERIAL_ID),
                npcInventoryService.getMaterialKg(npcId, com.example.snowisland.util.ItemCatalog.WOOD_MATERIAL_ID),
                npcInventoryService.getMaterialKg(npcId, com.example.snowisland.util.ItemCatalog.FUEL_MATERIAL_ID)
        };
    }

    private static int sellableFromWorking(TradeItem.ItemType itemType, Integer itemId, int stock,
                                           int food, int wood, int fuel,
                                           int requiredFood, int requiredHeat) {
        if (itemType != TradeItem.ItemType.material || itemId == null) {
            return stock;
        }
        if (itemId == com.example.snowisland.util.ItemCatalog.FOOD_MATERIAL_ID) {
            return Math.min(stock, NpcSurvivalMath.sellableFood(food, requiredFood));
        }
        if (itemId == com.example.snowisland.util.ItemCatalog.WOOD_MATERIAL_ID) {
            return Math.min(stock, NpcSurvivalMath.sellableWood(wood, fuel, requiredHeat));
        }
        if (itemId == com.example.snowisland.util.ItemCatalog.FUEL_MATERIAL_ID) {
            return Math.min(stock, NpcSurvivalMath.sellableFuel(wood, fuel, requiredHeat));
        }
        return stock;
    }

    private static void deductWorking(int[] working, TradeItem.ItemType itemType, Integer itemId, int qty) {
        if (itemType != TradeItem.ItemType.material || itemId == null) {
            return;
        }
        if (itemId == com.example.snowisland.util.ItemCatalog.FOOD_MATERIAL_ID) {
            working[0] = Math.max(0, working[0] - qty);
        } else if (itemId == com.example.snowisland.util.ItemCatalog.WOOD_MATERIAL_ID) {
            working[1] = Math.max(0, working[1] - qty);
        } else if (itemId == com.example.snowisland.util.ItemCatalog.FUEL_MATERIAL_ID) {
            working[2] = Math.max(0, working[2] - qty);
        }
    }
}

