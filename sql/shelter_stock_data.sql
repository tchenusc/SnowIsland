-- =====================================================
-- 统治者避难所物资库存表 (shelter_stock)
-- 重构版本：基于 item_type + item_id 关联设计
-- 创建日期：2026-05-13
-- 说明：与 player_items 表结构保持一致，通过 item_type 和 item_id 关联物品目录表
-- =====================================================

-- ----------------------------
-- 1. 删除旧表（如果存在）
-- ----------------------------
DROP TABLE IF EXISTS `shelter_stock`;

-- ----------------------------
-- 2. 创建新表结构
-- ----------------------------
CREATE TABLE `shelter_stock` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `item_type` ENUM('item', 'weapon', 'ammo', 'material') NOT NULL COMMENT '物品类型：item道具/weapon武器/ammo弹药/material材料',
  `item_id` INT(11) NOT NULL COMMENT '物品ID，关联对应类型表的主键',
  `quantity` INT(11) NOT NULL DEFAULT 0 COMMENT '物品数量',
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间',
  `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '更新时间',

  -- 主键
  PRIMARY KEY (`id`),

  -- 唯一约束：同一类型+同一物品ID只能有一条库存记录
  UNIQUE KEY `UK_shelter_stock_type_item` (`item_type`, `item_id`),

  -- 索引：加速按物品类型查询
  KEY `idx_item_type` (`item_type`),

  -- 索引：加速按物品ID查询
  KEY `idx_item_id` (`item_id`)

) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='统治者避难所物资库存表';

-- ----------------------------
-- 3. 初始数据插入
-- ----------------------------
-- 说明：数据来源于旧版 item_key 格式的映射关系
--
-- 映射规则：
--   item_key (旧) -> item_type + item_id (新)
--   wood        -> material + 2    (木材)
--   stone       -> material + 7    (石料)
--   medical_kit -> item + 1        (医疗资源)
--   flashlight  -> item + 2        (手电筒)
--   ...

INSERT INTO `shelter_stock` (`item_type`, `item_id`, `quantity`, `created_at`, `updated_at`) VALUES
-- =====================================================
-- 材料类 (material) - 共5种
-- =====================================================
('material', 2, 45, NOW(6), NOW(6)),   -- 木材: 45单位, id=2
('material', 3, 35, NOW(6), NOW(6)),   -- 绳索: 35单位, id=3
('material', 4, 24, NOW(6), NOW(6)),   -- 木板: 24单位, id=4
('material', 7, 32, NOW(6), NOW(6)),   -- 石料: 32单位, id=7

-- =====================================================
-- 道具类 (item) - 共17种
-- =====================================================
('item', 1, 80, NOW(6), NOW(6)),       -- 医疗资源: 80份, id=1
('item', 2, 4, NOW(6), NOW(6)),        -- 手电筒: 4个, id=2
('item', 3, 2, NOW(6), NOW(6)),        -- 手铐: 2个, id=3
('item', 4, 3, NOW(6), NOW(6)),        -- 哨子: 3个, id=4
('item', 5, 1, NOW(6), NOW(6)),        -- 防弹衣: 1件, id=5
('item', 6, 1, NOW(6), NOW(6)),        -- 复合盾: 1个, id=6
('item', 7, 1, NOW(6), NOW(6)),        -- 信号枪: 1把, id=7
('item', 8, 5, NOW(6), NOW(6)),        -- 维修工具包: 5个, id=8
('item', 9, 2, NOW(6), NOW(6)),        -- 协议书: 2个, id=9
('item', 10, 10, NOW(6), NOW(6)),      -- 朗姆酒: 10瓶, id=10
('item', 11, 12, NOW(6), NOW(6)),      -- 草药: 12个, id=11
('item', 12, 2, NOW(6), NOW(6)),       -- 渔网: 2张, id=12
('item', 13, 18, NOW(6), NOW(6)),      -- 蜡烛: 18根, id=13
('item', 14, 3, NOW(6), NOW(6)),       -- 医用酒精: 3升, id=14
('item', 15, 6, NOW(6), NOW(6)),       -- 火柴: 6盒, id=15
('item', 16, 4, NOW(6), NOW(6)),       -- 铅笔: 4盒, id=16
('item', 17, 1, NOW(6), NOW(6));       -- 破损海图: 1张, id=17

INSERT INTO `shelter_stock` (`item_type`, `item_id`, `quantity`, `created_at`, `updated_at`) VALUES
-- =====================================================
-- 武器类 (weapon) - 共8种
-- =====================================================
('weapon', 1, 1, NOW(6), NOW(6)),       -- 制式手枪: 1把, id=1
('weapon', 2, 1, NOW(6), NOW(6)),       -- 猎枪: 1把, id=2
('weapon', 3, 2, NOW(6), NOW(6)),       -- 警棍: 2个, id=3
('weapon', 4, 1, NOW(6), NOW(6)),       -- 刺刀: 1把, id=4
('weapon', 6, 1, NOW(6), NOW(6)),       -- 鱼叉/矛: 1个, id=6
('weapon', 7, 1, NOW(6), NOW(6)),       -- 猎弓: 1张, id=7
('weapon', 8, 2, NOW(6), NOW(6)),       -- 十字镐: 2把, id=8
('weapon', 9, 1, NOW(6), NOW(6));       -- 斧头: 1把, id=9

-- ----------------------------
-- 4. 数据验证查询
-- ----------------------------
SELECT
  CASE item_type
    WHEN 'material' THEN '材料'
    WHEN 'item' THEN '道具'
    WHEN 'weapon' THEN '武器'
    WHEN 'ammo' THEN '弹药'
  END AS '物品类型',
  COUNT(*) AS '物品种类数',
  SUM(quantity) AS '总数量'
FROM shelter_stock
GROUP BY item_type
WITH ROLLUP;

-- ----------------------------
-- 5. 统计总览
-- ----------------------------
SELECT '避难所物资库存总览' AS '统计项',
       COUNT(*) AS '物品种类数',
       SUM(quantity) AS '物资总数量'
FROM shelter_stock;

-- =====================================================
-- 结束标记
-- =====================================================
SELECT 'shelter_stock 表结构重构完成，共插入 29 条初始数据' AS '执行结果';