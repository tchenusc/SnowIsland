package com.example.snowisland.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

/**
 * player.trade_ban_exempt：DM 豁免自动禁止交易（幂等加列）。
 */
@Component
@Order(15)
public class TradeBanExemptColumnMigration implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(TradeBanExemptColumnMigration.class);

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    @Transactional
    public void run(String... args) {
        try {
            ensureColumn("player", "trade_ban_exempt", "TINYINT(1) NOT NULL DEFAULT 0");
        } catch (Exception e) {
            logger.error("trade_ban_exempt 列迁移失败: {}", e.getMessage(), e);
        }
    }

    private void ensureColumn(String table, String column, String definition) {
        Number count = (Number) entityManager.createNativeQuery(
                "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?1 AND COLUMN_NAME = ?2"
        ).setParameter(1, table).setParameter(2, column).getSingleResult();

        if (count.intValue() == 0) {
            entityManager.createNativeQuery(
                    "ALTER TABLE " + table + " ADD COLUMN " + column + " " + definition
            ).executeUpdate();
            logger.info("{} 表已添加 {} 列", table, column);
        }
    }
}
