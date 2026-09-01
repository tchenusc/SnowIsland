/*
Navicat MySQL Data Transfer

Source Server         : cc
Source Server Version : 50717
Source Host           : localhost:3306
Source Database       : snowisland

Target Server Type    : MYSQL
Target Server Version : 50717
File Encoding         : 65001

Date: 2026-05-14 14:15:52
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for ammo
-- ----------------------------
DROP TABLE IF EXISTS `ammo`;
CREATE TABLE `ammo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `remark` text,
  `weapon_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `weapon_id` (`weapon_id`),
  CONSTRAINT `ammo_ibfk_1` FOREIGN KEY (`weapon_id`) REFERENCES `weapon` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of ammo
-- ----------------------------
INSERT INTO `ammo` VALUES ('1', '手枪弹', '枚', '制式手枪子弹', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `ammo` VALUES ('2', '猎枪弹', '枚', '猎枪子弹', '2', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `ammo` VALUES ('3', '信号弹', '枚', '信号枪子弹', '7', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `ammo` VALUES ('4', '箭矢', '枝', '猎弓箭矢', '7', '2026-04-27 11:36:23', '2026-04-27 11:36:23');

-- ----------------------------
-- Table structure for ark_config
-- ----------------------------
DROP TABLE IF EXISTS `ark_config`;
CREATE TABLE `ark_config` (
  `id` int(11) NOT NULL,
  `ark_status` varchar(20) DEFAULT NULL,
  `base_capacity` int(11) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `current_game_day` int(11) DEFAULT NULL,
  `daily_asphalt_limit` decimal(10,2) DEFAULT NULL,
  `daily_metal_limit` decimal(10,2) DEFAULT NULL,
  `daily_wood_limit` decimal(10,2) DEFAULT NULL,
  `food_per_capacity` int(11) DEFAULT NULL,
  `fuel_per_capacity` decimal(5,2) DEFAULT NULL,
  `initial_metal` decimal(10,2) DEFAULT NULL,
  `initial_wood` decimal(10,2) DEFAULT NULL,
  `sail_canvas_required` decimal(10,2) DEFAULT NULL,
  `sail_days_0_engine` int(11) DEFAULT NULL,
  `sail_days_1_engine` int(11) DEFAULT NULL,
  `sail_days_2_engine` int(11) DEFAULT NULL,
  `sail_days_3_engine` int(11) DEFAULT NULL,
  `sail_days_with_sail_0_engine` int(11) DEFAULT NULL,
  `sail_days_with_sail_1_engine` int(11) DEFAULT NULL,
  `sail_rope_required` decimal(10,2) DEFAULT NULL,
  `sail_wood_per_capacity` decimal(5,2) DEFAULT NULL,
  `sealant_per_capacity` decimal(5,2) DEFAULT NULL,
  `shortage_capacity_penalty` int(11) DEFAULT NULL,
  `shortage_completion_penalty` decimal(4,2) DEFAULT NULL,
  `target_asphalt` decimal(10,2) DEFAULT NULL,
  `target_metal` decimal(10,2) DEFAULT NULL,
  `target_wood` decimal(10,2) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `work_asphalt_per_unit` decimal(5,2) DEFAULT NULL,
  `work_metal_per_unit` decimal(5,2) DEFAULT NULL,
  `work_wood_per_unit` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of ark_config
-- ----------------------------
INSERT INTO `ark_config` VALUES ('1', 'building', '50', '2026-05-13 21:35:13.589000', '1', '20.00', '20.00', '30.00', '100', '2.00', '20.00', '10.00', '80.00', '10', '8', '6', '4', '10', '7', '100.00', '2.00', '500.00', '3', '2.50', '100.00', '100.00', '250.00', '2026-05-13 21:35:13.589000', '5.00', '5.00', '5.00');

-- ----------------------------
-- Table structure for ark_construction
-- ----------------------------
DROP TABLE IF EXISTS `ark_construction`;
CREATE TABLE `ark_construction` (
  `id` int(11) NOT NULL DEFAULT '1' COMMENT '单方舟模式，固定值为1',
  `current_wood` int(11) NOT NULL DEFAULT '0' COMMENT '当前木材数量（吨）',
  `current_metal` int(11) NOT NULL DEFAULT '0' COMMENT '当前金属制品数量（吨）',
  `current_sealant` int(11) NOT NULL DEFAULT '0' COMMENT '当前密封材料数量（kg）',
  `engine_count` int(11) NOT NULL DEFAULT '0' COMMENT '发动机数量（0-3）',
  `propeller_count` int(11) NOT NULL DEFAULT '0' COMMENT '螺旋桨数量',
  `generator_count` int(11) NOT NULL DEFAULT '0' COMMENT '发电机数量',
  `current_cargo_capacity` int(11) NOT NULL DEFAULT '0' COMMENT '当前载重能力',
  `completion_percentage` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '完成度百分比',
  `has_sail` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已建造帆',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='方舟建造进度表';

-- ----------------------------
-- Records of ark_construction
-- ----------------------------
INSERT INTO `ark_construction` VALUES ('1', '108', '100', '75', '2', '2', '0', '44', '74.55', '1', '2026-05-13 22:06:35', '2026-05-14 13:35:30');

-- ----------------------------
-- Table structure for ark_construction_log
-- ----------------------------
DROP TABLE IF EXISTS `ark_construction_log`;
CREATE TABLE `ark_construction_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_description` varchar(255) DEFAULT NULL,
  `action_type` varchar(30) NOT NULL,
  `asphalt_change` decimal(10,2) DEFAULT NULL,
  `capacity_change` int(11) DEFAULT NULL,
  `completion_change` decimal(5,2) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `current_capacity` int(11) DEFAULT NULL,
  `current_completion` decimal(5,2) DEFAULT NULL,
  `current_stage` varchar(30) DEFAULT NULL,
  `engine_installed` int(11) DEFAULT NULL,
  `game_day` int(11) NOT NULL,
  `generator_installed` int(11) DEFAULT NULL,
  `metal_change` decimal(10,2) DEFAULT NULL,
  `player_id` int(11) NOT NULL,
  `player_name` varchar(50) DEFAULT NULL,
  `previous_capacity` int(11) DEFAULT NULL,
  `previous_completion` decimal(5,2) DEFAULT NULL,
  `previous_stage` varchar(30) DEFAULT NULL,
  `propeller_installed` int(11) DEFAULT NULL,
  `sail_built` bit(1) DEFAULT NULL,
  `sail_canvas_used` decimal(10,2) DEFAULT NULL,
  `sail_rope_used` decimal(10,2) DEFAULT NULL,
  `wood_change` decimal(10,2) DEFAULT NULL,
  `work_units` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of ark_construction_log
-- ----------------------------

-- ----------------------------
-- Table structure for ark_required_skill
-- ----------------------------
DROP TABLE IF EXISTS `ark_required_skill`;
CREATE TABLE `ark_required_skill` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `effect_bonus` int(11) DEFAULT NULL,
  `is_required` bit(1) DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  `skill_code` varchar(50) NOT NULL,
  `skill_description` varchar(255) DEFAULT NULL,
  `skill_name` varchar(100) NOT NULL,
  `skill_type` varchar(20) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_5af48mct3mcot3g68dq9chwoh` (`skill_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of ark_required_skill
-- ----------------------------

-- ----------------------------
-- Table structure for ark_sail
-- ----------------------------
DROP TABLE IF EXISTS `ark_sail`;
CREATE TABLE `ark_sail` (
  `id` int(11) NOT NULL,
  `built_at_game_day` int(11) DEFAULT NULL,
  `built_by_player_id` int(11) DEFAULT NULL,
  `collected_canvas` decimal(10,2) DEFAULT NULL,
  `collected_rope` decimal(10,2) DEFAULT NULL,
  `condition_status` varchar(20) DEFAULT NULL,
  `construction_progress` decimal(5,2) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `effect_0_engine_days` int(11) DEFAULT NULL,
  `effect_1_engine_days` int(11) DEFAULT NULL,
  `is_built` bit(1) DEFAULT NULL,
  `is_work_completed` bit(1) DEFAULT NULL,
  `last_repaired_day` int(11) DEFAULT NULL,
  `required_canvas` decimal(10,2) DEFAULT NULL,
  `required_rope` decimal(10,2) DEFAULT NULL,
  `requires_work_action` bit(1) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `work_action_player_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of ark_sail
-- ----------------------------
INSERT INTO `ark_sail` VALUES ('1', null, null, '0.00', '0.00', 'normal', '0.00', '2026-05-13 21:35:13.618000', '10', '7', '\0', '\0', null, '80.00', '100.00', '', '2026-05-13 21:35:13.618000', null);

-- ----------------------------
-- Table structure for ark_voyage
-- ----------------------------
DROP TABLE IF EXISTS `ark_voyage`;
CREATE TABLE `ark_voyage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `actual_return_day` int(11) DEFAULT NULL,
  `base_sail_days` int(11) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `crisis_count` int(11) DEFAULT NULL,
  `crisis_events` text,
  `current_day_offset` int(11) DEFAULT NULL,
  `departed_at` datetime(6) DEFAULT NULL,
  `departure_day` int(11) NOT NULL,
  `engine_count` int(11) DEFAULT NULL,
  `final_bonus` int(11) DEFAULT NULL,
  `final_sail_days` int(11) DEFAULT NULL,
  `food_loaded` decimal(10,2) DEFAULT NULL,
  `fuel_loaded` decimal(10,2) DEFAULT NULL,
  `has_fisher` bit(1) DEFAULT NULL,
  `has_generator` bit(1) DEFAULT NULL,
  `has_navigator` bit(1) DEFAULT NULL,
  `has_sail` bit(1) DEFAULT NULL,
  `has_weather_watcher` bit(1) DEFAULT NULL,
  `notes` text,
  `passenger_count` int(11) DEFAULT NULL,
  `passenger_list` text,
  `planned_return_day` int(11) DEFAULT NULL,
  `propeller_count` int(11) DEFAULT NULL,
  `returned_at` datetime(6) DEFAULT NULL,
  `sealant_loaded` decimal(10,2) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `total_capacity` int(11) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `voyage_number` int(11) NOT NULL,
  `voyage_result` varchar(50) DEFAULT NULL,
  `wood_loaded` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of ark_voyage
-- ----------------------------

-- ----------------------------
-- Table structure for catastrophe_card
-- ----------------------------
DROP TABLE IF EXISTS `catastrophe_card`;
CREATE TABLE `catastrophe_card` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_number` int(11) NOT NULL COMMENT '卡牌编号',
  `name` varchar(50) NOT NULL COMMENT '卡牌名称',
  `description` text NOT NULL COMMENT '卡牌描述',
  `effect_type` varchar(50) DEFAULT NULL COMMENT '效果类型',
  `effect_param1` int(11) DEFAULT '0' COMMENT '效果参数1',
  `effect_param2` int(11) DEFAULT '0' COMMENT '效果参数2',
  `effect_param3` varchar(100) DEFAULT NULL COMMENT '效果参数3（字符串）',
  `is_unique` tinyint(1) DEFAULT '0' COMMENT '是否唯一卡牌',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `card_number` (`card_number`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COMMENT='天灾牌表';

-- ----------------------------
-- Records of catastrophe_card
-- ----------------------------
INSERT INTO `catastrophe_card` VALUES ('1', '1', '低温侵袭', '某处墙体结冰，寒气渗入。本天所有燃料消耗增加20%，木材消耗量15kg→18kg。', 'CONSUMPTION_INCREASE', '20', '15', '18', '0', '2026-05-14 11:53:11', '2026-05-14 11:53:11');
INSERT INTO `catastrophe_card` VALUES ('2', '2', '灾难蔓延', '增加5天暴雪持续时间', 'EXTEND_STORM', '5', '0', '', '0', '2026-05-14 11:53:11', '2026-05-14 11:53:11');
INSERT INTO `catastrophe_card` VALUES ('3', '3', '粮仓鼠患', '仓库中储存的粮食被老鼠啃食，损失10%的食物储备（向下取整）', 'FOOD_LOSS', '10', '0', '', '0', '2026-05-14 11:53:11', '2026-05-14 11:53:11');
INSERT INTO `catastrophe_card` VALUES ('4', '4', '燃料泄漏', '储油桶老化破裂，损失一处仓库的10%的燃料储备（优先扣除煤油/燃油）', 'FUEL_LOSS', '10', '0', '', '0', '2026-05-14 11:53:11', '2026-05-14 11:53:11');
INSERT INTO `catastrophe_card` VALUES ('5', '5', '工具锈蚀', '生产工具普遍老化。当天所有生产行动（渔猎、伐木、挖矿等）产量-20%。', 'PRODUCTION_DECREASE', '20', '0', '', '0', '2026-05-14 11:53:11', '2026-05-14 11:53:11');
INSERT INTO `catastrophe_card` VALUES ('6', '6', '海水倒灌', '风暴潮淹没码头设施，沿海仓库的部分物资被冲走（损失10%），方舟受损10%', 'DOCK_DAMAGE', '10', '10', '', '0', '2026-05-14 11:53:11', '2026-05-14 11:53:11');
INSERT INTO `catastrophe_card` VALUES ('7', '7', '水源污染', '岛上淡水水源被动物尸体污染，所有玩家当天需额外消耗1升煤油（烧开水）或面临患病风险', 'WATER_CONTAMINATION', '1', '0', '', '0', '2026-05-14 11:53:11', '2026-05-14 11:53:11');
INSERT INTO `catastrophe_card` VALUES ('8', '8', '信仰崩塌', '神父以及占卜师等精神领袖陷入自我怀疑，当天无法使用“布道”或“占星”技能。若第三天抽中不影响终局结算加成。', 'SKILL_DISABLE', '0', '0', '布道,占星', '0', '2026-05-14 11:53:11', '2026-05-14 11:53:11');
INSERT INTO `catastrophe_card` VALUES ('9', '9', '燃料受潮', '露天堆放的木柴被雨淋湿。随机一个仓库或玩家损失30kg木材。', 'WOOD_LOSS', '30', '0', '', '0', '2026-05-14 11:53:11', '2026-05-14 11:53:11');
INSERT INTO `catastrophe_card` VALUES ('10', '10', '逃役', '一名劳工趁夜色逃走了。统治者当天指定的劳工名单中，随机一人自动失效（不会劳作，也不会计入劳工）。主持人随机选择，不公开是谁。该玩家知道自己被逃役释放，当天正常进行行动。', 'ESCAPE_LABOR', '0', '0', '', '0', '2026-05-14 11:53:11', '2026-05-14 11:53:11');
INSERT INTO `catastrophe_card` VALUES ('11', '11', '祭品', '有人在教堂门口发现一只被割喉的黑羊。第二天必定触发一张额外天灾牌（命运在积蓄）。', 'EXTRA_CARD', '1', '0', '', '0', '2026-05-14 11:53:11', '2026-05-14 11:53:11');

-- ----------------------------
-- Table structure for catastrophe_deck
-- ----------------------------
DROP TABLE IF EXISTS `catastrophe_deck`;
CREATE TABLE `catastrophe_deck` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_id` int(11) NOT NULL COMMENT '天灾牌ID',
  `is_drawn` tinyint(1) DEFAULT '0' COMMENT '是否已抽取',
  `is_used` tinyint(1) DEFAULT '0' COMMENT '是否已使用',
  `drawn_at` datetime DEFAULT NULL COMMENT '抽取时间',
  `used_at` datetime DEFAULT NULL COMMENT '使用时间',
  `round_used` int(11) DEFAULT '0' COMMENT '使用回合',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `card_id` (`card_id`),
  CONSTRAINT `catastrophe_deck_ibfk_1` FOREIGN KEY (`card_id`) REFERENCES `catastrophe_card` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COMMENT='天灾牌组管理表';

-- ----------------------------
-- Records of catastrophe_deck
-- ----------------------------
INSERT INTO `catastrophe_deck` VALUES ('1', '1', '1', '0', '2026-05-14 14:12:24', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:24');
INSERT INTO `catastrophe_deck` VALUES ('2', '1', '1', '0', '2026-05-14 14:12:22', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:22');
INSERT INTO `catastrophe_deck` VALUES ('3', '1', '1', '1', '2026-05-14 14:00:34', '2026-05-14 14:02:22', '1', '2026-05-14 11:53:12', '2026-05-14 14:02:22');
INSERT INTO `catastrophe_deck` VALUES ('4', '2', '1', '0', '2026-05-14 13:44:28', null, '0', '2026-05-14 11:53:12', '2026-05-14 13:44:28');
INSERT INTO `catastrophe_deck` VALUES ('5', '2', '1', '0', '2026-05-14 11:54:49', null, '0', '2026-05-14 11:53:12', '2026-05-14 11:54:49');
INSERT INTO `catastrophe_deck` VALUES ('6', '2', '1', '0', '2026-05-14 14:12:15', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:15');
INSERT INTO `catastrophe_deck` VALUES ('7', '3', '1', '0', '2026-05-14 14:12:24', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:24');
INSERT INTO `catastrophe_deck` VALUES ('8', '3', '1', '0', '2026-05-14 13:44:41', null, '0', '2026-05-14 11:53:12', '2026-05-14 13:44:41');
INSERT INTO `catastrophe_deck` VALUES ('9', '3', '1', '0', '2026-05-14 14:10:31', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:10:31');
INSERT INTO `catastrophe_deck` VALUES ('10', '4', '1', '0', '2026-05-14 11:54:49', null, '0', '2026-05-14 11:53:12', '2026-05-14 11:54:49');
INSERT INTO `catastrophe_deck` VALUES ('11', '4', '1', '0', '2026-05-14 13:41:55', null, '0', '2026-05-14 11:53:12', '2026-05-14 13:41:55');
INSERT INTO `catastrophe_deck` VALUES ('12', '4', '1', '0', '2026-05-14 14:10:31', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:10:31');
INSERT INTO `catastrophe_deck` VALUES ('13', '5', '1', '0', '2026-05-14 11:54:49', null, '0', '2026-05-14 11:53:12', '2026-05-14 11:54:49');
INSERT INTO `catastrophe_deck` VALUES ('14', '5', '1', '0', '2026-05-14 13:41:54', null, '0', '2026-05-14 11:53:12', '2026-05-14 13:41:55');
INSERT INTO `catastrophe_deck` VALUES ('15', '5', '1', '1', '2026-05-14 13:44:41', '2026-05-14 13:51:05', '1', '2026-05-14 11:53:12', '2026-05-14 13:51:05');
INSERT INTO `catastrophe_deck` VALUES ('16', '6', '1', '0', '2026-05-14 13:44:28', null, '0', '2026-05-14 11:53:12', '2026-05-14 13:44:28');
INSERT INTO `catastrophe_deck` VALUES ('17', '6', '1', '0', '2026-05-14 13:44:28', null, '0', '2026-05-14 11:53:12', '2026-05-14 13:44:28');
INSERT INTO `catastrophe_deck` VALUES ('18', '6', '1', '1', '2026-05-14 14:00:34', '2026-05-14 14:03:15', '1', '2026-05-14 11:53:12', '2026-05-14 14:03:15');
INSERT INTO `catastrophe_deck` VALUES ('19', '7', '1', '0', '2026-05-14 14:12:15', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:15');
INSERT INTO `catastrophe_deck` VALUES ('20', '7', '1', '0', '2026-05-14 14:12:18', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:18');
INSERT INTO `catastrophe_deck` VALUES ('21', '7', '1', '0', '2026-05-14 14:00:34', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:00:34');
INSERT INTO `catastrophe_deck` VALUES ('22', '8', '1', '0', '2026-05-14 13:44:26', null, '0', '2026-05-14 11:53:12', '2026-05-14 13:44:26');
INSERT INTO `catastrophe_deck` VALUES ('23', '8', '1', '0', '2026-05-14 14:12:22', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:22');
INSERT INTO `catastrophe_deck` VALUES ('24', '8', '1', '0', '2026-05-14 14:12:15', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:15');
INSERT INTO `catastrophe_deck` VALUES ('25', '9', '1', '0', '2026-05-14 14:12:18', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:18');
INSERT INTO `catastrophe_deck` VALUES ('26', '9', '1', '0', '2026-05-14 13:44:26', null, '0', '2026-05-14 11:53:12', '2026-05-14 13:44:26');
INSERT INTO `catastrophe_deck` VALUES ('27', '9', '1', '0', '2026-05-14 14:12:24', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:24');
INSERT INTO `catastrophe_deck` VALUES ('28', '10', '1', '0', '2026-05-14 14:12:22', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:22');
INSERT INTO `catastrophe_deck` VALUES ('29', '10', '1', '0', '2026-05-14 14:12:18', null, '0', '2026-05-14 11:53:12', '2026-05-14 14:12:18');
INSERT INTO `catastrophe_deck` VALUES ('30', '10', '1', '0', '2026-05-14 13:44:26', null, '0', '2026-05-14 11:53:12', '2026-05-14 13:44:26');
INSERT INTO `catastrophe_deck` VALUES ('31', '11', '1', '1', '2026-05-14 13:44:41', '2026-05-14 13:53:27', '1', '2026-05-14 11:53:12', '2026-05-14 13:53:27');
INSERT INTO `catastrophe_deck` VALUES ('32', '11', '1', '1', '2026-05-14 14:10:31', '2026-05-14 14:10:53', '1', '2026-05-14 11:53:12', '2026-05-14 14:10:53');
INSERT INTO `catastrophe_deck` VALUES ('33', '11', '1', '0', '2026-05-14 13:41:55', null, '0', '2026-05-14 11:53:12', '2026-05-14 13:41:55');

-- ----------------------------
-- Table structure for catastrophe_progress
-- ----------------------------
DROP TABLE IF EXISTS `catastrophe_progress`;
CREATE TABLE `catastrophe_progress` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `progress` int(11) NOT NULL DEFAULT '0' COMMENT '天灾进度值 0-100',
  `last_updated_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_single_record` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COMMENT='天灾进度表';

-- ----------------------------
-- Records of catastrophe_progress
-- ----------------------------
INSERT INTO `catastrophe_progress` VALUES ('1', '0', '2026-05-14 13:54:39', '2026-05-14 11:53:11', '2026-05-14 13:54:39');

-- ----------------------------
-- Table structure for drawn_cards
-- ----------------------------
DROP TABLE IF EXISTS `drawn_cards`;
CREATE TABLE `drawn_cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `draw_round` int(11) NOT NULL COMMENT '抽取轮次',
  `deck_id` int(11) NOT NULL COMMENT '牌组ID',
  `position` int(11) NOT NULL COMMENT '位置（1-3）',
  `is_selected` tinyint(1) DEFAULT '0' COMMENT '是否被选中',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_draw_position` (`draw_round`,`position`),
  KEY `deck_id` (`deck_id`),
  CONSTRAINT `drawn_cards_ibfk_1` FOREIGN KEY (`deck_id`) REFERENCES `catastrophe_deck` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COMMENT='抽取牌记录表';

-- ----------------------------
-- Records of drawn_cards
-- ----------------------------
INSERT INTO `drawn_cards` VALUES ('1', '1', '5', '1', '0', '2026-05-14 11:54:49');
INSERT INTO `drawn_cards` VALUES ('2', '1', '10', '2', '0', '2026-05-14 11:54:49');
INSERT INTO `drawn_cards` VALUES ('3', '1', '13', '3', '0', '2026-05-14 11:54:49');
INSERT INTO `drawn_cards` VALUES ('4', '2', '14', '1', '0', '2026-05-14 13:41:55');
INSERT INTO `drawn_cards` VALUES ('5', '2', '33', '2', '0', '2026-05-14 13:41:55');
INSERT INTO `drawn_cards` VALUES ('6', '2', '11', '3', '0', '2026-05-14 13:41:55');
INSERT INTO `drawn_cards` VALUES ('7', '3', '30', '1', '0', '2026-05-14 13:44:26');
INSERT INTO `drawn_cards` VALUES ('8', '3', '22', '2', '0', '2026-05-14 13:44:26');
INSERT INTO `drawn_cards` VALUES ('9', '3', '26', '3', '0', '2026-05-14 13:44:26');
INSERT INTO `drawn_cards` VALUES ('10', '4', '4', '1', '0', '2026-05-14 13:44:28');
INSERT INTO `drawn_cards` VALUES ('11', '4', '17', '2', '0', '2026-05-14 13:44:28');
INSERT INTO `drawn_cards` VALUES ('12', '4', '16', '3', '0', '2026-05-14 13:44:28');
INSERT INTO `drawn_cards` VALUES ('13', '5', '8', '1', '0', '2026-05-14 13:44:41');
INSERT INTO `drawn_cards` VALUES ('14', '5', '15', '2', '0', '2026-05-14 13:44:41');
INSERT INTO `drawn_cards` VALUES ('15', '5', '31', '3', '0', '2026-05-14 13:44:41');
INSERT INTO `drawn_cards` VALUES ('16', '6', '21', '1', '0', '2026-05-14 14:00:34');
INSERT INTO `drawn_cards` VALUES ('17', '6', '3', '2', '0', '2026-05-14 14:00:34');
INSERT INTO `drawn_cards` VALUES ('18', '6', '18', '3', '0', '2026-05-14 14:00:34');
INSERT INTO `drawn_cards` VALUES ('19', '7', '32', '1', '0', '2026-05-14 14:10:31');
INSERT INTO `drawn_cards` VALUES ('20', '7', '12', '2', '0', '2026-05-14 14:10:31');
INSERT INTO `drawn_cards` VALUES ('21', '7', '9', '3', '0', '2026-05-14 14:10:31');
INSERT INTO `drawn_cards` VALUES ('22', '8', '6', '1', '0', '2026-05-14 14:12:15');
INSERT INTO `drawn_cards` VALUES ('23', '8', '19', '2', '0', '2026-05-14 14:12:15');
INSERT INTO `drawn_cards` VALUES ('24', '8', '24', '3', '0', '2026-05-14 14:12:15');
INSERT INTO `drawn_cards` VALUES ('25', '9', '20', '1', '0', '2026-05-14 14:12:18');
INSERT INTO `drawn_cards` VALUES ('26', '9', '29', '2', '0', '2026-05-14 14:12:18');
INSERT INTO `drawn_cards` VALUES ('27', '9', '25', '3', '0', '2026-05-14 14:12:18');
INSERT INTO `drawn_cards` VALUES ('28', '10', '28', '1', '0', '2026-05-14 14:12:22');
INSERT INTO `drawn_cards` VALUES ('29', '10', '23', '2', '0', '2026-05-14 14:12:22');
INSERT INTO `drawn_cards` VALUES ('30', '10', '2', '3', '0', '2026-05-14 14:12:22');
INSERT INTO `drawn_cards` VALUES ('31', '11', '1', '1', '0', '2026-05-14 14:12:24');
INSERT INTO `drawn_cards` VALUES ('32', '11', '7', '2', '0', '2026-05-14 14:12:24');
INSERT INTO `drawn_cards` VALUES ('33', '11', '27', '3', '0', '2026-05-14 14:12:24');

-- ----------------------------
-- Table structure for game_state
-- ----------------------------
DROP TABLE IF EXISTS `game_state`;
CREATE TABLE `game_state` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `current_day` int(11) NOT NULL DEFAULT '1' COMMENT '当前天数',
  `current_phase` varchar(20) NOT NULL DEFAULT 'DAY' COMMENT '当前阶段 DAY/NIGHT',
  `is_game_over` tinyint(1) DEFAULT '0' COMMENT '游戏是否结束',
  `catastrophe_triggered` tinyint(1) DEFAULT '0' COMMENT '天灾是否已触发',
  `extra_card_due` tinyint(1) DEFAULT '0' COMMENT '是否有待触发的额外天灾牌',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_single_state` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COMMENT='游戏状态表';

-- ----------------------------
-- Records of game_state
-- ----------------------------
INSERT INTO `game_state` VALUES ('1', '1', 'DAY', '1', '1', '0', '2026-05-14 11:53:12', '2026-05-14 13:54:34');

-- ----------------------------
-- Table structure for item
-- ----------------------------
DROP TABLE IF EXISTS `item`;
CREATE TABLE `item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `remark` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of item
-- ----------------------------
INSERT INTO `item` VALUES ('1', '医疗包', '个', '恢复生命值', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('2', '手电筒', '个', '提供光源', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('3', '手铐', '个', '限制行动', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('4', '哨子', '个', '发出信号', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('5', '防弹衣', '件', '减少伤害', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('6', '复合盾', '个', '提供防护', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('7', '信号枪', '把', '发射信号', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('8', '维修工具包', '个', '修复物品', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('9', '协议书', '个', '重要文件', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('10', '朗姆酒', '瓶', '恢复精力', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('11', '草药', '个', '治疗小伤口', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('12', '渔网', '张', '捕鱼工具', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('13', '蜡烛', '根', '提供光源', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('14', '医用酒精', '升', '消毒用品', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('15', '火柴', '盒', '点火工具', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('16', '铅笔', '盒', '书写工具', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('17', '破损海图', '张', '导航参考', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `item` VALUES ('18', '面包', '份', '额外行动', '2026-04-27 11:36:23', '2026-05-02 19:26:21');

-- ----------------------------
-- Table structure for job
-- ----------------------------
DROP TABLE IF EXISTS `job`;
CREATE TABLE `job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `skills` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `description` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of job
-- ----------------------------
INSERT INTO `job` VALUES ('1', '镇长', '射击', '2026-04-26 22:13:35', '2026-05-02 22:44:25', '在密谋、暴力冲突中，如果装备远距离武器增加威胁值。如果调查玩家，可以选择在夜晚阶段骰 d6 寻找攻击机会，成功可发起小规模冲突；多人调查可袭击。');
INSERT INTO `job` VALUES ('2', '监狱长', '格斗,急救', '2026-04-26 22:13:35', '2026-05-02 22:44:37', '格斗：在密谋、暴力冲突中，如果装备近距离武器增加威胁值。急救：花费 5 医疗资源，将“枪伤”改为“受伤”标记。');
INSERT INTO `job` VALUES ('3', '警长', '射击', '2026-04-26 22:13:35', '2026-05-02 22:44:47', '在密谋、暴力冲突中，如果装备远距离武器增加威胁值。如果调查玩家，可以选择在夜晚阶段骰 d6 寻找攻击机会，成功可发起小规模冲突；多人调查可袭击。');
INSERT INTO `job` VALUES ('4', '隐藏统治者', '无', '2026-04-26 22:13:35', '2026-05-02 22:44:57', '无职业技能。');
INSERT INTO `job` VALUES ('6', '民兵', '格斗', '2026-05-02 22:47:15', '2026-05-02 22:47:15', '格斗：在密谋、暴力冲突中，如果装备近距离武器增加威胁值；调查玩家时夜晚骰 d6 寻找攻击机会，成功可发起小规模冲突；多人调查可袭击。');
INSERT INTO `job` VALUES ('7', '巡夜人', '格斗,巡逻', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '格斗：在密谋、暴力冲突中，如果装备近距离武器增加威胁值。如果调查玩家，可以选择在夜晚阶段骰 d6 寻找攻击机会，成功可发起小规模冲突；多人调查可袭击。巡逻：夜间行动，选择一个地点，当晚该地点内非统治者阵营玩家夜晚行动成功率 -30%，巡夜人知晓其行动类型；需要当天未处于“劳工/过劳”。');
INSERT INTO `job` VALUES ('8', '农户', '食物生产', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '使用牲畜设施获得食物 15 单位；或使用自留田设施获得 30 斤面粉。');
INSERT INTO `job` VALUES ('9', '伐木工', '伐木', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '使用斧头获得 10 吨原木；使用电锯获得 30 吨原木。');
INSERT INTO `job` VALUES ('10', '矿工', '挖掘', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '使用电钻获得 20 吨石料，否则 5 吨；该技能可额外增加避难所建造进度。');
INSERT INTO `job` VALUES ('11', '铁匠', '炼铁', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '职业与技能在不满 48 人时不开放；具体效果未在资料中详细说明。');
INSERT INTO `job` VALUES ('12', '手工艺人', '手工艺', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '使用工具制备单制作材料/物品/武器；制作列表包括皮带弹袋、复合盾、鱼叉矛、规制箭矢和弓弩等。');
INSERT INTO `job` VALUES ('13', '工匠', '木石工艺', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '使用木板蒸汽箱将原木转化为木板；或使用切石机将石料转化为石墙。');
INSERT INTO `job` VALUES ('14', '渔民', '捕鱼,格斗', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '捕鱼：码头使用渔船设施，获得食物 10 单位或 20kg 鱼肉。格斗：在密谋、暴力冲突中，如果装备近距离武器增加威胁值。如果调查玩家，可以选择在夜晚阶段骰 d6 寻找攻击机会，成功可发起小规模冲突；多人调查可袭击。');
INSERT INTO `job` VALUES ('15', '水手', '航海,格斗', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '航海：码头使用货船设施获得 10kg 鱼肉；亦为远洋航行必要技能，对冒险者阵营有特殊用途。格斗：在密谋、暴力冲突中，如果装备近距离武器增加威胁值。如果调查玩家，可以选择在夜晚阶段骰 d6 寻找攻击机会，成功可发起小规模冲突；多人调查可袭击。');
INSERT INTO `job` VALUES ('16', '船长', '远洋导航,射击', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '远洋导航：为方舟终局提供更好的结局倾向，并查看所有天灾牌。射击：在密谋、暴力冲突中，如果装备远距离武器增加威胁值。如果调查玩家，可以选择在夜晚阶段骰 d6 寻找攻击机会，成功可发起小规模冲突；多人调查可袭击。');
INSERT INTO `job` VALUES ('17', '装卸工', '搬运,斗殴', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '搬运：搬运量永远是其他职业的两倍。斗殴：具体效果未详细说明（推测为格斗变体）。');
INSERT INTO `job` VALUES ('18', '采珠人', '潜水,捕鱼', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '潜水：每天一次，码头使用，由主持人投 d6：1-5 获得食物 8 单位，6 获得沉船遗物。捕鱼：在码头使用渔船设施，获得食物 10 单位或 20kg 鱼肉。');
INSERT INTO `job` VALUES ('19', '神父', '布道,医疗', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '布道：每天一次，选择最多 3 人，使其下一个行动生产 +50%；或为最多 3 人消除诅咒。医疗：每天一次，选择一位或至多 5 位“受伤”玩家，花费 3 医疗资源每人消除“受伤”；选择一位或多位“过劳”玩家，花费 2 医疗资源每人消除“过劳”。');
INSERT INTO `job` VALUES ('20', '赤脚医生', '医疗,急救', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '医疗：每天一次，选择一位或至多 5 位“受伤”玩家，花费 3 医疗资源每人消除“受伤”；选择一位或多位“过劳”玩家，花费 2 医疗资源每人消除“过劳”。急救：花费 5 医疗资源，将“枪伤”改为“受伤”标记。');
INSERT INTO `job` VALUES ('21', '杂货店主', '无', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '特殊性：初始拥有大量资源和商店功能；无职业技能。');
INSERT INTO `job` VALUES ('22', '旅店店主', '烘焙', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '烘焙：需要 5 单位食物与 15kg 木材制作 1 份面包；面包当天额外获得 1 个白天行动点，每人每天限 1 次。');
INSERT INTO `job` VALUES ('23', '酒馆老板', '无', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '特殊性：初始拥有大量酒类与医用酒精；无职业技能。');
INSERT INTO `job` VALUES ('24', '灯塔看守员', '射击', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '射击：在密谋、暴力冲突中，如果装备远距离武器增加威胁值。如果调查玩家，可以选择在夜晚阶段骰 d6 寻找攻击机会，成功可发起小规模冲突；多人调查可袭击。');
INSERT INTO `job` VALUES ('25', '面包师', '烘焙', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '烘焙：需要 5 单位食物与 15kg 木材制作 1 份面包；面包当天额外获得 1 个白天行动点，每人每天限 1 次。');
INSERT INTO `job` VALUES ('26', '向导', '急救,潜行', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '急救：花费 5 医疗资源，将“枪伤”改为“受伤”标记。潜行：为谋略增加成功率，且无法被调查。');
INSERT INTO `job` VALUES ('27', '猎户', '射击,潜行', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '射击：在密谋、暴力冲突中，如果装备远距离武器增加威胁值。如果调查玩家，可以选择在夜晚阶段骰 d6 寻找攻击机会，成功可发起小规模冲突；多人调查可袭击。潜行：为谋略增加成功率，且无法被调查。');
INSERT INTO `job` VALUES ('28', '邮递员', '潜行', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '潜行：为谋略增加成功率，且无法被调查。');
INSERT INTO `job` VALUES ('29', '守墓人', '通灵', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '每天一次，与一位死亡玩家建立私信交流，由主持人保底提供信息。');
INSERT INTO `job` VALUES ('30', '气象观测员', '天气预测', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '你通过科学手段发现异常暴雪来临；可查看所有天灾牌，并为终局结算提供更好的结局倾向。');
INSERT INTO `job` VALUES ('31', '占卜师', '占星', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '为终局结算提供更好的结局倾向；可抽取一张天灾牌撕毁使其不生效，或让一张事件牌撕毁不生效。');
INSERT INTO `job` VALUES ('32', '设施维护人', '维修', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '每天一次，修复一个被破坏的设施，花费 5 维修资源。');
INSERT INTO `job` VALUES ('33', '教师', '启蒙', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '每天一次，消耗一盒粉笔与 2 支铅笔，选择除自己外最多 2 名玩家，使其临时学会一项基础技能持续到次日白天结束；若已拥有则增产 50%。');
INSERT INTO `job` VALUES ('34', '治安官', '射击', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '在密谋、暴力冲突中，如果装备远距离武器增加威胁值。如果调查玩家，可以选择在夜晚阶段骰 d6 寻找攻击机会，成功可发起小规模冲突；多人调查可袭击。');
INSERT INTO `job` VALUES ('35', '女巫', '协议契约', '2026-05-02 22:49:32', '2026-05-02 22:49:32', '为一位或多位玩家建立协议契约，可以指定违反协议的惩罚内容。');

-- ----------------------------
-- Table structure for job_initial_items
-- ----------------------------
DROP TABLE IF EXISTS `job_initial_items`;
CREATE TABLE `job_initial_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL COMMENT '职业ID',
  `item_type` enum('item','weapon','ammo','material') NOT NULL COMMENT '物品类型',
  `item_id` int(11) NOT NULL COMMENT '物品ID',
  `quantity` int(11) NOT NULL DEFAULT '1' COMMENT '初始数量',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_job_item` (`job_id`,`item_type`,`item_id`),
  KEY `idx_job_id` (`job_id`),
  CONSTRAINT `job_initial_items_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `job` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=226 DEFAULT CHARSET=utf8mb4 COMMENT='职业初始资源表';

-- ----------------------------
-- Records of job_initial_items
-- ----------------------------
INSERT INTO `job_initial_items` VALUES ('1', '1', 'item', '5', '1', '件', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('2', '1', 'weapon', '1', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('3', '1', 'ammo', '1', '6', '枚', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('4', '2', 'item', '3', '2', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('5', '2', 'weapon', '3', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('6', '2', 'item', '5', '1', '件', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('7', '2', 'item', '2', '2', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('8', '2', 'item', '4', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('9', '3', 'weapon', '3', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('10', '3', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('11', '3', 'item', '4', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('12', '3', 'item', '5', '1', '件', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('13', '3', 'weapon', '1', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('14', '3', 'ammo', '1', '6', '枚', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('15', '4', 'item', '5', '1', '件', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('16', '5', 'item', '3', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('17', '5', 'weapon', '3', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('18', '5', 'item', '5', '1', '件', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('19', '5', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('20', '5', 'material', '5', '2', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('21', '5', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('22', '5', 'material', '2', '45', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('23', '5', 'weapon', '1', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('24', '5', 'ammo', '1', '2', '枚', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('25', '5', 'item', '1', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('26', '5', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('27', '5', 'item', '10', '5', '瓶', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('28', '6', 'item', '6', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('29', '6', 'weapon', '3', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('30', '6', 'material', '5', '2', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('31', '6', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('32', '6', 'material', '2', '45', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('33', '6', 'weapon', '1', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('34', '6', 'ammo', '1', '2', '枚', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('35', '6', 'item', '1', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('36', '6', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('37', '6', 'item', '10', '5', '瓶', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('38', '7', 'item', '4', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('39', '7', 'item', '2', '2', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('40', '7', 'item', '6', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('41', '7', 'item', '13', '10', '根', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('42', '7', 'material', '5', '2', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('43', '7', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('44', '7', 'material', '2', '45', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('45', '7', 'weapon', '1', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('46', '7', 'ammo', '1', '2', '枚', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('47', '7', 'item', '1', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('48', '7', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('49', '7', 'item', '10', '5', '瓶', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('50', '8', 'material', '5', '13', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('51', '8', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('52', '8', 'weapon', '9', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('53', '8', 'item', '15', '1', '盒', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('54', '8', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('55', '8', 'material', '2', '150', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('56', '9', 'weapon', '9', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('57', '9', 'weapon', '10', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('58', '9', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('59', '9', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('60', '9', 'item', '15', '1', '盒', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('61', '9', 'material', '5', '8', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('62', '9', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('63', '9', 'material', '2', '150', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('64', '10', 'weapon', '8', '3', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('65', '10', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('66', '10', 'item', '15', '1', '盒', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('67', '10', 'material', '5', '8', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('68', '10', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('69', '10', 'material', '2', '150', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('70', '11', 'weapon', '4', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('71', '11', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('72', '11', 'item', '15', '1', '盒', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('73', '11', 'material', '5', '8', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('74', '11', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('75', '11', 'material', '2', '150', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('76', '12', 'material', '1', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('77', '12', 'material', '3', '20', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('78', '12', 'material', '9', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('79', '12', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('80', '12', 'item', '15', '1', '盒', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('81', '12', 'material', '5', '8', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('82', '12', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('83', '12', 'material', '2', '150', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('84', '13', 'material', '5', '8', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('85', '13', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('86', '13', 'material', '2', '150', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('87', '14', 'weapon', '6', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('88', '14', 'item', '12', '1', '张', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('89', '14', 'weapon', '4', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('90', '14', 'material', '3', '20', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('91', '14', 'material', '5', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('92', '14', 'material', '2', '80', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('93', '14', 'material', '8', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('94', '15', 'weapon', '4', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('95', '15', 'material', '3', '30', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('96', '15', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('97', '15', 'item', '12', '1', '张', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('98', '15', 'material', '5', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('99', '15', 'material', '2', '80', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('100', '15', 'material', '8', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('101', '16', 'weapon', '4', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('102', '16', 'item', '7', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('103', '16', 'ammo', '3', '1', '枚', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('104', '16', 'item', '17', '1', '张', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('105', '16', 'material', '5', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('106', '16', 'material', '2', '80', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('107', '16', 'material', '8', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('108', '16', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('109', '17', 'material', '3', '30', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('110', '17', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('111', '17', 'weapon', '4', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('112', '17', 'material', '5', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('113', '17', 'material', '2', '80', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('114', '17', 'material', '8', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('115', '18', 'weapon', '4', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('116', '18', 'item', '12', '1', '张', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('117', '18', 'material', '3', '20', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('118', '18', 'material', '5', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('119', '18', 'material', '2', '80', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('120', '18', 'material', '8', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('121', '19', 'item', '13', '50', '支', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('122', '19', 'item', '15', '5', '盒', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('123', '19', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('124', '19', 'material', '5', '3', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('125', '19', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('126', '19', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('127', '19', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('128', '20', 'item', '1', '2', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('129', '20', 'weapon', '11', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('130', '20', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('131', '20', 'material', '5', '3', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('132', '20', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('133', '20', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('134', '20', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('135', '21', 'material', '5', '23', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('136', '21', 'item', '10', '10', '瓶', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('137', '21', 'material', '3', '100', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('138', '21', 'weapon', '8', '2', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('139', '21', 'weapon', '9', '2', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('140', '21', 'weapon', '2', '2', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('141', '21', 'ammo', '2', '4', '枚', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('142', '21', 'material', '8', '35', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('143', '21', 'material', '2', '350', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('144', '21', 'material', '1', '40', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('145', '21', 'material', '6', '30', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('146', '21', 'material', '9', '30', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('147', '21', 'item', '16', '5', '支', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('148', '22', 'material', '5', '18', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('149', '22', 'material', '2', '550', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('150', '22', 'material', '8', '105', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('151', '23', 'item', '15', '1', '盒', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('152', '23', 'item', '14', '10', '升', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('153', '23', 'material', '5', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('154', '23', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('155', '23', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('156', '23', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('157', '24', 'item', '7', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('158', '24', 'ammo', '3', '2', '枚', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('159', '24', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('160', '24', 'material', '8', '15', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('161', '24', 'item', '17', '1', '张', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('162', '24', 'material', '5', '3', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('163', '24', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('164', '24', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('165', '25', 'material', '5', '8', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('166', '25', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('167', '25', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('168', '25', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('169', '26', 'weapon', '4', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('170', '26', 'material', '3', '20', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('171', '26', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('172', '26', 'material', '5', '2', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('173', '26', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('174', '26', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('175', '26', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('176', '27', 'weapon', '2', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('177', '27', 'ammo', '2', '4', '枚', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('178', '27', 'weapon', '4', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('179', '27', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('180', '27', 'material', '5', '2', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('181', '27', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('182', '27', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('183', '27', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('184', '28', 'material', '3', '20', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('185', '28', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('186', '28', 'item', '4', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('187', '28', 'material', '5', '2', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('188', '28', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('189', '28', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('190', '28', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('191', '29', 'weapon', '8', '1', '把', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('192', '29', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('193', '29', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('194', '29', 'item', '13', '10', '支', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('195', '29', 'material', '5', '2', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('196', '29', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('197', '29', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('198', '29', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('199', '30', 'item', '16', '5', '支', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('200', '30', 'material', '8', '20', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('201', '30', 'material', '9', '20', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('202', '30', 'material', '5', '2', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('203', '30', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('204', '30', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('205', '31', 'item', '13', '10', '支', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('206', '31', 'item', '15', '1', '盒', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('207', '31', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('208', '31', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('209', '31', 'material', '5', '2', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('210', '31', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('211', '31', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('212', '31', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('213', '32', 'item', '8', '2', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('214', '32', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('215', '32', 'material', '3', '10', '米', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('216', '32', 'material', '5', '2', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('217', '32', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('218', '32', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('219', '32', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('220', '33', 'item', '16', '5', '支', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('221', '33', 'item', '2', '1', '个', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('222', '33', 'material', '5', '2', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('223', '33', 'material', '8', '5', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('224', '33', 'material', '2', '50', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');
INSERT INTO `job_initial_items` VALUES ('225', '33', 'material', '1', '10', 'kg', '2026-05-02 22:50:05', '2026-05-02 22:50:05');

-- ----------------------------
-- Table structure for material
-- ----------------------------
DROP TABLE IF EXISTS `material`;
CREATE TABLE `material` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `remark` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of material
-- ----------------------------
INSERT INTO `material` VALUES ('1', '金属制品', 'kg', '可用于制作工具', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `material` VALUES ('2', '木材', 'kg', '可用于建造', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `material` VALUES ('3', '绳索', '米', '多种用途', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `material` VALUES ('4', '木板', 'kg', '建筑材料', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `material` VALUES ('5', '食物', 'kg', '填饱肚子', '2026-04-27 11:36:23', '2026-05-02 19:19:33');
INSERT INTO `material` VALUES ('6', '沥青', 'kg', '建筑材料', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `material` VALUES ('7', '石料', 'kg', '建筑材料', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `material` VALUES ('8', '燃料/煤油', 'kg', '提供能源', '2026-04-27 11:36:23', '2026-05-02 22:20:31');
INSERT INTO `material` VALUES ('9', '帆布', '米', '制作帐篷', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `material` VALUES ('10', '发动机', '个', '机械动力', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `material` VALUES ('11', '螺旋桨', '个', '船只推进', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `material` VALUES ('12', '发电机', '个', '发电设备', '2026-04-27 11:36:23', '2026-04-27 11:36:23');

-- ----------------------------
-- Table structure for milestone
-- ----------------------------
DROP TABLE IF EXISTS `milestone`;
CREATE TABLE `milestone` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '里程碑名称',
  `description` text NOT NULL COMMENT '里程碑描述',
  `is_completed` tinyint(1) DEFAULT '0' COMMENT '是否已完成',
  `completed_at` datetime DEFAULT NULL COMMENT '完成时间',
  `order_number` int(11) NOT NULL COMMENT '排序序号',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order` (`order_number`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COMMENT='反抗者里程碑表';

-- ----------------------------
-- Records of milestone
-- ----------------------------
INSERT INTO `milestone` VALUES ('1', '团结平民', '星星之火也可以燎原。反抗者拥有一个初始协议书。反抗者应当与更多的玩家讨论，明确对方的特性，资源，加入阵营的意向，并且对其进行观察，辨别可能的内鬼。当包括初始反抗者在内的确认加入反抗者名单大于等于8人后（以签订了契约为准，以死亡玩家应也计算在内），该里程碑事件完成。', '1', '2026-05-14 10:52:58', '1', '2026-05-14 10:40:18', '2026-05-14 10:52:58');
INSERT INTO `milestone` VALUES ('2', '解放我们的同伴', '铁窗锁不住自由的心。目前在监狱里面的同伴都是曾经为了我们的革命事业献出自由乃是生命的同志。所以解放他们对于我们来讲至关重要。解救身在监狱中的那些同伴，他们将继续加入你们，并点燃这个岛上平民心中对于自由的渴望。当同伴被解救出来，该里程碑事件完成。', '0', null, '2', '2026-05-14 10:40:18', '2026-05-14 10:52:41');
INSERT INTO `milestone` VALUES ('3', '我们不是生来就应该如此', '在统治者使用审判环节，若被审判人员为加入反抗者阵营中人。要尽力解救我们的同胞，避免让他被统治者所残害。当被审判的反抗者人员无罪释放，该里程碑事件完成。', '0', null, '3', '2026-05-14 10:40:18', '2026-05-14 10:52:54');
INSERT INTO `milestone` VALUES ('4', '反抗不是我们的目的，平等才是', '不给人活路，那就掀桌子。你们或联系任意你们信任的人。向统治者进行施压，要求调整劳工名单或者让统治者分配一定的资源给其他镇民。当该施压投票超过半数被统治者同意，该里程碑事件完成。', '0', null, '4', '2026-05-14 10:40:18', '2026-05-14 10:52:51');
INSERT INTO `milestone` VALUES ('5', '正义属于我们', '敌人的刀，也能转过来对着他们自己。有1名原本属于统治者阵营的玩家（或主持人控制的NPC）主动投靠反抗者，并提供信息或协助。该里程碑事件完成。', '1', '2026-05-14 10:52:59', '5', '2026-05-14 10:40:18', '2026-05-14 10:52:59');
INSERT INTO `milestone` VALUES ('6', '团结一切可以团结的力量', '那些外来人，要么帮忙，要么别挡道。至少1名冒险者身份的玩家公开承诺在革命日当天加入反抗者起义，或至少2名冒险者承诺保持中立（不帮统治者）。需以契约为证。完成上述条件后，该里程碑事件完成。', '0', null, '6', '2026-05-14 10:40:18', '2026-05-14 10:40:18');
INSERT INTO `milestone` VALUES ('7', '让人民觉醒', '第一条血债，就是最好的宣言。当第一次有玩家因为统治者的直接行为（审判、冲突，抓捕等，由主持人判定）死亡或重伤后，主持人会秘密告知反抗者阵营这条消息。得知消息后，反抗者在当晚的夜间回合一名反叛者可以花费一行动点发起一次匿名投票，向全体玩家问一个问题：“统治者是否草菅人命？”投票规则：匿名投票，每人一票。选项为“是”或“否”。如果投票人数超过玩家总数的一半，且其中同意“是”的票数多于“否”，该里程碑完成。', '0', null, '7', '2026-05-14 10:40:18', '2026-05-14 10:52:43');

-- ----------------------------
-- Table structure for milestone_player_status
-- ----------------------------
DROP TABLE IF EXISTS `milestone_player_status`;
CREATE TABLE `milestone_player_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL COMMENT '玩家ID',
  `milestone_id` int(11) NOT NULL COMMENT '里程碑ID',
  `has_viewed` tinyint(1) DEFAULT '0' COMMENT '玩家是否已查看',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_player_milestone` (`player_id`,`milestone_id`),
  KEY `milestone_id` (`milestone_id`),
  CONSTRAINT `milestone_player_status_ibfk_1` FOREIGN KEY (`milestone_id`) REFERENCES `milestone` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='玩家里程碑查看状态表';

-- ----------------------------
-- Records of milestone_player_status
-- ----------------------------

-- ----------------------------
-- Table structure for player
-- ----------------------------
DROP TABLE IF EXISTS `player`;
CREATE TABLE `player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `is_weak` tinyint(1) NOT NULL DEFAULT '0',
  `is_overworked` tinyint(1) NOT NULL DEFAULT '0',
  `is_injured` tinyint(1) NOT NULL DEFAULT '0',
  `job_id` int(11) NOT NULL,
  `skill_id` int(11) DEFAULT NULL,
  `faction` enum('统治者','反叛者','冒险者','天灾使者','平民') NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `job_id` (`job_id`),
  KEY `skill_id` (`skill_id`),
  CONSTRAINT `player_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `job` (`id`),
  CONSTRAINT `player_ibfk_2` FOREIGN KEY (`skill_id`) REFERENCES `skill` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of player
-- ----------------------------
INSERT INTO `player` VALUES ('1', '阿尔伯特', '0', '0', '0', '1', '1', '统治者', '2026-04-26 22:13:35', '2026-04-26 22:13:35');
INSERT INTO `player` VALUES ('2', '莉莉丝', '0', '1', '0', '2', '2', '反叛者', '2026-04-26 22:13:35', '2026-04-26 22:13:35');
INSERT INTO `player` VALUES ('3', '罗宾', '1', '0', '0', '3', '3', '冒险者', '2026-04-26 22:13:35', '2026-04-26 22:13:35');
INSERT INTO `player` VALUES ('4', '亚瑟', '0', '0', '1', '4', '4', '天灾使者', '2026-04-26 22:13:35', '2026-05-14 11:15:19');
INSERT INTO `player` VALUES ('5', '艾米丽', '0', '0', '0', '5', '5', '平民', '2026-04-26 22:13:35', '2026-04-26 22:13:35');
INSERT INTO `player` VALUES ('6', '测试', '0', '0', '0', '2', '2', '平民', '2026-04-29 01:14:41', '2026-04-29 01:14:41');

-- ----------------------------
-- Table structure for player_items
-- ----------------------------
DROP TABLE IF EXISTS `player_items`;
CREATE TABLE `player_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL,
  `item_type` enum('item','weapon','ammo','material') NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_player_type_item` (`player_id`,`item_type`,`item_id`),
  KEY `idx_player_type` (`player_id`,`item_type`),
  CONSTRAINT `player_items_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of player_items
-- ----------------------------
INSERT INTO `player_items` VALUES ('1', '1', 'item', '1', '2', '2026-04-27 11:36:23', '2026-05-02 17:09:47');
INSERT INTO `player_items` VALUES ('2', '1', 'item', '2', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('3', '1', 'item', '5', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('4', '1', 'weapon', '1', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('5', '1', 'weapon', '3', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('6', '1', 'ammo', '1', '30', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('7', '1', 'material', '1', '5', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('8', '1', 'material', '2', '10', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('9', '2', 'item', '4', '2', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('10', '2', 'item', '7', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('11', '2', 'weapon', '2', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('12', '2', 'weapon', '6', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('13', '2', 'ammo', '2', '10', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('14', '2', 'ammo', '3', '5', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('15', '2', 'material', '3', '20', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('16', '2', 'material', '5', '9', '2026-04-27 11:36:23', '2026-05-05 21:17:54');
INSERT INTO `player_items` VALUES ('17', '3', 'item', '8', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('18', '3', 'item', '10', '2', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('19', '3', 'weapon', '4', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('20', '3', 'weapon', '8', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('21', '3', 'material', '4', '15', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('22', '3', 'material', '6', '5', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('23', '3', 'material', '9', '10', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('24', '4', 'item', '3', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('25', '4', 'item', '12', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('26', '4', 'weapon', '5', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('27', '4', 'weapon', '7', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('28', '4', 'ammo', '4', '20', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('29', '4', 'material', '7', '20', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('30', '4', 'material', '8', '10', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('31', '5', 'item', '6', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('32', '5', 'item', '14', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('33', '5', 'weapon', '9', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('34', '5', 'weapon', '10', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('35', '5', 'material', '10', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('36', '5', 'material', '11', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('37', '5', 'material', '12', '1', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
INSERT INTO `player_items` VALUES ('38', '1', 'material', '5', '7', '2026-05-01 10:54:53', '2026-05-05 21:17:17');

-- ----------------------------
-- Table structure for selected_catastrophe
-- ----------------------------
DROP TABLE IF EXISTS `selected_catastrophe`;
CREATE TABLE `selected_catastrophe` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `deck_id` int(11) NOT NULL COMMENT '牌组ID',
  `player_id` int(11) DEFAULT NULL COMMENT '选择的玩家ID（天灾使者）',
  `selected_at` datetime DEFAULT NULL COMMENT '选择时间',
  `is_active` tinyint(1) DEFAULT '0' COMMENT '是否正在生效',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `deck_id` (`deck_id`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `selected_catastrophe_ibfk_1` FOREIGN KEY (`deck_id`) REFERENCES `catastrophe_deck` (`id`) ON DELETE CASCADE,
  CONSTRAINT `selected_catastrophe_ibfk_2` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COMMENT='已选择的天灾牌表';

-- ----------------------------
-- Records of selected_catastrophe
-- ----------------------------
INSERT INTO `selected_catastrophe` VALUES ('1', '8', null, null, '0', '2026-05-14 13:44:43', '2026-05-14 14:00:47');
INSERT INTO `selected_catastrophe` VALUES ('2', '15', null, null, '0', '2026-05-14 13:44:43', '2026-05-14 14:00:47');
INSERT INTO `selected_catastrophe` VALUES ('3', '31', '4', '2026-05-14 13:53:27', '0', '2026-05-14 13:44:43', '2026-05-14 14:00:47');
INSERT INTO `selected_catastrophe` VALUES ('4', '21', null, null, '0', '2026-05-14 14:00:47', '2026-05-14 14:10:35');
INSERT INTO `selected_catastrophe` VALUES ('5', '3', null, null, '0', '2026-05-14 14:00:47', '2026-05-14 14:10:35');
INSERT INTO `selected_catastrophe` VALUES ('6', '18', '4', '2026-05-14 14:03:15', '0', '2026-05-14 14:00:47', '2026-05-14 14:10:35');
INSERT INTO `selected_catastrophe` VALUES ('7', '32', '4', '2026-05-14 14:10:53', '1', '2026-05-14 14:10:35', '2026-05-14 14:10:53');
INSERT INTO `selected_catastrophe` VALUES ('8', '12', null, null, '1', '2026-05-14 14:10:35', '2026-05-14 14:10:35');
INSERT INTO `selected_catastrophe` VALUES ('9', '9', null, null, '1', '2026-05-14 14:10:35', '2026-05-14 14:10:35');

-- ----------------------------
-- Table structure for shelter_progress
-- ----------------------------
DROP TABLE IF EXISTS `shelter_progress`;
CREATE TABLE `shelter_progress` (
  `id` int(11) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `current_build_value` int(11) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of shelter_progress
-- ----------------------------
INSERT INTO `shelter_progress` VALUES ('1', '2026-05-12 09:58:06.701000', '50', '2026-05-12 09:58:06.701000');

-- ----------------------------
-- Table structure for shelter_stock
-- ----------------------------
DROP TABLE IF EXISTS `shelter_stock`;
CREATE TABLE `shelter_stock` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `item_type` enum('item','weapon','ammo','material') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物品类型：item道具/weapon武器/ammo弹药/material材料',
  `item_id` int(11) NOT NULL COMMENT '物品ID，关联对应类型表的主键',
  `quantity` int(11) NOT NULL DEFAULT '0' COMMENT '物品数量',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间',
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_shelter_stock_type_item` (`item_type`,`item_id`),
  KEY `idx_item_type` (`item_type`),
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='统治者避难所物资库存表';

-- ----------------------------
-- Records of shelter_stock
-- ----------------------------
INSERT INTO `shelter_stock` VALUES ('30', 'material', '2', '40', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:40.880277');
INSERT INTO `shelter_stock` VALUES ('31', 'material', '3', '35', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('32', 'material', '4', '24', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('33', 'material', '7', '32', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('34', 'item', '1', '8', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('35', 'item', '2', '4', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('36', 'item', '3', '2', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('37', 'item', '4', '3', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('38', 'item', '5', '1', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('39', 'item', '6', '1', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('40', 'item', '7', '1', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('41', 'item', '8', '5', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('42', 'item', '9', '2', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('43', 'item', '10', '10', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('44', 'item', '11', '12', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('45', 'item', '12', '2', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('46', 'item', '13', '18', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('47', 'item', '14', '3', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('48', 'item', '15', '6', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('49', 'item', '16', '4', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('50', 'item', '17', '1', '2026-05-13 18:52:32.224220', '2026-05-13 18:52:32.224220');
INSERT INTO `shelter_stock` VALUES ('51', 'weapon', '1', '1', '2026-05-13 18:52:32.227988', '2026-05-13 18:52:32.227988');
INSERT INTO `shelter_stock` VALUES ('52', 'weapon', '2', '1', '2026-05-13 18:52:32.227988', '2026-05-13 18:52:32.227988');
INSERT INTO `shelter_stock` VALUES ('53', 'weapon', '3', '2', '2026-05-13 18:52:32.227988', '2026-05-13 18:52:32.227988');
INSERT INTO `shelter_stock` VALUES ('54', 'weapon', '4', '1', '2026-05-13 18:52:32.227988', '2026-05-13 18:52:32.227988');
INSERT INTO `shelter_stock` VALUES ('55', 'weapon', '6', '1', '2026-05-13 18:52:32.227988', '2026-05-13 18:52:32.227988');
INSERT INTO `shelter_stock` VALUES ('56', 'weapon', '7', '1', '2026-05-13 18:52:32.227988', '2026-05-13 18:52:32.227988');
INSERT INTO `shelter_stock` VALUES ('57', 'weapon', '8', '2', '2026-05-13 18:52:32.227988', '2026-05-13 18:52:32.227988');
INSERT INTO `shelter_stock` VALUES ('58', 'weapon', '9', '1', '2026-05-13 18:52:32.227988', '2026-05-13 18:52:32.227988');

-- ----------------------------
-- Table structure for skill
-- ----------------------------
DROP TABLE IF EXISTS `skill`;
CREATE TABLE `skill` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '技能名称',
  `function` text NOT NULL COMMENT '技能效果描述',
  `faction` enum('平民','统治者','冒险者','反叛者','天灾使者') NOT NULL DEFAULT '平民' COMMENT '阵营限制',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `idx_faction` (`faction`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COMMENT='个人技能表';

-- ----------------------------
-- Records of skill
-- ----------------------------
INSERT INTO `skill` VALUES ('1', '囤积症', '你屋里堆满了舍不得扔的旧报纸、空罐头和麻绳。获得额外的资源【金属制品1000kg，煤油100升，帆布50米，麻绳50米】', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('2', '情报贩子', '你和村里的几个孩子是铁哥们，总能先知道些风声。可以每天指定npc「阿丹」执行调查玩家行动，不占用你的主要行动。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('3', '扮演：圣徒', '你是小镇最虔诚的人。你相信神会拯救所有人，请聆听神父的声音。你会知道他是否能够信任。这是一个公开的扮演特性，请遵守圣徒的规律，他可能代表着一种话语权。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('4', '秘密钥匙', '你拥有小镇一个废弃房屋的地下室钥匙。所有人都不知道还有这样一个地方。若你终局来临时没有进入庇护所或者避难所，你可以在这里储存够你存活90天及以上的物资进入个人结算结局。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('5', '第六感', '你在岛上活了几十年，谁对你有恶意你闻都闻出来。效果：你能够知道对你使用调查的玩家名称', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('6', '偷窃癖', '你喜欢偷东西的感觉，你获得技能偷盗。效果：偷盗：选择一位玩家，获得对方的秘密资源物品信息。需要投掷1d6+1检定在5以上即可获得对方一件物品。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('7', '潮汐症', '每年冬天，当第一场暴风雪封岛，你就开始犯病。睡不着，吃不下，整夜整夜坐在窗前听风声，总觉得海浪声里有人的喊叫。你知道那是幻觉——那年冬天你爹的船没回来，你站在码头听了三天三夜。镇上人说你是“潮汐症”，不吉利，躲着你走。你不怪他们。有些东西，离近了会传染。效果：任何玩家死亡，你会第一时间得到死亡玩家与死亡地点。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('8', '曾经是走私者的线人', '你知道岛上谁在夜里往岸上搬东西，知道哪条船不靠码头靠礁石，知道仓库哪面墙的锁是坏的。你替他们望风、递消息、在酒馆里吆喝“有巡警”的时候，他们就往你口袋里塞几个硬币。效果：你知道通往码头仓库与燃料仓库的暗道，可以避开巡逻人员和看守。也许这些东西对杀戮者或者反抗者很有用。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('9', '银币', '你有一枚银币。不是你赚的，不是你捡的，是——不知道从哪来的。你醒来的时候，它就攥在你手里，攥得掌心发红。你试过花掉，第二天它又回到你口袋；你试过扔掉，第二天它又出现在枕头底下；你试过送人，那人第二天发烧，银币又回来了。你不敢再试了。你怕的不是这枚银币，是它要你做什么。效果：银币不可丢弃、不可交易、不可偷窃。它“选择”留在你身边。全局，你可使用银币进行一次“许愿”。向主持人提出一个要求，如“明天生产+20%”“消除xxx的诅咒”“今日天灾牌无效”，主持人根据需要尽可能地满足要求，越是破坏平衡的愿望越可能带来强大的个人负面因素。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('10', '回声', '你能听见别人听不见的东西。不是耳朵好，是那种——不该听见的东西。酒馆里有人说悄悄话，你能听见；码头有人夜里密谋，你能听见；教堂地窖里神父自言自语，你也能听见。你不敢说。说了，你就是怪物。你把这些声音存在脑子里，像存钱。有一天，你要用它们换点什么。效果:在游戏开始时选择3名玩家你会得到他们全部的初始阵营信息。但不一一对应。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('11', '爱狗人', '你妈生你的时候难产死了，你爹喝了二十年酒，去年也死了。你吃百家饭长大。你认为狗比人好——狗不骗你，狗不嫌你，狗给你暖脚。你养了一只狗，它是你的重要伙伴。效果：初始拥有一只狗，可以给它取名字。它计算为0.5威胁值。狗不会被偷走，会一直跟着你。在有人试图偷盗你时会打断对方行为。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('12', '海藻医生', '你奶奶教你的：海藻能止血，昆布能退烧，石莼能敷伤口。镇上人笑你是“海带大夫”，但冬天码头有人被缆绳打断腿的时候，第一个喊的是你。你采了一辈子海藻，尝了一辈子海藻，知道哪片礁石上的能治病，哪片的有毒。你不知道自己算不算医生，但你知道，没有你，这个冬天要多死几个人。效果：获得“医疗”技能', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('13', '百宝袋', '你兜里永远揣着各种各样的物品。效果：一次机会，你可以选择5个物品列表中的非武器的非重复物品，获得其标准单位数量的物品。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('14', '望远镜', '你有个军用望远镜，能看清远处。效果：每天1次，可私聊主持人“行动点x时使用特性望（xz地点）”，获知当时有谁在那里。无法获知矿场，避难所等地下结构。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('15', '海的呼唤', '你不对劲。不是生病，是那种——不该有的不对劲。上个月码头有条狗对着你狂吠，你瞪了它一眼，它夹着尾巴跑了，跑之前尿了一地。上周酒馆老张摸你肩膀，你碰了他一下，他回家后发烧三天。你自己也怕。你开始半夜往海边跑，对着月亮发呆，觉得海在叫你。你知道这不正常，但不知道这算什么。效果：你获得一个“诅咒标记”可以被布道去除。诅咒无法再影响你，你永远无法成为天灾使者的诅咒目标。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('16', '鱼骨占卜', '你奶奶传下来的手艺。不是那些神神叨叨的巫术——是把吃剩的鱼骨头洗干净，扔在桌上，看它们落地的样子。你说这能看出鱼汛、天气、谁家要死人。信的人当真，不信的人当笑话。但去年你说老李家的船别出海，他偏去了，没回来。那之后，找你的人多了，怕你的人也多了。效果：初始获得3个特殊鱼骨。可消耗“鱼骨”为他人占卜，需要对方同意。占卜的结果由主持人暗中判定。（为3选一随机不重复触发。对方的全部协议内容，对方的阵营信息，对方的特性信息）', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('17', '幸运贝壳', '你有一串穿孔的贝壳，说是祖上传下来保平安的。效果：拥有两颗幸运贝壳，一颗可以用来躲避一次伤害，一颗可以用来在没有食物时捡到2单位食物。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('18', '遗书', '你觉得世道不太平，早把后事安排好了。效果：每天可修改一次遗书私聊主持人，死后自动发给你指定的人或者公开。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('19', '单恋者', '你深爱着另一个人，你可以为他（她）付出一切。在游戏开始前选择一名玩家作为你的暗恋对象。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('20', '仇人', '你恨着一位统治者，你知晓隐藏统治者的身份。你憎恨着他也同时为自己准备了一条出路，你白天回合可以选择花费一个行动点进行“消失”。夜晚回合无法被调查，无法被攻击。但第二天你仍然会回到游戏之中。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('21', '扮演·大善', '你坚定地相信神的意志，认为神不会抛弃人们，你不愿意任何人受难和死去，并且诚心地愿望帮助他人。这是一个公开的扮演特性，请遵守善意的规律，它代表着一种话语权。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('22', '忠诚', '你的理念告诉你，当你选择了哪一条路，将不会存在背叛。一旦你加入了某个阵营就无法退出，同时你会给阵营带来意想不到的一定加成。统治者：你担任劳工或者守卫的时候，目标地点额外+2防御值。反抗者：你参与的“密谋”增加1点成功率。冒险者：你参与“方舟建设”时，当日总工作量提高10%。冒险者阵营“看守方舟”时防御值+1。天灾使者（若允许平民加入）：你的“诅咒”目标在被诅咒期间，无法对你发起任何攻击或密谋。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('23', '账房先生', '你算账清楚，记忆力好。效果：游戏开始时，你获得一份模糊的物资统计：知晓所有仓库的总资源排名（如“燃料最多的是燃料仓库，食物最多的是码头”），但不知具体数字和所属玩家。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('24', '老好人', '大家都不太防备你。效果：当你使用“调查玩家”时，如果目标玩家未进行“隐藏”，你不用投1/2概率，直接获知其阵营行动（但不包括具体内容，仅知“进行了生产”“进行了隐藏”等）。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('25', '酒蒙子', '你离不开酒。效果：游戏开始时额外获得10瓶朗姆酒。每天必须消耗2瓶朗姆酒，否则第二天白天行动点-1。（朗姆酒可交易）', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('26', '即兴演说', '你说话能打动人。效果：在“公开审判”中，如果你的发言被主持人认为有说服力，你可以在投票阶段额外增加/减少1票有效影响力（由主持人裁定）。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('27', '老水手', '你曾经出过海。效果：你获得“航海”技能。如果你已拥有，则获得“海洋导航”。在“出海”结算时，你为船只提供一次抗风暴加成（减少一次危机事件）。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('28', '梦魇', '你经常做噩梦，梦见暴雪。效果：每天晚上，你随机获知一张未被触发的天灾牌的名称（不触发效果）。同一天灾牌不会重复获知。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('29', '穷光蛋', '你什么资产都没有。效果：你初始资源减半（食物、燃料等基础配置减半）。但你不会被任何人调查出有价值的资产信息（调查你只能得到“一无所有”），也不会被“偷窃癖”偷走任何东西（因为你没有）。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('30', '守财奴', '你舍不得花。效果：你每天可以多保存25%的食物（每日消耗时按1.5食物计算。）代价：你无法主动赠送资源给其他玩家（必须交换）。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('31', '讲故事的人', '你脑子里有很多故事。效果：每天一次，你可以给去往的某地点某NPC讲一个故事。NPC心情变好后，可能会告诉你一条他“本来不想说”的无关紧要信息（如“昨天码头来了几个人”）。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('32', '好奇心重', '你什么都想知道。效果：你每天可以多问主持人一个“是/否”问题（关于游戏设定、地点、NPC，不涉及玩家阵营和行动）。主持人必须如实回答。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('33', '不满已久', '这些年忍够了。矿场、码头、粮仓……凭什么他们说了算？该换个活法了。效果：游戏开始时，你知晓反抗者阵营其中一个成员的名字。如果你成功加入反抗者阵营，你获得一个一次性效果：在反抗者发起的第一次密谋中，你增加2点成功率（而不是常规的1点）。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('34', '渴望出海', '这岛要完了，但我不想死在这儿。跟着大船走，哪怕当个水手也行。游戏开始时，你知晓冒险者阵营两个成员的名字。如果你成功加入冒险者阵营，你获得一个一次性效果：在“方舟建设”行动中，你可以选择一次贡献量翻倍（一天算两天）。', '平民', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('35', '虚伪的仁慈', '如果主持人告知你其他玩家粮食不足，你必须提供维持对方一天的食物需求。如果对方接受了你的救助，你可以控制对方第二天的一个行动点去向。对方只会知道“受特性影响该行动点无效”。', '统治者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('36', '暴君', '你可以每天额外压榨一名劳工。', '统治者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('37', '铁腕', '效果：你主持的“公开审判”中，投票环节你的个人票数算作3票（而不是1票）。', '统治者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('38', '恩主', '效果：每天一次，你可以免除一名劳工的“过劳”状态（他今天劳作后不会积累过劳标记）。', '统治者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('39', '窃听者', '效果：每天夜晚阶段，你可以选择一条非统治者阵营的私人群组（如反抗者群、冒险者群），主持人随机抽取该群当天的一段对话（不超过5条）匿名发给你。你不会知道说话者是谁。', '统治者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('40', '暗桩', '效果：游戏开始时，你秘密选择一名NPC（非玩家）作为你的“暗桩”。你可以每天向主持人询问一次“暗桩报告”。包括有哪些人来过他所在的地方，和什么NPC进行了交互。', '统治者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('41', '镇守', '效果：当你亲自在某地点过夜（夜晚阶段结束时你位于该地点），该地点的防御值+3。', '统治者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('42', '点名', '每天开始前，你可以宣布一个玩家的名字。该玩家当天无法进行“隐藏”行动（如果已经隐藏，则自动暴露）。', '统治者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('43', '藏料', '效果：游戏开始时，你在码头秘密藏了额外资源：木材20吨、金属制品5吨、密封材料10kg。这些资源只有你知道位置，不会被其他阵营搜刮。', '冒险者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('44', '号召', '效果：每天一次，你可以向一名平民玩家发出“上船邀请”。如果对方同意临时加入冒险者阵营，对方获得一次免费“建设方舟”行动。', '冒险者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('45', '探风', '效果：每天一次，你可以询问主持人“今天是否有玩家在码头或海边活动”。主持人回答“有人”或“没人”，不透露具体是谁。', '冒险者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('46', '听潮', '效果：每天夜晚阶段结束时，你可以询问主持人“今晚是否有玩家在码头进行了非公开行动（如密谋、隐藏、偷盗）”。主持人回答“是”或“否”。', '冒险者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('47', '备材', '效果：全局一次，当你的阵营在进行“方舟建设”时缺少某一种资源（如缺木材、缺金属），你可以使用“备材”。主持人会告知你岛上哪个地点（不精确到NPC）可以找到该资源的下落（如“矿场仓库有金属”或“伐木营地有木材”）。', '冒险者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('48', '同路人', '效果：每天一次，你可以询问主持人“今天是否有平民玩家加入了某个阵营（你可以指定一个阵营，如反抗者）”。主持人回答“有”或“没有”。', '冒险者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('49', '摸底', '效果：每天一次，选择一名玩家。主持人私聊告知你：该玩家今天是否进行了“生产”行动，以及产出是否上交给了统治者（“上交了”“没上交”）。', '反叛者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('50', '硬骨头', '效果：全局一次，如果你被统治者选为劳工，你可以选择“反抗”。当天你不会被计入劳工名单，统治者会得知你未能成功被征为劳工。', '反叛者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('51', '正义宣传', '效果：每天一次，当统治者宣布劳工名单后，你可以选择其中一名劳工。该劳工当天建造值-50%（向下取整）。统治者不会自动知道是谁干的，但可以调查或者排除出来。', '反叛者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('52', '老面孔', '效果：游戏开始时，你随机知晓一名监狱/关押地点看守NPC的名字和弱点（如“他晚上会喝酒”“他贪财”）。你可以利用这个信息，在劫狱时让该看守“暂时离开岗位”（需消耗一次行动点），使目标地点的防御值-2。', '反叛者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('53', '舆论', '效果：每天一次，你可以通过主持人在公屏发布一条“民间声音”（如“矿工们今天不想干活”“码头有人在议论镇长”不超过20个字。）。这条信息会被视为“NPC的态度”，统治者如果无视，可能影响部分NPC对他们的态度。', '反叛者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('54', '集结号', '效果：当劫狱和公开审判两个里程碑都完成后，你可以在劳工傍晚回合宣布“起义”。起义当天，所有反抗者阵营成员的“威胁值”+1（不限武器）。', '反叛者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('55', '瘟疫', '效果：你将永远拥有“瘟疫诅咒”。每天一次，你可以对一名玩家施加“瘟疫诅咒”。该玩家不会立即死亡，但会在终局结算时产生以下影响：如果该玩家在避难所中，避难所的食物消耗增加5%（因为他污染了存粮）；如果该玩家在方舟上，方舟的可能的医疗资源需求+50%（因为他传染他人）；如果该玩家死亡，“瘟疫诅咒”会随机传染给另一名存活玩家（终局结算时生效）。多个“瘟疫诅咒”效果叠加。被诅咒的玩家不会知道，但会感到“身体不适”。', '天灾使者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('56', '战争', '效果：全局一次，当你参与一场“冲突，起义，劫狱”非自身阵营引发对抗和暴力的行动时，你可以宣布“战争降临”。该场冲突中，所有参与者的威胁值翻倍（包括敌我），且冲突结束后，无论胜负，所有参与者都会获得一个“受伤”标记。之后战争的阴影也笼罩在人们心上，触发全局效果“战争”。如果你本人在冲突中死亡，“战争”效果依然持续到冲突结束。', '天灾使者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('57', '饥荒', '效果：全局一次，你可以花费一个行动点“饥荒降临”。选择一种资源类型（食物、燃料、木材、金属制品、医疗资源），主持人从所有仓库（4个统治者仓库、反抗者、冒险者）中随机两个仓库销毁该资源的10%（最低保留1单位）。此特性使用后，所有玩家会收到公屏提示：“一场诡异的霉病席卷了粮仓/燃料/仓库……”，但不知道是谁干的。', '天灾使者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');
INSERT INTO `skill` VALUES ('58', '死亡骑士', '触发条件：当天灾使者阵营只剩最后一名存活成员时，若有天灾使者挂机第一天第二天都挂机也认为他满足死亡条件。玩家可以在当天任意阶段（白天/夜晚/结算前）私信主持人，选择是否“成为死亡骑士”。若没有回答默认拒绝。拒绝：无事发生，游戏继续。同意：全屏公告——“天灾的低语响彻岛屿：有人接过了死亡骑士的缰绳。”效果：你可以选择以下两个效果之一：如果游戏进入终局结算（暴雪将至），你可以暗中联系主持人“终焉宣告”。选择以下效果之一：对避难所：避难所的所有防御值和资源储备在结算时视为80%（食物、燃料只计算80%）；对方舟：方舟在出海结算时额外遭遇2次危机事件。此效果在终局结算时自动生效，无需额外行动。如果你在终局前死亡，此效果依然生效（你已成为死亡骑士，诅咒已落下）。', '天灾使者', '2026-05-02 23:09:27', '2026-05-02 23:09:27');

-- ----------------------------
-- Table structure for trade
-- ----------------------------
DROP TABLE IF EXISTS `trade`;
CREATE TABLE `trade` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `from_player_id` int(11) NOT NULL COMMENT '发起方玩家ID',
  `to_player_id` int(11) NOT NULL COMMENT '接收方玩家ID',
  `status` enum('pending','accepted','rejected','cancelled','completed') NOT NULL DEFAULT 'pending' COMMENT '交易状态：pending-交易中, accepted-已接受, rejected-已拒绝, cancelled-交易中止, completed-交易成功',
  `remark` text COMMENT '交易备注',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_from_player` (`from_player_id`),
  KEY `idx_to_player` (`to_player_id`),
  KEY `idx_status` (`status`),
  KEY `idx_from_to_status` (`from_player_id`,`to_player_id`,`status`),
  CONSTRAINT `trade_ibfk_1` FOREIGN KEY (`from_player_id`) REFERENCES `player` (`id`),
  CONSTRAINT `trade_ibfk_2` FOREIGN KEY (`to_player_id`) REFERENCES `player` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COMMENT='交易主表';

-- ----------------------------
-- Records of trade
-- ----------------------------
INSERT INTO `trade` VALUES ('1', '1', '2', 'cancelled', '需要一些食物', '2026-04-30 14:06:06', '2026-05-01 09:34:00');
INSERT INTO `trade` VALUES ('2', '3', '1', 'accepted', '换一些工具', '2026-04-30 14:06:06', '2026-04-30 14:06:06');
INSERT INTO `trade` VALUES ('3', '4', '5', 'rejected', '想要发电机', '2026-04-30 14:06:06', '2026-04-30 14:06:06');
INSERT INTO `trade` VALUES ('4', '2', '3', 'cancelled', '物资不匹配', '2026-04-30 14:06:06', '2026-04-30 14:06:06');
INSERT INTO `trade` VALUES ('5', '5', '1', 'completed', '完成了交易', '2026-04-30 14:06:06', '2026-04-30 14:06:06');
INSERT INTO `trade` VALUES ('6', '1', '2', 'cancelled', '测试', '2026-05-01 09:36:56', '2026-05-01 09:37:18');
INSERT INTO `trade` VALUES ('7', '1', '2', 'completed', '1', '2026-05-01 10:29:46', '2026-05-01 10:30:46');
INSERT INTO `trade` VALUES ('8', '1', '2', 'completed', '', '2026-05-01 10:54:31', '2026-05-01 10:54:53');
INSERT INTO `trade` VALUES ('9', '2', '1', 'completed', '??????', '2026-05-02 17:41:28', '2026-05-05 21:17:17');
INSERT INTO `trade` VALUES ('10', '2', '1', 'completed', '??????', '2026-05-02 17:46:24', '2026-05-02 18:31:01');
INSERT INTO `trade` VALUES ('11', '1', '2', 'completed', '测试性质', '2026-05-05 21:16:29', '2026-05-05 21:17:54');
INSERT INTO `trade` VALUES ('12', '1', '2', 'completed', '测试', '2026-05-05 21:17:33', '2026-05-05 21:17:55');

-- ----------------------------
-- Table structure for trade_items
-- ----------------------------
DROP TABLE IF EXISTS `trade_items`;
CREATE TABLE `trade_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `trade_id` int(11) NOT NULL COMMENT '关联的交易ID',
  `item_type` enum('item','weapon','ammo','material') NOT NULL COMMENT '物品类型',
  `item_id` int(11) NOT NULL COMMENT '物品ID',
  `quantity` int(11) NOT NULL DEFAULT '1' COMMENT '物品数量',
  `direction` enum('give','take') NOT NULL COMMENT '物品方向：give-给予, take-索取',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `name` varchar(255) DEFAULT NULL,
  `unit` varchar(255) DEFAULT NULL,
  `item_key` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_trade_id` (`trade_id`),
  KEY `idx_item` (`item_type`,`item_id`),
  CONSTRAINT `trade_items_ibfk_1` FOREIGN KEY (`trade_id`) REFERENCES `trade` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COMMENT='交易物品明细表';

-- ----------------------------
-- Records of trade_items
-- ----------------------------
INSERT INTO `trade_items` VALUES ('1', '1', 'item', '1', '1', 'give', '2026-04-30 14:06:06', null, null, null);
INSERT INTO `trade_items` VALUES ('2', '1', 'weapon', '1', '1', 'give', '2026-04-30 14:06:06', null, null, null);
INSERT INTO `trade_items` VALUES ('3', '1', 'material', '5', '5', 'take', '2026-04-30 14:06:06', null, null, null);
INSERT INTO `trade_items` VALUES ('4', '2', 'weapon', '4', '1', 'give', '2026-04-30 14:06:06', null, null, null);
INSERT INTO `trade_items` VALUES ('5', '2', 'item', '8', '1', 'take', '2026-04-30 14:06:06', null, null, null);
INSERT INTO `trade_items` VALUES ('6', '3', 'material', '7', '10', 'give', '2026-04-30 14:06:06', null, null, null);
INSERT INTO `trade_items` VALUES ('7', '3', 'material', '12', '1', 'take', '2026-04-30 14:06:06', null, null, null);
INSERT INTO `trade_items` VALUES ('8', '4', 'item', '4', '2', 'give', '2026-04-30 14:06:06', null, null, null);
INSERT INTO `trade_items` VALUES ('9', '4', 'ammo', '2', '5', 'take', '2026-04-30 14:06:06', null, null, null);
INSERT INTO `trade_items` VALUES ('10', '5', 'weapon', '9', '1', 'give', '2026-04-30 14:06:06', null, null, null);
INSERT INTO `trade_items` VALUES ('11', '5', 'weapon', '3', '1', 'take', '2026-04-30 14:06:06', null, null, null);
INSERT INTO `trade_items` VALUES ('12', '6', 'material', '5', '1', 'take', '2026-05-01 09:36:56', null, null, null);
INSERT INTO `trade_items` VALUES ('13', '7', 'material', '5', '1', 'take', '2026-05-01 10:29:46', null, null, null);
INSERT INTO `trade_items` VALUES ('14', '8', 'material', '5', '1', 'take', '2026-05-01 10:54:31', null, null, null);
INSERT INTO `trade_items` VALUES ('15', '9', 'material', '5', '3', 'give', '2026-05-02 17:41:28', null, null, null);
INSERT INTO `trade_items` VALUES ('16', '10', 'material', '5', '3', 'give', '2026-05-02 17:46:24', null, null, null);
INSERT INTO `trade_items` VALUES ('17', '11', 'material', '5', '1', 'give', '2026-05-05 21:16:29', null, null, null);
INSERT INTO `trade_items` VALUES ('18', '12', 'material', '5', '1', 'give', '2026-05-05 21:17:33', null, null, null);

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `role` enum('dm','player') NOT NULL,
  `player_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('1', 'dm1', 'test123', 'dm', null, '2026-04-26 22:13:35', '2026-04-26 22:13:35', '1');
INSERT INTO `user` VALUES ('2', 'dm2', 'test123', 'dm', null, '2026-04-26 22:13:35', '2026-04-26 22:13:35', '1');
INSERT INTO `user` VALUES ('3', 'player1', 'test123', 'player', '1', '2026-04-26 22:13:35', '2026-04-26 22:13:35', '1');
INSERT INTO `user` VALUES ('4', 'player2', 'test123', 'player', '2', '2026-04-26 22:13:35', '2026-04-26 22:13:35', '1');
INSERT INTO `user` VALUES ('5', 'player3', 'test123', 'player', '3', '2026-04-26 22:13:35', '2026-04-26 22:13:35', '1');
INSERT INTO `user` VALUES ('6', 'player4', 'test123', 'player', '4', '2026-04-26 22:13:35', '2026-04-26 22:13:35', '1');
INSERT INTO `user` VALUES ('7', 'player5', 'test123', 'player', '5', '2026-04-26 22:13:35', '2026-04-26 22:13:35', '1');
INSERT INTO `user` VALUES ('8', 'player6', 'test123', 'player', '6', '2026-04-29 10:34:27', '2026-04-29 10:34:27', '1');

-- ----------------------------
-- Table structure for weapon
-- ----------------------------
DROP TABLE IF EXISTS `weapon`;
CREATE TABLE `weapon` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `remark` text,
  `threat_level` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of weapon
-- ----------------------------
INSERT INTO `weapon` VALUES ('1', '制式手枪', '把', '标准配备', '4', '2026-04-27 11:36:23', '2026-05-02 19:21:41');
INSERT INTO `weapon` VALUES ('2', '猎枪', '把', '威力较大', '6', '2026-04-27 11:36:23', '2026-05-02 19:21:45');
INSERT INTO `weapon` VALUES ('3', '警棍', '个', '非致命武器', '1', '2026-04-27 11:36:23', '2026-05-02 19:20:27');
INSERT INTO `weapon` VALUES ('4', '刺刀', '把', '军用制式刺刀，长约20厘米。威胁值2。', '2', '2026-04-27 11:36:23', '2026-05-02 19:21:50');
INSERT INTO `weapon` VALUES ('5', '水手刀', '把', '多功能刀具', '2', '2026-04-27 11:36:23', '2026-05-02 19:21:53');
INSERT INTO `weapon` VALUES ('6', '鱼叉/矛', '个', '狩猎工具', '4', '2026-04-27 11:36:23', '2026-05-02 19:21:56');
INSERT INTO `weapon` VALUES ('7', '猎弓', '张', '远程武器', '4', '2026-04-27 11:36:23', '2026-05-02 19:22:03');
INSERT INTO `weapon` VALUES ('8', '十字镐', '把', '挖掘工具', '1', '2026-04-27 11:36:23', '2026-05-02 19:21:04');
INSERT INTO `weapon` VALUES ('9', '斧头', '把', '砍伐工具', '2', '2026-04-27 11:36:23', '2026-05-02 19:22:11');
INSERT INTO `weapon` VALUES ('10', '电锯', '把', '切割工具', '4', '2026-04-27 11:36:23', '2026-05-02 19:22:15');
INSERT INTO `weapon` VALUES ('11', '手术刀', '把', '医疗工具', '1', '2026-04-27 11:36:23', '2026-05-02 19:21:20');
INSERT INTO `weapon` VALUES ('12', '炸药', 'kg', '爆炸物', '10', '2026-04-27 11:36:23', '2026-04-27 11:36:23');
