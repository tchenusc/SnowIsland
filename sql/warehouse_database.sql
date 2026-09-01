-- =============================================
-- SnowIsland 仓库系统数据库
-- =============================================

USE snowisland;

-- 新增6种钥匙到item表
INSERT INTO item (id, name, unit, remark) VALUES
(19, '仓库钥匙', '把', '开启仓库的钥匙'),
(20, '燃料仓库钥匙', '把', '开启燃料仓库的钥匙'),
(21, '镇武库钥匙', '把', '开启镇武库的钥匙'),
(22, '码头集换站钥匙', '把', '开启码头集换站的钥匙'),
(23, '反叛者基地钥匙', '把', '开启反叛者基地的钥匙'),
(24, '方舟钥匙', '把', '开启方舟仓库的钥匙')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 仓库表（与shelter_stock结构一致）
DROP TABLE IF EXISTS warehouse_fuel;
DROP TABLE IF EXISTS warehouse_armory;
DROP TABLE IF EXISTS warehouse_dock;
DROP TABLE IF EXISTS warehouse_rebel;
DROP TABLE IF EXISTS warehouse_ark;
DROP TABLE IF EXISTS warehouse_general;

CREATE TABLE warehouse_general (
  id INT AUTO_INCREMENT PRIMARY KEY,
  item_type ENUM('item','weapon','ammo','material') NOT NULL,
  item_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_warehouse_general_type_item (item_type, item_id),
  KEY idx_item_type (item_type),
  KEY idx_item_id (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库-通用仓库';

CREATE TABLE warehouse_fuel (
  id INT AUTO_INCREMENT PRIMARY KEY,
  item_type ENUM('item','weapon','ammo','material') NOT NULL,
  item_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_warehouse_fuel_type_item (item_type, item_id),
  KEY idx_item_type (item_type),
  KEY idx_item_id (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库-燃料仓库';

CREATE TABLE warehouse_armory (
  id INT AUTO_INCREMENT PRIMARY KEY,
  item_type ENUM('item','weapon','ammo','material') NOT NULL,
  item_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_warehouse_armory_type_item (item_type, item_id),
  KEY idx_item_type (item_type),
  KEY idx_item_id (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库-镇武库';

CREATE TABLE warehouse_dock (
  id INT AUTO_INCREMENT PRIMARY KEY,
  item_type ENUM('item','weapon','ammo','material') NOT NULL,
  item_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_warehouse_dock_type_item (item_type, item_id),
  KEY idx_item_type (item_type),
  KEY idx_item_id (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库-码头集换站';

CREATE TABLE warehouse_rebel (
  id INT AUTO_INCREMENT PRIMARY KEY,
  item_type ENUM('item','weapon','ammo','material') NOT NULL,
  item_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_warehouse_rebel_type_item (item_type, item_id),
  KEY idx_item_type (item_type),
  KEY idx_item_id (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库-反叛者基地';

CREATE TABLE warehouse_ark (
  id INT AUTO_INCREMENT PRIMARY KEY,
  item_type ENUM('item','weapon','ammo','material') NOT NULL,
  item_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_warehouse_ark_type_item (item_type, item_id),
  KEY idx_item_type (item_type),
  KEY idx_item_id (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库-方舟仓库';

-- 仓库钥匙映射配置表
DROP TABLE IF EXISTS warehouse_config;
CREATE TABLE warehouse_config (
  id INT AUTO_INCREMENT PRIMARY KEY,
  warehouse_key VARCHAR(50) NOT NULL UNIQUE COMMENT '仓库标识键',
  warehouse_name VARCHAR(50) NOT NULL COMMENT '仓库名称',
  table_name VARCHAR(50) NOT NULL COMMENT '对应数据库表名',
  key_item_id INT NOT NULL COMMENT '对应钥匙的item表ID',
  icon VARCHAR(20) DEFAULT '' COMMENT '图标',
  sort_order INT NOT NULL DEFAULT 0 COMMENT '排序'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库配置表';

INSERT INTO warehouse_config (warehouse_key, warehouse_name, table_name, key_item_id, icon, sort_order) VALUES
('general', '通用仓库', 'warehouse_general', 19, 'box', 1),
('fuel', '燃料仓库', 'warehouse_fuel', 20, 'fuel', 2),
('armory', '镇武库', 'warehouse_armory', 21, 'sword', 3),
('dock', '码头集换站', 'warehouse_dock', 22, 'anchor', 4),
('rebel', '反叛者基地', 'warehouse_rebel', 23, 'flag', 5),
('ark', '方舟仓库', 'warehouse_ark', 24, 'ship', 6);

-- 开局库存（《仓库物资.doc》）
INSERT INTO warehouse_fuel (item_type, item_id, quantity) VALUES
('material', 8, 500),
('material', 2, 50000),
('item', 15, 2),
('item', 13, 20),
('item', 2, 8),
('material', 6, 50);

INSERT INTO warehouse_armory (item_type, item_id, quantity) VALUES
('weapon', 1, 2),
('ammo', 1, 4),
('weapon', 2, 1),
('ammo', 2, 2),
('weapon', 7, 1),
('ammo', 4, 4),
('weapon', 4, 2),
('weapon', 3, 3),
('item', 6, 4),
('item', 5, 1),
('item', 3, 2),
('material', 12, 1);

INSERT INTO warehouse_general (item_type, item_id, quantity) VALUES
('material', 1, 50000),
('material', 2, 5000),
('material', 7, 5000),
('material', 4, 100),
('material', 3, 100),
('material', 9, 100),
('weapon', 8, 2),
('weapon', 9, 1),
('item', 8, 2),
('material', 12, 1);

INSERT INTO warehouse_dock (item_type, item_id, quantity) VALUES
('material', 5, 800),
('item', 18, 1),
('item', 10, 20),
('item', 14, 5),
('item', 1, 20),
('item', 11, 3),
('item', 12, 1),
('weapon', 6, 2),
('item', 7, 1),
('ammo', 3, 2),
('item', 17, 1),
('material', 11, 3);

INSERT INTO warehouse_rebel (item_type, item_id, quantity) VALUES
('weapon', 2, 1),
('ammo', 2, 2),
('weapon', 7, 2),
('ammo', 4, 4),
('material', 6, 20);

INSERT INTO warehouse_ark (item_type, item_id, quantity) VALUES
('weapon', 7, 2),
('ammo', 4, 12),
('weapon', 6, 1),
('weapon', 1, 1),
('ammo', 1, 2);
