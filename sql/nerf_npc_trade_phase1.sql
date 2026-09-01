-- Phase 1 trade nerf: catalog quantities / favor gates (existing DBs)
SET NAMES utf8mb4;

-- NPC1: pay more fuel-like material, get less food; supply needs favor>=20
UPDATE `npc_trade_config`
SET `quantity` = 8
WHERE `id` = 137 AND `config_type` = 'demand';

UPDATE `npc_trade_config`
SET `quantity` = 2, `min_favor` = 20
WHERE `id` = 138 AND `config_type` = 'supply';

-- NPC2: medical resources cost 20; metal supply 50→12 and favor>=40
UPDATE `npc_trade_config`
SET `quantity` = 20
WHERE `id` = 139 AND `config_type` = 'demand';

UPDATE `npc_trade_config`
SET `quantity` = 12, `min_favor` = 40
WHERE `id` = 140 AND `config_type` = 'supply';
