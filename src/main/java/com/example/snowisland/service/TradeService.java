package com.example.snowisland.service;

import com.example.snowisland.entity.TradeItem.ItemType;
import com.example.snowisland.entity.Player;
import com.example.snowisland.entity.PlayerItem;
import com.example.snowisland.entity.Trade;
import com.example.snowisland.entity.TradeItem;
import com.example.snowisland.repository.PlayerRepository;
import com.example.snowisland.repository.PlayerItemRepository;
import com.example.snowisland.repository.TradeItemRepository;
import com.example.snowisland.repository.TradeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import javax.annotation.PostConstruct;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.util.*;

@Service
public class TradeService {
    @Autowired
    private TradeRepository tradeRepository;

    @Autowired
    private TradeItemRepository tradeItemRepository;

    @Autowired
    private PlayerItemRepository playerItemRepository;

    @Autowired
    private PlayerRepository playerRepository;

    @Autowired
    private ActivityLogService activityLogService;

    @Autowired
    private GameStateService gameStateService;

    @Autowired
    private TradeRestrictionService tradeRestrictionService;

    @PersistenceContext
    private EntityManager entityManager;

    private Map<String, Map<Integer, String>> itemNames = new HashMap<>();
    private Map<String, Map<Integer, String>> itemUnits = new HashMap<>();

    @PostConstruct
    public void initItemData() {
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
        itemNames.get("material").put(13, "草木灰");

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
        itemUnits.get("material").put(13, "kg");
    }

    private String validateNonTradableItems(List<Map<String, Object>> items) {
        if (items == null || items.isEmpty()) {
            return null;
        }
        Set<Integer> itemIds = new HashSet<>();
        for (Map<String, Object> item : items) {
            if (item == null) {
                continue;
            }
            if (!"item".equals(String.valueOf(item.get("itemType")))) {
                continue;
            }
            Object itemIdObj = item.get("itemId");
            if (itemIdObj instanceof Number) {
                itemIds.add(((Number) itemIdObj).intValue());
            }
        }
        if (itemIds.isEmpty()) {
            return null;
        }
        @SuppressWarnings("unchecked")
        List<String> names = entityManager.createNativeQuery(
                "SELECT name FROM item WHERE tradable = 0 AND id IN (:ids)")
                .setParameter("ids", itemIds)
                .getResultList();
        if (names == null || names.isEmpty()) {
            return null;
        }
        StringBuilder sb = new StringBuilder();
        for (String name : names) {
            sb.append("「").append(name).append("」");
        }
        sb.append("为不可交易道具，无法交易");
        return sb.toString();
    }

    private String getItemName(String itemType, Integer itemId) {
        String type = itemType != null ? itemType.toLowerCase() : "item";
        int id = itemId != null ? itemId : 0;
        return itemNames.getOrDefault(type, Collections.emptyMap()).getOrDefault(id, "未知物品");
    }

    private String getItemUnit(String itemType, Integer itemId) {
        String type = itemType != null ? itemType.toLowerCase() : "item";
        int id = itemId != null ? itemId : 0;
        return itemUnits.getOrDefault(type, Collections.emptyMap()).getOrDefault(id, "个");
    }

    public List<Trade> getTradesByPlayerId(Integer playerId) {
        List<Trade> trades = tradeRepository.findByFromPlayerIdOrToPlayerId(playerId, playerId);
        populateItemInfo(trades);
        return trades;
    }

    public List<Trade> getIncomingTrades(Integer playerId) {
        List<Trade> trades = tradeRepository.findByToPlayerId(playerId);
        populateItemInfo(trades);
        return trades;
    }

    public long countIncomingPendingTrades(Integer playerId) {
        return tradeRepository.countByToPlayerIdAndStatus(playerId, Trade.TradeStatus.pending);
    }

    public Map<String, Object> getDmPendingAndCompletedTrades() {
        Map<String, Object> out = new LinkedHashMap<>();
        try {
            List<Trade> trades = tradeRepository.findByStatusesWithItemsOrderByCreatedAtDesc(
                    Arrays.asList(Trade.TradeStatus.pending, Trade.TradeStatus.completed));
            populateItemInfo(trades);
            List<Map<String, Object>> list = new ArrayList<>();
            for (Trade t : trades) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", t.getId());
                row.put("fromPlayerId", t.getFromPlayerId());
                row.put("toPlayerId", t.getToPlayerId());
                row.put("fromPlayerName", resolvePlayerNameForDm(t.getFromPlayerId()));
                row.put("toPlayerName", resolvePlayerNameForDm(t.getToPlayerId()));
                row.put("status", t.getStatus().name());
                row.put("remark", t.getRemark());
                row.put("createdAt", t.getCreatedAt());
                row.put("updatedAt", t.getUpdatedAt());
                List<Map<String, Object>> itemRows = new ArrayList<>();
                if (t.getItems() != null) {
                    for (TradeItem it : t.getItems()) {
                        Map<String, Object> im = new LinkedHashMap<>();
                        im.put("name", it.getName());
                        im.put("unit", it.getUnit());
                        im.put("quantity", it.getQuantity());
                        im.put("direction", it.getDirection() != null ? it.getDirection().name() : null);
                        im.put("itemType", it.getItemType() != null ? it.getItemType().name() : null);
                        im.put("itemId", it.getItemId());
                        itemRows.add(im);
                    }
                }
                row.put("items", itemRows);
                list.add(row);
            }
            out.put("success", true);
            out.put("trades", list);
        } catch (Exception e) {
            out.put("success", false);
            out.put("message", "加载交易列表失败: " + e.getMessage());
        }
        return out;
    }

    private String resolvePlayerNameForDm(Integer playerId) {
        if (playerId == null) {
            return "?";
        }
        return playerRepository.findById(playerId).map(Player::getName).orElse("玩家" + playerId);
    }

    private void populateItemInfo(List<Trade> trades) {
        for (Trade trade : trades) {
            List<TradeItem> items = trade.getItems();
            if (items != null) {
                for (TradeItem item : items) {
                    fillTradeItemDisplay(item);
                }
            }
        }
    }

    private void fillTradeItemDisplay(TradeItem item) {
        if (item.getItemType() == null) {
            item.setItemType(ItemType.item);
        }
        int id = item.getItemId() != null ? item.getItemId() : 0;
        String typeKey = item.getItemType().name();
        item.setName(getItemName(typeKey, id));
        item.setUnit(getItemUnit(typeKey, id));
    }

    public Map<String, Object> getTradeDetail(Integer id) {
        Map<String, Object> result = new HashMap<>();
        try {
            Optional<Trade> tradeOpt = tradeRepository.findById(id);
            if (!tradeOpt.isPresent()) {
                result.put("success", false);
                result.put("message", "交易不存在");
                return result;
            }
            Trade trade = tradeOpt.get();
            List<TradeItem> items = tradeItemRepository.findByTradeId(id);
            for (TradeItem item : items) {
                fillTradeItemDisplay(item);
            }
            result.put("success", true);
            result.put("trade", trade);
            result.put("items", items);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "获取交易详情失败: " + e.getMessage());
        }
        return result;
    }

    @Transactional
    public Map<String, Object> createTrade(Trade trade, List<Map<String, Object>> items) {
        Map<String, Object> result = new HashMap<>();
        try {
            String banError = tradeRestrictionService.rejectIfBanned(trade.getFromPlayerId(), trade.getToPlayerId());
            if (banError != null) {
                result.put("success", false);
                result.put("message", banError);
                return result;
            }
            String tradableError = validateNonTradableItems(items);
            if (tradableError != null) {
                result.put("success", false);
                result.put("message", tradableError);
                return result;
            }
            Map<String, Object> reserveResult = reserveOfferedItems(trade.getFromPlayerId(), items);
            if (!(Boolean) reserveResult.getOrDefault("success", false)) {
                result.put("success", false);
                result.put("message", reserveResult.getOrDefault("message", "库存不足，无法发起交易"));
                return result;
            }
            trade.setStatus(Trade.TradeStatus.pending);
            Trade savedTrade = tradeRepository.save(trade);
            for (Map<String, Object> item : items) {
                TradeItem tradeItem = new TradeItem();
                tradeItem.setTradeId(savedTrade.getId());
                tradeItem.setItemType(ItemType.valueOf(String.valueOf(item.get("itemType"))));
                Object itemIdObj = item.get("itemId");
                tradeItem.setItemId(itemIdObj instanceof Number ? ((Number) itemIdObj).intValue() : 0);
                Object qtyObj = item.get("quantity");
                tradeItem.setQuantity(qtyObj instanceof Number ? ((Number) qtyObj).intValue() : 1);
                tradeItem.setDirection(TradeItem.Direction.valueOf((String) item.get("direction")));
                tradeItemRepository.save(tradeItem);
            }
            result.put("success", true);
            result.put("trade", savedTrade);
            logTrade("发起交易", savedTrade.getFromPlayerId(), savedTrade.getToPlayerId(), savedTrade.getId(), items);
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "创建交易失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    @Transactional
    public Map<String, Object> acceptTrade(Integer id, Integer playerId) {
        Map<String, Object> result = new HashMap<>();
        try {
            Optional<Trade> tradeOpt = tradeRepository.findById(id);
            if (!tradeOpt.isPresent()) {
                result.put("success", false);
                result.put("message", "交易不存在");
                return result;
            }
            Trade trade = tradeOpt.get();
            if (!trade.getToPlayerId().equals(playerId)) {
                result.put("success", false);
                result.put("message", "无权操作此交易");
                return result;
            }
            if (trade.getStatus() != Trade.TradeStatus.pending) {
                result.put("success", false);
                result.put("message", "交易状态不是待处理");
                return result;
            }
            String banError = tradeRestrictionService.rejectIfBanned(trade.getFromPlayerId(), trade.getToPlayerId());
            if (banError != null) {
                result.put("success", false);
                result.put("message", banError);
                return result;
            }
            List<TradeItem> tradeItems = tradeItemRepository.findByTradeId(id);
            String validationError = validateTradeStock(trade, tradeItems);
            if (validationError != null) {
                result.put("success", false);
                result.put("message", validationError);
                return result;
            }
            String transferMessage = executeItemTransfer(trade, tradeItems);
            trade.setStatus(Trade.TradeStatus.completed);
            tradeRepository.save(trade);
            result.put("success", true);
            result.put("message", "交易成功！" + transferMessage);
            result.put("trade", trade);
            logTrade("接受交易", playerId, trade.getFromPlayerId(), trade.getId(), null);
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "确认交易失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    private String validateTradeStock(Trade trade, List<TradeItem> tradeItems) {
        Integer fromPlayerId = trade.getFromPlayerId();
        Integer toPlayerId = trade.getToPlayerId();
        for (TradeItem item : tradeItems) {
            fillTradeItemDisplay(item);
            if (item.getDirection() == TradeItem.Direction.give) {
                int stock = getStockQuantity(fromPlayerId, item.getItemType().name(), item.getItemId());
                if (stock < item.getQuantity()) {
                    return "发起者 " + getItemName(item.getItemType().name(), item.getItemId()) + " 库存不足";
                }
            } else if (item.getDirection() == TradeItem.Direction.take) {
                int stock = getStockQuantity(toPlayerId, item.getItemType().name(), item.getItemId());
                if (stock < item.getQuantity()) {
                    return "接收者 " + getItemName(item.getItemType().name(), item.getItemId()) + " 库存不足";
                }
            }
        }
        return null;
    }

    private String executeItemTransfer(Trade trade, List<TradeItem> tradeItems) {
        StringBuilder sb = new StringBuilder();
        int successCount = 0;
        for (TradeItem item : tradeItems) {
            fillTradeItemDisplay(item);
            Integer fromPlayerId = trade.getFromPlayerId();
            Integer toPlayerId = trade.getToPlayerId();
            if (item.getDirection() == TradeItem.Direction.give) {
                int affected = transferStock(fromPlayerId, toPlayerId, item);
                if (affected > 0) successCount++;
            } else if (item.getDirection() == TradeItem.Direction.take) {
                int affected = transferStock(toPlayerId, fromPlayerId, item);
                if (affected > 0) successCount++;
            }
        }
        sb.append("成功完成 ").append(successCount).append(" 项物资转移。");
        return sb.toString();
    }

    private int transferStock(Integer fromPlayerId, Integer toPlayerId, TradeItem item) {
        int reduced = reduceStock(fromPlayerId, item);
        if (reduced <= 0) return 0;
        return addStockByType(toPlayerId, item);
    }

    private int addStockByType(Integer playerId, TradeItem item) {
        ItemType type = item.getItemType() != null ? item.getItemType() : ItemType.item;
        int itemId = item.getItemId() != null ? item.getItemId() : 0;
        int qty = item.getQuantity() != null ? item.getQuantity() : 0;
        if (qty <= 0) {
            return 0;
        }
        return addPlayerItem(playerId, type, itemId, qty);
    }

    private int reduceStock(Integer playerId, TradeItem item) {
        ItemType type = item.getItemType() != null ? item.getItemType() : ItemType.item;
        int itemId = item.getItemId() != null ? item.getItemId() : 0;
        int qty = item.getQuantity() != null ? item.getQuantity() : 0;
        if (qty <= 0) {
            return 0;
        }
        return reducePlayerItem(playerId, type, itemId, qty);
    }

    private Map<String, Object> reserveOfferedItems(Integer fromPlayerId, List<Map<String, Object>> items) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> giveItems = new ArrayList<>();
        for (Map<String, Object> item : items) {
            String direction = String.valueOf(item.get("direction"));
            if ("give".equals(direction)) {
                giveItems.add(item);
            }
        }
        for (Map<String, Object> item : giveItems) {
            String itemType = String.valueOf(item.get("itemType"));
            int qty = ((Number) item.get("quantity")).intValue();
            if (qty <= 0) {
                result.put("success", false);
                result.put("message", "交易数量必须大于 0");
                return result;
            }
            int itemId = item.get("itemId") != null ? ((Number) item.get("itemId")).intValue() : 0;
            int stock = getStockQuantity(fromPlayerId, itemType, itemId);
            if (stock < qty) {
                result.put("success", false);
                result.put("message", getItemName(itemType, itemId) + " 库存不足");
                return result;
            }
        }
        result.put("success", true);
        return result;
    }

    private int getStockQuantity(Integer playerId, String itemType, int itemId) {
        return playerItemRepository.findByPlayerIdAndItemTypeAndItemId(
                        playerId, ItemType.valueOf(itemType), itemId)
                .map(PlayerItem::getQuantity)
                .orElse(0);
    }

    private int reducePlayerItem(Integer playerId, ItemType itemType, Integer itemId, Integer quantity) {
        Optional<PlayerItem> existingOpt = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(
                playerId, itemType, itemId);
        if (existingOpt.isPresent()) {
            PlayerItem item = existingOpt.get();
            int currentQty = item.getQuantity();
            if (currentQty < quantity) {
                return 0;
            }
            item.setQuantity(currentQty - quantity);
            playerItemRepository.save(item);
            return 1;
        }
        return 0;
    }

    private int addPlayerItem(Integer playerId, ItemType itemType, Integer itemId, Integer quantity) {
        Optional<PlayerItem> existingOpt = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(
            playerId, itemType, itemId);
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

    @Transactional
    public Map<String, Object> rejectTrade(Integer id, Integer playerId) {
        Map<String, Object> result = new HashMap<>();
        try {
            Optional<Trade> tradeOpt = tradeRepository.findById(id);
            if (!tradeOpt.isPresent()) {
                result.put("success", false);
                result.put("message", "交易不存在");
                return result;
            }
            Trade trade = tradeOpt.get();
            if (!trade.getToPlayerId().equals(playerId)) {
                result.put("success", false);
                result.put("message", "无权操作此交易");
                return result;
            }
            if (trade.getStatus() != Trade.TradeStatus.pending) {
                result.put("success", false);
                result.put("message", "该交易不是待处理状态");
                return result;
            }
            trade.setStatus(Trade.TradeStatus.rejected);
            tradeRepository.save(trade);
            result.put("success", true);
            result.put("message", "交易已拒绝");
            result.put("trade", trade);
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "拒绝交易失败: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    private void logTrade(String verb, Integer actorPlayerId, Integer otherPlayerId, Integer tradeId,
                          List<Map<String, Object>> items) {
        Player actor = playerRepository.findById(actorPlayerId).orElse(null);
        String actorName = actor != null ? actor.getName() : ("#" + actorPlayerId);
        Player other = otherPlayerId != null ? playerRepository.findById(otherPlayerId).orElse(null) : null;
        String otherName = other != null ? other.getName() : ("#" + otherPlayerId);
        int day = gameStateService.getCurrentDay();
        String summary = verb + "→" + otherName + " #" + tradeId;
        StringBuilder detail = new StringBuilder("对方:").append(otherName);
        if (items != null) {
            for (Map<String, Object> item : items) {
                if (item == null) continue;
                String type = String.valueOf(item.get("itemType"));
                int id = item.get("itemId") instanceof Number ? ((Number) item.get("itemId")).intValue() : 0;
                int qty = item.get("quantity") instanceof Number ? ((Number) item.get("quantity")).intValue() : 0;
                String dir = item.get("direction") != null ? String.valueOf(item.get("direction")) : "";
                detail.append(" | ").append(dir).append(" ")
                        .append(getItemName(type, id)).append("×").append(qty);
            }
        }
        String actorFaction = actor != null && actor.getFaction() != null ? actor.getFaction().name() : null;
        activityLogService.log(day, actorPlayerId, actorName, actorFaction, ActivityLogService.CAT_TRADE, summary,
                ActivityLogService.truncate(detail.toString(), 400));
    }
}
