-- 交易系统数据库初始化脚本
USE snowisland;

-- 创建交易表 (trade)
CREATE TABLE IF NOT EXISTS trade (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    from_player_id INT(11) NOT NULL COMMENT '发起方玩家ID',
    to_player_id INT(11) NOT NULL COMMENT '接收方玩家ID',
    status ENUM('pending', 'accepted', 'rejected', 'cancelled', 'completed') NOT NULL DEFAULT 'pending' COMMENT '交易状态：pending-交易中, accepted-已接受, rejected-已拒绝, cancelled-交易中止, completed-交易成功',
    remark TEXT NULL COMMENT '交易备注',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (from_player_id) REFERENCES player(id),
    FOREIGN KEY (to_player_id) REFERENCES player(id),
    INDEX idx_from_player (from_player_id),
    INDEX idx_to_player (to_player_id),
    INDEX idx_status (status),
    INDEX idx_from_to_status (from_player_id, to_player_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='交易主表';

-- 创建交易物品表 (trade_items)
CREATE TABLE IF NOT EXISTS trade_items (
    id INT(11) PRIMARY KEY AUTO_INCREMENT,
    trade_id INT(11) NOT NULL COMMENT '关联的交易ID',
    item_type ENUM('item', 'weapon', 'ammo', 'material') NOT NULL COMMENT '物品类型',
    item_id INT(11) NOT NULL COMMENT '物品ID',
    quantity INT(11) NOT NULL DEFAULT 1 COMMENT '物品数量',
    direction ENUM('give', 'take') NOT NULL COMMENT '物品方向：give-给予, take-索取',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (trade_id) REFERENCES trade(id) ON DELETE CASCADE,
    INDEX idx_trade_id (trade_id),
    INDEX idx_item (item_type, item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='交易物品明细表';

-- 插入测试交易数据
-- 交易1：player1 向 player2 发起交易（交易中状态）
INSERT INTO trade (from_player_id, to_player_id, status, remark) VALUES
(1, 2, 'pending', '需要一些食物');

-- 交易1的物品
INSERT INTO trade_items (trade_id, item_type, item_id, quantity, direction) VALUES
(1, 'item', 1, 10, 'give'),  -- player1给予医疗资源 x10
(1, 'weapon', 1, 1, 'give'),  -- player1给予制式手枪 x1
(1, 'material', 5, 5, 'take');  -- player1索取食物 x5kg

-- 交易2：player3 向 player1 发起交易（已接受状态）
INSERT INTO trade (from_player_id, to_player_id, status, remark) VALUES
(3, 1, 'accepted', '换一些工具');

-- 交易2的物品
INSERT INTO trade_items (trade_id, item_type, item_id, quantity, direction) VALUES
(2, 'weapon', 4, 1, 'give'),  -- player3给予刺刀 x1
(2, 'item', 8, 1, 'take');  -- player3索取维修工具包 x1

-- 交易3：player4 向 player5 发起交易（已拒绝状态）
INSERT INTO trade (from_player_id, to_player_id, status, remark) VALUES
(4, 5, 'rejected', '想要发电机');

-- 交易3的物品
INSERT INTO trade_items (trade_id, item_type, item_id, quantity, direction) VALUES
(3, 'material', 7, 10, 'give'),  -- player4给予石料 x10kg
(3, 'material', 12, 1, 'take');  -- player4索取发电机 x1

-- 交易4：player2 向 player3 发起交易（交易中止状态）
INSERT INTO trade (from_player_id, to_player_id, status, remark) VALUES
(2, 3, 'cancelled', '物资不匹配');

-- 交易4的物品
INSERT INTO trade_items (trade_id, item_type, item_id, quantity, direction) VALUES
(4, 'item', 4, 2, 'give'),  -- player2给予哨子 x2
(4, 'ammo', 2, 5, 'take');  -- player2索取猎枪弹 x5

-- 交易5：player5 向 player1 发起交易（交易成功状态）
INSERT INTO trade (from_player_id, to_player_id, status, remark) VALUES
(5, 1, 'completed', '完成了交易');

-- 交易5的物品
INSERT INTO trade_items (trade_id, item_type, item_id, quantity, direction) VALUES
(5, 'weapon', 9, 1, 'give'),  -- player5给予斧头 x1
(5, 'weapon', 3, 1, 'take');  -- player5索取警棍 x1
