package com.example.snowisland.util;

import com.example.snowisland.entity.TradeItem.ItemType;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Deterministic survival take/give math for NPC AI trade proposals.
 */
public final class NpcTradeProposalMath {

    public static final int MAX_GIVE_LINES = 3;
    public static final int MAX_TAKE_LINES_OPPORTUNISTIC = 2;
    public static final int MAX_MATERIAL_QTY = 5;
    public static final int MAX_ITEM_QTY = 1;
    /** Item 1 used to be 1 kit; cap give/take at 10 resource units so 1-kit behavior stays equivalent. */
    private static final int MEDICAL_RESOURCE_PER_OLD_KIT = 10;
    public static final String FALLBACK_REMARK = "我缺过冬的东西，用这些换。";

    private NpcTradeProposalMath() {
    }

    public static final class Line {
        public final ItemType itemType;
        public final int itemId;
        public final int quantity;
        public final String name;

        public Line(ItemType itemType, int itemId, int quantity, String name) {
            this.itemType = itemType;
            this.itemId = itemId;
            this.quantity = quantity;
            this.name = name == null ? "" : name;
        }

        public Map<String, Object> toMap() {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("t", itemType == null ? "item" : itemType.name());
            row.put("itemType", itemType == null ? "item" : itemType.name());
            row.put("id", itemId);
            row.put("itemId", itemId);
            row.put("q", quantity);
            row.put("quantity", quantity);
            row.put("name", name);
            row.put("itemName", name);
            return row;
        }
    }

    public static List<Line> survivalTake(int foodKg, int woodKg, int fuelKg,
                                          int requiredFood, int requiredHeat) {
        List<Line> take = new ArrayList<>();
        int needFood = Math.max(0, requiredFood - foodKg);
        if (needFood > 0) {
            take.add(new Line(ItemType.material, ItemCatalog.FOOD_MATERIAL_ID, needFood, ItemCatalog.FOOD_NAME));
        }
        int heat = NpcSurvivalMath.currentHeat(woodKg, fuelKg);
        int heatShort = Math.max(0, requiredHeat - heat);
        if (heatShort > 0) {
            if (heatShort >= PlayerConsumptionServiceHeat.FUEL_HEAT_PER_KG) {
                int fuelNeed = (heatShort + PlayerConsumptionServiceHeat.FUEL_HEAT_PER_KG - 1)
                        / PlayerConsumptionServiceHeat.FUEL_HEAT_PER_KG;
                take.add(new Line(ItemType.material, ItemCatalog.FUEL_MATERIAL_ID, fuelNeed, ItemCatalog.FUEL_NAME));
            } else {
                take.add(new Line(ItemType.material, ItemCatalog.WOOD_MATERIAL_ID, heatShort, ItemCatalog.WOOD_NAME));
            }
        }
        return take;
    }

    public static boolean canSurviveToday(int foodKg, int woodKg, int fuelKg, int requiredFood, int requiredHeat) {
        return NpcSurvivalMath.reserveHolds(foodKg, woodKg, fuelKg, requiredFood, requiredHeat);
    }

    /**
     * First 1–3 non-empty surplus lines. Prefer non-survival extras, then leftover sellable food/heat.
     */
    public static List<Line> deterministicGive(List<Line> surplus) {
        return deterministicGive(surplus, 40);
    }

    public static Line capGive(Line line) {
        int cap = itemQuantityCap(line.itemType, line.itemId);
        int qty = Math.min(line.quantity, cap);
        qty = Math.max(1, qty);
        return new Line(line.itemType, line.itemId, qty, line.name);
    }

    public static Line clampGiveAgainstSellable(Line line, int sellable) {
        return clampGiveAgainstSellable(line, sellable, 100);
    }

    public static int maxGiveLines(int favor) {
        if (favor >= 60) {
            return MAX_GIVE_LINES;
        }
        if (favor >= 20) {
            return 2;
        }
        return 1;
    }

    public static int materialQtyCap(int favor, ItemType itemType) {
        return materialQtyCap(favor, itemType, 0);
    }

    public static int materialQtyCap(int favor, ItemType itemType, int itemId) {
        if (itemType == ItemType.item && itemId == 1) {
            return MEDICAL_RESOURCE_PER_OLD_KIT;
        }
        if (itemType != ItemType.material) {
            return MAX_ITEM_QTY;
        }
        if (favor >= 60) {
            return MAX_MATERIAL_QTY;
        }
        if (favor >= 20) {
            return 3;
        }
        return 2;
    }

    /** How many of the player's named extras the NPC will take. */
    public static int maxOfferedExtras(int favor) {
        if (favor >= 60) {
            return MAX_TAKE_LINES_OPPORTUNISTIC;
        }
        return 1;
    }

    /** Extra catalog wants piled on besides what the player offered. Low favor is greedier. */
    public static int maxGreedyExtraTakes(int favor) {
        return favor < 20 ? 1 : 0;
    }

    public static int maxExtraTakeLines(int favor) {
        return Math.min(MAX_TAKE_LINES_OPPORTUNISTIC + 1,
                maxOfferedExtras(favor) + maxGreedyExtraTakes(favor));
    }

    /**
     * Weapons are high value. Ammo, engines and medical resources (old 1-kit stack) are also too good for a cold relationship.
     */
    public static boolean isHighValueGive(ItemType itemType, int itemId) {
        if (itemType == ItemType.weapon || itemType == ItemType.ammo) {
            return true;
        }
        if (itemType == ItemType.material && (itemId == 10 || itemId == 11 || itemId == 12)) {
            return true;
        }
        return itemType == ItemType.item && itemId == 1;
    }

    private static int itemQuantityCap(ItemType itemType, int itemId) {
        if (itemType == ItemType.item && itemId == 1) {
            return MEDICAL_RESOURCE_PER_OLD_KIT;
        }
        return itemType == ItemType.material ? MAX_MATERIAL_QTY : MAX_ITEM_QTY;
    }

    public static boolean mayGive(ItemType itemType, int itemId, int favor) {
        if (itemType == ItemType.weapon && favor < 60) {
            return false;
        }
        if (favor < 20 && isHighValueGive(itemType, itemId)) {
            return false;
        }
        return true;
    }

    public static Line clampGiveAgainstSellable(Line line, int sellable, int favor) {
        if (line == null || sellable <= 0 || !mayGive(line.itemType, line.itemId, favor)) {
            return null;
        }
        int qty = Math.min(line.quantity, sellable);
        qty = Math.min(qty, materialQtyCap(favor, line.itemType, line.itemId));
        if (qty <= 0) {
            return null;
        }
        return new Line(line.itemType, line.itemId, qty, line.name);
    }

    public static List<Line> deterministicGive(List<Line> surplus, int favor) {
        int cap = Math.max(1, Math.min(MAX_GIVE_LINES, maxGiveLines(favor)));
        List<Line> cheap = new ArrayList<>();
        List<Line> pricey = new ArrayList<>();
        List<Line> survival = new ArrayList<>();
        for (Line line : surplus) {
            if (line == null || line.quantity <= 0) {
                continue;
            }
            Line capped = clampGiveAgainstSellable(line, line.quantity, favor);
            if (capped == null) {
                continue;
            }
            if (isSurvivalMaterial(line.itemType, line.itemId)) {
                survival.add(capped);
            } else if (isHighValueGive(line.itemType, line.itemId)) {
                pricey.add(capped);
            } else {
                cheap.add(capped);
            }
        }
        List<Line> out = new ArrayList<>();
        for (Line line : cheap) {
            if (out.size() >= cap) {
                break;
            }
            out.add(line);
        }
        for (Line line : survival) {
            if (out.size() >= cap) {
                break;
            }
            out.add(line);
        }
        if (favor >= 60) {
            for (Line line : pricey) {
                if (out.size() >= cap) {
                    break;
                }
                out.add(line);
            }
        }
        return out;
    }

    public static Line clampOpportunisticTake(ItemType type, int itemId, int quantity, String name, boolean tradable) {
        if (type == null || itemId <= 0 || !tradable) {
            return null;
        }
        int cap = itemQuantityCap(type, itemId);
        int qty = Math.max(1, Math.min(quantity, cap));
        return new Line(type, itemId, qty, name);
    }

    public static String sanitizeRemark(String remark, String fallback) {
        if (remark == null) {
            return fallback;
        }
        String trimmed = remark.trim().replaceAll("\\s+", " ");
        if (trimmed.isEmpty()) {
            return fallback;
        }
        if (trimmed.length() > 80) {
            trimmed = trimmed.substring(0, 80);
        }
        return trimmed;
    }

    public static boolean isSurvivalMaterial(ItemType itemType, int itemId) {
        return itemType == ItemType.material
                && (itemId == ItemCatalog.FOOD_MATERIAL_ID
                || itemId == ItemCatalog.WOOD_MATERIAL_ID
                || itemId == ItemCatalog.FUEL_MATERIAL_ID);
    }

    private static final class PlayerConsumptionServiceHeat {
        static final int FUEL_HEAT_PER_KG = 15;
    }
}
