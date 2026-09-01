package com.example.snowisland.service;

import com.example.snowisland.entity.LocationNpc;
import com.example.snowisland.entity.NpcDailyDialogueCount;
import com.example.snowisland.entity.NpcDialogue;
import com.example.snowisland.entity.NpcFavor;
import com.example.snowisland.entity.PlayerNpcRecognition;
import com.example.snowisland.repository.LocationNpcRepository;
import com.example.snowisland.repository.NpcDailyDialogueCountRepository;
import com.example.snowisland.repository.NpcDialogueRepository;
import com.example.snowisland.repository.NpcFavorRepository;
import com.example.snowisland.repository.PlayerNpcRecognitionRepository;
import com.example.snowisland.repository.PlayerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class NpcDialogueService {

    private static final Logger logger = LoggerFactory.getLogger(NpcDialogueService.class);

    /** 好感度最小值 */
    public static final int MIN_FAVOR = -100;
    /** 好感度最大值 */
    public static final int MAX_FAVOR = 100;

    /** 好感度等级定义 */
    public static final String FAVOR_LEVEL_HOSTILE = "敌视";
    public static final String FAVOR_LEVEL_UNFRIENDLY = "冷漠";
    public static final String FAVOR_LEVEL_NEUTRAL = "中立";
    public static final String FAVOR_LEVEL_FRIENDLY = "友善";
    public static final String FAVOR_LEVEL_CLOSE = "亲近";

    /** 同一 NPC 对话加好感全程上限 */
    public static final int MAX_DIALOGUE_FAVOR = 75;

    /** 每日对话上限配置 */
    @Value("${npc.dialogue.daily-limit:5}")
    private int dailyDialogueLimit;

    @Autowired
    private LocationNpcRepository locationNpcRepository;

    @Autowired
    private NpcFavorRepository npcFavorRepository;

    @Autowired
    private NpcDialogueRepository npcDialogueRepository;

    @Autowired
    private NpcDailyDialogueCountRepository dialogueCountRepository;

    @Autowired
    private PlayerRepository playerRepository;

    @Autowired
    private GameStateService gameStateService;

    @Autowired
    private AiDialogueService aiDialogueService;

    @Autowired
    private PlayerNpcRecognitionRepository recognitionRepository;

    @Autowired
    private SpecialClueService specialClueService;

    @Autowired
    private NpcTradeProposalService npcTradeProposalService;

    /**
     * 获取好感度等级描述
     */
    public static String getFavorLevel(Integer favorValue) {
        if (favorValue == null) favorValue = 0;
        if (favorValue <= -60) return FAVOR_LEVEL_HOSTILE;
        if (favorValue <= -20) return FAVOR_LEVEL_UNFRIENDLY;
        if (favorValue <= 20) return FAVOR_LEVEL_NEUTRAL;
        if (favorValue <= 60) return FAVOR_LEVEL_FRIENDLY;
        return FAVOR_LEVEL_CLOSE;
    }

    /**
     * 获取好感度颜色标识
     */
    public static String getFavorColor(Integer favorValue) {
        if (favorValue == null) favorValue = 0;
        if (favorValue <= -60) return "#ef4444";
        if (favorValue <= -20) return "#f59e0b";
        if (favorValue <= 20) return "#6b7280";
        if (favorValue <= 60) return "#3b82f6";
        return "#22c55e";
    }

    /**
     * 获取所有NPC列表（带玩家好感度，只返回已认识的NPC）
     */
    public List<Map<String, Object>> getAllNpcsWithFavor(Integer playerId) {
        if (playerId == null) {
            return new ArrayList<>();
        }

        Set<Integer> recognizedIds = recognitionRepository.findByPlayerId(playerId).stream()
                .map(PlayerNpcRecognition::getNpcId)
                .collect(java.util.stream.Collectors.toSet());

        return locationNpcRepository.findAll().stream()
                .filter(npc -> recognizedIds.contains(npc.getId()))
                .map(npc -> npcToMapWithFavor(npc, playerId))
                .collect(java.util.stream.Collectors.toList());
    }

    /**
     * 获取指定位置的NPC列表
     */
    public List<Map<String, Object>> getNpcsByLocation(Integer locationId, Integer playerId) {
        return locationNpcRepository.findByLocationId(locationId).stream()
                .map(npc -> npcToMapWithFavor(npc, playerId))
                .collect(Collectors.toList());
    }

    /**
     * 获取NPC详细信息（带玩家好感度和对话历史）
     */
    public Map<String, Object> getNpcDetail(Integer npcId, Integer playerId) {
        Map<String, Object> result = new HashMap<>();
        try {
            Optional<LocationNpc> optNpc = locationNpcRepository.findById(npcId);
            if (!optNpc.isPresent()) {
                result.put("success", false);
                result.put("message", "NPC不存在");
                return result;
            }

            LocationNpc npc = optNpc.get();
            result.put("success", true);
            result.put("npc", npcToMapWithFavor(npc, playerId));

            List<NpcDialogue> dialogues = npcDialogueRepository
                    .findByPlayerIdAndNpcIdOrderByCreatedAtAsc(playerId, npcId);
            result.put("dialogues", dialogues.stream().map(this::dialogueToMap).collect(Collectors.toList()));

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "获取NPC详情失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    /**
     * 发送消息给NPC（核心对话逻辑）
     */
    @Transactional
    public Map<String, Object> sendMessage(Integer playerId, Integer npcId, String message) {
        Map<String, Object> result = new HashMap<>();
        try {
            Optional<LocationNpc> optNpc = locationNpcRepository.findById(npcId);
            if (!optNpc.isPresent()) {
                result.put("success", false);
                result.put("message", "NPC不存在");
                return result;
            }

            LocationNpc npc = optNpc.get();
            int currentGameDay = gameStateService.getCurrentDay();

            String npcStatus = npc.getStatus() != null ? npc.getStatus() : "正常";
            
            if ("死亡".equals(npcStatus)) {
                result.put("success", true);
                result.put("reply", "寒冬浸润了ta的尸骨，不再言语");
                result.put("favorChange", 0);
                result.put("newFavor", 0);
                result.put("favorLevel", "中立");
                result.put("npcName", npc.getName());
                result.put("locked", true);
                return result;
            }
            
            if ("失踪".equals(npcStatus)) {
                result.put("success", true);
                result.put("reply", "你没找到ta，ta在哪里？");
                result.put("favorChange", 0);
                result.put("newFavor", 0);
                result.put("favorLevel", "中立");
                result.put("npcName", npc.getName());
                result.put("locked", true);
                return result;
            }
            
            if ("被捕".equals(npcStatus)) {
                result.put("success", true);
                result.put("reply", "他被捕了，你知道的，上面的人总有理由定任何人的罪，不是么。");
                result.put("favorChange", 0);
                result.put("newFavor", 0);
                result.put("favorLevel", "中立");
                result.put("npcName", npc.getName());
                result.put("locked", true);
                return result;
            }

            // 检查对话次数限制
            Map<String, Object> limitCheck = checkDialogueLimit(playerId, npcId, currentGameDay);
            if (!(Boolean) limitCheck.get("canChat")) {
                result.put("success", false);
                result.put("message", limitCheck.get("message"));
                result.put("remainingChats", limitCheck.get("remainingChats"));
                result.put("locked", true);
                result.put("dailyLimit", dailyDialogueLimit);
                return result;
            }

            int currentFavor = getOrCreateFavor(npcId, playerId);

            AiDialogueService.NpcTurn turn = generateNpcTurnWithClue(npc, message, currentFavor, playerId);
            String npcReply = turn.reply;
            int favorChange = turn.favorChange;
            if (favorChange > 0) {
                int already = sumPositiveDialogueFavor(playerId, npcId);
                int remaining = Math.max(0, MAX_DIALOGUE_FAVOR - already);
                favorChange = Math.min(favorChange, remaining);
            }

            if ("受伤".equals(npcStatus)) {
                npcReply += "（你可以支付10份医疗资源帮助npc恢复健康，请使用快速交互与dm描述行动）";
            }

            int newFavor = Math.max(MIN_FAVOR, Math.min(MAX_FAVOR, currentFavor + favorChange));

            updateOrCreateFavor(npcId, playerId, newFavor);

            NpcDialogue dialogue = new NpcDialogue();
            dialogue.setNpcId(npcId);
            dialogue.setPlayerId(playerId);
            dialogue.setPlayerMessage(message);
            dialogue.setNpcReply(npcReply);
            dialogue.setFavorChange(favorChange);
            dialogue.setDialogueRound(currentGameDay);
            npcDialogueRepository.save(dialogue);

            // 更新对话次数
            updateDialogueCount(playerId, npcId, currentGameDay);

            int remainingChats = dailyDialogueLimit - ((Integer) limitCheck.get("currentCount")) - 1;
            if (remainingChats < 0) remainingChats = 0;

            result.put("success", true);
            result.put("reply", npcReply);
            result.put("favorChange", favorChange);
            result.put("newFavor", newFavor);
            result.put("favorLevel", getFavorLevel(newFavor));
            result.put("npcName", npc.getName());
            result.put("dialogueId", dialogue.getId());
            result.put("remainingChats", remainingChats);
            result.put("locked", false);
            result.put("dailyLimit", dailyDialogueLimit);
            result.put("tradeProposed", false);
            putDialogueFavorCaps(result, playerId, npcId);

            Map<String, Object> proposal = npcTradeProposalService.maybeProposeAfterChat(playerId, npcId, message);
            if (proposal != null && Boolean.TRUE.equals(proposal.get("tradeProposed"))) {
                result.put("tradeProposed", true);
                result.put("tradeId", proposal.get("tradeId"));
            }

        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "对话失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    /**
     * 获取玩家与NPC的对话历史
     */
    public List<Map<String, Object>> getDialogueHistory(Integer playerId, Integer npcId) {
        return npcDialogueRepository.findByPlayerIdAndNpcIdOrderByCreatedAtAsc(playerId, npcId)
                .stream()
                .map(this::dialogueToMap)
                .collect(Collectors.toList());
    }

    /**
     * 获取玩家所有NPC好感度
     */
    public List<Map<String, Object>> getPlayerFavors(Integer playerId) {
        return npcFavorRepository.findByPlayerId(playerId).stream()
                .map(favor -> {
                    Map<String, Object> map = new LinkedHashMap<>();
                    map.put("npcId", favor.getNpcId());
                    map.put("playerId", favor.getPlayerId());
                    map.put("favorValue", favor.getFavorValue());
                    map.put("favorLevel", getFavorLevel(favor.getFavorValue()));
                    locationNpcRepository.findById(favor.getNpcId()).ifPresent(npc -> {
                        map.put("npcName", npc.getName());
                        map.put("npcJob", npc.getJob());
                    });
                    return map;
                })
                .collect(Collectors.toList());
    }

    /**
     * DM手动设置NPC好感度
     */
    @Transactional
    public Map<String, Object> setFavor(Integer npcId, Integer playerId, Integer favorValue) {
        Map<String, Object> result = new HashMap<>();
        try {
            if (favorValue == null || favorValue < MIN_FAVOR || favorValue > MAX_FAVOR) {
                result.put("success", false);
                result.put("message", "好感度必须在 " + MIN_FAVOR + "-" + MAX_FAVOR + " 之间");
                return result;
            }

            updateOrCreateFavor(npcId, playerId, favorValue);

            result.put("success", true);
            result.put("message", "好感度设置成功");
            result.put("favorValue", favorValue);
            result.put("favorLevel", getFavorLevel(favorValue));

        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "设置好感度失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    /**
     * 获取或创建好感度记录
     */
    private int getOrCreateFavor(Integer npcId, Integer playerId) {
        return npcFavorRepository.findByNpcIdAndPlayerId(npcId, playerId)
                .map(NpcFavor::getFavorValue)
                .orElse(0);
    }

    /**
     * 更新或创建好感度记录
     */
    private void updateOrCreateFavor(Integer npcId, Integer playerId, Integer favorValue) {
        Optional<NpcFavor> existing = npcFavorRepository.findByNpcIdAndPlayerId(npcId, playerId);
        if (existing.isPresent()) {
            NpcFavor favor = existing.get();
            favor.setFavorValue(favorValue);
            npcFavorRepository.save(favor);
        } else {
            NpcFavor favor = new NpcFavor();
            favor.setNpcId(npcId);
            favor.setPlayerId(playerId);
            favor.setFavorValue(favorValue);
            npcFavorRepository.save(favor);
        }
    }

    private int sumPositiveDialogueFavor(Integer playerId, Integer npcId) {
        return Math.max(0, npcDialogueRepository.sumPositiveFavor(playerId, npcId));
    }

    private void putDialogueFavorCaps(Map<String, Object> result, Integer playerId, Integer npcId) {
        int total = sumPositiveDialogueFavor(playerId, npcId);
        result.put("dialogueFavorTotal", total);
        result.put("dialogueFavorCap", MAX_DIALOGUE_FAVOR);
        result.put("dialogueFavorRemaining", Math.max(0, MAX_DIALOGUE_FAVOR - total));
    }

    /**
     * 检查对话次数限制
     */
    private Map<String, Object> checkDialogueLimit(Integer playerId, Integer npcId, Integer currentGameDay) {
        Map<String, Object> result = new HashMap<>();
        
        Optional<NpcDailyDialogueCount> existingCount = dialogueCountRepository.findByPlayerIdAndNpcId(playerId, npcId);
        
        int currentCount = 0;
        boolean canChat = true;
        String message = "";
        
        if (existingCount.isPresent()) {
            NpcDailyDialogueCount count = existingCount.get();
            
            // 如果是新的游戏天，重置计数
            if (count.getLastGameDay() < currentGameDay) {
                currentCount = 0;
            } else {
                currentCount = count.getDialogueCount();
            }
        }
        
        int remainingChats = Math.max(0, dailyDialogueLimit - currentCount);
        
        if (currentCount >= dailyDialogueLimit) {
            canChat = false;
            message = "今日与该NPC的交流次数已用完（" + currentCount + "/" + dailyDialogueLimit + "），请等待明天重置或DM更新游戏天数。";
            System.out.println("[对话限制] 玩家" + playerId + "与NPC" + npcId + "对话次数已达上限");
        } else {
            message = "剩余交流次数: " + remainingChats + "/" + dailyDialogueLimit;
        }
        
        result.put("canChat", canChat);
        result.put("currentCount", currentCount);
        result.put("remainingChats", remainingChats);
        result.put("message", message);
        result.put("limit", dailyDialogueLimit);
        
        return result;
    }

    /**
     * 更新对话次数
     */
    private void updateDialogueCount(Integer playerId, Integer npcId, Integer currentGameDay) {
        Optional<NpcDailyDialogueCount> existingCount = dialogueCountRepository.findByPlayerIdAndNpcId(playerId, npcId);
        
        if (existingCount.isPresent()) {
            NpcDailyDialogueCount count = existingCount.get();
            // 如果是新的游戏天，重置计数
            if (count.getLastGameDay() < currentGameDay) {
                count.setDialogueCount(1);
            } else {
                count.setDialogueCount(count.getDialogueCount() + 1);
            }
            count.setLastGameDay(currentGameDay);
            count.setLastDialogueTime(new java.util.Date());
            dialogueCountRepository.save(count);
        } else {
            NpcDailyDialogueCount newCount = new NpcDailyDialogueCount();
            newCount.setPlayerId(playerId);
            newCount.setNpcId(npcId);
            newCount.setDialogueCount(1);
            newCount.setLastGameDay(currentGameDay);
            newCount.setLastDialogueTime(new java.util.Date());
            dialogueCountRepository.save(newCount);
        }
    }

    /**
     * 获取玩家与NPC的剩余对话次数
     */
    public Map<String, Object> getDialogueLimitInfo(Integer playerId, Integer npcId) {
        Map<String, Object> result = new HashMap<>();
        int currentGameDay = gameStateService.getCurrentDay();
        
        Optional<NpcDailyDialogueCount> existingCount = dialogueCountRepository.findByPlayerIdAndNpcId(playerId, npcId);
        
        int currentCount = 0;
        if (existingCount.isPresent()) {
            NpcDailyDialogueCount count = existingCount.get();
            if (count.getLastGameDay() < currentGameDay) {
                currentCount = 0;
            } else {
                currentCount = count.getDialogueCount();
            }
        }
        
        int remainingChats = Math.max(0, dailyDialogueLimit - currentCount);
        boolean locked = currentCount >= dailyDialogueLimit;
        
        result.put("success", true);
        result.put("currentCount", currentCount);
        result.put("remainingChats", remainingChats);
        result.put("dailyLimit", dailyDialogueLimit);
        result.put("locked", locked);
        result.put("message", locked ? 
            "今日与该NPC的交流次数已用完（" + currentCount + "/" + dailyDialogueLimit + "），请等待明天重置。" : 
            "剩余交流次数: " + remainingChats + "/" + dailyDialogueLimit);
        putDialogueFavorCaps(result, playerId, npcId);
        
        return result;
    }

    /**
     * 获取玩家所有NPC的对话次数记录
     */
    public List<Map<String, Object>> getAllDialogueCounts(Integer playerId) {
        List<NpcDailyDialogueCount> counts = dialogueCountRepository.findByPlayerId(playerId);
        int currentGameDay = gameStateService.getCurrentDay();
        
        return counts.stream().map(count -> {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("playerId", count.getPlayerId());
            map.put("npcId", count.getNpcId());
            
            // 如果是新的游戏天，显示已重置
            int displayCount = count.getLastGameDay() < currentGameDay ? 0 : count.getDialogueCount();
            map.put("dialogueCount", displayCount);
            map.put("lastGameDay", count.getLastGameDay());
            map.put("remainingChats", Math.max(0, dailyDialogueLimit - displayCount));
            map.put("locked", displayCount >= dailyDialogueLimit);
            map.put("lastDialogueTime", count.getLastDialogueTime());
            
            // 获取NPC名称
            locationNpcRepository.findById(count.getNpcId()).ifPresent(npc -> {
                map.put("npcName", npc.getName());
            });
            
            return map;
        }).collect(Collectors.toList());
    }

    /**
     * DM重置指定玩家的所有对话次数
     */
    @Transactional
    public Map<String, Object> resetPlayerDialogueCounts(Integer playerId) {
        Map<String, Object> result = new HashMap<>();
        try {
            List<NpcDailyDialogueCount> counts = dialogueCountRepository.findByPlayerId(playerId);
            int resetCount = 0;
            for (NpcDailyDialogueCount count : counts) {
                count.setDialogueCount(0);
                dialogueCountRepository.save(count);
                resetCount++;
            }
            
            result.put("success", true);
            result.put("message", "已重置玩家" + playerId + "的" + resetCount + "条对话次数记录");
            result.put("resetCount", resetCount);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "重置失败: " + e.getMessage());
        }
        return result;
    }

    private AiDialogueService.NpcTurn generateNpcTurnWithClue(LocationNpc npc, String playerMessage, int currentFavor, Integer playerId) {
        String npcMatchedKeyword = checkNpcClueKeywords(npc, playerMessage);
        if (npcMatchedKeyword != null && npc.getSpecialClueContent() != null && !npc.getSpecialClueContent().trim().isEmpty()) {
            logger.info("NPC自定义线索触发: npcId={}, keyword={}", npc.getId(), npcMatchedKeyword);
            return aiDialogueService.generateNpcTurn(
                npc.getName(), npc.getJob(), npc.getPersonality(), npc.getDialogueStyle(),
                npc.getIntroduction(), playerMessage, currentFavor, npc.getSpecialClueContent());
        }

        Map<String, Object> clueCheck = specialClueService.checkKeywordMatch(playerMessage, playerId, npc.getId());

        if ((Boolean) clueCheck.get("matched") && (Boolean) clueCheck.get("triggered")) {
            Map<String, Object> clueData = (Map<String, Object>) clueCheck.get("clue");
            String clueContent = (String) clueData.get("content");
            String matchedKeyword = (String) clueCheck.get("matchedKeyword");

            AiDialogueService.NpcTurn turn = aiDialogueService.generateNpcTurn(
                npc.getName(), npc.getJob(), npc.getPersonality(), npc.getDialogueStyle(),
                npc.getIntroduction(), playerMessage, currentFavor, clueContent);

            try {
                com.example.snowisland.entity.SpecialClue clue = new com.example.snowisland.entity.SpecialClue();
                clue.setId((Integer) clueData.get("id"));
                clue.setClueCode((String) clueData.get("clueCode"));
                specialClueService.logTrigger(playerId, npc.getId(), clue, playerMessage, matchedKeyword, turn.reply);
            } catch (Exception e) {
                logger.warn("记录线索触发日志失败: {}", e.getMessage());
            }

            return turn;
        }

        return aiDialogueService.generateNpcTurn(
            npc.getName(), npc.getJob(), npc.getPersonality(), npc.getDialogueStyle(),
            npc.getIntroduction(), playerMessage, currentFavor, null);
    }

    /**
     * 检查NPC自定义关键词匹配
     */
    private String checkNpcClueKeywords(LocationNpc npc, String playerMessage) {
        if (playerMessage == null || playerMessage.isEmpty()) {
            return null;
        }
        String keywordsStr = npc.getClueKeywords();
        if (keywordsStr == null || keywordsStr.trim().isEmpty()) {
            return null;
        }
        String[] keywords = keywordsStr.split("[,，;；、\\n\\r]");
        for (String keyword : keywords) {
            keyword = keyword.trim();
            if (keyword.isEmpty()) {
                continue;
            }
            if (playerMessage.toLowerCase().contains(keyword.toLowerCase())) {
                return keyword;
            }
        }
        return null;
    }

    /**
     * 计算好感度变化
     */
    private int calculateFavorChange(LocationNpc npc, String message, int currentFavor) {
        String lowerMsg = message.toLowerCase();

        if (lowerMsg.contains("谢谢") || lowerMsg.contains("感谢") || lowerMsg.contains("帮助")) {
            return 3;
        }

        if (lowerMsg.contains("你好") || lowerMsg.contains("hello") || lowerMsg.contains("hi")) {
            return 2;
        }

        if (lowerMsg.contains("道歉") || lowerMsg.contains("对不起")) {
            return 2;
        }

        if (lowerMsg.contains("资源") || lowerMsg.contains("交易") || lowerMsg.contains("钱")) {
            if (npc.getJob().contains("商人")) {
                return 2;
            }
            return 0;
        }

        if (lowerMsg.contains("信仰") || lowerMsg.contains("主") || lowerMsg.contains("神")) {
            if (npc.getJob().contains("神父") || npc.getJob().contains("牧师")) {
                return 3;
            }
            return 0;
        }

        if (lowerMsg.contains("武器") || lowerMsg.contains("战斗") || lowerMsg.contains("危险")) {
            if (npc.getJob().contains("猎人") || npc.getJob().contains("铁匠")) {
                return 2;
            }
            return 0;
        }

        if (lowerMsg.contains("医疗") || lowerMsg.contains("药") || lowerMsg.contains("受伤")) {
            if (npc.getJob().contains("医") || npc.getJob().contains("护士")) {
                return 3;
            }
            return 0;
        }

        if (lowerMsg.contains("再见") || lowerMsg.contains("保重")) {
            return 1;
        }

        if (lowerMsg.contains("你是谁") || lowerMsg.contains("介绍")) {
            return 2;
        }

        return 0;
    }

    /**
     * NPC转Map（带好感度）
     */
    private Map<String, Object> npcToMapWithFavor(LocationNpc npc, Integer playerId) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", npc.getId());
        map.put("name", npc.getName());
        map.put("job", npc.getJob());
        map.put("gender", npc.getGender().name());
        map.put("introduction", npc.getIntroduction());
        map.put("locationId", npc.getLocationId());
        map.put("status", npc.getStatus());
        map.put("avatarUrl", npc.getAvatarUrl());

        if (playerId != null) {
            npcFavorRepository.findByNpcIdAndPlayerId(npc.getId(), playerId).ifPresent(favor -> {
                map.put("favorValue", favor.getFavorValue());
                map.put("favorLevel", getFavorLevel(favor.getFavorValue()));
                map.put("favorColor", getFavorColor(favor.getFavorValue()));
            });
        }

        return map;
    }

    /**
     * 对话记录转Map
     */
    private Map<String, Object> dialogueToMap(NpcDialogue dialogue) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", dialogue.getId());
        map.put("npcId", dialogue.getNpcId());
        map.put("playerId", dialogue.getPlayerId());
        map.put("playerMessage", dialogue.getPlayerMessage());
        map.put("npcReply", dialogue.getNpcReply());
        map.put("favorChange", dialogue.getFavorChange());
        map.put("dialogueRound", dialogue.getDialogueRound());
        map.put("createdAt", dialogue.getCreatedAt());
        return map;
    }
}