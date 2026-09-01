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
 * 方舟终局「漂浮的救援物资」文案：1个医疗包（可视为10份医疗资源）→ 10份医疗资源。
 * 独立于计数单位迁移（不走「医疗包」名称守卫），已跑过 ×10 的库也会修正。
 * 幂等：WHERE description LIKE 旧子串，REPLACE 后再次启动匹配 0 行。
 */
@Component
@Order(18)
public class EndgameArkEventMedicalTextMigration implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(EndgameArkEventMedicalTextMigration.class);

    private static final String OLD_PHRASE = "1个医疗包（可视为10份医疗资源）";
    private static final String NEW_PHRASE = "10份医疗资源";

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void run(String... args) {
        try {
            if (!tableExists("endgame_ark_event")) {
                logger.info("endgame_ark_event 表不存在，跳过方舟救援物资文案修正");
                return;
            }
            int rows = entityManager.createNativeQuery(
                    "UPDATE endgame_ark_event SET description = REPLACE(description, :oldPhrase, :newPhrase), "
                            + "updated_at = NOW() "
                            + "WHERE description LIKE :likePhrase"
            )
                    .setParameter("oldPhrase", OLD_PHRASE)
                    .setParameter("newPhrase", NEW_PHRASE)
                    .setParameter("likePhrase", "%" + OLD_PHRASE + "%")
                    .executeUpdate();
            if (rows > 0) {
                logger.info("已将 endgame_ark_event 救援物资文案改为 10份医疗资源（{} 行）", rows);
            } else {
                logger.info("endgame_ark_event 救援物资文案无需修正");
            }
        } catch (Exception e) {
            logger.error("方舟救援物资文案修正失败，事务将回滚以便下次启动重试: {}", e.getMessage(), e);
            if (e instanceof RuntimeException) {
                throw (RuntimeException) e;
            }
            throw new IllegalStateException("方舟救援物资文案修正失败", e);
        }
    }

    private boolean tableExists(String table) {
        Number count = (Number) entityManager.createNativeQuery(
                "SELECT COUNT(*) FROM information_schema.TABLES "
                        + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?1"
        ).setParameter(1, table).getSingleResult();
        return count.intValue() > 0;
    }
}
