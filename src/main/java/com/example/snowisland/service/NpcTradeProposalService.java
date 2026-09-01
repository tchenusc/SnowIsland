package com.example.snowisland.service;

import com.example.snowisland.entity.LocationNpc;
import com.example.snowisland.entity.NpcFavor;
import com.example.snowisland.entity.NpcItem;
import com.example.snowisland.entity.NpcTradeProposal;
import com.example.snowisland.entity.NpcTradeRecord;
import com.example.snowisland.entity.PlayerItem;
import com.example.snowisland.entity.TradeItem.ItemType;
import com.example.snowisland.repository.LocationNpcRepository;
import com.example.snowisland.repository.NpcFavorRepository;
import com.example.snowisland.repository.NpcItemRepository;
import com.example.snowisland.repository.NpcTradeProposalRepository;
import com.example.snowisland.repository.NpcTradeRecordRepository;
import com.example.snowisland.repository.PlayerItemRepository;
import com.example.snowisland.util.ItemCatalog;
import com.example.snowisland.util.NpcSurvivalMath;
import com.example.snowisland.util.NpcTradeProposalMath;
import com.example.snowisland.util.NpcTradeProposalMath.Line;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

@Service
public class NpcTradeProposalService {

    private static final Logger logger = LoggerFactory.getLogger(NpcTradeProposalService.class);
    private static final Set<Integer> HARDCODED_NON_TRADABLE_ITEMS = new HashSet<>();
    static {
        HARDCODED_NON_TRADABLE_ITEMS.add(30);
        HARDCODED_NON_TRADABLE_ITEMS.add(42);
        HARDCODED_NON_TRADABLE_ITEMS.add(43);
    }

    @Autowired
    private NpcTradeProposalRepository proposalRepository;

    @Autowired
    private LocationNpcRepository npcRepository;

    @Autowired
    private NpcItemRepository npcItemRepository;

    @Autowired
    private NpcFavorRepository npcFavorRepository;

    @Autowired
    private PlayerItemRepository playerItemRepository;

    @Autowired
    private NpcTradeRecordRepository tradeRecordRepository;

    @Autowired
    private NpcInventoryService npcInventoryService;

    @Autowired
    private GameStateService gameStateService;

    @Autowired
    private PlayerConsumptionService playerConsumptionService;

    @Autowired
    private AiDialogueService aiDialogueService;

    @Autowired
    private TradeRestrictionService tradeRestrictionService;

    @Autowired
    private ObjectMapper objectMapper;

    @PersistenceContext
    private EntityManager entityManager;

    /**
     * After a successful spoken chat turn.
     * Skip while an offer is still open, or after a completed swap today.
     * Reject / expire frees the slot so a later chat can propose again.
     */
    @Transactional
    public Map<String, Object> maybeProposeAfterChat(Integer playerId, Integer npcId) {
        return maybeProposeAfterChat(playerId, npcId, null);
    }

    @Transactional
    public Map<String, Object> maybeProposeAfterChat(Integer playerId, Integer npcId, String playerMessage) {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("tradeProposed", false);
        try {
            if (playerId == null || npcId == null) {
                return out;
            }
            Optional<LocationNpc> npcOpt = npcRepository.findById(npcId);
            if (!npcOpt.isPresent()) {
                return out;
            }
            LocationNpc npc = npcOpt.get();
            if (NpcSurvivalMath.isGone(npc.getStatus())) {
                return out;
            }
            int favor = favorValue(npcId, playerId);
            if (NpcTradeService.isHostile(favor)) {
                return out;
            }
            if (!tradeRestrictionService.reasonsFor(playerId).isEmpty()) {
                return out;
            }
            int day = gameStateService.getCurrentDay();
            if (proposalRepository.existsByNpcIdAndPlayerIdAndGameDayAndStatus(
                    npcId, playerId, day, NpcTradeProposal.STATUS_OPEN)) {
                return out;
            }
            if (proposalRepository.existsByNpcIdAndPlayerIdAndGameDayAndStatus(
                    npcId, playerId, day, NpcTradeProposal.STATUS_COMPLETED)) {
                return out;
            }

            int[] need = currentRequirements();
            int food = npcInventoryService.getMaterialKg(npcId, ItemCatalog.FOOD_MATERIAL_ID);
            int wood = npcInventoryService.getMaterialKg(npcId, ItemCatalog.WOOD_MATERIAL_ID);
            int fuel = npcInventoryService.getMaterialKg(npcId, ItemCatalog.FUEL_MATERIAL_ID);
            boolean surviving = NpcTradeProposalMath.canSurviveToday(food, wood, fuel, need[0], need[1]);

            List<Line> surplus = listSellableSurplus(npcId, need[0], need[1]);
            if (surplus.isEmpty()) {
                return out;
            }

            List<Line> take;
            List<Line> give;
            String remark;
            if (!surviving) {
                List<Line> survivalTake = NpcTradeProposalMath.survivalTake(food, wood, fuel, need[0], need[1]);
                if (survivalTake.isEmpty()) {
                    return out;
                }
                AiDialogueService.TradeProposalPayload ai = aiDialogueService.generateTradeProposal(
                        npc.getName(), npc.getJob(), npc.getPersonality(), true,
                        inventoryBrief(npcId), surplusBrief(surplus), catalogBrief(),
                        Math.max(0, need[0] - food),
                        Math.max(0, need[1] - NpcSurvivalMath.currentHeat(wood, fuel)),
                        playerMessage, favor);
                take = mergeSurvivalAndOfferedTakes(survivalTake, ai, favor);
                give = clampGiveFromAi(ai, surplus, true, favor);
                if (give.isEmpty()) {
                    return out;
                }
                remark = NpcTradeProposalMath.sanitizeRemark(
                        ai == null ? null : ai.remark, NpcTradeProposalMath.FALLBACK_REMARK);
            } else {
                AiDialogueService.TradeProposalPayload ai = aiDialogueService.generateTradeProposal(
                        npc.getName(), npc.getJob(), npc.getPersonality(), false,
                        inventoryBrief(npcId), surplusBrief(surplus), catalogBrief(), 0, 0,
                        playerMessage, favor);
                if (ai == null || Boolean.FALSE.equals(ai.want)) {
                    return out;
                }
                give = clampGiveFromAi(ai, surplus, false, favor);
                take = clampOpportunisticTake(ai.take, favor);
                if (give.isEmpty() || take.isEmpty()) {
                    return out;
                }
                remark = NpcTradeProposalMath.sanitizeRemark(ai.remark, "拿这些换我要的东西。");
            }

            NpcTradeProposal row = new NpcTradeProposal();
            row.setNpcId(npcId);
            row.setPlayerId(playerId);
            row.setGameDay(day);
            row.setStatus(NpcTradeProposal.STATUS_OPEN);
            row.setGiveItems(toJson(toMaps(give)));
            row.setTakeItems(toJson(toMaps(take)));
            row.setRemark(remark);
            proposalRepository.save(row);

            out.put("tradeProposed", true);
            out.put("tradeId", row.getId());
            return out;
        } catch (Exception e) {
            logger.error("生成NPC交易提议失败: {}", e.getMessage(), e);
            return out;
        }
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getOpenProposalMap(Integer npcId, Integer playerId) {
        if (npcId == null || playerId == null) {
            return null;
        }
        int day = gameStateService.getCurrentDay();
        Optional<NpcTradeProposal> opt = proposalRepository.findFirstByNpcIdAndPlayerIdAndGameDayAndStatusOrderByIdDesc(
                npcId, playerId, day, NpcTradeProposal.STATUS_OPEN);
        if (!opt.isPresent()) {
            return null;
        }
        return toTabMap(opt.get());
    }

    @Transactional
    public Map<String, Object> accept(Integer playerId, Integer npcId) {
        Map<String, Object> result = new LinkedHashMap<>();
        try {
            NpcTradeProposal proposal = requireOpen(playerId, npcId, result);
            if (proposal == null) {
                return result;
            }
            if (!tradeRestrictionService.reasonsFor(playerId).isEmpty()) {
                result.put("success", false);
                result.put("message", "无法交易：你当前被禁止交易");
                return result;
            }
            Optional<LocationNpc> npcOpt = npcRepository.findById(npcId);
            if (!npcOpt.isPresent() || NpcSurvivalMath.isGone(npcOpt.get().getStatus())) {
                result.put("success", false);
                result.put("message", "对方无法交易");
                return result;
            }

            List<Line> take = parseLines(proposal.getTakeItems());
            List<Line> give = parseLines(proposal.getGiveItems());
            String missing = validatePlayerStock(playerId, take);
            if (missing != null) {
                result.put("success", false);
                result.put("message", missing);
                return result;
            }
            String npcShort = validateNpcGiveStock(npcId, give);
            if (npcShort != null) {
                result.put("success", false);
                result.put("message", npcShort);
                return result;
            }

            for (Line line : take) {
                if (!reducePlayerItem(playerId, line.itemType, line.itemId, line.quantity)) {
                    TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
                    result.put("success", false);
                    result.put("message", "缺少" + line.name + " " + line.quantity);
                    return result;
                }
                npcInventoryService.addItem(npcId, line.itemType, line.itemId, line.quantity);
            }
            for (Line line : give) {
                npcInventoryService.deductItem(npcId, line.itemType, line.itemId, line.quantity);
                addPlayerItem(playerId, line.itemType, line.itemId, line.quantity);
            }

            proposal.setStatus(NpcTradeProposal.STATUS_COMPLETED);
            proposalRepository.save(proposal);

            int favor = favorValue(npcId, playerId);
            int favorChange = NpcTradeService.calculateTradeFavorChange(favor);
            int newFavor = Math.max(-100, Math.min(100, favor + favorChange));
            updateFavor(npcId, playerId, newFavor);

            NpcTradeRecord record = new NpcTradeRecord();
            record.setNpcId(npcId);
            record.setPlayerId(playerId);
            record.setGameDay(proposal.getGameDay());
            record.setDemandItems(proposal.getTakeItems());
            record.setSupplyItems(proposal.getGiveItems());
            record.setFavorChange(favorChange);
            tradeRecordRepository.save(record);

            result.put("success", true);
            result.put("message", "交易成功");
            result.put("favorChange", favorChange);
            result.put("newFavor", newFavor);
            result.put("proposal", toTabMap(proposal));
            return result;
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            logger.error("接受NPC交易失败: {}", e.getMessage(), e);
            result.put("success", false);
            result.put("message", "交易失败: " + e.getMessage());
            return result;
        }
    }

    @Transactional
    public Map<String, Object> reject(Integer playerId, Integer npcId) {
        Map<String, Object> result = new LinkedHashMap<>();
        try {
            NpcTradeProposal proposal = requireOpen(playerId, npcId, result);
            if (proposal == null) {
                return result;
            }
            proposal.setStatus(NpcTradeProposal.STATUS_REJECTED);
            proposalRepository.save(proposal);
            result.put("success", true);
            result.put("message", "已拒绝这笔交换");
            result.put("favorChange", 0);
            return result;
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "拒绝失败: " + e.getMessage());
            return result;
        }
    }

    @Transactional
    public int expireOpenForDay(int gameDay) {
        List<NpcTradeProposal> open = proposalRepository.findByStatusAndGameDay(NpcTradeProposal.STATUS_OPEN, gameDay);
        int n = 0;
        for (NpcTradeProposal row : open) {
            row.setStatus(NpcTradeProposal.STATUS_EXPIRED);
            proposalRepository.save(row);
            n++;
        }
        return n;
    }

    public int reservedGiveQuantity(Integer npcId, ItemType itemType, Integer itemId) {
        if (npcId == null || itemType == null || itemId == null) {
            return 0;
        }
        int total = 0;
        for (NpcTradeProposal row : proposalRepository.findByNpcIdAndStatus(npcId, NpcTradeProposal.STATUS_OPEN)) {
            for (Line line : parseLines(row.getGiveItems())) {
                if (line.itemType == itemType && line.itemId == itemId) {
                    total += line.quantity;
                }
            }
        }
        return total;
    }

    public List<Map<String, Object>> surplusForFreeReward(Integer npcId, int requiredFood, int requiredHeat) {
        List<Map<String, Object>> out = new ArrayList<>();
        for (Line line : listSellableSurplus(npcId, requiredFood, requiredHeat)) {
            if (out.size() >= NpcTradeProposalMath.MAX_GIVE_LINES) {
                break;
            }
            int giftQty = isMedicalResourceGift(line) ? 10 : 1;
            Line one = new Line(line.itemType, line.itemId, giftQty, line.name);
            out.add(one.toMap());
        }
        return out;
    }

    private NpcTradeProposal requireOpen(Integer playerId, Integer npcId, Map<String, Object> result) {
        if (playerId == null || npcId == null) {
            result.put("success", false);
            result.put("message", "参数无效");
            return null;
        }
        int day = gameStateService.getCurrentDay();
        Optional<NpcTradeProposal> opt = proposalRepository.findFirstByNpcIdAndPlayerIdAndGameDayAndStatusOrderByIdDesc(
                npcId, playerId, day, NpcTradeProposal.STATUS_OPEN);
        if (!opt.isPresent()) {
            result.put("success", false);
            result.put("message", "没有待处理的交换");
            return null;
        }
        return opt.get();
    }

    private static boolean isMedicalResourceGift(Line line) {
        if (line == null || line.itemType != ItemType.item) {
            return false;
        }
        if (line.itemId == 1) {
            return true;
        }
        return "医疗资源".equals(line.name) || "医疗包".equals(line.name);
    }

    private List<Line> listSellableSurplus(Integer npcId, int requiredFood, int requiredHeat) {
        List<Line> surplus = new ArrayList<>();
        for (NpcItem row : npcItemRepository.findByNpcId(npcId)) {
            if (row.getItemType() == null || row.getItemId() == null) {
                continue;
            }
            if (!isTradable(row.getItemType(), row.getItemId())) {
                continue;
            }
            int sellable = npcInventoryService.sellableQuantity(npcId, row.getItemType(), row.getItemId(),
                    requiredFood, requiredHeat);
            if (sellable <= 0) {
                continue;
            }
            surplus.add(new Line(row.getItemType(), row.getItemId(), sellable,
                    NpcInventoryService.itemName(row.getItemType(), row.getItemId())));
        }
        return surplus;
    }

    private List<Line> clampGiveFromAi(AiDialogueService.TradeProposalPayload ai, List<Line> surplus,
                                      boolean allowFallback, int favor) {
        Map<String, Integer> sellable = new HashMap<>();
        Map<String, Line> byKey = new LinkedHashMap<>();
        for (Line line : surplus) {
            String key = key(line.itemType, line.itemId);
            sellable.put(key, line.quantity);
            byKey.put(key, line);
        }
        int lineCap = NpcTradeProposalMath.maxGiveLines(favor);
        List<Line> give = new ArrayList<>();
        if (ai != null && ai.give != null) {
            for (Map<String, Object> raw : ai.give) {
                Line parsed = parseAiLine(raw);
                if (parsed == null) {
                    continue;
                }
                Integer have = sellable.get(key(parsed.itemType, parsed.itemId));
                if (have == null) {
                    continue;
                }
                Line clamped = NpcTradeProposalMath.clampGiveAgainstSellable(parsed, have, favor);
                if (clamped == null) {
                    continue;
                }
                Line named = new Line(clamped.itemType, clamped.itemId, clamped.quantity,
                        NpcInventoryService.itemName(clamped.itemType, clamped.itemId));
                give.add(named);
                sellable.put(key(parsed.itemType, parsed.itemId), have - named.quantity);
                if (give.size() >= lineCap) {
                    break;
                }
            }
        }
        if (give.isEmpty() && allowFallback) {
            return NpcTradeProposalMath.deterministicGive(new ArrayList<>(byKey.values()), favor);
        }
        return give;
    }

    private List<Line> mergeSurvivalAndOfferedTakes(List<Line> survivalTake,
                                                   AiDialogueService.TradeProposalPayload ai, int favor) {
        List<Line> take = new ArrayList<>(survivalTake);
        Set<String> seen = new HashSet<>();
        for (Line line : survivalTake) {
            seen.add(key(line.itemType, line.itemId));
        }
        int extra = NpcTradeProposalMath.maxExtraTakeLines(favor);
        if (extra <= 0 || ai == null) {
            return take;
        }
        for (Line offered : clampOpportunisticTake(ai.take, favor)) {
            String k = key(offered.itemType, offered.itemId);
            if (!seen.add(k)) {
                continue;
            }
            take.add(offered);
            extra--;
            if (extra <= 0) {
                break;
            }
        }
        return take;
    }

    private List<Line> clampOpportunisticTake(List<Map<String, Object>> rawTake, int favor) {
        List<Line> take = new ArrayList<>();
        if (rawTake == null) {
            return take;
        }
        int cap = Math.max(1, NpcTradeProposalMath.maxExtraTakeLines(favor));
        Set<String> seen = new HashSet<>();
        for (Map<String, Object> raw : rawTake) {
            Line parsed = parseAiLine(raw);
            if (parsed == null || !isTradable(parsed.itemType, parsed.itemId) || !isKnownCatalogId(parsed.itemType, parsed.itemId)) {
                continue;
            }
            String k = key(parsed.itemType, parsed.itemId);
            if (!seen.add(k)) {
                continue;
            }
            Line clamped = NpcTradeProposalMath.clampOpportunisticTake(
                    parsed.itemType, parsed.itemId, parsed.quantity,
                    NpcInventoryService.itemName(parsed.itemType, parsed.itemId), true);
            if (clamped != null) {
                take.add(clamped);
            }
            if (take.size() >= cap) {
                break;
            }
        }
        return take;
    }

    private Line parseAiLine(Map<String, Object> raw) {
        if (raw == null) {
            return null;
        }
        Object tObj = raw.get("t");
        if (tObj == null) {
            tObj = raw.get("itemType");
        }
        Object idObj = raw.get("id");
        if (idObj == null) {
            idObj = raw.get("itemId");
        }
        Object qObj = raw.get("q");
        if (qObj == null) {
            qObj = raw.get("quantity");
        }
        if (tObj == null || idObj == null) {
            return null;
        }
        ItemType type;
        try {
            type = ItemType.valueOf(String.valueOf(tObj).trim().toLowerCase());
        } catch (Exception e) {
            return null;
        }
        int id = asInt(idObj, 0);
        int q = asInt(qObj, 1);
        if (id <= 0 || q <= 0) {
            return null;
        }
        return new Line(type, id, q, NpcInventoryService.itemName(type, id));
    }

    private String validatePlayerStock(Integer playerId, List<Line> take) {
        for (Line line : take) {
            int have = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(playerId, line.itemType, line.itemId)
                    .map(PlayerItem::getQuantity).orElse(0);
            if (have < line.quantity) {
                String unit = NpcTradeProposalMath.isSurvivalMaterial(line.itemType, line.itemId) ? "kg" : "";
                return "缺少" + line.name + " " + line.quantity + unit + "（当前 " + have + "）";
            }
        }
        return null;
    }

    private String validateNpcGiveStock(Integer npcId, List<Line> give) {
        for (Line line : give) {
            int have = npcInventoryService.getQuantity(npcId, line.itemType, line.itemId);
            if (have < line.quantity) {
                return "对方已经没有足够的" + line.name;
            }
        }
        return null;
    }

    private boolean reducePlayerItem(Integer playerId, ItemType itemType, Integer itemId, int quantity) {
        Optional<PlayerItem> existing = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(playerId, itemType, itemId);
        if (!existing.isPresent()) {
            return false;
        }
        PlayerItem row = existing.get();
        int have = row.getQuantity() == null ? 0 : row.getQuantity();
        if (have < quantity) {
            return false;
        }
        int left = have - quantity;
        if (left <= 0) {
            playerItemRepository.delete(row);
        } else {
            row.setQuantity(left);
            playerItemRepository.save(row);
        }
        return true;
    }

    private void addPlayerItem(Integer playerId, ItemType itemType, Integer itemId, int quantity) {
        Optional<PlayerItem> existing = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(playerId, itemType, itemId);
        if (existing.isPresent()) {
            PlayerItem row = existing.get();
            row.setQuantity((row.getQuantity() == null ? 0 : row.getQuantity()) + quantity);
            playerItemRepository.save(row);
        } else {
            PlayerItem row = new PlayerItem();
            row.setPlayerId(playerId);
            row.setItemType(itemType);
            row.setItemId(itemId);
            row.setQuantity(quantity);
            playerItemRepository.save(row);
        }
    }

    private Map<String, Object> toTabMap(NpcTradeProposal proposal) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("id", proposal.getId());
        map.put("npcId", proposal.getNpcId());
        map.put("playerId", proposal.getPlayerId());
        map.put("gameDay", proposal.getGameDay());
        map.put("status", proposal.getStatus());
        map.put("remark", proposal.getRemark());
        map.put("give", parseMaps(proposal.getGiveItems()));
        map.put("take", parseMaps(proposal.getTakeItems()));
        return map;
    }

    private List<Map<String, Object>> toMaps(List<Line> lines) {
        List<Map<String, Object>> out = new ArrayList<>();
        for (Line line : lines) {
            out.add(line.toMap());
        }
        return out;
    }

    private List<Line> parseLines(String json) {
        List<Line> out = new ArrayList<>();
        for (Map<String, Object> raw : parseMaps(json)) {
            Line line = parseAiLine(raw);
            if (line != null) {
                out.add(line);
            }
        }
        return out;
    }

    private List<Map<String, Object>> parseMaps(String json) {
        if (json == null || json.trim().isEmpty()) {
            return new ArrayList<>();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<List<Map<String, Object>>>() { });
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }

    private String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            return "[]";
        }
    }

    private int[] currentRequirements() {
        int day = gameStateService.getCurrentDay();
        com.example.snowisland.entity.GameDaySettings settings =
                playerConsumptionService.getOrCreateDaySettings(Math.max(1, day));
        int food = settings.getRequiredFoodUnits() != null
                ? settings.getRequiredFoodUnits() : PlayerConsumptionService.DEFAULT_FOOD_UNITS;
        int heat = settings.getRequiredFuelKg() != null
                ? settings.getRequiredFuelKg() : PlayerConsumptionService.DEFAULT_FUEL_KG;
        return new int[]{food, heat};
    }

    private int favorValue(Integer npcId, Integer playerId) {
        return npcFavorRepository.findByNpcIdAndPlayerId(npcId, playerId)
                .map(NpcFavor::getFavorValue)
                .orElse(0);
    }

    private void updateFavor(Integer npcId, Integer playerId, int value) {
        Optional<NpcFavor> existing = npcFavorRepository.findByNpcIdAndPlayerId(npcId, playerId);
        if (existing.isPresent()) {
            existing.get().setFavorValue(value);
            npcFavorRepository.save(existing.get());
        } else {
            NpcFavor favor = new NpcFavor();
            favor.setNpcId(npcId);
            favor.setPlayerId(playerId);
            favor.setFavorValue(value);
            npcFavorRepository.save(favor);
        }
    }

    private static boolean isKnownCatalogId(ItemType type, int itemId) {
        if (type == null || itemId <= 0) {
            return false;
        }
        switch (type) {
            case material:
                return itemId >= 1 && itemId <= 12;
            case item:
                return itemId >= 1 && itemId <= 18;
            case weapon:
                return itemId >= 1 && itemId <= 11;
            case ammo:
                return itemId >= 1 && itemId <= 4;
            default:
                return false;
        }
    }

    private boolean isTradable(ItemType type, int itemId) {
        if (type == ItemType.item && HARDCODED_NON_TRADABLE_ITEMS.contains(itemId)) {
            return false;
        }
        if (type != ItemType.item) {
            return true;
        }
        try {
            Number count = (Number) entityManager.createNativeQuery(
                    "SELECT COUNT(*) FROM item WHERE tradable = 0 AND id = :id")
                    .setParameter("id", itemId)
                    .getSingleResult();
            return count.intValue() == 0;
        } catch (Exception e) {
            return true;
        }
    }

    private String inventoryBrief(Integer npcId) {
        StringBuilder sb = new StringBuilder();
        for (NpcItem row : npcItemRepository.findByNpcId(npcId)) {
            if (sb.length() > 0) {
                sb.append(',');
            }
            sb.append(row.getItemType() == null ? "item" : row.getItemType().name())
                    .append(':').append(row.getItemId())
                    .append('x').append(row.getQuantity());
        }
        return sb.toString();
    }

    private String surplusBrief(List<Line> surplus) {
        StringBuilder sb = new StringBuilder();
        for (Line line : surplus) {
            if (sb.length() > 0) {
                sb.append(',');
            }
            sb.append(line.itemType.name()).append(':').append(line.itemId)
                    .append('x').append(line.quantity).append(line.name);
        }
        return sb.toString();
    }

    private String catalogBrief() {
        StringBuilder sb = new StringBuilder();
        appendCatalog(sb, ItemType.material, 1, 13);
        appendCatalog(sb, ItemType.item, 1, 18);
        appendCatalog(sb, ItemType.weapon, 1, 11);
        appendCatalog(sb, ItemType.ammo, 1, 4);
        return sb.toString();
    }

    private void appendCatalog(StringBuilder sb, ItemType type, int from, int to) {
        for (int id = from; id <= to; id++) {
            if (type == ItemType.item && HARDCODED_NON_TRADABLE_ITEMS.contains(id)) {
                continue;
            }
            if (sb.length() > 0) {
                sb.append(',');
            }
            sb.append(type.name()).append(':').append(id)
                    .append(NpcInventoryService.itemName(type, id));
        }
    }

    private static String key(ItemType type, int id) {
        return type.name() + ":" + id;
    }

    private static int asInt(Object value, int fallback) {
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        if (value == null) {
            return fallback;
        }
        try {
            return Integer.parseInt(String.valueOf(value).trim());
        } catch (NumberFormatException e) {
            return fallback;
        }
    }
}
