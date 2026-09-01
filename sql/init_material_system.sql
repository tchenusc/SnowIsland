-- 物资管理系统初始化脚本
USE snowisland;

-- 创建道具表 (item)
CREATE TABLE IF NOT EXISTS item (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    unit VARCHAR(20) NOT NULL,
    remark TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建武器表 (weapon)
CREATE TABLE IF NOT EXISTS weapon (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    unit VARCHAR(20) NOT NULL,
    remark TEXT NULL,
    threat_level INT(11) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建子弹表 (ammo)
CREATE TABLE IF NOT EXISTS ammo (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    unit VARCHAR(20) NOT NULL,
    remark TEXT NULL,
    weapon_id INT(11) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (weapon_id) REFERENCES weapon(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建物资表 (material)
CREATE TABLE IF NOT EXISTS material (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    unit VARCHAR(20) NOT NULL,
    remark TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建玩家物资关联表 (player_items)
CREATE TABLE IF NOT EXISTS player_items (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    player_id INT(11) NOT NULL,
    item_type ENUM('item', 'weapon', 'ammo', 'material') NOT NULL,
    item_id INT(11) NOT NULL,
    quantity INT(11) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES player(id),
    INDEX idx_player_type_item (player_id, item_type, item_id),
    INDEX idx_player_type (player_id, item_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入道具数据
INSERT INTO item (name, unit, remark) VALUES
('医疗资源', '份', '基础医疗物资，急救重伤需5份'),
('手电筒', '个', '提供光源'),
('手铐', '个', '限制行动'),
('哨子', '个', '发出信号'),
('防弹衣', '件', '减少伤害'),
('复合盾', '个', '提供防护'),
('信号枪', '把', '发射信号'),
('维修工具包', '个', '修复物品'),
('协议书', '个', '重要文件'),
('朗姆酒', '瓶', '恢复精力'),
('草药', '个', '治疗小伤口'),
('渔网', '张', '捕鱼工具'),
('蜡烛', '根', '提供光源'),
('医用酒精', '升', '消毒用品'),
('火柴', '盒', '点火工具'),
('铅笔', '盒', '书写工具'),
('破损海图', '张', '导航参考'),
('面包', '份', '额外白天行动点'),
('仓库钥匙', '把', '仓库通行'),
('燃料仓库钥匙', '把', '燃料仓库通行'),
('镇武库钥匙', '把', '镇武库通行'),
('码头集购站钥匙', '把', '码头集购站通行');

-- 插入武器数据
INSERT INTO weapon (name, unit, remark, threat_level) VALUES
('制式手枪', '把', '标准配备', 5),
('猎枪', '把', '威力较大', 8),
('警棍', '个', '非致命武器', 3),
('刺刀', '把', '近战武器', 4),
('水手刀', '把', '多功能刀具', 3),
('鱼叉/矛', '个', '狩猎工具', 6),
('猎弓', '张', '远程武器', 5),
('十字镐', '把', '挖掘工具', 4),
('斧头', '把', '砍伐工具', 6),
('电锯', '把', '切割工具', 7),
('手术刀', '把', '医疗工具', 2),
('炸药', 'kg', '爆炸物', 10);

-- 插入子弹数据
INSERT INTO ammo (name, unit, remark, weapon_id) VALUES
('手枪弹', '枚', '制式手枪子弹', 1),
('猎枪弹', '枚', '猎枪子弹', 2),
('信号弹', '枚', '信号枪子弹', 7),
('箭矢', '枝', '猎弓箭矢', 7);

-- 插入物资数据
INSERT INTO material (name, unit, remark) VALUES
('金属制品', 'kg', '可用于制作工具'),
('木材', 'kg', '可用于建造'),
('绳索', '米', '多种用途'),
('木板', 'kg', '建筑材料'),
('食物', 'kg', '恢复饥饿'),
('沥青', 'kg', '建筑材料'),
('石料', 'kg', '建筑材料'),
('燃料', 'kg', '提供能源'),
('帆布', '米', '制作帐篷'),
('发动机', '个', '机械动力'),
('螺旋桨', '个', '船只推进'),
('发电机', '个', '发电设备');

-- 插入玩家物资关联数据（玩家1）
INSERT INTO player_items (player_id, item_type, item_id, quantity) VALUES
(1, 'item', 1, 30),  -- 医疗资源 x30
(1, 'item', 2, 1),  -- 手电筒 x1
(1, 'item', 5, 1),  -- 防弹衣 x1
(1, 'weapon', 1, 1),  -- 制式手枪 x1
(1, 'weapon', 3, 1),  -- 警棍 x1
(1, 'weapon', 11, 1),  -- 手术刀 x1（测试）
(1, 'ammo', 1, 30),  -- 手枪弹 x30
(1, 'material', 1, 5),  -- 金属制品 x5
(1, 'material', 2, 10);  -- 木材 x10

-- 插入玩家物资关联数据（玩家2）
INSERT INTO player_items (player_id, item_type, item_id, quantity) VALUES
(2, 'item', 4, 2),  -- 哨子 x2
(2, 'item', 7, 1),  -- 信号枪 x1
(2, 'weapon', 2, 1),  -- 猎枪 x1
(2, 'weapon', 6, 1),  -- 鱼叉/矛 x1
(2, 'ammo', 2, 10),  -- 猎枪弹 x10
(2, 'ammo', 3, 5),  -- 信号弹 x5
(2, 'material', 3, 20),  -- 绳索 x20
(2, 'material', 5, 8);  -- 食物 x8

-- 插入玩家物资关联数据（玩家3）
INSERT INTO player_items (player_id, item_type, item_id, quantity) VALUES
(3, 'item', 8, 1),  -- 维修工具包 x1
(3, 'item', 10, 2),  -- 朗姆酒 x2
(3, 'weapon', 4, 1),  -- 刺刀 x1
(3, 'weapon', 8, 1),  -- 十字镐 x1
(3, 'material', 4, 15),  -- 木板 x15
(3, 'material', 6, 5),  -- 沥青 x5
(3, 'material', 9, 10);  -- 帆布 x10

-- 插入玩家物资关联数据（玩家4）
INSERT INTO player_items (player_id, item_type, item_id, quantity) VALUES
(4, 'item', 3, 1),  -- 手铐 x1
(4, 'item', 12, 1),  -- 渔网 x1
(4, 'weapon', 5, 1),  -- 水手刀 x1
(4, 'weapon', 7, 1),  -- 猎弓 x1
(4, 'ammo', 4, 20),  -- 箭矢 x20
(4, 'material', 7, 20),  -- 石料 x20
(4, 'material', 8, 10);  -- 燃料 x10

-- 插入玩家物资关联数据（玩家5）
INSERT INTO player_items (player_id, item_type, item_id, quantity) VALUES
(5, 'item', 6, 1),  -- 复合盾 x1
(5, 'item', 14, 1),  -- 医用酒精 x1
(5, 'weapon', 9, 1),  -- 斧头 x1
(5, 'weapon', 10, 1),  -- 电锯 x1
(5, 'material', 10, 1),  -- 发动机 x1
(5, 'material', 11, 1),  -- 螺旋桨 x1
(5, 'material', 12, 1);  -- 发电机 x1