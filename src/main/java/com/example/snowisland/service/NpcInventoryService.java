package com.example.snowisland.service;

import com.example.snowisland.entity.Job;
import com.example.snowisland.entity.JobInitialItems;
import com.example.snowisland.entity.LocationNpc;
import com.example.snowisland.entity.NpcItem;
import com.example.snowisland.entity.TradeItem.ItemType;
import com.example.snowisland.repository.JobInitialItemsRepository;
import com.example.snowisland.repository.JobRepository;
import com.example.snowisland.repository.LocationNpcRepository;
import com.example.snowisland.repository.NpcItemRepository;
import com.example.snowisland.util.ItemCatalog;
import com.example.snowisland.util.NpcSurvivalMath;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class NpcInventoryService {

    private static final Logger logger = LoggerFactory.getLogger(NpcInventoryService.class);

    @Autowired
    private NpcItemRepository npcItemRepository;

    @Autowired
    private LocationNpcRepository npcRepository;

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    private JobInitialItemsRepository jobInitialItemsRepository;

    @Autowired
    @Lazy
    private NpcTradeProposalService npcTradeProposalService;

    public int getQuantity(Integer npcId, ItemType itemType, Integer itemId) {
        if (npcId == null || itemType == null || itemId == null) {
            return 0;
        }
        return npcItemRepository.findByNpcIdAndItemTypeAndItemId(npcId, itemType, itemId)
                .map(row -> row.getQuantity() != null ? row.getQuantity() : 0)
                .orElse(0);
    }

    public int getMaterialKg(Integer npcId, int materialId) {
        return getQuantity(npcId, ItemType.material, materialId);
    }

    @Transactional
    public void addItem(Integer npcId, ItemType itemType, Integer itemId, int quantity) {
        if (quantity <= 0) {
            return;
        }
        Optional<NpcItem> existing = npcItemRepository.findByNpcIdAndItemTypeAndItemId(npcId, itemType, itemId);
        if (existing.isPresent()) {
            NpcItem row = existing.get();
            row.setQuantity(row.getQuantity() + quantity);
            npcItemRepository.save(row);
        } else {
            NpcItem row = new NpcItem();
            row.setNpcId(npcId);
            row.setItemType(itemType);
            row.setItemId(itemId);
            row.setQuantity(quantity);
            npcItemRepository.save(row);
        }
    }

    @Transactional
    public void deductItem(Integer npcId, ItemType itemType, Integer itemId, int quantity) {
        if (quantity <= 0) {
            return;
        }
        Optional<NpcItem> existing = npcItemRepository.findByNpcIdAndItemTypeAndItemId(npcId, itemType, itemId);
        int have = existing.map(row -> row.getQuantity() != null ? row.getQuantity() : 0).orElse(0);
        if (have < quantity) {
            throw new IllegalStateException("NPC物资不足：" + itemName(itemType, itemId)
                    + " 需要 " + quantity + "，当前 " + have);
        }
        NpcItem row = existing.get();
        int left = have - quantity;
        if (left <= 0) {
            npcItemRepository.delete(row);
        } else {
            row.setQuantity(left);
            npcItemRepository.save(row);
        }
    }

    @Transactional
    public void setQuantity(Integer npcId, ItemType itemType, Integer itemId, int quantity) {
        if (quantity < 0) {
            throw new IllegalArgumentException("数量不能为负数");
        }
        Optional<NpcItem> existing = npcItemRepository.findByNpcIdAndItemTypeAndItemId(npcId, itemType, itemId);
        if (quantity == 0) {
            existing.ifPresent(npcItemRepository::delete);
            return;
        }
        if (existing.isPresent()) {
            NpcItem row = existing.get();
            row.setQuantity(quantity);
            npcItemRepository.save(row);
        } else {
            NpcItem row = new NpcItem();
            row.setNpcId(npcId);
            row.setItemType(itemType);
            row.setItemId(itemId);
            row.setQuantity(quantity);
            npcItemRepository.save(row);
        }
    }

    public int sellableQuantity(Integer npcId, ItemType itemType, Integer itemId,
                                int requiredFood, int requiredHeat) {
        int stock = getQuantity(npcId, itemType, itemId);
        int reserved = reservedGive(npcId, itemType, itemId);
        int available = Math.max(0, stock - reserved);
        if (itemType != ItemType.material) {
            return available;
        }
        int food = Math.max(0, getMaterialKg(npcId, ItemCatalog.FOOD_MATERIAL_ID)
                - reservedGive(npcId, ItemType.material, ItemCatalog.FOOD_MATERIAL_ID));
        int wood = Math.max(0, getMaterialKg(npcId, ItemCatalog.WOOD_MATERIAL_ID)
                - reservedGive(npcId, ItemType.material, ItemCatalog.WOOD_MATERIAL_ID));
        int fuel = Math.max(0, getMaterialKg(npcId, ItemCatalog.FUEL_MATERIAL_ID)
                - reservedGive(npcId, ItemType.material, ItemCatalog.FUEL_MATERIAL_ID));
        if (itemId == ItemCatalog.FOOD_MATERIAL_ID) {
            return Math.min(available, NpcSurvivalMath.sellableFood(food, requiredFood));
        }
        if (itemId == ItemCatalog.WOOD_MATERIAL_ID) {
            return Math.min(available, NpcSurvivalMath.sellableWood(wood, fuel, requiredHeat));
        }
        if (itemId == ItemCatalog.FUEL_MATERIAL_ID) {
            return Math.min(available, NpcSurvivalMath.sellableFuel(wood, fuel, requiredHeat));
        }
        return available;
    }

    private int reservedGive(Integer npcId, ItemType itemType, Integer itemId) {
        if (npcTradeProposalService == null) {
            return 0;
        }
        return npcTradeProposalService.reservedGiveQuantity(npcId, itemType, itemId);
    }

    public boolean reserveHoldsAfterSale(Integer npcId, ItemType itemType, Integer itemId, int quantity,
                                         int requiredFood, int requiredHeat) {
        int food = getMaterialKg(npcId, ItemCatalog.FOOD_MATERIAL_ID);
        int wood = getMaterialKg(npcId, ItemCatalog.WOOD_MATERIAL_ID);
        int fuel = getMaterialKg(npcId, ItemCatalog.FUEL_MATERIAL_ID);
        if (itemType == ItemType.material) {
            if (itemId == ItemCatalog.FOOD_MATERIAL_ID) {
                food -= quantity;
            } else if (itemId == ItemCatalog.WOOD_MATERIAL_ID) {
                wood -= quantity;
            } else if (itemId == ItemCatalog.FUEL_MATERIAL_ID) {
                fuel -= quantity;
            }
        }
        return NpcSurvivalMath.reserveHolds(food, wood, fuel, requiredFood, requiredHeat)
                || !isSurvivalMaterial(itemType, itemId);
    }

    public static boolean isSurvivalMaterial(ItemType itemType, Integer itemId) {
        return itemType == ItemType.material && itemId != null
                && (itemId == ItemCatalog.FOOD_MATERIAL_ID
                || itemId == ItemCatalog.WOOD_MATERIAL_ID
                || itemId == ItemCatalog.FUEL_MATERIAL_ID);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> listItems(Integer npcId) {
        List<Map<String, Object>> out = new ArrayList<>();
        for (NpcItem row : npcItemRepository.findByNpcId(npcId)) {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("id", row.getId());
            map.put("itemType", row.getItemType() != null ? row.getItemType().name() : null);
            map.put("itemId", row.getItemId());
            map.put("itemName", itemName(row.getItemType(), row.getItemId()));
            map.put("quantity", row.getQuantity());
            out.add(map);
        }
        return out;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> survivalSnapshot(Integer npcId, int requiredFood, int requiredHeat) {
        int food = getMaterialKg(npcId, ItemCatalog.FOOD_MATERIAL_ID);
        int wood = getMaterialKg(npcId, ItemCatalog.WOOD_MATERIAL_ID);
        int fuel = getMaterialKg(npcId, ItemCatalog.FUEL_MATERIAL_ID);
        Map<String, Object> snap = new LinkedHashMap<>();
        snap.put("foodKg", food);
        snap.put("woodKg", wood);
        snap.put("fuelKg", fuel);
        snap.put("heatValue", NpcSurvivalMath.currentHeat(wood, fuel));
        snap.put("requiredFoodUnits", requiredFood);
        snap.put("requiredFuelKg", requiredHeat);
        snap.put("sellableFoodKg", NpcSurvivalMath.sellableFood(food, requiredFood));
        snap.put("sellableWoodKg", NpcSurvivalMath.sellableWood(wood, fuel, requiredHeat));
        snap.put("sellableFuelKg", NpcSurvivalMath.sellableFuel(wood, fuel, requiredHeat));
        snap.put("reserveHolds", NpcSurvivalMath.reserveHolds(food, wood, fuel, requiredFood, requiredHeat));
        return snap;
    }

    @Transactional
    public int seedFromJobIfEmpty(Integer npcId) {
        if (npcId == null) {
            return 0;
        }
        if (!npcItemRepository.findByNpcId(npcId).isEmpty()) {
            return 0;
        }
        return grantJobKit(npcId);
    }

    @Transactional
    public void clearInventory(Integer npcId) {
        npcItemRepository.deleteByNpcId(npcId);
    }

    @Transactional
    public int replaceFromJob(Integer npcId) {
        npcItemRepository.deleteByNpcId(npcId);
        return grantJobKit(npcId);
    }

    @Transactional
    public int seedAllEmptyInventories() {
        int granted = 0;
        for (LocationNpc npc : npcRepository.findAll()) {
            granted += seedFromJobIfEmpty(npc.getId());
        }
        return granted;
    }

    @Transactional
    public int resetAllFromJobs() {
        int granted = 0;
        for (LocationNpc npc : npcRepository.findAll()) {
            granted += replaceFromJob(npc.getId());
        }
        return granted;
    }

    private int grantJobKit(Integer npcId) {
        Optional<LocationNpc> npcOpt = npcRepository.findById(npcId);
        if (!npcOpt.isPresent()) {
            return 0;
        }
        String jobName = npcOpt.get().getJob();
        if (jobName == null || jobName.trim().isEmpty()) {
            logger.warn("NPC {} 无职业，跳过初始物资", npcId);
            return 0;
        }
        Optional<Job> jobOpt = jobRepository.findByName(jobName.trim());
        if (!jobOpt.isPresent()) {
            logger.warn("NPC {} 职业「{}」未匹配到 job 表，跳过初始物资", npcId, jobName);
            return 0;
        }
        List<JobInitialItems> kit = jobInitialItemsRepository.findByJobId(jobOpt.get().getId());
        int added = 0;
        for (JobInitialItems row : kit) {
            if (row.getItemType() == null || row.getItemId() == null || row.getQuantity() == null
                    || row.getQuantity() <= 0) {
                continue;
            }
            addItem(npcId, row.getItemType(), row.getItemId(), row.getQuantity());
            added += 1;
        }
        logger.info("已按职业「{}」为 NPC {} 发放 {} 种初始物资", jobName, npcId, added);
        return added;
    }

    public static String itemName(ItemType itemType, Integer itemId) {
        if (itemType == null || itemId == null) {
            return "未知";
        }
        switch (itemType) {
            case weapon:
                return weaponName(itemId);
            case ammo:
                return ammoName(itemId);
            case material:
                return materialName(itemId);
            default:
                return propName(itemId);
        }
    }

    private static String propName(Integer itemId) {
        switch (itemId) {
            case 1: return "医疗资源";
            case 2: return "手电筒";
            case 4: return "哨子";
            case 8: return "维修工具包";
            case 10: return "朗姆酒";
            case 12: return "渔网";
            case 15: return "点火工具";
            case 18: return "食物补给";
            default: return "道具" + itemId;
        }
    }

    private static String weaponName(Integer itemId) {
        switch (itemId) {
            case 1: return "制式手枪";
            case 2: return "猎枪";
            case 3: return "警棍";
            case 4: return "刺刀";
            case 9: return "斧头";
            case 11: return "手术刀";
            default: return "武器" + itemId;
        }
    }

    private static String ammoName(Integer itemId) {
        switch (itemId) {
            case 1: return "手枪弹";
            case 2: return "猎枪弹";
            case 3: return "信号弹";
            default: return "弹药" + itemId;
        }
    }

    private static String materialName(Integer itemId) {
        switch (itemId) {
            case 1: return "金属制品";
            case 2: return ItemCatalog.WOOD_NAME;
            case 3: return "绳索";
            case 4: return "木板";
            case 5: return ItemCatalog.FOOD_NAME;
            case 6: return "沥青";
            case 7: return "石料";
            case 8: return ItemCatalog.FUEL_NAME;
            case 9: return "帆布";
            case 10: return "发动机";
            case 11: return "螺旋桨";
            case 12: return "发电机";
            default: return "物资" + itemId;
        }
    }
}
