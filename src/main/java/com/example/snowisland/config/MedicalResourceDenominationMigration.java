package com.example.snowisland.config;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * 医疗包 → 医疗资源（1 包 = 10 份）。幂等：item id=1 名称已是「医疗资源」则整次跳过。
 * 失败必须抛出以使 {@code @Transactional} 整批回滚，避免半改名半 ×10 后被名称守卫永久跳过。
 */
@Component
@Order(16)
public class MedicalResourceDenominationMigration implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(MedicalResourceDenominationMigration.class);

    private static final String NEW_NAME = "医疗资源";
    private static final String OLD_NAME = "医疗包";
    private static final String NEW_REMARK = "基础医疗物资，急救重伤需5份";

    private static final List<String> QTY_TABLES = Arrays.asList(
            "player_items",
            "npc_items",
            "shelter_stock",
            "warehouse_general",
            "warehouse_fuel",
            "warehouse_armory",
            "warehouse_dock",
            "warehouse_rebel",
            "warehouse_ark",
            "job_initial_items",
            "npc_trade_config",
            "trade_items"
    );

    private final ObjectMapper objectMapper = new ObjectMapper();

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void run(String... args) {
        try {
            if (!tableExists("item")) {
                logger.warn("item 表不存在，跳过医疗资源计数单位迁移");
                return;
            }
            @SuppressWarnings("unchecked")
            List<Object> names = entityManager.createNativeQuery(
                    "SELECT name FROM item WHERE id = 1"
            ).getResultList();
            if (names.isEmpty() || names.get(0) == null) {
                logger.info("item id=1 不存在，跳过医疗资源计数单位迁移");
                return;
            }
            String currentName = String.valueOf(names.get(0)).trim();
            if (NEW_NAME.equals(currentName)) {
                logger.info("item id=1 已是医疗资源，跳过整次迁移");
                return;
            }
            if (!OLD_NAME.equals(currentName)) {
                logger.warn("item id=1 名称为「{}」，非医疗包，跳过整次迁移", currentName);
                return;
            }

            int renamed = entityManager.createNativeQuery(
                    "UPDATE item SET name = :newName, unit = '份', remark = :remark, updated_at = NOW() "
                            + "WHERE id = 1 AND name = :oldName"
            )
                    .setParameter("newName", NEW_NAME)
                    .setParameter("remark", NEW_REMARK)
                    .setParameter("oldName", OLD_NAME)
                    .executeUpdate();
            logger.info("item id=1 已更名为医疗资源（{} 行）", renamed);

            for (String table : QTY_TABLES) {
                scaleItem1Quantity(table);
                if ("job_initial_items".equals(table) && tableExists(table)) {
                    entityManager.createNativeQuery(
                            "UPDATE job_initial_items SET unit = '份' WHERE item_type = 'item' AND item_id = 1"
                    ).executeUpdate();
                }
            }

            scaleKitDenominatedEventRewards();
            scaleNpcTradeProposals();
        } catch (Exception e) {
            logger.error("医疗资源计数单位迁移失败，事务将回滚以便下次启动重试: {}", e.getMessage(), e);
            if (e instanceof RuntimeException) {
                throw (RuntimeException) e;
            }
            throw new IllegalStateException("医疗资源计数单位迁移失败", e);
        }
    }

    private int scaleItem1Quantity(String table) {
        if (!tableExists(table)) {
            logger.info("表 {} 不存在，跳过 item 1 数量换算", table);
            return -1;
        }
        int rows = entityManager.createNativeQuery(
                "UPDATE " + table + " SET quantity = quantity * 10 "
                        + "WHERE item_type = 'item' AND item_id = 1"
        ).executeUpdate();
        logger.info("已将 {} 中 item 1 数量 ×10（{} 行）", table, rows);
        return rows;
    }

    /**
     * Only kit-denominated island events. quantity &lt; 10 skips rows already
     * rewritten by EventPackMigration from the updated exploration_events.txt.
     */
    private void scaleKitDenominatedEventRewards() {
        if (!tableExists("island_event_reward") || !tableExists("island_event")) {
            logger.info("岛屿事件表不存在，跳过医疗资源奖励换算");
            return;
        }
        int rows = entityManager.createNativeQuery(
                "UPDATE island_event_reward r "
                        + "INNER JOIN island_event e ON r.event_id = e.id "
                        + "SET r.quantity = r.quantity * 10 "
                        + "WHERE r.item_type = 'item' AND r.item_id = 1 AND r.quantity < 10 AND ("
                        + "e.name LIKE '%守夜人的秘密补给点%' "
                        + "OR e.name LIKE '%教堂花园的枯井%' "
                        + "OR e.name LIKE '%地热泉眼%' "
                        + "OR e.name LIKE '%遇难的科考队%' "
                        + "OR e.name LIKE '%潮汐症者的日志%' "
                        + "OR e.name LIKE '%血祭者的反叛遗言%' "
                        + "OR e.name LIKE '%封信%' "
                        + "OR e.name LIKE '%一封信%' "
                        + "OR e.name LIKE '%被冻结的%铁砧%'"
                        + ")"
        ).executeUpdate();
        logger.info("已将套件计数的岛屿事件奖励 ×10（{} 行）", rows);
    }

    /**
     * In-flight NPC proposals store kit-denominated JSON lines (t/itemType, id/itemId, q/quantity, name).
     */
    private void scaleNpcTradeProposals() {
        if (!tableExists("npc_trade_proposal")) {
            logger.info("npc_trade_proposal 表不存在，跳过提案 JSON 换算");
            return;
        }
        @SuppressWarnings("unchecked")
        List<Object[]> rows = entityManager.createNativeQuery(
                "SELECT id, give_items, take_items FROM npc_trade_proposal"
        ).getResultList();
        int updated = 0;
        for (Object[] row : rows) {
            Object id = row[0];
            String giveJson = row[1] == null ? null : String.valueOf(row[1]);
            String takeJson = row[2] == null ? null : String.valueOf(row[2]);
            String newGive = scaleProposalJson(giveJson);
            String newTake = scaleProposalJson(takeJson);
            boolean giveChanged = jsonChanged(giveJson, newGive);
            boolean takeChanged = jsonChanged(takeJson, newTake);
            if (!giveChanged && !takeChanged) {
                continue;
            }
            entityManager.createNativeQuery(
                    "UPDATE npc_trade_proposal SET give_items = :giveItems, take_items = :takeItems, "
                            + "updated_at = NOW() WHERE id = :id"
            )
                    .setParameter("giveItems", newGive)
                    .setParameter("takeItems", newTake)
                    .setParameter("id", id)
                    .executeUpdate();
            updated++;
        }
        logger.info("已将 npc_trade_proposal 中医疗物资 JSON 数量 ×10（{} 行）", updated);
    }

    private String scaleProposalJson(String json) {
        if (json == null || json.trim().isEmpty()) {
            return json;
        }
        List<Map<String, Object>> lines;
        try {
            lines = objectMapper.readValue(json, new TypeReference<List<Map<String, Object>>>() { });
        } catch (Exception e) {
            throw new IllegalStateException("解析 npc_trade_proposal JSON 失败: " + json, e);
        }
        boolean changed = false;
        for (Map<String, Object> line : lines) {
            if (line == null || !isMedicalKitLine(line)) {
                continue;
            }
            scaleQuantityField(line, "q");
            scaleQuantityField(line, "quantity");
            rewriteNameField(line, "name");
            rewriteNameField(line, "itemName");
            changed = true;
        }
        if (!changed) {
            return json;
        }
        try {
            return objectMapper.writeValueAsString(lines);
        } catch (Exception e) {
            throw new IllegalStateException("写出 npc_trade_proposal JSON 失败", e);
        }
    }

    private boolean isMedicalKitLine(Map<String, Object> line) {
        String type = firstString(line, "t", "itemType", "type");
        int itemId = asInt(firstValue(line, "id", "itemId"), -1);
        String name = firstString(line, "name", "itemName");
        boolean typeIsItem = type.isEmpty() || "item".equalsIgnoreCase(type);
        if (typeIsItem && itemId == 1) {
            return true;
        }
        return OLD_NAME.equals(name);
    }

    private void scaleQuantityField(Map<String, Object> line, String key) {
        if (!line.containsKey(key) || line.get(key) == null) {
            return;
        }
        line.put(key, asInt(line.get(key), 0) * 10);
    }

    private void rewriteNameField(Map<String, Object> line, String key) {
        if (!line.containsKey(key) || line.get(key) == null) {
            return;
        }
        line.put(key, NEW_NAME);
    }

    private static Object firstValue(Map<String, Object> line, String... keys) {
        for (String key : keys) {
            if (line.containsKey(key) && line.get(key) != null) {
                return line.get(key);
            }
        }
        return null;
    }

    private static String firstString(Map<String, Object> line, String... keys) {
        Object value = firstValue(line, keys);
        return value == null ? "" : String.valueOf(value).trim();
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

    private static boolean jsonChanged(String original, String updated) {
        if (original == null) {
            return updated != null;
        }
        return !original.equals(updated);
    }

    private boolean tableExists(String table) {
        Number count = (Number) entityManager.createNativeQuery(
                "SELECT COUNT(*) FROM information_schema.TABLES "
                        + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?1"
        ).setParameter(1, table).getSingleResult();
        return count.intValue() > 0;
    }
}
