-- NPC物资交易系统迁移脚本
-- 版本: 1.0
-- 日期: 2026-06-22

-- 1. 扩展location_npc表，添加每日交易上限字段
ALTER TABLE location_npc
ADD COLUMN daily_trade_limit INT NOT NULL DEFAULT 1 COMMENT '每日交易上限次数' AFTER avatar_url;

-- 2. 创建NPC交易配置表（需求物资和供给物资）
CREATE TABLE IF NOT EXISTS npc_trade_config (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    npc_id INTEGER NOT NULL COMMENT 'NPC编号',
    config_type VARCHAR(20) NOT NULL COMMENT '配置类型: demand(需求)/supply(供给)',
    item_type VARCHAR(20) NOT NULL COMMENT '物资类型: item/weapon/ammo/material',
    item_id INTEGER NOT NULL COMMENT '物资编号',
    quantity INTEGER NOT NULL DEFAULT 1 COMMENT '数量',
    min_favor INTEGER DEFAULT -100 COMMENT '最低好感度要求',
    max_favor INTEGER DEFAULT 100 COMMENT '最高好感度限制',
    probability DECIMAL(5,2) DEFAULT 1.00 COMMENT '出现概率(0-1)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_npc_config_item (npc_id, config_type, item_type, item_id),
    CONSTRAINT fk_npc_trade_config_npc FOREIGN KEY (npc_id) REFERENCES location_npc(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='NPC交易配置表';

-- 3. 创建NPC交易记录表
CREATE TABLE IF NOT EXISTS npc_trade_record (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    npc_id INTEGER NOT NULL COMMENT 'NPC编号',
    player_id INTEGER NOT NULL COMMENT '玩家编号',
    game_day INTEGER NOT NULL COMMENT '交易发生的游戏天数',
    demand_items TEXT COMMENT '玩家付出的物资JSON',
    supply_items TEXT COMMENT 'NPC提供的物资JSON',
    favor_change INTEGER DEFAULT 0 COMMENT '交易带来的好感度变化',
    trade_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '交易时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_npc_player_day (npc_id, player_id, game_day),
    CONSTRAINT fk_npc_trade_record_npc FOREIGN KEY (npc_id) REFERENCES location_npc(id),
    CONSTRAINT fk_npc_trade_record_player FOREIGN KEY (player_id) REFERENCES player(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='NPC交易记录表';

-- 4. 创建NPC每日交易计数器表（用于追踪当日交易次数）
CREATE TABLE IF NOT EXISTS npc_daily_trade_count (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    npc_id INTEGER NOT NULL COMMENT 'NPC编号',
    player_id INTEGER NOT NULL COMMENT '玩家编号',
    game_day INTEGER NOT NULL COMMENT '游戏天数',
    trade_count INTEGER NOT NULL DEFAULT 0 COMMENT '当日交易次数',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_npc_player_day_count (npc_id, player_id, game_day),
    CONSTRAINT fk_npc_daily_count_npc FOREIGN KEY (npc_id) REFERENCES location_npc(id),
    CONSTRAINT fk_npc_daily_count_player FOREIGN KEY (player_id) REFERENCES player(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='NPC每日交易计数器表';

-- 5. 初始化示例数据（为现有NPC添加默认交易配置）
-- 假设NPC 1是一个商人，需要食物/燃料，提供道具和材料
INSERT INTO npc_trade_config (npc_id, config_type, item_type, item_id, quantity, min_favor, max_favor, probability) VALUES
-- NPC 1 的需求（需要食物和燃料）
(1, 'demand', 'material', 5, 10, -100, 100, 1.00),  -- 食物 10kg
(1, 'demand', 'material', 8, 5, -100, 100, 1.00),   -- 燃料 5kg

-- NPC 1 的供给（提供医疗资源、金属制品、木材）
(1, 'supply', 'item', 1, 10, -100, 100, 0.80),      -- 医疗资源 x10
(1, 'supply', 'material', 1, 5, -50, 100, 0.70),    -- 金属制品 x5
(1, 'supply', 'material', 2, 8, -50, 100, 0.70),    -- 木材 x8
(1, 'supply', 'item', 8, 1, 20, 100, 0.50),        -- 维修工具包 x1（需要友善以上）
(1, 'supply', 'weapon', 1, 1, 60, 100, 0.30),       -- 制式手枪 x1（需要亲近）

-- NPC 2 的需求
(2, 'demand', 'material', 5, 8, -100, 100, 1.00),   -- 食物 8kg

-- NPC 2 的供给
(2, 'supply', 'material', 3, 10, -100, 100, 0.80),  -- 绳索 x10
(2, 'supply', 'item', 12, 1, -50, 100, 0.60),       -- 渔网 x1
(2, 'supply', 'material', 9, 5, 20, 100, 0.50),     -- 帆布 x5

-- NPC 3 的需求
(3, 'demand', 'material', 8, 8, -100, 100, 1.00),   -- 燃料 8kg

-- NPC 3 的供给
(3, 'supply', 'material', 12, 1, -50, 100, 0.50),   -- 发电机 x1
(3, 'supply', 'material', 10, 1, 20, 100, 0.40),    -- 发动机 x1
(3, 'supply', 'item', 15, 2, -100, 100, 0.70)       -- 点火工具 x2

ON DUPLICATE KEY UPDATE
    quantity = VALUES(quantity),
    min_favor = VALUES(min_favor),
    max_favor = VALUES(max_favor),
    probability = VALUES(probability);