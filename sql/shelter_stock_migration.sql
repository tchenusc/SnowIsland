-- shelter_stock表结构重构迁移脚本
-- 新增字段：item_type, item_id；移除字段：item_key

-- 1. 创建临时表存储旧数据
CREATE TABLE IF NOT EXISTS `shelter_stock_old` LIKE `shelter_stock`;
INSERT INTO `shelter_stock_old` SELECT * FROM `shelter_stock`;

-- 2. 删除旧表
DROP TABLE IF EXISTS `shelter_stock`;

-- 3. 创建新表结构
CREATE TABLE `shelter_stock` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` enum('item','weapon','ammo','material') NOT NULL COMMENT '物品类型',
  `item_id` int(11) NOT NULL COMMENT '物品ID',
  `quantity` int(11) NOT NULL DEFAULT '0' COMMENT '数量',
  `created_at` datetime(6) NOT NULL COMMENT '创建时间',
  `updated_at` datetime(6) NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_item_type_item_id` (`item_type`, `item_id`),
  KEY `idx_item_type` (`item_type`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8 COMMENT='避难所物资库存表';

-- 4. 插入迁移数据
INSERT INTO `shelter_stock` (`item_type`, `item_id`, `quantity`, `created_at`, `updated_at`) VALUES
('material', 2, 45, '2026-05-12 09:58:06.806000', '2026-05-12 09:58:06.806000'),  -- wood
('material', 7, 32, '2026-05-12 09:58:06.818000', '2026-05-12 09:58:06.818000'),  -- stone
('item', 1, 80, '2026-05-12 09:58:06.819000', '2026-05-12 09:58:06.819000'),      -- medical resources
('item', 2, 4, '2026-05-12 09:58:06.819000', '2026-05-12 09:58:06.819000'),       -- flashlight
('item', 3, 2, '2026-05-12 09:58:06.820000', '2026-05-12 09:58:06.820000'),       -- handcuffs
('item', 4, 3, '2026-05-12 09:58:06.821000', '2026-05-12 09:58:06.821000'),       -- whistle
('item', 5, 1, '2026-05-12 09:58:06.821000', '2026-05-12 09:58:06.821000'),       -- body_armor
('item', 6, 1, '2026-05-12 09:58:06.822000', '2026-05-12 09:58:06.822000'),       -- composite_shield
('item', 7, 1, '2026-05-12 09:58:06.823000', '2026-05-12 09:58:06.823000'),       -- flare_gun
('item', 8, 5, '2026-05-12 09:58:06.823000', '2026-05-12 09:58:06.823000'),       -- repair_kit
('item', 9, 2, '2026-05-12 09:58:06.824000', '2026-05-12 09:58:06.824000'),       -- contract
('item', 10, 10, '2026-05-12 09:58:06.824000', '2026-05-12 09:58:06.824000'),     -- rum
('item', 11, 12, '2026-05-12 09:58:06.824000', '2026-05-12 09:58:06.824000'),     -- herbs
('item', 12, 2, '2026-05-12 09:58:06.825000', '2026-05-12 09:58:06.825000'),       -- fishing_net
('item', 13, 18, '2026-05-12 09:58:06.826000', '2026-05-12 09:58:06.826000'),     -- candle
('item', 14, 3, '2026-05-12 09:58:06.826000', '2026-05-12 09:58:06.826000'),       -- rubbing_alcohol
('item', 15, 6, '2026-05-12 09:58:06.827000', '2026-05-12 09:58:06.827000'),       -- matches
('item', 16, 4, '2026-05-12 09:58:06.828000', '2026-05-12 09:58:06.828000'),       -- pencil
('item', 17, 1, '2026-05-12 09:58:06.828000', '2026-05-12 09:58:06.828000'),       -- tattered_chart
('weapon', 1, 1, '2026-05-12 09:58:06.829000', '2026-05-12 09:58:06.829000'),       -- service_pistol
('weapon', 2, 1, '2026-05-12 09:58:06.829000', '2026-05-12 09:58:06.829000'),       -- hunting_shotgun
('weapon', 3, 2, '2026-05-12 09:58:06.830000', '2026-05-12 09:58:06.830000'),       -- baton
('weapon', 4, 1, '2026-05-12 09:58:06.830000', '2026-05-12 09:58:06.830000'),       -- bayonet
('weapon', 6, 1, '2026-05-12 09:58:06.831000', '2026-05-12 09:58:06.831000'),       -- harpoon_spear
('weapon', 7, 1, '2026-05-12 09:58:06.831000', '2026-05-12 09:58:06.831000'),       -- hunting_bow
('weapon', 8, 2, '2026-05-12 09:58:06.834000', '2026-05-12 09:58:06.834000'),       -- pickaxe
('weapon', 9, 1, '2026-05-12 09:58:06.835000', '2026-05-12 09:58:06.835000'),       -- axe
('material', 4, 24, '2026-05-12 09:58:06.835000', '2026-05-12 09:58:06.835000'),    -- plank
('material', 3, 35, '2026-05-12 09:58:06.836000', '2026-05-12 09:58:06.836000');    -- rope

-- 5. 可选：删除临时表
-- DROP TABLE IF EXISTS `shelter_stock_old`;

SELECT 'shelter_stock表重构迁移完成' AS result;