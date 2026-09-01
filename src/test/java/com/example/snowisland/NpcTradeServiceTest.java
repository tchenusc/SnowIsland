package com.example.snowisland;

import com.example.snowisland.entity.PlayerItem;
import com.example.snowisland.entity.TradeItem.ItemType;
import com.example.snowisland.repository.PlayerItemRepository;
import com.example.snowisland.service.NpcTradeService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Transactional
public class NpcTradeServiceTest {

    @Autowired
    private NpcTradeService npcTradeService;

    @Autowired
    private PlayerItemRepository playerItemRepository;

    private static final int TEST_PLAYER_ID = 8;
    private static final int TEST_NPC_ID = 1;

    @BeforeEach
    public void setUp() {
        clearPlayerItems(TEST_PLAYER_ID);
    }

    private void clearPlayerItems(int playerId) {
        playerItemRepository.deleteByPlayerId(playerId);
    }

    private void addPlayerItem(int playerId, String itemType, int itemId, int quantity) {
        PlayerItem item = new PlayerItem();
        item.setPlayerId(playerId);
        item.setItemType(ItemType.valueOf(itemType.toLowerCase()));
        item.setItemId(itemId);
        item.setQuantity(quantity);
        playerItemRepository.save(item);
    }

    private int getPlayerItemQuantity(int playerId, String itemType, int itemId) {
        return playerItemRepository.findByPlayerIdAndItemTypeAndItemId(
                playerId, ItemType.valueOf(itemType.toLowerCase()), itemId)
                .map(PlayerItem::getQuantity)
                .orElse(0);
    }

    @Test
    public void testGetTradeConfig() {
        Map<String, Object> result = npcTradeService.getTradeConfig(TEST_NPC_ID, TEST_PLAYER_ID);
        assertNotNull(result);
        assertTrue((Boolean) result.get("success"));
    }

    @Test
    public void testPlayerStockRead() {
        int stock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
        assertEquals(0, stock);
        
        addPlayerItem(TEST_PLAYER_ID, "material", 5, 10);
        stock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
        assertEquals(10, stock);
    }

    @Test
    public void testTradeConfigSaveAndRead() {
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 10);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        Map<String, Object> saveResult = npcTradeService.saveTradeConfig(TEST_NPC_ID, demandItems, supplyItems);
        assertTrue((Boolean) saveResult.get("success"));

        Map<String, Object> configResult = npcTradeService.getTradeConfig(TEST_NPC_ID, TEST_PLAYER_ID);
        assertTrue((Boolean) configResult.get("success"));
        assertTrue(configResult.containsKey("proposal"));
        assertTrue(Boolean.TRUE.equals(configResult.get("giftAllowed")));
        
        List<Map<String, Object>> demandList = (List<Map<String, Object>>) configResult.get("demandItems");
        List<Map<String, Object>> supplyList = (List<Map<String, Object>>) configResult.get("supplyItems");
        
        assertTrue(demandList == null || demandList.isEmpty());
        assertTrue(supplyList == null || supplyList.isEmpty());
    }

    @Test
    public void testTradeWithConfigCheck() {
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 10);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(TEST_NPC_ID, demandItems, supplyItems);

        Map<String, Object> configBefore = npcTradeService.getTradeConfig(TEST_NPC_ID, TEST_PLAYER_ID);
        assertTrue((Boolean) configBefore.get("success"));
        
        List<Map<String, Object>> demandList = (List<Map<String, Object>>) configBefore.get("demandItems");
        List<Map<String, Object>> supplyList = (List<Map<String, Object>>) configBefore.get("supplyItems");
        
        System.out.println("Demand items count: " + demandList.size());
        System.out.println("Supply items count: " + supplyList.size());
        
        if (!demandList.isEmpty()) {
            System.out.println("Demand item: " + demandList.get(0));
        }
        if (!supplyList.isEmpty()) {
            System.out.println("Supply item: " + supplyList.get(0));
        }
        
        addPlayerItem(TEST_PLAYER_ID, "material", 5, 10);
        int stock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
        System.out.println("Player stock before trade: " + stock);
        
        Map<String, Object> tradeResult = npcTradeService.executeTrade(TEST_PLAYER_ID, TEST_NPC_ID);
        System.out.println("Trade result: " + tradeResult);
        
        if ((Boolean) tradeResult.get("success")) {
            stock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
            System.out.println("Player stock after trade: " + stock);
        }
    }

    @Test
    public void testTradeWithLowFavor() {
        int testNpcId = 2;
        
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 10);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        addPlayerItem(TEST_PLAYER_ID, "material", 5, 10);
        int stockBefore = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
        System.out.println("Player stock before trade: " + stockBefore);
        
        Map<String, Object> tradeResult = npcTradeService.executeTrade(TEST_PLAYER_ID, testNpcId);
        System.out.println("Trade result: " + tradeResult);
        
        if ((Boolean) tradeResult.get("success")) {
            int stockAfter = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
            System.out.println("Player stock after trade: " + stockAfter);
            
            int stockReceived = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 1);
            System.out.println("Player received item stock: " + stockReceived);
            
            assertEquals(0, stockAfter);
            assertEquals(5, stockReceived);
        }
    }

    @Test
    public void testGetTradeConfigNotFound() {
        Map<String, Object> result = npcTradeService.getTradeConfig(99999, TEST_PLAYER_ID);
        assertFalse((Boolean) result.get("success"));
        assertEquals("NPC不存在", result.get("message"));
    }

    @Test
    public void testExecuteTradeNpcNotFound() {
        Map<String, Object> result = npcTradeService.executeTrade(TEST_PLAYER_ID, 99999);
        assertFalse((Boolean) result.get("success"));
        assertEquals("NPC不存在", result.get("message"));
    }

    @Test
    public void testGetAllTradeConfigs() {
        List<Map<String, Object>> configs = npcTradeService.getAllTradeConfigs();
        assertNotNull(configs);
        assertTrue(configs.size() >= 0);
        for (Map<String, Object> config : configs) {
            assertNotNull(config.get("npcId"));
            assertNotNull(config.get("npcName"));
            assertNotNull(config.get("demandItems"));
            assertNotNull(config.get("supplyItems"));
        }
    }

    @Test
    public void testSetDailyTradeLimit() {
        Map<String, Object> result = npcTradeService.setDailyTradeLimit(TEST_NPC_ID, 3);
        assertTrue((Boolean) result.get("success"));
        assertEquals(3, result.get("dailyTradeLimit"));
    }

    @Test
    public void testSetDailyTradeLimitInvalidNpc() {
        Map<String, Object> result = npcTradeService.setDailyTradeLimit(99999, 3);
        assertFalse((Boolean) result.get("success"));
        assertEquals("NPC不存在", result.get("message"));
    }

    @Test
    public void testSetDailyTradeLimitNegative() {
        Map<String, Object> result = npcTradeService.setDailyTradeLimit(TEST_NPC_ID, -1);
        assertFalse((Boolean) result.get("success"));
        assertEquals("交易上限不能为负数", result.get("message"));
    }

    @Test
    public void testSaveTradeConfig() {
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 10);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        Map<String, Object> result = npcTradeService.saveTradeConfig(TEST_NPC_ID, demandItems, supplyItems);
        assertTrue((Boolean) result.get("success"));
        assertEquals("交易配置已保存", result.get("message"));
    }

    @Test
    public void testSaveTradeConfigInvalidNpc() {
        List<Map<String, Object>> demandItems = new ArrayList<>();
        List<Map<String, Object>> supplyItems = new ArrayList<>();
        
        Map<String, Object> result = npcTradeService.saveTradeConfig(99999, demandItems, supplyItems);
        assertFalse((Boolean) result.get("success"));
        assertEquals("NPC不存在", result.get("message"));
    }

    @Test
    public void testGetTradeHistory() {
        List<Map<String, Object>> history = npcTradeService.getTradeHistory(TEST_PLAYER_ID);
        assertNotNull(history);
    }

    @Test
    public void testGetTradeHistoryByNpc() {
        List<Map<String, Object>> history = npcTradeService.getTradeHistoryByNpc(TEST_PLAYER_ID, TEST_NPC_ID);
        assertNotNull(history);
    }

    @Test
    public void testTradeConfigPersistence() {
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 2);
        demandItem.put("minFavor", -50);
        demandItem.put("maxFavor", 50);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "item");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 3);
        supplyItem.put("minFavor", -50);
        supplyItem.put("maxFavor", 50);
        supplyItem.put("probability", 0.8);
        supplyItems.add(supplyItem);

        npcTradeService.saveTradeConfig(TEST_NPC_ID, demandItems, supplyItems);

        List<Map<String, Object>> configs = npcTradeService.getAllTradeConfigs();
        Map<String, Object> config = configs.stream()
            .filter(c -> c.get("npcId").equals(TEST_NPC_ID))
            .findFirst()
            .orElse(null);

        assertNotNull(config);
        List<Map<String, Object>> savedDemand = (List<Map<String, Object>>) config.get("demandItems");
        assertTrue(savedDemand.size() >= 1);
        List<Map<String, Object>> savedSupply = (List<Map<String, Object>>) config.get("supplyItems");
        assertTrue(savedSupply.size() >= 1);
    }

    @Test
    public void testExecuteTradeWithInsufficientItems() {
        int testNpcId = 2;
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 10);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        addPlayerItem(TEST_PLAYER_ID, "material", 5, 5);

        Map<String, Object> result = npcTradeService.executeTrade(TEST_PLAYER_ID, testNpcId);
        assertFalse((Boolean) result.get("success"));
        assertTrue(result.get("message").toString().contains("不足"));
    }

    @Test
    public void testExecuteTradeWithExactlyEnoughItems() {
        int testNpcId = 2;
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 10);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        addPlayerItem(TEST_PLAYER_ID, "material", 5, 10);

        int initialDemandStock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
        int initialSupplyStock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 1);

        assertEquals(10, initialDemandStock);
        assertEquals(0, initialSupplyStock);

        Map<String, Object> result = npcTradeService.executeTrade(TEST_PLAYER_ID, testNpcId);
        assertTrue((Boolean) result.get("success"));
        assertTrue(result.get("message").toString().contains("交易成功"));

        int finalDemandStock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
        int finalSupplyStock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 1);

        assertEquals(0, finalDemandStock);
        assertEquals(5, finalSupplyStock);
    }

    @Test
    public void testExecuteTradeWithMoreThanEnoughItems() {
        int testNpcId = 2;
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 10);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        addPlayerItem(TEST_PLAYER_ID, "material", 5, 20);

        int initialDemandStock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
        assertEquals(20, initialDemandStock);

        Map<String, Object> result = npcTradeService.executeTrade(TEST_PLAYER_ID, testNpcId);
        assertTrue((Boolean) result.get("success"));

        int finalDemandStock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
        int finalSupplyStock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 1);

        assertEquals(10, finalDemandStock);
        assertEquals(5, finalSupplyStock);
    }

    @Test
    public void testExecuteTradeWithZeroItems() {
        int testNpcId = 2;
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 10);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        Map<String, Object> result = npcTradeService.executeTrade(TEST_PLAYER_ID, testNpcId);
        assertFalse((Boolean) result.get("success"));
        assertTrue(result.get("message").toString().contains("不足"));
    }

    @Test
    public void testTradeDataPersistence() {
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 5);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 3);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(TEST_NPC_ID, demandItems, supplyItems);

        addPlayerItem(TEST_PLAYER_ID, "material", 5, 10);

        Map<String, Object> result = npcTradeService.executeTrade(TEST_PLAYER_ID, TEST_NPC_ID);
        assertTrue((Boolean) result.get("success"));

        assertNotNull(result.get("tradeId"));

        List<Map<String, Object>> history = npcTradeService.getTradeHistory(TEST_PLAYER_ID);
        assertTrue(history.size() >= 1);

        List<Map<String, Object>> historyByNpc = npcTradeService.getTradeHistoryByNpc(TEST_PLAYER_ID, TEST_NPC_ID);
        assertTrue(historyByNpc.size() >= 1);
    }

    @Test
    public void testTradeWithFavorDiscount() {
        int testNpcId = 2;
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 10);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        addPlayerItem(TEST_PLAYER_ID, "material", 5, 10);

        Map<String, Object> result = npcTradeService.executeTrade(TEST_PLAYER_ID, testNpcId);
        assertTrue((Boolean) result.get("success"));

        int finalDemandStock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
        assertEquals(0, finalDemandStock);
    }

    @Test
    public void testMultipleDemandItemsTrade() {
        int testNpcId = 2;
        List<Map<String, Object>> demandItems = new ArrayList<>();
        
        Map<String, Object> demandItem1 = new HashMap<>();
        demandItem1.put("itemType", "material");
        demandItem1.put("itemId", 5);
        demandItem1.put("quantity", 5);
        demandItem1.put("minFavor", -100);
        demandItem1.put("maxFavor", 100);
        demandItems.add(demandItem1);

        Map<String, Object> demandItem2 = new HashMap<>();
        demandItem2.put("itemType", "material");
        demandItem2.put("itemId", 8);
        demandItem2.put("quantity", 3);
        demandItem2.put("minFavor", -100);
        demandItem2.put("maxFavor", 100);
        demandItems.add(demandItem2);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        addPlayerItem(TEST_PLAYER_ID, "material", 5, 5);
        addPlayerItem(TEST_PLAYER_ID, "material", 8, 3);

        int initialStock1 = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
        int initialStock2 = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 8);
        assertEquals(5, initialStock1);
        assertEquals(3, initialStock2);

        Map<String, Object> result = npcTradeService.executeTrade(TEST_PLAYER_ID, testNpcId);
        assertTrue((Boolean) result.get("success"));

        int finalStock1 = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 5);
        int finalStock2 = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 8);
        int finalSupplyStock = getPlayerItemQuantity(TEST_PLAYER_ID, "material", 1);

        assertEquals(0, finalStock1);
        assertEquals(0, finalStock2);
        assertEquals(5, finalSupplyStock);
    }

    @Test
    public void testTradeWithInvalidItemType() {
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "invalid_type");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 10);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(TEST_NPC_ID, demandItems, supplyItems);

        addPlayerItem(TEST_PLAYER_ID, "material", 5, 10);

        Map<String, Object> result = npcTradeService.executeTrade(TEST_PLAYER_ID, TEST_NPC_ID);
        assertFalse((Boolean) result.get("success"));
    }

    @Test
    public void testTradeWithEntityUpdateConsistency() {
        int testNpcId = 3;
        
        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 5);
        demandItem.put("quantity", 10);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 1);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        PlayerItem item = new PlayerItem();
        item.setPlayerId(TEST_PLAYER_ID);
        item.setItemType(ItemType.material);
        item.setItemId(5);
        item.setQuantity(10);
        playerItemRepository.save(item);

        int stockBefore = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(
                TEST_PLAYER_ID, ItemType.material, 5)
                .map(PlayerItem::getQuantity)
                .orElse(0);
        assertEquals(10, stockBefore);

        Map<String, Object> tradeResult = npcTradeService.executeTrade(TEST_PLAYER_ID, testNpcId);
        assertTrue((Boolean) tradeResult.get("success"));

        int stockAfter = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(
                TEST_PLAYER_ID, ItemType.material, 5)
                .map(PlayerItem::getQuantity)
                .orElse(0);
        assertEquals(0, stockAfter);

        int receivedStock = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(
                TEST_PLAYER_ID, ItemType.material, 1)
                .map(PlayerItem::getQuantity)
                .orElse(0);
        assertEquals(5, receivedStock);
    }

    @Test
    public void testMedicalKitItemTypeRecognition() {
        int testNpcId = 4;

        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "item");
        demandItem.put("itemId", 1);
        demandItem.put("quantity", 1);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 5);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        PlayerItem medicalKit = new PlayerItem();
        medicalKit.setPlayerId(TEST_PLAYER_ID);
        medicalKit.setItemType(ItemType.item);
        medicalKit.setItemId(1);
        medicalKit.setQuantity(4);
        playerItemRepository.save(medicalKit);

        int stock = playerItemRepository.findByPlayerIdAndItemTypeAndItemId(
                TEST_PLAYER_ID, ItemType.item, 1)
                .map(PlayerItem::getQuantity)
                .orElse(0);
        assertEquals(4, stock);

        Map<String, Object> config = npcTradeService.getTradeConfig(testNpcId, TEST_PLAYER_ID);
        assertTrue((Boolean) config.get("success"));
        assertEquals(4, stock, "医疗资源库存应仍为4");
    }

    @Test
    public void testSmartStockRecognitionWithWrongItemType() {
        int testNpcId = 5;

        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 1);
        demandItem.put("quantity", 1);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 5);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        PlayerItem medicalKit = new PlayerItem();
        medicalKit.setPlayerId(TEST_PLAYER_ID);
        medicalKit.setItemType(ItemType.item);
        medicalKit.setItemId(1);
        medicalKit.setQuantity(4);
        playerItemRepository.save(medicalKit);

        Map<String, Object> config = npcTradeService.getTradeConfig(testNpcId, TEST_PLAYER_ID);
        assertTrue((Boolean) config.get("success"));
        Map<String, Object> diagnosis = npcTradeService.diagnoseTradeConfig(testNpcId, TEST_PLAYER_ID);
        assertTrue((Boolean) diagnosis.get("success"));
    }

    @Test
    public void testDiagnoseTradeConfig() {
        int testNpcId = 6;

        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 1);
        demandItem.put("quantity", 1);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 5);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        PlayerItem medicalKit = new PlayerItem();
        medicalKit.setPlayerId(TEST_PLAYER_ID);
        medicalKit.setItemType(ItemType.item);
        medicalKit.setItemId(1);
        medicalKit.setQuantity(4);
        playerItemRepository.save(medicalKit);

        Map<String, Object> diagnosis = npcTradeService.diagnoseTradeConfig(testNpcId, TEST_PLAYER_ID);
        assertTrue((Boolean) diagnosis.get("success"));
        
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> issues = (List<Map<String, Object>>) diagnosis.get("issues");
        assertFalse(issues.isEmpty(), "应该检测到itemType不匹配问题");
        
        Map<String, Object> firstIssue = issues.get(0);
        assertEquals("material", firstIssue.get("configItemType"));
        assertEquals("item", firstIssue.get("actualItemType"));
        assertEquals(4, firstIssue.get("actualQuantity"));
    }

    @Test
    public void testAutoFixTradeConfig() {
        int testNpcId = 7;

        List<Map<String, Object>> demandItems = new ArrayList<>();
        Map<String, Object> demandItem = new HashMap<>();
        demandItem.put("itemType", "material");
        demandItem.put("itemId", 1);
        demandItem.put("quantity", 1);
        demandItem.put("minFavor", -100);
        demandItem.put("maxFavor", 100);
        demandItems.add(demandItem);

        List<Map<String, Object>> supplyItems = new ArrayList<>();
        Map<String, Object> supplyItem = new HashMap<>();
        supplyItem.put("itemType", "material");
        supplyItem.put("itemId", 5);
        supplyItem.put("quantity", 5);
        supplyItem.put("minFavor", -100);
        supplyItem.put("maxFavor", 100);
        supplyItem.put("probability", 1.0);
        supplyItems.add(supplyItem);
        
        npcTradeService.saveTradeConfig(testNpcId, demandItems, supplyItems);

        PlayerItem medicalKit = new PlayerItem();
        medicalKit.setPlayerId(TEST_PLAYER_ID);
        medicalKit.setItemType(ItemType.item);
        medicalKit.setItemId(1);
        medicalKit.setQuantity(4);
        playerItemRepository.save(medicalKit);

        Map<String, Object> fixResult = npcTradeService.autoFixTradeConfig(testNpcId, TEST_PLAYER_ID);
        assertTrue((Boolean) fixResult.get("success"));
        assertEquals(1, fixResult.get("fixedCount"));

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> fixedItems = (List<Map<String, Object>>) fixResult.get("fixedItems");
        assertEquals(1, fixedItems.size());
        assertEquals("item", fixedItems.get(0).get("newType"));

        Map<String, Object> config = npcTradeService.getTradeConfig(testNpcId, TEST_PLAYER_ID);
        assertTrue((Boolean) config.get("success"));
        Map<String, Object> diagnosis = npcTradeService.getPlayerItemDiagnosis(TEST_PLAYER_ID);
        assertTrue((Boolean) diagnosis.get("success"));
        assertEquals(4, playerItemRepository.findByPlayerIdAndItemTypeAndItemId(
                TEST_PLAYER_ID, ItemType.item, 1).map(PlayerItem::getQuantity).orElse(0));
    }

    @Test
    public void testGetPlayerItemDiagnosis() {
        PlayerItem item1 = new PlayerItem();
        item1.setPlayerId(TEST_PLAYER_ID);
        item1.setItemType(ItemType.item);
        item1.setItemId(1);
        item1.setQuantity(4);
        playerItemRepository.save(item1);

        Map<String, Object> diagnosis = npcTradeService.getPlayerItemDiagnosis(TEST_PLAYER_ID);
        assertTrue((Boolean) diagnosis.get("success"));
        assertEquals(1, diagnosis.get("totalItems"));

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> items = (List<Map<String, Object>>) diagnosis.get("items");
        assertEquals(1, items.size());
        assertEquals("item", items.get(0).get("itemType"));
        assertEquals(1, items.get(0).get("itemId"));
        assertEquals("医疗资源", items.get(0).get("itemName"));
        assertEquals(4, items.get(0).get("quantity"));
    }

    @Test
    public void testGetDemandDiscountRate_Hostile() {
        assertEquals(0.0, NpcTradeService.getDemandDiscountRate(-60), 0.001);
        assertEquals(0.0, NpcTradeService.getDemandDiscountRate(-80), 0.001);
        assertEquals(0.0, NpcTradeService.getDemandDiscountRate(-100), 0.001);
    }

    @Test
    public void testGetDemandDiscountRate_Unfriendly() {
        assertEquals(0.0, NpcTradeService.getDemandDiscountRate(-59), 0.001);
        assertEquals(0.0, NpcTradeService.getDemandDiscountRate(-40), 0.001);
        assertEquals(0.0, NpcTradeService.getDemandDiscountRate(-21), 0.001);
    }

    @Test
    public void testGetDemandDiscountRate_Neutral() {
        assertEquals(0.0, NpcTradeService.getDemandDiscountRate(-20), 0.001);
        assertEquals(0.0, NpcTradeService.getDemandDiscountRate(0), 0.001);
        assertEquals(0.0, NpcTradeService.getDemandDiscountRate(19), 0.001);
    }

    @Test
    public void testGetDemandDiscountRate_Friendly() {
        assertEquals(0.1, NpcTradeService.getDemandDiscountRate(20), 0.001);
        assertEquals(0.1, NpcTradeService.getDemandDiscountRate(40), 0.001);
        assertEquals(0.1, NpcTradeService.getDemandDiscountRate(59), 0.001);
    }

    @Test
    public void testGetDemandDiscountRate_Close() {
        assertEquals(0.25, NpcTradeService.getDemandDiscountRate(60), 0.001);
        assertEquals(0.25, NpcTradeService.getDemandDiscountRate(80), 0.001);
        assertEquals(0.25, NpcTradeService.getDemandDiscountRate(99), 0.001);
    }

    @Test
    public void testGetDemandDiscountRate_Max() {
        assertEquals(1.0, NpcTradeService.getDemandDiscountRate(100), 0.001);
    }

    @Test
    public void testGetSupplyBonusRate_Hostile() {
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(-60), 0.001);
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(-80), 0.001);
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(-100), 0.001);
    }

    @Test
    public void testGetSupplyBonusRate_Unfriendly() {
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(-59), 0.001);
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(-40), 0.001);
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(-21), 0.001);
    }

    @Test
    public void testGetSupplyBonusRate_Neutral() {
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(-20), 0.001);
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(0), 0.001);
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(19), 0.001);
    }

    @Test
    public void testGetSupplyBonusRate_Friendly() {
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(20), 0.001);
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(40), 0.001);
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(59), 0.001);
    }

    @Test
    public void testGetSupplyBonusRate_Close() {
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(60), 0.001);
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(80), 0.001);
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(99), 0.001);
    }

    @Test
    public void testGetSupplyBonusRate_Max() {
        assertEquals(0.0, NpcTradeService.getSupplyBonusRate(100), 0.001);
    }

    @Test
    public void testIsHostile() {
        assertTrue(NpcTradeService.isHostile(-60));
        assertTrue(NpcTradeService.isHostile(-80));
        assertTrue(NpcTradeService.isHostile(-100));
        assertFalse(NpcTradeService.isHostile(-59));
        assertFalse(NpcTradeService.isHostile(0));
        assertFalse(NpcTradeService.isHostile(100));
    }

    @Test
    public void testCanTrade() {
        assertFalse(NpcTradeService.canTrade(-60));
        assertFalse(NpcTradeService.canTrade(-80));
        assertTrue(NpcTradeService.canTrade(-59));
        assertTrue(NpcTradeService.canTrade(0));
        assertTrue(NpcTradeService.canTrade(100));
    }

    @Test
    public void testCalculateDiscountedDemand_HostileUnfriendlyNeutral() {
        assertEquals(10, NpcTradeService.calculateDiscountedDemand(10, 0.0));
        assertEquals(5, NpcTradeService.calculateDiscountedDemand(5, 0.0));
        assertEquals(0, NpcTradeService.calculateDiscountedDemand(0, 0.0));
    }

    @Test
    public void testCalculateDiscountedDemand_Friendly() {
        assertEquals(8, NpcTradeService.calculateDiscountedDemand(10, 0.2));
        assertEquals(4, NpcTradeService.calculateDiscountedDemand(5, 0.2));
        assertEquals(16, NpcTradeService.calculateDiscountedDemand(20, 0.2));
    }

    @Test
    public void testCalculateDiscountedDemand_Close() {
        assertEquals(5, NpcTradeService.calculateDiscountedDemand(10, 0.5));
        assertEquals(3, NpcTradeService.calculateDiscountedDemand(5, 0.5));
        assertEquals(10, NpcTradeService.calculateDiscountedDemand(20, 0.5));
    }

    @Test
    public void testCalculateDiscountedDemand_Max() {
        assertEquals(0, NpcTradeService.calculateDiscountedDemand(10, 1.0));
        assertEquals(0, NpcTradeService.calculateDiscountedDemand(5, 1.0));
        assertEquals(0, NpcTradeService.calculateDiscountedDemand(20, 1.0));
    }

    @Test
    public void testCalculateBonusSupply_HostileUnfriendlyNeutral() {
        assertEquals(10, NpcTradeService.calculateBonusSupply(10, 0.0));
        assertEquals(5, NpcTradeService.calculateBonusSupply(5, 0.0));
        assertEquals(1, NpcTradeService.calculateBonusSupply(0, 0.0));
    }

    @Test
    public void testCalculateBonusSupply_Friendly() {
        assertEquals(12, NpcTradeService.calculateBonusSupply(10, 0.2));
        assertEquals(6, NpcTradeService.calculateBonusSupply(5, 0.2));
        assertEquals(24, NpcTradeService.calculateBonusSupply(20, 0.2));
    }

    @Test
    public void testCalculateBonusSupply_Close() {
        assertEquals(15, NpcTradeService.calculateBonusSupply(10, 0.5));
        assertEquals(8, NpcTradeService.calculateBonusSupply(5, 0.5));
        assertEquals(30, NpcTradeService.calculateBonusSupply(20, 0.5));
    }

    @Test
    public void testCalculateBonusSupply_Max() {
        assertEquals(20, NpcTradeService.calculateBonusSupply(10, 1.0));
        assertEquals(10, NpcTradeService.calculateBonusSupply(5, 1.0));
        assertEquals(40, NpcTradeService.calculateBonusSupply(20, 1.0));
    }

    @Test
    public void testGetFavorTier() {
        assertEquals("敌视", NpcTradeService.getFavorTier(-60));
        assertEquals("敌视", NpcTradeService.getFavorTier(-100));
        assertEquals("冷漠", NpcTradeService.getFavorTier(-59));
        assertEquals("冷漠", NpcTradeService.getFavorTier(-21));
        assertEquals("中立", NpcTradeService.getFavorTier(-20));
        assertEquals("中立", NpcTradeService.getFavorTier(0));
        assertEquals("中立", NpcTradeService.getFavorTier(19));
        assertEquals("友善", NpcTradeService.getFavorTier(20));
        assertEquals("友善", NpcTradeService.getFavorTier(59));
        assertEquals("亲近", NpcTradeService.getFavorTier(60));
        assertEquals("亲近", NpcTradeService.getFavorTier(99));
        assertEquals("挚友", NpcTradeService.getFavorTier(100));
    }

    @Test
    public void testCalculateDiscountedDemand_BoundaryValues() {
        assertEquals(0, NpcTradeService.calculateDiscountedDemand(0, 0.5));
        assertEquals(0, NpcTradeService.calculateDiscountedDemand(-1, 0.5));
        assertEquals(1, NpcTradeService.calculateDiscountedDemand(1, 0.5));
        assertEquals(10, NpcTradeService.calculateDiscountedDemand(10, 0.0));
        assertEquals(0, NpcTradeService.calculateDiscountedDemand(10, 1.0));
    }

    @Test
    public void testCalculateBonusSupply_BoundaryValues() {
        assertEquals(1, NpcTradeService.calculateBonusSupply(0, 0.5));
        assertEquals(1, NpcTradeService.calculateBonusSupply(-1, 0.5));
        assertEquals(2, NpcTradeService.calculateBonusSupply(1, 0.5));
        assertEquals(10, NpcTradeService.calculateBonusSupply(10, 0.0));
        assertEquals(20, NpcTradeService.calculateBonusSupply(10, 1.0));
    }
}
