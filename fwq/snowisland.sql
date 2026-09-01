
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `ammo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ammo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `remark` text,
  `weapon_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tag` varchar(100) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `weapon_id` (`weapon_id`),
  CONSTRAINT `ammo_ibfk_1` FOREIGN KEY (`weapon_id`) REFERENCES `weapon` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `ammo` WRITE;
/*!40000 ALTER TABLE `ammo` DISABLE KEYS */;
INSERT INTO `ammo` VALUES (1,'手枪弹','枚','.38/200口径手枪弹药，每发为韦伯利手枪专用。装填后可使手枪的威胁值生效。',1,'2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(2,'猎枪弹','枚','12号口径霰弹，每发内含多颗铅弹。装填后可使猎枪的威胁值生效。',2,'2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(3,'信号弹','枚','红/绿两色信号弹，每发可发射一次。用信号枪发射后，由主持人在公屏展示信号内容。',7,'2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(4,'箭矢','枝','木质箭杆配金属箭头，每支为猎弓专用。装填后可使猎弓的威胁值生效。',7,'2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL);
/*!40000 ALTER TABLE `ammo` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `ark_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ark_config` (
  `id` int NOT NULL,
  `ark_status` varchar(20) DEFAULT NULL,
  `base_capacity` int DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `current_game_day` int DEFAULT NULL,
  `daily_asphalt_limit` decimal(10,2) DEFAULT NULL,
  `daily_metal_limit` decimal(10,2) DEFAULT NULL,
  `daily_wood_limit` decimal(10,2) DEFAULT NULL,
  `food_per_capacity` int DEFAULT NULL,
  `fuel_per_capacity` decimal(5,2) DEFAULT NULL,
  `initial_metal` decimal(10,2) DEFAULT NULL,
  `initial_wood` decimal(10,2) DEFAULT NULL,
  `sail_canvas_required` decimal(10,2) DEFAULT NULL,
  `sail_days_0_engine` int DEFAULT NULL,
  `sail_days_1_engine` int DEFAULT NULL,
  `sail_days_2_engine` int DEFAULT NULL,
  `sail_days_3_engine` int DEFAULT NULL,
  `sail_days_with_sail_0_engine` int DEFAULT NULL,
  `sail_days_with_sail_1_engine` int DEFAULT NULL,
  `sail_rope_required` decimal(10,2) DEFAULT NULL,
  `sail_wood_per_capacity` decimal(5,2) DEFAULT NULL,
  `sealant_per_capacity` decimal(5,2) DEFAULT NULL,
  `shortage_capacity_penalty` int DEFAULT NULL,
  `shortage_completion_penalty` decimal(4,2) DEFAULT NULL,
  `target_asphalt` decimal(10,2) DEFAULT NULL,
  `target_metal` decimal(10,2) DEFAULT NULL,
  `target_wood` decimal(10,2) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `work_asphalt_per_unit` decimal(5,2) DEFAULT NULL,
  `work_metal_per_unit` decimal(5,2) DEFAULT NULL,
  `work_wood_per_unit` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `ark_config` WRITE;
/*!40000 ALTER TABLE `ark_config` DISABLE KEYS */;
INSERT INTO `ark_config` VALUES (1,'building',50,'2026-05-13 21:35:13.589000',1,20.00,20.00,30.00,100,2.00,20.00,10.00,80.00,10,8,6,4,10,7,100.00,2.00,500.00,3,2.50,100.00,100.00,250.00,'2026-05-13 21:35:13.589000',5.00,5.00,5.00);
/*!40000 ALTER TABLE `ark_config` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `ark_construction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ark_construction` (
  `id` int NOT NULL DEFAULT '1' COMMENT '单方舟模式，固定值为1',
  `current_wood` double NOT NULL DEFAULT '0' COMMENT '当前木材数量（吨）',
  `current_metal` double NOT NULL DEFAULT '0' COMMENT '当前金属制品数量（吨）',
  `current_sealant` int NOT NULL DEFAULT '0' COMMENT '当前密封材料数量（kg）',
  `engine_count` int NOT NULL DEFAULT '0' COMMENT '发动机数量（0-3）',
  `propeller_count` int NOT NULL DEFAULT '0' COMMENT '螺旋桨数量',
  `generator_count` int NOT NULL DEFAULT '0' COMMENT '发电机数量',
  `current_cargo_capacity` int NOT NULL DEFAULT '0' COMMENT '当前载重能力',
  `completion_percentage` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '完成度百分比',
  `has_sail` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已建造帆',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `bonus_percentage` decimal(5,2) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='方舟建造进度表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `ark_construction` WRITE;
/*!40000 ALTER TABLE `ark_construction` DISABLE KEYS */;
INSERT INTO `ark_construction` VALUES (1,5,1,0,0,0,0,0,0.00,0,'2026-08-28 04:50:33','2026-08-28 04:50:33',0.00);
/*!40000 ALTER TABLE `ark_construction` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `ark_construction_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ark_construction_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_description` varchar(255) DEFAULT NULL,
  `action_type` varchar(30) NOT NULL,
  `asphalt_change` decimal(10,2) DEFAULT NULL,
  `capacity_change` int DEFAULT NULL,
  `completion_change` decimal(5,2) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `current_capacity` int DEFAULT NULL,
  `current_completion` decimal(5,2) DEFAULT NULL,
  `current_stage` varchar(30) DEFAULT NULL,
  `engine_installed` int DEFAULT NULL,
  `game_day` int NOT NULL,
  `generator_installed` int DEFAULT NULL,
  `metal_change` decimal(10,2) DEFAULT NULL,
  `player_id` int NOT NULL,
  `player_name` varchar(50) DEFAULT NULL,
  `previous_capacity` int DEFAULT NULL,
  `previous_completion` decimal(5,2) DEFAULT NULL,
  `previous_stage` varchar(30) DEFAULT NULL,
  `propeller_installed` int DEFAULT NULL,
  `sail_built` bit(1) DEFAULT NULL,
  `sail_canvas_used` decimal(10,2) DEFAULT NULL,
  `sail_rope_used` decimal(10,2) DEFAULT NULL,
  `wood_change` decimal(10,2) DEFAULT NULL,
  `work_units` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `ark_construction_log` WRITE;
/*!40000 ALTER TABLE `ark_construction_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `ark_construction_log` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `ark_required_skill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ark_required_skill` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `effect_bonus` int DEFAULT NULL,
  `is_required` bit(1) DEFAULT NULL,
  `priority` int DEFAULT NULL,
  `skill_code` varchar(50) NOT NULL,
  `skill_description` varchar(255) DEFAULT NULL,
  `skill_name` varchar(100) NOT NULL,
  `skill_type` varchar(20) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_5af48mct3mcot3g68dq9chwoh` (`skill_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `ark_required_skill` WRITE;
/*!40000 ALTER TABLE `ark_required_skill` DISABLE KEYS */;
/*!40000 ALTER TABLE `ark_required_skill` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `ark_sail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ark_sail` (
  `id` int NOT NULL,
  `built_at_game_day` int DEFAULT NULL,
  `built_by_player_id` int DEFAULT NULL,
  `collected_canvas` decimal(10,2) DEFAULT NULL,
  `collected_rope` decimal(10,2) DEFAULT NULL,
  `condition_status` varchar(20) DEFAULT NULL,
  `construction_progress` decimal(5,2) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `effect_0_engine_days` int DEFAULT NULL,
  `effect_1_engine_days` int DEFAULT NULL,
  `is_built` bit(1) DEFAULT NULL,
  `is_work_completed` bit(1) DEFAULT NULL,
  `last_repaired_day` int DEFAULT NULL,
  `required_canvas` decimal(10,2) DEFAULT NULL,
  `required_rope` decimal(10,2) DEFAULT NULL,
  `requires_work_action` bit(1) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `work_action_player_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `ark_sail` WRITE;
/*!40000 ALTER TABLE `ark_sail` DISABLE KEYS */;
/*!40000 ALTER TABLE `ark_sail` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `ark_voyage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ark_voyage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actual_return_day` int DEFAULT NULL,
  `base_sail_days` int DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `crisis_count` int DEFAULT NULL,
  `crisis_events` text,
  `current_day_offset` int DEFAULT NULL,
  `departed_at` datetime(6) DEFAULT NULL,
  `departure_day` int NOT NULL,
  `engine_count` int DEFAULT NULL,
  `final_bonus` int DEFAULT NULL,
  `final_sail_days` int DEFAULT NULL,
  `food_loaded` decimal(10,2) DEFAULT NULL,
  `fuel_loaded` decimal(10,2) DEFAULT NULL,
  `has_fisher` bit(1) DEFAULT NULL,
  `has_generator` bit(1) DEFAULT NULL,
  `has_navigator` bit(1) DEFAULT NULL,
  `has_sail` bit(1) DEFAULT NULL,
  `has_weather_watcher` bit(1) DEFAULT NULL,
  `notes` text,
  `passenger_count` int DEFAULT NULL,
  `passenger_list` text,
  `planned_return_day` int DEFAULT NULL,
  `propeller_count` int DEFAULT NULL,
  `returned_at` datetime(6) DEFAULT NULL,
  `sealant_loaded` decimal(10,2) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `total_capacity` int DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `voyage_number` int NOT NULL,
  `voyage_result` varchar(50) DEFAULT NULL,
  `wood_loaded` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `ark_voyage` WRITE;
/*!40000 ALTER TABLE `ark_voyage` DISABLE KEYS */;
/*!40000 ALTER TABLE `ark_voyage` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `catastrophe_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catastrophe_card` (
  `id` int NOT NULL AUTO_INCREMENT,
  `card_number` int NOT NULL COMMENT '卡牌编号',
  `name` varchar(50) NOT NULL COMMENT '卡牌名称',
  `description` text NOT NULL COMMENT '卡牌描述',
  `effect_type` varchar(50) DEFAULT NULL COMMENT '效果类型',
  `effect_param1` int DEFAULT '0' COMMENT '效果参数1',
  `effect_param2` int DEFAULT '0' COMMENT '效果参数2',
  `effect_param3` varchar(100) DEFAULT NULL COMMENT '效果参数3（字符串）',
  `is_unique` tinyint(1) DEFAULT '0' COMMENT '是否唯一卡牌',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `card_number` (`card_number`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='天灾牌表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `catastrophe_card` WRITE;
/*!40000 ALTER TABLE `catastrophe_card` DISABLE KEYS */;
INSERT INTO `catastrophe_card` VALUES (64,1,'低温侵袭','某处墙体结冰，寒气渗入。本天所有燃料消耗增加100%，木材消耗量15kg→30kg。','CONSUMPTION_INCREASE',100,15,'30',0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(65,2,'灾难蔓延','增加5天暴雪持续时间，方舟航行难度增加航行时间加2天。','EXTEND_STORM',5,2,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(66,3,'粮仓鼠患','由天灾使者选择两个仓库\n仓库中储存的粮食被老鼠啃食，损失20%的食物储备（向下取整）','FOOD_LOSS',20,2,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(67,4,'燃料泄漏','储油桶老化破裂，损失一处仓库的20%的燃料储备（优先扣除煤油/燃油）','FUEL_LOSS',20,0,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(68,5,'工具锈蚀','生产工具普遍老化。当天所有生产行动（渔猎、伐木、挖矿等）产量-50%。','PRODUCTION_DECREASE',50,0,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(69,6,'海水倒灌','风暴潮淹没码头设施，沿海仓库的部分物资被冲走（损失20%），方舟受损30%。','DOCK_DAMAGE',20,30,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(70,7,'水源污染','岛上淡水水源被动物尸体污染，所有玩家当天需额外消耗1升煤油（烧开水）或面临患病风险','WATER_CONTAMINATION',1,0,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(71,8,'信仰崩塌','神父以及占卜师等精神领袖陷入自我怀疑，当天无法使用\"布道\"或\"占星\"技能。若第三天抽中不影响终局结算加成。','SKILL_DISABLE',0,0,'布道,占星',0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(72,9,'燃料受潮','露天堆放的木柴被雨淋湿。随机一个仓库或玩家损失30kg木材。','WOOD_LOSS',30,0,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(73,10,'逃役','一名劳工趁夜色逃走了。统治者当天指定的劳工名单中，随机一人自动失效（不会劳作，也不会计入劳工）。主持人随机选择，不公开是谁。该玩家知道自己被逃役释放，当天正常进行行动。','ESCAPE_LABOR',0,0,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(74,11,'祭品','有人在教堂门口发现一只被割喉的黑羊。第二天必定触发两张额外天灾牌（也就是第二天触发3张天灾牌）。','EXTRA_CARD',2,0,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(75,12,'屋顶坍塌','某栋小镇建筑（随机）的屋顶因积雪过厚而垮塌，压坏内部设施。\n效果：主持人随机选择一个小镇地点，该地点的防御值永久-2，且内部一个随机设施损坏（如发电机、烘焙炉、电报机等），需消耗 50kg木材 和 1次维修行动 修复。','BUILDING_COLLAPSE',2,50,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(76,13,'道路冰封','一夜之间，连接各主要地点的土路冻成镜面，车和人都打滑难行。\n当天所有地点之间的移动搬运量减半（任何运输行动效率-50%）。','TRANSPORT_DECREASE',50,0,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33');
/*!40000 ALTER TABLE `catastrophe_card` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `catastrophe_deck`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catastrophe_deck` (
  `id` int NOT NULL AUTO_INCREMENT,
  `card_id` int NOT NULL COMMENT '天灾牌ID',
  `is_drawn` tinyint(1) DEFAULT '0' COMMENT '是否已抽取',
  `is_used` tinyint(1) DEFAULT '0' COMMENT '是否已使用',
  `drawn_at` datetime DEFAULT NULL COMMENT '抽取时间',
  `used_at` datetime DEFAULT NULL COMMENT '使用时间',
  `round_used` int DEFAULT '0' COMMENT '使用回合',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `card_id` (`card_id`),
  CONSTRAINT `catastrophe_deck_ibfk_1` FOREIGN KEY (`card_id`) REFERENCES `catastrophe_card` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=229 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='天灾牌组管理表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `catastrophe_deck` WRITE;
/*!40000 ALTER TABLE `catastrophe_deck` DISABLE KEYS */;
INSERT INTO `catastrophe_deck` VALUES (190,64,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(191,64,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(192,64,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(193,65,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(194,65,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(195,65,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(196,66,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(197,66,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(198,66,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(199,67,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(200,67,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(201,67,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(202,68,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(203,68,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(204,68,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(205,69,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(206,69,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(207,69,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(208,70,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(209,70,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(210,70,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(211,71,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(212,71,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(213,71,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(214,72,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(215,72,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(216,72,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(217,73,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(218,73,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(219,73,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(220,74,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(221,74,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(222,74,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(223,75,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(224,75,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(225,75,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(226,76,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(227,76,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33'),(228,76,0,0,NULL,NULL,0,'2026-08-28 04:50:33','2026-08-28 04:50:33');
/*!40000 ALTER TABLE `catastrophe_deck` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `catastrophe_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `catastrophe_progress` (
  `id` int NOT NULL AUTO_INCREMENT,
  `progress` int NOT NULL DEFAULT '0' COMMENT '天灾进度值 0-100',
  `last_updated_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_single_record` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='天灾进度表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `catastrophe_progress` WRITE;
/*!40000 ALTER TABLE `catastrophe_progress` DISABLE KEYS */;
/*!40000 ALTER TABLE `catastrophe_progress` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `clue_trigger_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clue_trigger_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `clue_code` varchar(50) DEFAULT NULL,
  `clue_id` int NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `matched_keyword` varchar(200) DEFAULT NULL,
  `npc_id` int NOT NULL,
  `player_id` int NOT NULL,
  `player_message` text,
  `response_text` text,
  `trigger_time` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `clue_trigger_log` WRITE;
/*!40000 ALTER TABLE `clue_trigger_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `clue_trigger_log` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `drawn_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `drawn_cards` (
  `id` int NOT NULL AUTO_INCREMENT,
  `draw_round` int NOT NULL COMMENT '抽取轮次',
  `deck_id` int NOT NULL COMMENT '牌组ID',
  `position` int NOT NULL COMMENT '位置（1-3）',
  `is_selected` tinyint(1) DEFAULT '0' COMMENT '是否被选中',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_draw_position` (`draw_round`,`position`),
  KEY `deck_id` (`deck_id`),
  CONSTRAINT `drawn_cards_ibfk_1` FOREIGN KEY (`deck_id`) REFERENCES `catastrophe_deck` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='抽取牌记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `drawn_cards` WRITE;
/*!40000 ALTER TABLE `drawn_cards` DISABLE KEYS */;
/*!40000 ALTER TABLE `drawn_cards` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `endgame_ark_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `endgame_ark_event` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `sort_order` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `endgame_ark_event` WRITE;
/*!40000 ALTER TABLE `endgame_ark_event` DISABLE KEYS */;
INSERT INTO `endgame_ark_event` VALUES (1,'巨浪拍舷','一道突如其来的侧浪狠狠拍打船身，甲板上的物资被冲得七零八落，几个水手差点落水。 效果：随机损失10%的食物（被浪卷走）。若拥有\"航海\"技能玩家或额外消耗50kg燃料紧急调整航向，可将损失降至0。','危机',1,NULL,NULL),(2,'帆布撕裂','强风将主帆撕开一道大口子，帆布在风中啪啪作响，船速骤降。\n\n效果：本日及后续航行天数增加1天（因减速）。若消耗10米帆布或\"维修\"技能玩家现场缝补，可免于增加天数。若无帆船（纯发动机），此事件无效，重新抽取。','危机',2,NULL,NULL),(3,'淡水变质','储存的桶装淡水出现绿藻和异味，部分已不可饮用。 效果：损失10%的食物储备。消耗5份医疗资源或200kg木材可净化剩余淡水，将损失降至5%。否则获得3个\"患病\"标记。','危机',3,NULL,NULL),(4,'发动机过热','因长时间高负荷运转，发动机冷却系统失效，缸体发红，必须停机。\n\n效果：若不修复，航行强制暂停1天（需原地等待冷却）。消耗1个维修工具包或拥有\"维修\"技能玩家可当场修复，不损失时间。','危机',4,NULL,NULL),(5,'晕船蔓延','连续颠簸让超过一半人晕船呕吐，体力下降，士气低迷。 效果：获得3个\"患病\"标记（严重晕船）。若拥有\"医疗\"技能玩家或消耗10份朗姆酒可缓解。','危机',5,NULL,NULL),(6,'暗礁险情','海面下隐约看到黑色礁石轮廓，舵手紧急打舵。\n\n效果：若拥有\"海洋导航\"技能玩家，可安全绕行。否则船底擦伤，船体完整度下降5%，并损失5%燃料（泄漏）。','危机',6,NULL,NULL),(7,'食物中毒','一批腌肉在高温下变质，多人食用后腹痛腹泻。 效果：获得方舟人数的\"患病\"标记，并损失10%食物（变质部分丢弃）。消耗20份医疗资源可救治所有人，避免患病标记。','危机',7,NULL,NULL),(8,'内部盗窃','有人趁夜偷走部分燃料和食物，藏在个人箱子里。被发现后引发争执。\n\n效果：若不消耗2个朗姆酒则损失5%燃料和5%食物（被窃并挥霍），且随机1名玩家受伤（斗殴）。','危机',8,NULL,NULL),(9,'螺旋桨缠绕','漂浮的渔网或海草缠住了螺旋桨，动力下降，船体抖动。\n\n效果：需有玩家或拥有\"格斗\"/\"潜水\"技能玩家下水清理，或搁置耗时加1天。可消耗1个维修工具包远程切断。','危机',9,NULL,NULL),(10,'暴风雨迷航','一场无预报的暴风雨遮天蔽日，指南针失灵，航向偏移。\n\n效果：若拥有\"天气预测\"技能玩家或海图（特殊物品），可校准航向，无损失。否则航行天数增加1天，并额外消耗10%燃料。','危机',10,NULL,NULL),(11,'舱底进水','船底板接缝处渗水，水泵来不及抽排，水位缓慢上升。 效果：消耗500kg木材可堵漏。否则每过1天，船体完整度下降5%且获得3个\"患病\"标记（潮湿寒冷）。','危机',11,NULL,NULL),(12,'传染病爆发','一种类似流感的疾病在密闭船舱中迅速传播，咳嗽声此起彼伏。 效果：获得5个\"患病\"标记。消耗20份医疗资源或拥有\"医疗\"或\"布道\"玩家可控制疫情，只获得1个\"患病\"标记。','危机',12,NULL,NULL),(13,'桅杆断裂','一阵强风拦腰折断主桅，帆具垮塌，甲板一片狼藉。\n\n效果：船体完整度下降10%。若拥有500kg木材可临时修复，只增加1天。','危机',13,NULL,NULL),(14,'漂浮的救援物资','桅杆上的瞭望手突然大喊：\"左舷海面上有漂浮的桶！\"你们靠近后发现，那正是你们之前通过邮局电报机向外发送求救信号的回应——一艘货轮在暴风雪来临前抛下了救援物资桶，上面还绑着一面沾着冰霜的旗帜。\n\n效果：获得20单位食物+50kg燃料（煤油/柴油）+10份医疗资源。若船上拥有\"天气预测\"或\"海洋导航\"技能玩家，还能额外找到1个维修工具包。这些物资直接进入方舟公共仓库。','希望',14,NULL,NULL),(15,'顺风加速','风向突然转为顺风，帆面鼓满，船头像切开黄油一样劈开浪花。舵手兴奋地吹起口哨。\n\n效果：航行天数减少1天。同时，本日不消耗额外燃料（发动机可停机半天）。','希望',15,NULL,NULL),(16,'海鸟引路','一群海鸟盘旋在船头方向，不时俯冲入水。经验丰富的水手说：\"跟着它们，前面必有浅滩或岛屿。\"\n\n效果：第二天航海检定自动成功（相当于一次免费绕开险情）。','希望',16,NULL,NULL),(17,'漂浮的救援物资','桅杆上的瞭望手突然大喊：\"左舷海面上有漂浮的桶！\"你们靠近后发现，那正是你们之前通过邮局电报机向外发送求救信号的回应——一艘货轮在暴风雪来临前抛下了救援物资桶，上面还绑着一面沾着冰霜的旗帜。\n\n效果：获得20单位食物+50kg燃料（煤油/柴油）+10份医疗资源。若船上拥有\"天气预测\"或\"海洋导航\"技能玩家，还能额外找到1个维修工具包。这些物资直接进入方舟公共仓库。','希望',17,NULL,NULL),(18,'漂浮的救援物资','桅杆上的瞭望手突然大喊：\"左舷海面上有漂浮的桶！\"你们靠近后发现，那正是你们之前通过邮局电报机向外发送求救信号的回应——一艘货轮在暴风雪来临前抛下了救援物资桶，上面还绑着一面沾着冰霜的旗帜。\n\n效果：获得20单位食物+50kg燃料（煤油/柴油）+10份医疗资源。若船上拥有\"天气预测\"或\"海洋导航\"技能玩家，还能额外找到1个维修工具包。这些物资直接进入方舟公共仓库。','希望',18,NULL,NULL),(19,'漂浮的救援物资','桅杆上的瞭望手突然大喊：\"左舷海面上有漂浮的桶！\"你们靠近后发现，那正是你们之前通过邮局电报机向外发送求救信号的回应——一艘货轮在暴风雪来临前抛下了救援物资桶，上面还绑着一面沾着冰霜的旗帜。\n\n效果：获得20单位食物+50kg燃料（煤油/柴油）+10份医疗资源。若船上拥有\"天气预测\"或\"海洋导航\"技能玩家，还能额外找到1个维修工具包。这些物资直接进入方舟公共仓库。','希望',19,NULL,NULL);
/*!40000 ALTER TABLE `endgame_ark_event` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `endgame_shelter_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `endgame_shelter_event` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `sort_order` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `endgame_shelter_event` WRITE;
/*!40000 ALTER TABLE `endgame_shelter_event` DISABLE KEYS */;
INSERT INTO `endgame_shelter_event` VALUES (1,'岩层渗水','避难所深处的一面岩壁开始渗水，泥浆顺着裂缝流下来，空气变得潮湿阴冷。如果不加固，可能会引发更大规模塌方或积水。如果为牢固避难所则此事件失效。 效果：若拥有100kg石料或500kg木材，可选择消耗其一进行加固，事件安全解决。否则，避难所湿度持续上升，获得3个\"患病\"标记（因呼吸道疾病或风湿），且下一轮燃料消耗增加100%（因取暖需求上升）。','危机',1,NULL,NULL),(2,'通风道堵塞','主通风道被落石和冻土堵死，二氧化碳浓度缓慢攀升，人们开始头痛、昏沉。 效果：若拥有\"维修\"或\"格斗\"能力的玩家（或NPC）手动清理，或消耗200kg木材临时搭建辅助通风管，可恢复通风。否则，增加3个\"患病\"标记。','危机',2,NULL,NULL),(3,'地下暗涌','一场小型地下水脉破裂，冲毁了部分储备区。\n\n效果：随机损失10%～20%的燃料（优先煤油、柴油）和5%～10%的食物（被水浸泡）。若拥有5000kg石料或10名劳工可紧急筑坝，将损失归零。牢固避难所消耗资源减半。','危机',3,NULL,NULL),(4,'集体幻觉','长期不见日光和心理压力导致数人产生幻觉，他们尖叫着冲向紧急出口，引发混乱。 \r\n效果：若无拥有\"布道\"或\"医疗\"技能的玩家进行安抚，并且花费20份医疗资源。产生5个\"患病\"标记（精神创伤）。消耗40份医疗资源可代替技能平定事态。','危机',4,NULL,NULL),(5,'燃料挥发泄漏','储存的煤油桶因锈蚀出现微小裂缝，挥发气体聚集在低洼处，刺鼻且易燃。\n\n效果：强制损失10%的燃料储备（挥发浪费）。若拥有维修工具包或消耗100kg金属制品修补桶体，则只损失5%的燃料储备。','危机',5,NULL,NULL),(6,'鼠群入侵','一群耐寒的老鼠咬穿了一道木质隔板，开始在粮袋间肆虐。牢固避难所不结算此效果。\n\n效果：损失10%的食物。','危机',6,NULL,NULL),(7,'心理崩溃——自残','一名避难者突然用尖锐工具划伤自己，鲜血和尖叫让所有人都绷紧了神经。\r\n 效果：消耗25份医疗资源救治伤者，并额外消耗10份朗姆酒或10份食物用于安抚群众。否则获得5个\"患病\"标记（集体抑郁）','危机',7,NULL,NULL),(8,'支柱朽坏','一根支撑主通道的木梁发出碎裂声，顶部碎石摇摇欲坠。\n\n效果：若拥有500kg木材或200kg石材可替换，事件安全。否则发生局部塌方，随机2～5名玩家受伤（获得\"受伤\"标记，无法生产但可医疗），并损失10%的公共物资（被埋）。','危机',8,NULL,NULL),(9,'炭火中毒','有人在密闭小隔间中使用炭火取暖，一氧化碳扩散到主厅，多人呕吐晕眩。 效果：消耗25份医疗资源进行高治疗，或拥有通风改造（之前解决过通风事件可免疫）。否则产生3个\"患病\"标记。','危机',9,NULL,NULL),(10,'医疗物资污染','因潮湿和霉菌，部分绷带、药品和消毒剂变质失效。\n\n效果：若拥有500kg燃料用于高温消毒处理剩余物资，可将损失降至10%。否则损失20%的医疗资源（向下取整）。','危机',10,NULL,NULL),(11,'地下冰裂——寒气入侵','避难所下方开裂，寒气从地面缝隙中冒出，温度骤降。\n\n效果：当天及之后每天燃料消耗增加10%。若拥有100kg石料或200kg木材铺地隔绝，可消除此效果（牢固避难所消耗材料降低20%）。','危机',11,NULL,NULL),(12,'污水倒灌','简易厕所和排污管堵塞，脏水溢出，弥漫恶臭。 效果：消耗1000kg木材可彻底疏通，或立即获得3个\"患病\"标记。','危机',12,NULL,NULL),(13,'粮仓霉变','储存区湿度过高，谷物表面出现绿毛和黑斑。 效果：损失20%的食物储备（霉坏）。若立即消耗50kg燃料或750kg木材进行烘干处理，可挽回一半损失（即只损失10%）。','危机',13,NULL,NULL),(14,'坍塌？','避难所顶部出现了坍塌，导致了2名随机玩家受伤，交付10医疗资源可通过此次判定，并且矿场仓库得到了联通，你们可以尝试获得10000kg的矿场仓库的资源到避难所','希望',14,NULL,NULL),(15,'无事发生','这事好事，不是吗','希望',15,NULL,NULL),(16,'无事发生','这是好事，不是吗','希望',16,NULL,NULL);
/*!40000 ALTER TABLE `endgame_shelter_event` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `event_pack`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_pack` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `sort_order` int NOT NULL DEFAULT '0',
  `parent_id` int DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_event_pack_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `event_pack` WRITE;
/*!40000 ALTER TABLE `event_pack` DISABLE KEYS */;
INSERT INTO `event_pack` VALUES (1,'基础包',1,1,NULL,'2026-08-28 04:48:40.790195','2026-08-28 04:48:40.791437'),(2,'旧世界的末尾',0,2,NULL,'2026-08-28 04:48:40.815047','2026-08-28 04:48:40.815061'),(3,'第四纪元',0,3,NULL,'2026-08-28 04:48:40.817257','2026-08-28 04:48:40.817267'),(4,'隐秘居所',0,4,NULL,'2026-08-28 04:48:40.819248','2026-08-28 04:48:40.819259');
/*!40000 ALTER TABLE `event_pack` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `faction_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `faction_action` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL COMMENT '提交玩家ID',
  `player_name` varchar(50) DEFAULT NULL COMMENT '玩家名称快照',
  `faction` varchar(20) NOT NULL COMMENT '提交时阵营',
  `action_type` varchar(40) NOT NULL COMMENT '阵营行动类型：assign_personnel/assign_guard/sabotage等',
  `payload` text COMMENT 'JSON输入数据',
  `result` text COMMENT '行动结果/DM反馈',
  `status` enum('pending','feedbacked') NOT NULL DEFAULT 'pending' COMMENT '反馈状态',
  `game_day` int NOT NULL DEFAULT '1' COMMENT '游戏天数',
  `phase` varchar(20) DEFAULT 'day' COMMENT '阶段：day白天/night夜晚',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_player_day` (`player_id`,`game_day`),
  KEY `idx_faction_day` (`faction`,`game_day`),
  KEY `idx_action_type` (`action_type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='阵营行动表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `faction_action` WRITE;
/*!40000 ALTER TABLE `faction_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `faction_action` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `game_activity_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `game_activity_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category` varchar(24) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `detail` text,
  `game_day` int NOT NULL,
  `player_faction` varchar(20) DEFAULT NULL,
  `player_id` int DEFAULT NULL,
  `player_name` varchar(50) DEFAULT NULL,
  `summary` varchar(400) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_activity_created` (`created_at`),
  KEY `idx_activity_day` (`game_day`)
) ENGINE=InnoDB AUTO_INCREMENT=558 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `game_activity_log` WRITE;
/*!40000 ALTER TABLE `game_activity_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `game_activity_log` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `game_day_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `game_day_settings` (
  `game_day` int NOT NULL COMMENT '游戏天数',
  `required_food_units` int NOT NULL DEFAULT '2' COMMENT '每人每日所需食物（单位）',
  `required_fuel_kg` int NOT NULL DEFAULT '25' COMMENT '每人每日取暖燃料（千克，木材或燃料）',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`game_day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='每日全局消耗需求（DM在游戏设置中配置）';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `game_day_settings` WRITE;
/*!40000 ALTER TABLE `game_day_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `game_day_settings` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `game_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `game_state` (
  `id` int NOT NULL AUTO_INCREMENT,
  `current_day` int NOT NULL DEFAULT '1' COMMENT '当前天数',
  `current_phase` varchar(20) NOT NULL DEFAULT 'DAY' COMMENT '当前阶段 DAY/NIGHT',
  `is_game_over` tinyint(1) DEFAULT '0' COMMENT '游戏是否结束',
  `catastrophe_triggered` tinyint(1) DEFAULT '0' COMMENT '天灾是否已触发',
  `extra_card_due` tinyint(1) DEFAULT '0' COMMENT '是否有待触发的额外天灾牌',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_single_state` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='游戏状态表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `game_state` WRITE;
/*!40000 ALTER TABLE `game_state` DISABLE KEYS */;
/*!40000 ALTER TABLE `game_state` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `island_event`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `island_event` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `description` text NOT NULL,
  `name` varchar(100) NOT NULL,
  `rarity` varchar(20) DEFAULT NULL,
  `triggered` bit(1) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `event_difficulty` int NOT NULL DEFAULT '5' COMMENT '事件难度(0-20, 0=最简单的捡垃圾，20=极限危险)',
  `is_special` bit(1) NOT NULL,
  `location_desc` text,
  `lore_fragment` text,
  `pack_id` int DEFAULT NULL,
  `pack_name` varchar(100) DEFAULT NULL,
  `source_number` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `island_event` WRITE;
/*!40000 ALTER TABLE `island_event` DISABLE KEYS */;
INSERT INTO `island_event` VALUES (17,'2026-06-24 18:03:53.653000','地点描述：一座建在巨树高处的废弃木台，通往它的绳梯已经半朽。台上有一个被遗弃的巢穴，似乎被匆忙放弃。\n可获得物资：绳索 (10米)， 火把 (1把)\n历史秘密碎片：你在木台的柱子上发现了一连串古老的刻痕，像是某种计数方式。旁边画着一个歪歪扭扭的太阳，正在被雪花吞没。这似乎记录着某个先民对漫漫长夜的恐惧。\n难度：1','废弃的猎人瞭望台','common',_binary '\0','2026-08-28 04:48:40.934883',1,_binary '\0','一座建在巨树高处的废弃木台，通往它的绳梯已经半朽。台上有一个被遗弃的巢穴，似乎被匆忙放弃。','你在木台的柱子上发现了一连串古老的刻痕，像是某种计数方式。旁边画着一个歪歪扭扭的太阳，正在被雪花吞没。这似乎记录着某个先民对漫漫长夜的恐惧。',1,'基础包',1),(18,'2026-06-24 18:03:53.721000','地点描述：森林深处，一个早已被触发、长满青苔的捕兽夹，旁边散落着一些锈蚀的金属零件。\n可获得物资：金属制品 (5kg)， 猎弓 (1把)\n历史秘密碎片：你清理陷阱旁的落叶时，挖出一个油布包裹的小包，里面是一块打磨过的黑色石头。拿在手里，总觉得这上面似乎浸透了某种陈旧的、不属于这个时代的气息。\n难度：2','被遗忘的猎人陷阱','common',_binary '\0','2026-08-28 04:48:40.934894',2,_binary '\0','森林深处，一个早已被触发、长满青苔的捕兽夹，旁边散落着一些锈蚀的金属零件。','你清理陷阱旁的落叶时，挖出一个油布包裹的小包，里面是一块打磨过的黑色石头。拿在手里，总觉得这上面似乎浸透了某种陈旧的、不属于这个时代的气息。',1,'基础包',2),(19,'2026-06-24 18:03:53.747000','地点描述：一条几乎干涸溪流的源头，水流从岩石缝隙中渗出，形成一个小水潭。周围的植物异常茂盛。\n可获得物资：食物 (8单位)， 帆布 (2m)\n历史秘密碎片：你注意到水潭底的鹅卵石排列得异常整齐，似乎形成了一个古老的箭头，指向森林的更深处。这不是自然形成的。\n难度：2','隐秘的溪流源头','common',_binary '\0','2026-08-28 04:48:40.934899',2,_binary '\0','一条几乎干涸溪流的源头，水流从岩石缝隙中渗出，形成一个小水潭。周围的植物异常茂盛。','你注意到水潭底的鹅卵石排列得异常整齐，似乎形成了一个古老的箭头，指向森林的更深处。这不是自然形成的。',1,'基础包',3),(20,'2026-06-24 18:03:53.770000','地点描述：一个新的洞穴在风暴后露出，入口狭窄，内部潮湿，回荡着水声。墙壁上似乎有模糊的图案。\n可获得物资：医疗资源 (5单位)， 煤油 (2升)\n历史秘密碎片：墙壁上的图案描绘了一群人正将某种发光的石头沉入海底，而天空之上，有巨大的眼睛在注视着这一切。你感到一阵没来由的寒意。\n难度：3','风暴后的海岸洞穴','common',_binary '\0','2026-08-28 04:48:40.934905',3,_binary '\0','一个新的洞穴在风暴后露出，入口狭窄，内部潮湿，回荡着水声。墙壁上似乎有模糊的图案。','墙壁上的图案描绘了一群人正将某种发光的石头沉入海底，而天空之上，有巨大的眼睛在注视着这一切。你感到一阵没来由的寒意。',1,'基础包',4),(21,'2026-06-24 18:03:53.791000','地点描述：一艘被冲上沙滩、早已破烂不堪的渔船残骸，船体断裂，长满藤壶。\n可获得物资：木材 (5吨)， 金属制品 (3吨)， 煤油 (2升)\n历史秘密碎片：在船长的舱室，你找到一本泡烂的航海日志，最后几页的字迹疯狂扭曲，反复写着同一句话：“他们不该打开那个盒子......银色的盒子......”。字迹在“银色的盒子”这里戛然而止。\n难度：4','搁浅的旧渔船残骸','common',_binary '\0','2026-08-28 04:48:41.205109',4,_binary '\0','一艘被冲上沙滩、早已破烂不堪的渔船残骸，船体断裂，长满藤壶。','在船长的舱室，你找到一本泡烂的航海日志，最后几页的字迹疯狂扭曲，反复写着同一句话：“他们不该打开那个盒子......银色的盒子......”。字迹在“银色的盒子”这里戛然而止。',1,'基础包',5),(22,'2026-06-24 18:03:53.822000','地点描述：一个被藤蔓覆盖的木制路标，指向两个方向。一个方向指向小镇，另一个方向模糊难辨，通往一片被迷雾笼罩的谷地。\n可获得物资：无直接物资，但获得进入一个隐藏地点的线索。请私信dm。\n历史秘密碎片：路标上除了现代字迹，下方隐约刻着一行古老的文字，与现在任何语言都不相似。当你触摸它时，仿佛听到了极远处传来的钟声。\n难度：8','旧路标与岔道','uncommon',_binary '\0','2026-08-28 04:48:40.934915',8,_binary '\0','一个被藤蔓覆盖的木制路标，指向两个方向。一个方向指向小镇，另一个方向模糊难辨，通往一片被迷雾笼罩的谷地。','路标上除了现代字迹，下方隐约刻着一行古老的文字，与现在任何语言都不相似。当你触摸它时，仿佛听到了极远处传来的钟声。',1,'基础包',6),(23,'2026-06-24 18:03:53.830000','地点描述：小镇边缘一间半倒塌的旧工坊，内部有一个废弃的铁制炉灶，炉膛里积满了灰烬和杂物。\n可获得物资：金属制品 (8kg)， 木材 (5吨)\n历史秘密碎片：你在清理炉灶时，发现一块被熏黑的铁板，上面用钢钉歪歪扭扭地刻着一句话：“我们烧掉了所有带‘标记’的东西，但灰烬里又长出了新的。”这让你联想到那些瘟疫时期的传言。\n难度：9','废弃的工坊炉灶','uncommon',_binary '\0','2026-08-28 04:48:41.218024',9,_binary '\0','小镇边缘一间半倒塌的旧工坊，内部有一个废弃的铁制炉灶，炉膛里积满了灰烬和杂物。','你在清理炉灶时，发现一块被熏黑的铁板，上面用钢钉歪歪扭扭地刻着一句话：“我们烧掉了所有带‘标记’的东西，但灰烬里又长出了新的。”这让你联想到那些瘟疫时期的传言。',1,'基础包',7),(24,'2026-06-24 18:03:53.851000','地点描述：一处早已废弃的羊圈，石墙倒塌，里面空无一物，只有厚厚的干草和粪便。\n可获得物资： 木材 (5吨)\n历史秘密碎片：在清理一个石缝时，你找到一枚锈蚀的铜质奖章，上面刻着“第一届殖民垦殖纪念——1887”。但这座岛屿在官方的历史中，从未在1887年有过大规模殖民活动。\n难度：5','坍塌的羊圈遗址','common',_binary '\0','2026-08-28 04:48:41.224115',5,_binary '\0','一处早已废弃的羊圈，石墙倒塌，里面空无一物，只有厚厚的干草和粪便。','在清理一个石缝时，你找到一枚锈蚀的铜质奖章，上面刻着“第一届殖民垦殖纪念——1887”。但这座岛屿在官方的历史中，从未在1887年有过大规模殖民活动。',1,'基础包',8),(25,'2026-06-24 18:03:53.866000','地点描述：一棵空心大树的树洞里，藏着一个油布包裹的旧木箱，上面落满了灰尘和松针。\n可获得物资：猎枪弹 (4发)， 信号枪 (1把，含2发照明弹)\n历史秘密碎片：箱盖内侧刻着一张粗糙的地图，标记着一个远离所有已知地点的X。旁边写着：“如果看到红色的月亮，就去那里。”你不确定这是玩笑还是某种古老的预警。\n难度：6','猎人的旧货箱','uncommon',_binary '\0','2026-08-28 04:48:41.230685',6,_binary '\0','一棵空心大树的树洞里，藏着一个油布包裹的旧木箱，上面落满了灰尘和松针。','箱盖内侧刻着一张粗糙的地图，标记着一个远离所有已知地点的X。旁边写着：“如果看到红色的月亮，就去那里。”你不确定这是玩笑还是某种古老的预警。',1,'基础包',9),(26,'2026-06-24 18:03:53.881000','地点描述：在一块刻有“静默”二字的巨石下，你发现一个被油布盖住的小坑。里面似乎是某人存放的紧急物资，用的都是很老旧的款式。\n可获得物资：医疗资源 (10份)， 手电筒 (1个)\n历史秘密碎片：油布的一角绣着一行小字：“致下一位守夜者”。你不确定这指的是某个职业，还是某个秘密组织的成员。\n难度：7','守夜人的秘密补给点','uncommon',_binary '\0','2026-08-28 04:48:41.236553',7,_binary '\0','在一块刻有“静默”二字的巨石下，你发现一个被油布盖住的小坑。里面似乎是某人存放的紧急物资，用的都是很老旧的款式。','油布的一角绣着一行小字：“致下一位守夜者”。你不确定这指的是某个职业，还是某个秘密组织的成员。',1,'基础包',10),(27,'2026-06-24 18:03:53.905000','地点描述：一个被灌木和碎石掩盖的、通往矿场深处的新入口。进入后能闻到一股不同于普通矿石的、微弱的金属气味。\n可获得物资：金属制品 (1吨)， 煤油 (5升)\n历史秘密碎片：在矿道深处，你发现一处被凿开的墙壁，里面镶嵌着一些带有精细纹路的黑色金属块。这不像是本岛已知的任何矿产。\n难度：9','旧矿道的另一个入口','uncommon',_binary '\0','2026-08-28 04:48:41.242804',9,_binary '\0','一个被灌木和碎石掩盖的、通往矿场深处的新入口。进入后能闻到一股不同于普通矿石的、微弱的金属气味。','在矿道深处，你发现一处被凿开的墙壁，里面镶嵌着一些带有精细纹路的黑色金属块。这不像是本岛已知的任何矿产。',1,'基础包',11),(28,'2026-06-24 18:03:53.926000','地点描述：一片林间空地上，有一堆早已冰冷的篝火余烬，周围散落着一些罐头盒和磨损的皮靴。\n可获得物资：食物 (5单位)， 绳索 (5米)\n历史秘密碎片：你用木棍拨开灰烬时，发现一枚被烧得变形的铜扣子，上面还残留着一小片布料的痕迹。那布料的颜色和纹路，与气象观测站里的旧制服惊人地相似。\n难度：3','林间空地的篝火余烬','common',_binary '\0','2026-08-28 04:48:40.934945',3,_binary '\0','一片林间空地上，有一堆早已冰冷的篝火余烬，周围散落着一些罐头盒和磨损的皮靴。','你用木棍拨开灰烬时，发现一枚被烧得变形的铜扣子，上面还残留着一小片布料的痕迹。那布料的颜色和纹路，与气象观测站里的旧制服惊人地相似。',1,'基础包',12),(29,'2026-06-24 18:03:53.949000','地点描述：你注意到一个半埋在沙中的绿色玻璃瓶，里面似乎塞着一张纸条。\n可获得物资：无物资，但获得一条来自“外界”或“过去”的模糊信息。\n历史秘密碎片：纸条上的字迹已经模糊，只能依稀辨认出几个词：“......我们失败了......轮回继续......希望下一次有人能打破......银币是钥匙，也是枷锁......”落款是一串数字，而不是名字。\n难度：10','海滩上的漂流瓶','rare',_binary '\0','2026-08-28 04:48:41.255137',10,_binary '\0','你注意到一个半埋在沙中的绿色玻璃瓶，里面似乎塞着一张纸条。','纸条上的字迹已经模糊，只能依稀辨认出几个词：“......我们失败了......轮回继续......希望下一次有人能打破......银币是钥匙，也是枷锁......”落款是一串数字，而不是名字。',1,'基础包',13),(30,'2026-06-24 18:03:53.962000','地点描述：一座用黑色石头垒砌的圆形基座，像是某种古老的观测站或祭坛。中心有一根断裂的石柱。\n可获得物资：金属制品 (10kg)\n历史秘密碎片：基座的地面上有被火烧过的痕迹，呈现出一种奇异的同心圆图案。这让你想起灯塔透镜的结构。也许，这里才是岛上最早的“灯塔”。\n难度：11','古老观测站遗迹','rare',_binary '\0','2026-08-28 04:48:41.260119',11,_binary '\0','一座用黑色石头垒砌的圆形基座，像是某种古老的观测站或祭坛。中心有一根断裂的石柱。','基座的地面上有被火烧过的痕迹，呈现出一种奇异的同心圆图案。这让你想起灯塔透镜的结构。也许，这里才是岛上最早的“灯塔”。',1,'基础包',14),(31,'2026-06-24 18:03:53.977000','地点描述：在码头外围的浅水区，半沉着一艘小型铁皮驳船。船舱进水，但部分结构露出水面。\n可获得物资：金属制品 (1吨)， 煤油 (8升)， 绳索 (5米)\n历史秘密碎片：你在驾驶室找到一本浸透的账本，上面的日期停在了一个未知的年份。最后一笔账目记录的是：“5瓶朗姆酒换20kg食物”这与你从旅店老人口中听到的、关于“最后的晚餐”的传闻惊人地相似。\n难度：12','沉没的驳船','rare',_binary '\0','2026-08-28 04:48:41.265660',12,_binary '\0','在码头外围的浅水区，半沉着一艘小型铁皮驳船。船舱进水，但部分结构露出水面。','你在驾驶室找到一本浸透的账本，上面的日期停在了一个未知的年份。最后一笔账目记录的是：“5瓶朗姆酒换20kg食物”这与你从旅店老人口中听到的、关于“最后的晚餐”的传闻惊人地相似。',1,'基础包',15),(32,'2026-06-24 18:03:54.008000','地点描述：一棵巨大古树被连根拔起，巨大的根系暴露在外，形成了一个天然空洞。\n可获得物资：木材 (10吨)， 沥青（10kg）。\n历史秘密碎片：你在树根之间发现一个石质的、被树根缠绕的小盒子。打开后，里面空无一物，只在盒盖上刻着一行小字：“为了遗忘”。\n难度：13','被连根拔起的古树','rare',_binary '\0','2026-08-28 04:48:41.272480',13,_binary '\0','一棵巨大古树被连根拔起，巨大的根系暴露在外，形成了一个天然空洞。','你在树根之间发现一个石质的、被树根缠绕的小盒子。打开后，里面空无一物，只在盒盖上刻着一行小字：“为了遗忘”。',1,'基础包',16),(33,'2026-06-24 18:03:54.029000','地点描述：在陡峭的悬崖边，你发现一面早已褪色的破旧信号旗，被固定在岩石缝隙中。在下方一处涨潮线以上的岩缝里，藏着一个沉重、被油布包裹的货包。\n可获得物资：沥青 (10kg)， 帆布 (3m)， 绳索 (5米)\n历史秘密碎片：旗帜的布料纤维非常奇特，不像本地能生产的。上面用一种暗红色的染料画着一个符号：一艘船，正驶向一个圆形的、散发着光芒的入口。那包沥青的包装上，印着一个已经模糊不清的、带有某种“委员会”字样的徽记。\n难度：12','悬崖上的信号旗与沉货','rare',_binary '\0','2026-08-28 04:48:41.279468',12,_binary '\0','在陡峭的悬崖边，你发现一面早已褪色的破旧信号旗，被固定在岩石缝隙中。在下方一处涨潮线以上的岩缝里，藏着一个沉重、被油布包裹的货包。','旗帜的布料纤维非常奇特，不像本地能生产的。上面用一种暗红色的染料画着一个符号：一艘船，正驶向一个圆形的、散发着光芒的入口。那包沥青的包装上，印着一个已经模糊不清的、带有某种“委员会”字样的徽记。',1,'基础包',17),(34,'2026-06-24 18:03:54.053000','地点描述：在酒吧后巷的垃圾堆旁，你踢到一个被隐藏得极好的木板箱，上面有撬开的痕迹。\n可获得物资：朗姆酒 (3瓶)， 旧式手枪 (1把，含6发子弹)\n历史秘密碎片：箱底铺着的旧报纸上，刊登着一则轶闻：“神秘女士于风暴夜造访本岛，随身携带一枚‘雕有巨瞳’的银色奖章，后不知所踪。”\n难度：15','废弃的木板箱（走私者藏匿点）','epic',_binary '\0','2026-08-28 04:48:41.286591',15,_binary '\0','在酒吧后巷的垃圾堆旁，你踢到一个被隐藏得极好的木板箱，上面有撬开的痕迹。','箱底铺着的旧报纸上，刊登着一则轶闻：“神秘女士于风暴夜造访本岛，随身携带一枚‘雕有巨瞳’的银色奖章，后不知所踪。”',1,'基础包',18),(35,'2026-06-24 18:03:54.065000','地点描述：教堂后面的废弃花园中，一口被石板半掩的枯井。井壁上长满了潮湿的苔藓，深处似乎有空间。\n可获得物资：医疗资源 (20单位)\n历史秘密碎片：你下到井底，发现井壁上有一处被新泥掩盖过的暗门。门缝里夹着一角泛黄的纸，上面写着：“他们没有建塔，他们挖了井。一直挖，直到听见下面有呼吸声。”这个“下面”，是指地底，还是指别的什么？\n难度：17','教堂花园的枯井','epic',_binary '\0','2026-08-28 04:48:41.293511',17,_binary '\0','教堂后面的废弃花园中，一口被石板半掩的枯井。井壁上长满了潮湿的苔藓，深处似乎有空间。','你下到井底，发现井壁上有一处被新泥掩盖过的暗门。门缝里夹着一角泛黄的纸，上面写着：“他们没有建塔，他们挖了井。一直挖，直到听见下面有呼吸声。”这个“下面”，是指地底，还是指别的什么？',1,'基础包',19),(36,'2026-06-24 18:03:54.078000','地点描述：你偷偷潜入旅店的阁楼，在积满灰尘的旧物中翻找。你发现了旧地图 (标记了某些特殊地点，如隐藏入口)，可私信dm。\n可获得物资：维修工具包 (1个)\n历史秘密碎片：你找到一本匿名笔记，上面写道：“我听到了那些在梦中死去的殖民者的低语。他们告诉我，暴雪是‘收割者’，而我们是种下的作物。只有找到最初的‘种子’，才能逃离这个循环。”\n难度：19','旅店阁楼的笔记','legendary',_binary '\0','2026-08-28 04:48:41.299588',19,_binary '\0','你偷偷潜入旅店的阁楼，在积满灰尘的旧物中翻找。你发现了旧地图 (标记了某些特殊地点，如隐藏入口)，可私信dm。','你找到一本匿名笔记，上面写道：“我听到了那些在梦中死去的殖民者的低语。他们告诉我，暴雪是‘收割者’，而我们是种下的作物。只有找到最初的‘种子’，才能逃离这个循环。”',1,'基础包',20),(37,'2026-06-24 18:03:54.091000','地点描述：你凭借对教堂结构的了解或探索，发现一个通往地下墓穴的暗门。空气冰冷而凝滞。你获得了一枚磨损严重的旧银币（不可丢弃的诅咒信物）\n可获得物资：医疗资源 (10单位)， 煤油 (5升)\n历史秘密碎片：墓穴墙壁上刻满了密密麻麻的名字和日期，最早的可以追溯到几百年前。最底部的墙壁上，用现代英语刻着一句新话：“又开始了。”下面的日期，正是预测暴雪来临的日子。那枚银币的图案，正是那个“巨瞳”符号——你在之前多处线索中看到过它。握在手中，你第一次清晰地意识到：这座岛是一个周期，而你，刚刚走进了这个周期的证据里。\n难度：20','教堂地下的低语（指向度最高）','legendary',_binary '\0','2026-08-28 04:48:41.305080',20,_binary '','你凭借对教堂结构的了解或探索，发现一个通往地下墓穴的暗门。空气冰冷而凝滞。你获得了一枚磨损严重的旧银币（不可丢弃的诅咒信物）','墓穴墙壁上刻满了密密麻麻的名字和日期，最早的可以追溯到几百年前。最底部的墙壁上，用现代英语刻着一句新话：“又开始了。”下面的日期，正是预测暴雪来临的日子。那枚银币的图案，正是那个“巨瞳”符号——你在之前多处线索中看到过它。握在手中，你第一次清晰地意识到：这座岛是一个周期，而你，刚刚走进了这个周期的证据里。',1,'基础包',21),(38,'2026-06-24 18:03:54.110000','地点描述：森林边缘一座被积雪半掩的小木屋，门板已经朽坏，屋内一片狼藉。壁炉里还有未燃尽的柴火，但早已冻成了冰坨。\n可获得物资：木材（2吨）， 煤油（2升）， 火柴（3盒）\n历史秘密碎片：你在床板下发现一块刻满划痕的木板，上面记录着“第7次”和一个潦草的倒计时。旁边有一行小字：“我们以为熬过暴雪就赢了，但暴雪之后，还有东西在等着我们。”字迹到此为止，笔尖在木板上划出一道长长的、颤抖的痕迹。\n难度：16','冰封的猎人小屋','epic',_binary '\0','2026-08-28 04:48:41.311306',16,_binary '\0','森林边缘一座被积雪半掩的小木屋，门板已经朽坏，屋内一片狼藉。壁炉里还有未燃尽的柴火，但早已冻成了冰坨。','你在床板下发现一块刻满划痕的木板，上面记录着“第7次”和一个潦草的倒计时。旁边有一行小字：“我们以为熬过暴雪就赢了，但暴雪之后，还有东西在等着我们。”字迹到此为止，笔尖在木板上划出一道长长的、颤抖的痕迹。',1,'基础包',22),(39,'2026-06-24 18:03:54.134000','地点描述：一片向阳的山坡上，排列着几个破败的木质蜂箱，早已没有蜜蜂的踪迹。周围长满了干枯的野花。\n可获得物资：草药（4单位） ， 蜡烛（5根）\n历史秘密碎片：你打开一个蜂箱的底层，发现一块被蜂蜡密封的油布。打开后，里面是一幅用炭笔画的速写：一个巨大的、被藤蔓和苔藓覆盖的圆形建筑，顶端裂开，一道光柱直射向天空。画的背面写着：“他们以为是信号塔，其实是接收器。他们一直在等‘上面’的回应。”\n难度：5','废弃的蜂箱','common',_binary '\0','2026-08-28 04:48:41.318455',5,_binary '\0','一片向阳的山坡上，排列着几个破败的木质蜂箱，早已没有蜜蜂的踪迹。周围长满了干枯的野花。','你打开一个蜂箱的底层，发现一块被蜂蜡密封的油布。打开后，里面是一幅用炭笔画的速写：一个巨大的、被藤蔓和苔藓覆盖的圆形建筑，顶端裂开，一道光柱直射向天空。画的背面写着：“他们以为是信号塔，其实是接收器。他们一直在等‘上面’的回应。”',1,'基础包',23),(40,'2026-06-24 18:03:54.156000','地点描述：在一处人迹罕至的礁石滩上，搁浅着一艘小型划艇，船底已经破了一个大洞。船桨断成两截，散落在附近。\n可获得物资：金属制品（20kg） ， 绳索（8米）， 渔网（1张）\n历史秘密碎片：你在划艇的坐板下找到一个防水盒，里面有一封没有寄出的信。信上写道：“亲爱的玛莎，我发现了他们藏起来的真相——这座岛不是被发现的，是被‘放’在这里的。那些银色的盒子，每一个都是一段被删除的记忆。我必须把证据藏起来，藏在……”信件在这里中断，最后几个字被水渍完全浸染，无法辨认。\n难度：14','搁浅的划艇','epic',_binary '\0','2026-08-28 04:48:41.325257',14,_binary '\0','在一处人迹罕至的礁石滩上，搁浅着一艘小型划艇，船底已经破了一个大洞。船桨断成两截，散落在附近。','你在划艇的坐板下找到一个防水盒，里面有一封没有寄出的信。信上写道：“亲爱的玛莎，我发现了他们藏起来的真相——这座岛不是被发现的，是被‘放’在这里的。那些银色的盒子，每一个都是一段被删除的记忆。我必须把证据藏起来，藏在……”信件在这里中断，最后几个字被水渍完全浸染，无法辨认。',1,'基础包',24),(41,'2026-06-24 18:03:54.182000','地点描述：岛内一处隐蔽的峡谷中，有一汪冒着热气的地热泉，周围没有积雪，反而长着一些深绿色的蕨类植物。空气中弥漫着一股硫磺味。\n可获得物资：食物（5单位） ， 医疗资源（20单位）\n历史秘密碎片：你发现在泉眼边缘的岩石上，有人用锐器刻下了一句话：“水温能救命，但救不了轮回。他们在地下深处烧着某种东西，那东西让整个岛都在呼吸。”你伸手探了探水温，温热的触感让你短暂地忘记了寒冷，但那句“呼吸”却让你后背发凉。\n难度：8','地热泉眼','uncommon',_binary '\0','2026-08-28 04:48:41.347807',8,_binary '\0','岛内一处隐蔽的峡谷中，有一汪冒着热气的地热泉，周围没有积雪，反而长着一些深绿色的蕨类植物。空气中弥漫着一股硫磺味。','你发现在泉眼边缘的岩石上，有人用锐器刻下了一句话：“水温能救命，但救不了轮回。他们在地下深处烧着某种东西，那东西让整个岛都在呼吸。”你伸手探了探水温，温热的触感让你短暂地忘记了寒冷，但那句“呼吸”却让你后背发凉。',1,'基础包',25),(42,'2026-06-24 18:03:54.210000','地点描述：在一条通往内陆的雪径上，散落着一辆损坏的雪橇，拉绳已经断裂，上面堆着一些空木箱。\n可获得物资：木材（1吨） ， 帆布（2米）\n历史秘密碎片：你在雪橇底部发现一张被冻脆的纸片，上面画着一幅简单的星图，其中一颗星被重点圈出，旁边标注着：“当它再次亮起时，暴雪就会开始。这不是天气预报，这是某种约定。”你抬头看了看阴沉的天色，不知道那颗星是否已经亮起。\n难度：7','被遗弃的雪橇','uncommon',_binary '\0','2026-08-28 04:48:41.369238',7,_binary '\0','在一条通往内陆的雪径上，散落着一辆损坏的雪橇，拉绳已经断裂，上面堆着一些空木箱。','你在雪橇底部发现一张被冻脆的纸片，上面画着一幅简单的星图，其中一颗星被重点圈出，旁边标注着：“当它再次亮起时，暴雪就会开始。这不是天气预报，这是某种约定。”你抬头看了看阴沉的天色，不知道那颗星是否已经亮起。',1,'基础包',26),(43,'2026-06-24 18:03:54.229000','地点描述：小镇废弃邮局门口，一个锈迹斑斑的红色邮箱依然伫立，锁头已经损坏。\n可获得物资：铅笔（3支）\n历史秘密碎片：你从邮箱里掏出一叠被虫蛀过的信件。其中一封的落款是“委员会档案室”，内容很简短：“致本岛居民：你们申报的‘气候异常’已收到。经核实，该区域未有相关记录。请勿传播不实信息。”信的底部，有人用红笔愤怒地批注了一行字：“骗子！他们删掉了所有1887年之前的记录！”信件中你发现了一个频率信号，或许可以在邮局发挥作用。\n难度：16','旧邮局的邮箱','epic',_binary '\0','2026-08-28 04:48:41.406325',16,_binary '\0','小镇废弃邮局门口，一个锈迹斑斑的红色邮箱依然伫立，锁头已经损坏。','你从邮箱里掏出一叠被虫蛀过的信件。其中一封的落款是“委员会档案室”，内容很简短：“致本岛居民：你们申报的‘气候异常’已收到。经核实，该区域未有相关记录。请勿传播不实信息。”信的底部，有人用红笔愤怒地批注了一行字：“骗子！他们删掉了所有1887年之前的记录！”信件中你发现了一个频率信号，或许可以在邮局发挥作用。',1,'基础包',27),(44,'2026-06-24 18:03:54.242000','地点描述：岛屿最高处，几块巨大的黑色岩石被围成圆圈，看起来不像自然形成。中间有一块平坦的祭坛石，上面布满了裂隙。\n可获得物资：石料（10吨）\n历史秘密碎片：你清扫祭坛石上的积雪时，发现上面刻着一幅精细的浮雕：一条首尾相接的蛇，咬着自己的尾巴，蛇身由无数个小小的“巨瞳”符号组成。蛇的中央，是一枚硬币的形状。你终于明白，这个符号不是装饰，是地图——一个无限循环的地图。\n难度：17','山顶的巨石阵','epic',_binary '\0','2026-08-28 04:48:41.425324',17,_binary '\0','岛屿最高处，几块巨大的黑色岩石被围成圆圈，看起来不像自然形成。中间有一块平坦的祭坛石，上面布满了裂隙。','你清扫祭坛石上的积雪时，发现上面刻着一幅精细的浮雕：一条首尾相接的蛇，咬着自己的尾巴，蛇身由无数个小小的“巨瞳”符号组成。蛇的中央，是一枚硬币的形状。你终于明白，这个符号不是装饰，是地图——一个无限循环的地图。',1,'基础包',28),(45,'2026-06-24 18:03:54.256000','地点描述：一片结冰的湖面上，冰层深处隐约可见一些轮廓，像是被冻住的木船或者小屋。冰面边缘有一处塌陷，露出冰冷的湖水。\n可获得物资：金属制品（50kg） ， 木材（3吨）\n历史秘密碎片：你小心地靠近塌陷处，用长杆打捞，勾上来一块巴掌大的铜牌。上面刻着：“献给第116位沉睡者。”下方是一行小字：“当我们变成冰的一部分，冰就会替我们记住一切。”\n难度：15','冰下墓地','epic',_binary '\0','2026-08-28 04:48:41.436303',15,_binary '\0','一片结冰的湖面上，冰层深处隐约可见一些轮廓，像是被冻住的木船或者小屋。冰面边缘有一处塌陷，露出冰冷的湖水。','你小心地靠近塌陷处，用长杆打捞，勾上来一块巴掌大的铜牌。上面刻着：“献给第116位沉睡者。”下方是一行小字：“当我们变成冰的一部分，冰就会替我们记住一切。”',1,'基础包',29),(46,'2026-06-24 18:03:54.272000','地点描述：在通往旧矿山的山路上，散落着一节锈蚀的矿车轨道和一具翻倒的蒸汽机车残骸，早已和藤蔓岩石融为一体。\n可获得物资：金属制品（8吨） ， 煤油（12升） ， 发动机（1个）\n历史秘密碎片：你在机车的锅炉里发现一个被烧得变形的铁盒，里面有一卷胶卷。虽然大部分已损毁，但有几帧还能看清：一群穿着旧式服装的人，正在将一块巨大的银色金属板沉入一个深坑，旁边站着一个穿着黑袍、手持提灯的人，看不清脸。\n难度：18','火车残骸（矿山支线）','legendary',_binary '\0','2026-08-28 04:48:40.935036',18,_binary '\0','在通往旧矿山的山路上，散落着一节锈蚀的矿车轨道和一具翻倒的蒸汽机车残骸，早已和藤蔓岩石融为一体。','你在机车的锅炉里发现一个被烧得变形的铁盒，里面有一卷胶卷。虽然大部分已损毁，但有几帧还能看清：一群穿着旧式服装的人，正在将一块巨大的银色金属板沉入一个深坑，旁边站着一个穿着黑袍、手持提灯的人，看不清脸。',1,'基础包',30),(47,'2026-06-24 18:03:54.296000','地点描述：在一片茂密的冷杉林中，有一个被遗弃的营地，帐篷已经坍塌，篝火堆里还有未燃尽的骨头。\n可获得物资：猎枪弹（4发） ， 食物（6单位），猎枪（1把）\n历史秘密碎片：你在帐篷下的泥土里挖出一个密封的锡罐，里面是一张纸条：“我看到了那些‘守夜者’的秘密集会。他们在向一个银色的盒子祈祷。盒子上刻着那个眼睛。那不是神，是某种监控装置。我决定把它挖出来，埋到一个没人能找到的地方……”纸条没有署名，但你注意到纸条背面用铅笔轻轻画了一个箭头，指向岛的东北方向。\n难度：16','失踪猎人营地','epic',_binary '\0','2026-08-28 04:48:41.451862',16,_binary '\0','在一片茂密的冷杉林中，有一个被遗弃的营地，帐篷已经坍塌，篝火堆里还有未燃尽的骨头。','你在帐篷下的泥土里挖出一个密封的锡罐，里面是一张纸条：“我看到了那些‘守夜者’的秘密集会。他们在向一个银色的盒子祈祷。盒子上刻着那个眼睛。那不是神，是某种监控装置。我决定把它挖出来，埋到一个没人能找到的地方……”纸条没有署名，但你注意到纸条背面用铅笔轻轻画了一个箭头，指向岛的东北方向。',1,'基础包',31),(48,'2026-06-24 18:03:54.319000','地点描述：海岸边一座高耸的金属信号塔，被狂风吹得微微倾斜，顶部的警示灯早已熄灭。塔身锈迹斑斑，底部有一扇紧锁的铁门。\n可获得物资：金属制品（5吨） ， 手电筒（1个）\n历史秘密碎片：你设法撬开铁门，在塔内控制台上发现一本值班日志。最后一页的日期是“1892年11月”。上面写着：“收到一艘未注册船只的求救信号。对方声称来自‘锚点’站。我们回复‘锚点已失效’。对方沉默了很久，只回了四个字：‘那我们来重置。’”你抬头看了看这座塔，忽然意识到它可能不是什么信号塔。\n难度：19','风暴中的信号塔','legendary',_binary '\0','2026-08-28 04:48:41.460732',19,_binary '\0','海岸边一座高耸的金属信号塔，被狂风吹得微微倾斜，顶部的警示灯早已熄灭。塔身锈迹斑斑，底部有一扇紧锁的铁门。','你设法撬开铁门，在塔内控制台上发现一本值班日志。最后一页的日期是“1892年11月”。上面写着：“收到一艘未注册船只的求救信号。对方声称来自‘锚点’站。我们回复‘锚点已失效’。对方沉默了很久，只回了四个字：‘那我们来重置。’”你抬头看了看这座塔，忽然意识到它可能不是什么信号塔。',1,'基础包',32),(49,'2026-06-24 18:03:54.335000','地点描述：在森林深处，有一口被厚重铁板盖住的古井，铁板上有一个滑轮装置，垂下一根粗麻绳，末端系着一个破旧的木吊篮。\n可获得物资：绳索（30米） ， 医疗资源（3单位）\n历史秘密碎片：你把吊篮拉上来，发现篮底有一块被油布包裹的石头。石头上刻着一张脸，但那脸上的五官是倒置的。旁边刻着一行细小的文字：“向下看，才是向上。他们从一开始就告诉了我们真相，只是我们从未相信。”\n难度：9','深井与吊篮','uncommon',_binary '\0','2026-08-28 04:48:41.468891',9,_binary '\0','在森林深处，有一口被厚重铁板盖住的古井，铁板上有一个滑轮装置，垂下一根粗麻绳，末端系着一个破旧的木吊篮。','你把吊篮拉上来，发现篮底有一块被油布包裹的石头。石头上刻着一张脸，但那脸上的五官是倒置的。旁边刻着一行细小的文字：“向下看，才是向上。他们从一开始就告诉了我们真相，只是我们从未相信。”',1,'基础包',33),(50,'2026-06-24 18:03:54.351000','地点描述：小镇主街上的一家旧相机店，橱窗玻璃破碎，里面散落着落满灰尘的相机和胶卷盒。\n可获得物资：维修工具包（1个） ， 火把（2把）\n历史秘密碎片：你在一台木制的大画幅相机暗盒里，发现一张尚未冲洗的底片。对着光仔细辨认，画面里是一个穿着旧式长裙的女人，站在一扇巨大的圆形金属门前，手里捧着一个发光的球体。她的脸被一片光晕遮住，但那扇门上的纹路，和你在教堂地下看到的图案一模一样。\n难度：4','古董相机店','common',_binary '\0','2026-08-28 04:48:40.935057',4,_binary '\0','小镇主街上的一家旧相机店，橱窗玻璃破碎，里面散落着落满灰尘的相机和胶卷盒。','你在一台木制的大画幅相机暗盒里，发现一张尚未冲洗的底片。对着光仔细辨认，画面里是一个穿着旧式长裙的女人，站在一扇巨大的圆形金属门前，手里捧着一个发光的球体。她的脸被一片光晕遮住，但那扇门上的纹路，和你在教堂地下看到的图案一模一样。',1,'基础包',34),(51,'2026-06-24 18:03:54.367000','地点描述：旧工坊群深处，一间独立的砖砌建筑，内部有一座巨大的铁制锅炉，已经完全冷却。角落里堆满废铁和煤渣。\n可获得物资：金属制品（1吨） ， 燃料（煤炭，可作燃料，1吨）\n历史秘密碎片：你发现在锅炉的炉门内侧，用粉笔写着一句话：“我们烧了三天三夜，把那些带‘标记’的东西全扔进去了，但它们没有融化，只是变得更烫了。那晚，锅炉自己唱起了歌。”你伸手摸了摸冰冷的炉壁，仿佛能感觉到某种余温。\n难度：10','废弃的锅炉房','rare',_binary '\0','2026-08-28 04:48:41.482284',10,_binary '\0','旧工坊群深处，一间独立的砖砌建筑，内部有一座巨大的铁制锅炉，已经完全冷却。角落里堆满废铁和煤渣。','你发现在锅炉的炉门内侧，用粉笔写着一句话：“我们烧了三天三夜，把那些带‘标记’的东西全扔进去了，但它们没有融化，只是变得更烫了。那晚，锅炉自己唱起了歌。”你伸手摸了摸冰冷的炉壁，仿佛能感觉到某种余温。',1,'基础包',36),(52,'2026-06-24 18:03:54.379000','地点描述：一条几乎完全冰封的小河上，横亘着一座由树枝和泥土筑成的巨大河狸坝，结构异常结实。\n可获得物资：木材（2吨） ， 沥青（5kg）\n历史秘密碎片：你试图拆解坝体时，发现一根被咬断的树枝里夹着一块叠好的皮革。展开后，上面是用红色墨水绘制的地图，标记着一处“不在任何图上”的地点。地图边缘写着：“河狸比我们更早学会筑墙。它们筑墙是为了引水，我们筑墙是为了引……”最后一个字被一团墨迹盖住，但你隐约觉得那是个“祸”字。\n难度：9','河狸坝','uncommon',_binary '\0','2026-08-28 04:48:41.488831',9,_binary '\0','一条几乎完全冰封的小河上，横亘着一座由树枝和泥土筑成的巨大河狸坝，结构异常结实。','你试图拆解坝体时，发现一根被咬断的树枝里夹着一块叠好的皮革。展开后，上面是用红色墨水绘制的地图，标记着一处“不在任何图上”的地点。地图边缘写着：“河狸比我们更早学会筑墙。它们筑墙是为了引水，我们筑墙是为了引……”最后一个字被一团墨迹盖住，但你隐约觉得那是个“祸”字。',1,'基础包',37),(53,'2026-06-24 18:03:54.395000','地点描述：在一处背风的岩壁下，搭着一顶坍塌的帐篷，旁边散落着一些仪器设备，像是地质勘探用的。帐篷内外都覆盖着厚厚的积雪。\n可获得物资：医疗资源（10份） ， 食物（5单位）\n历史秘密碎片：你在帐篷里找到一本笔记本，字迹工整，但最后一页上歪歪扭扭地写着：“我们测出了地下的异常结构。那不是矿脉，是一个比整个岛还大的空腔。里面有规律的震动，像心跳。队长决定向‘委员会’报告，然后……我们收到了一个‘保持沉默’的命令。我们不该来的。”\n难度：4','遇难的科考队','common',_binary '\0','2026-08-28 04:48:41.496243',4,_binary '\0','在一处背风的岩壁下，搭着一顶坍塌的帐篷，旁边散落着一些仪器设备，像是地质勘探用的。帐篷内外都覆盖着厚厚的积雪。','你在帐篷里找到一本笔记本，字迹工整，但最后一页上歪歪扭扭地写着：“我们测出了地下的异常结构。那不是矿脉，是一个比整个岛还大的空腔。里面有规律的震动，像心跳。队长决定向‘委员会’报告，然后……我们收到了一个‘保持沉默’的命令。我们不该来的。”',1,'基础包',38),(54,'2026-06-24 18:03:54.417000','地点描述：灯塔基座旁，有一间半塌的玻璃花房，屋顶已经碎裂，但内部的土壤中居然还顽强地生长着几株枯萎的玫瑰。\n可获得物资：朗姆酒（2瓶）\n历史秘密碎片：你清理花房的角落时，发现一块嵌入墙中的铜牌，上面刻着：“献给那个一直在种花的人。他知道暴雪会来，但他还是种了。”铜牌背后，刻着一个微小的“巨瞳”符号。\n难度：3','灯塔看守人的花房','common',_binary '\0','2026-08-28 04:48:41.503405',3,_binary '\0','灯塔基座旁，有一间半塌的玻璃花房，屋顶已经碎裂，但内部的土壤中居然还顽强地生长着几株枯萎的玫瑰。','你清理花房的角落时，发现一块嵌入墙中的铜牌，上面刻着：“献给那个一直在种花的人。他知道暴雪会来，但他还是种了。”铜牌背后，刻着一个微小的“巨瞳”符号。',1,'基础包',39),(55,'2026-06-24 18:03:54.432000','地点描述：深入那艘搁浅渔船的残骸内部，在严重倾斜的船长室里，有一个半埋在淤泥中的小型保险箱，锁已经锈死。\n可获得物资：旧式手枪（1把，含6发子弹） ， 协议书（1张）\n历史秘密碎片：你用工具撬开保险箱，里面没有财物，只有一本泡烂的圣经。圣经的内页被挖空，藏着一叠纸。纸上记录着：“银色的盒子不是钥匙，是终点。我们以为自己在探索世界，其实我们在探索自己的牢笼。每打开一个盒子，牢笼就会缩小一点。我烧掉了第4个盒子，但还有……”纸在这里被撕掉了，但你看到纸张边缘有一行墨水写的、极其细小的字：“3个。”\n难度：13','沉船船长室保险箱','rare',_binary '\0','2026-08-28 04:48:41.509722',13,_binary '\0','深入那艘搁浅渔船的残骸内部，在严重倾斜的船长室里，有一个半埋在淤泥中的小型保险箱，锁已经锈死。','你用工具撬开保险箱，里面没有财物，只有一本泡烂的圣经。圣经的内页被挖空，藏着一叠纸。纸上记录着：“银色的盒子不是钥匙，是终点。我们以为自己在探索世界，其实我们在探索自己的牢笼。每打开一个盒子，牢笼就会缩小一点。我烧掉了第4个盒子，但还有……”纸在这里被撕掉了，但你看到纸张边缘有一行墨水写的、极其细小的字：“3个。”',1,'基础包',40),(56,'2026-06-24 18:03:54.438000','地点描述：在岛北侧一片冻土荒原上，地面裂开一道缝，露出一个埋藏已久的陶罐口沿。\n可获得物资：食物（3单位） ， 草药（3单位）\n历史秘密碎片：你挖出陶罐，发现里面装着几块刻满符文的骨片。符文你不认识，但你注意到其中一片的背面，有人用现代钢笔写了一行注：“翻译员说这是某种祈禳文，大意是‘愿火焰吞噬眼睛’——但为什么我们的祖先要祈禳一个眼睛？”\n难度：7','冻土下的陶罐','uncommon',_binary '\0','2026-08-28 04:48:41.515869',7,_binary '\0','在岛北侧一片冻土荒原上，地面裂开一道缝，露出一个埋藏已久的陶罐口沿。','你挖出陶罐，发现里面装着几块刻满符文的骨片。符文你不认识，但你注意到其中一片的背面，有人用现代钢笔写了一行注：“翻译员说这是某种祈禳文，大意是‘愿火焰吞噬眼睛’——但为什么我们的祖先要祈禳一个眼睛？”',1,'基础包',41),(57,'2026-06-24 18:03:54.449000','地点描述：在一棵濒临枯死的古树顶端，有一个巨大的鸟巢，早已废弃。巢中用干草和树枝铺成，你发现其中夹杂着一些非自然的光泽。\n可获得物资：绳索（6米） ， 金属制品（50kg）\n历史秘密碎片：你爬上树顶，从巢中掏出一架黄铜制成的小型望远镜，镜筒上刻着“1883”。你透过它随意望向远方，但在转动角度时，你突然看见远处一座山的轮廓，那形状……像极了一个侧卧的、被冻僵的人形。你放下望远镜再看向那座山，它就只是一座普通的山了。\n难度：6','鸟巢与望远镜','uncommon',_binary '\0','2026-08-28 04:48:41.521236',6,_binary '\0','在一棵濒临枯死的古树顶端，有一个巨大的鸟巢，早已废弃。巢中用干草和树枝铺成，你发现其中夹杂着一些非自然的光泽。','你爬上树顶，从巢中掏出一架黄铜制成的小型望远镜，镜筒上刻着“1883”。你透过它随意望向远方，但在转动角度时，你突然看见远处一座山的轮廓，那形状……像极了一个侧卧的、被冻僵的人形。你放下望远镜再看向那座山，它就只是一座普通的山了。',1,'基础包',42),(58,'2026-06-24 18:03:54.466000','地点描述：小镇外围，一座红砖建筑，招牌已经脱落。内部是宽阔的大厅，地面有沟槽，空中悬挂着锈蚀的铁钩和滑轮。空气中弥漫着一股无法形容的、混合了铁锈和焦油的气味。\n可获得物资：金属制品（200kg） ， 绳索（12米） ， 煤油（4升）\n历史秘密碎片：你在操作台下的暗格里，发现一本被撕掉封皮的账簿。上面记录的条目很奇怪：“第1个：于北坡收割。”、“第2个：于海岸洞穴收割。”……一直到“第6个：于教堂地下收割。”每一行后面都画着一个“✓”。而在账簿的最后一页，用崭新的墨水写着：“第7轮次，收割者已就位。轮到你们了。”\n难度：10','废弃的屠宰场','rare',_binary '\0','2026-08-28 04:48:41.526891',10,_binary '\0','小镇外围，一座红砖建筑，招牌已经脱落。内部是宽阔的大厅，地面有沟槽，空中悬挂着锈蚀的铁钩和滑轮。空气中弥漫着一股无法形容的、混合了铁锈和焦油的气味。','你在操作台下的暗格里，发现一本被撕掉封皮的账簿。上面记录的条目很奇怪：“第1个：于北坡收割。”、“第2个：于海岸洞穴收割。”……一直到“第6个：于教堂地下收割。”每一行后面都画着一个“✓”。而在账簿的最后一页，用崭新的墨水写着：“第7轮次，收割者已就位。轮到你们了。”',1,'基础包',43),(59,'2026-06-24 18:03:54.488000','地点描述：在旅店地下室的隐蔽暗格中，你发现一本用防水布包裹的日记，属于一位名叫“埃利斯”的殖民者。日记的日期横跨多个年份，但笔迹逐渐从工整变得癫狂。\n可获得物资：医疗资源（40单位） ， 朗姆酒（1瓶）\n历史秘密碎片：日记中写道：“他们说我是疯子，说我听见的‘低语’是幻觉。但我听得越来越清楚——那不是风声，是人声。成千上万的人声，在每一次暴雪来临前一起哭泣。他们告诉我，暴雪不是天气，是‘投票’。当岛上的人互相残杀到一定数量，暴雪就来了。他们称之为‘收割合格样本’。”你合上日记时，耳边似乎真的掠过一丝若有若无的啜泣。\n难度：12','潮汐症者的日志','rare',_binary '\0','2026-08-28 04:48:41.540294',12,_binary '\0','在旅店地下室的隐蔽暗格中，你发现一本用防水布包裹的日记，属于一位名叫“埃利斯”的殖民者。日记的日期横跨多个年份，但笔迹逐渐从工整变得癫狂。','日记中写道：“他们说我是疯子，说我听见的‘低语’是幻觉。但我听得越来越清楚——那不是风声，是人声。成千上万的人声，在每一次暴雪来临前一起哭泣。他们告诉我，暴雪不是天气，是‘投票’。当岛上的人互相残杀到一定数量，暴雪就来了。他们称之为‘收割合格样本’。”你合上日记时，耳边似乎真的掠过一丝若有若无的啜泣。',1,'基础包',45),(60,'2026-06-24 18:03:54.505000','地点描述：旧堡垒地下指挥室，一张倒塌的桌子旁，散落着发霉的羊皮纸和破碎的望远镜。\n可获得物资：金属制品（50kg） ， 维修工具包（1个）\n历史秘密碎片：你找到一份用三种语言写成的命令书，其中最后一段是：“封死所有闸门。不要让‘扬帆者’回来。他们看到的‘新大陆’是假象，是诱饵。这个岛就是全部，墙外只有雪和眼睛。宁可死在墙内，也别死在墙外让他们‘观察’。”命令书底部有一个血手印，旁边写着：“但我们没有守住。他们在墙上画了那个眼睛，门就从里面开了。”\n难度：8','筑墙者最后的命令','uncommon',_binary '\0','2026-08-28 04:48:41.547204',8,_binary '\0','旧堡垒地下指挥室，一张倒塌的桌子旁，散落着发霉的羊皮纸和破碎的望远镜。','你找到一份用三种语言写成的命令书，其中最后一段是：“封死所有闸门。不要让‘扬帆者’回来。他们看到的‘新大陆’是假象，是诱饵。这个岛就是全部，墙外只有雪和眼睛。宁可死在墙内，也别死在墙外让他们‘观察’。”命令书底部有一个血手印，旁边写着：“但我们没有守住。他们在墙上画了那个眼睛，门就从里面开了。”',1,'基础包',46),(61,'2026-06-24 18:03:54.520000','地点描述：在沉船残骸最底层的密封铅桶中，你找到一卷被蜡封的航海图，比之前找到的任何海图都更古老。\n可获得物资：帆布（3米） ， 绳索（12米）\n历史秘密碎片：海图上标注着一片你从未见过的海域，方向指向“外界”。但所有航线最终都折返回岛屿，形成一个闭环。图边用极细的笔迹写着：“我们从未离开。每一次‘远航’，都只是绕了一个大圈，回到原点。海平线是弯曲的，这个岛是碗底，我们被盛在里面。”你突然意识到，所谓“摆渡船”接引亡魂前往的“观察席”，可能就在这个碗沿上——看得见，却永远够不到。\n难度：8','扬帆者的最后航海图','uncommon',_binary '\0','2026-08-28 04:48:41.552981',8,_binary '\0','在沉船残骸最底层的密封铅桶中，你找到一卷被蜡封的航海图，比之前找到的任何海图都更古老。','海图上标注着一片你从未见过的海域，方向指向“外界”。但所有航线最终都折返回岛屿，形成一个闭环。图边用极细的笔迹写着：“我们从未离开。每一次‘远航’，都只是绕了一个大圈，回到原点。海平线是弯曲的，这个岛是碗底，我们被盛在里面。”你突然意识到，所谓“摆渡船”接引亡魂前往的“观察席”，可能就在这个碗沿上——看得见，却永远够不到。',1,'基础包',47),(62,'2026-06-24 18:03:54.540000','地点描述：一处被巨树和藤蔓完全遮蔽的地下天然井，井底有一块黑色的、被磨得光滑如镜的石板。石板周围散落着风化的骨骸和锈蚀的仪式刀具。\n可获得物资： 医疗资源（2单位）\n历史秘密碎片：你发现石板表面刻满了名字——每一个名字后面都画着一个“✓”。最新的一行写着：“第6轮——埃里克·哈里斯（自愿）。”更下方有一行暗红色的字：“杀戮不是目的，是献祭。每一滴血都在向那个眼睛证明：这个文明的强度足以进入‘下一阶段’。但我们从未通过。我们总是在筑墙和远航之间争吵，直到雪来。血祭者只是……加速了这个过程。”你盯着那面光滑的石板，忽然在反光中看到自己的脸——但你身后，似乎站着一个模糊的、不属于你的影子。\n难度：13','血祭者的祭坛（禁忌地点）','rare',_binary '\0','2026-08-28 04:48:41.559045',13,_binary '\0','一处被巨树和藤蔓完全遮蔽的地下天然井，井底有一块黑色的、被磨得光滑如镜的石板。石板周围散落着风化的骨骸和锈蚀的仪式刀具。','你发现石板表面刻满了名字——每一个名字后面都画着一个“✓”。最新的一行写着：“第6轮——埃里克·哈里斯（自愿）。”更下方有一行暗红色的字：“杀戮不是目的，是献祭。每一滴血都在向那个眼睛证明：这个文明的强度足以进入‘下一阶段’。但我们从未通过。我们总是在筑墙和远航之间争吵，直到雪来。血祭者只是……加速了这个过程。”你盯着那面光滑的石板，忽然在反光中看到自己的脸——但你身后，似乎站着一个模糊的、不属于你的影子。',1,'基础包',48),(63,'2026-06-24 18:03:54.553000','地点描述：结冰的湖面中央，冰层下隐约可见一串串气泡被冻住，形状像是……一张张向上张开的嘴。\n可获得物资：食物（5单位） ， 木材（1吨）\n历史秘密碎片：你跪在冰面上，冰下的气泡让你想起“潮汐症”患者描述的那种窒息感。当你把耳朵贴在冰面时，你听到了——不是风声，而是无数重叠的呢喃：“别筑墙……别造船……别杀人……别重复……”声音在“重复”这个词上叠加了无数个回声，像是几百个周期、几千个亡魂在同声控诉。你猛地抬起头，四周一片寂静，只有风吹过湖面的呜咽。\n难度：18','潮汐症共鸣点——冰封湖面','legendary',_binary '\0','2026-08-28 04:48:41.565070',18,_binary '\0','结冰的湖面中央，冰层下隐约可见一串串气泡被冻住，形状像是……一张张向上张开的嘴。','你跪在冰面上，冰下的气泡让你想起“潮汐症”患者描述的那种窒息感。当你把耳朵贴在冰面时，你听到了——不是风声，而是无数重叠的呢喃：“别筑墙……别造船……别杀人……别重复……”声音在“重复”这个词上叠加了无数个回声，像是几百个周期、几千个亡魂在同声控诉。你猛地抬起头，四周一片寂静，只有风吹过湖面的呜咽。',1,'基础包',49),(64,'2026-06-24 18:03:54.569000','地点描述：山顶一座早已废弃的无线电广播站，天线已经折断，设备全部被拆空。角落里有一个掉落的铁皮柜。\n可获得物资：金属制品（30kg） ， 火柴（5盒）\n历史秘密碎片：你撬开铁皮柜，发现一盘老旧的钢丝录音带和一台手摇播放器。你播放录音，里面传来一个男人的声音，语气疲惫而绝望：“……这里是本岛第5轮次广播。如果你听到这段录音，说明我们又一次失败了。我要告诉后来者一件重要的事：那个眼睛不是神，也不是自然现象——是镜子。我们凝视它，它就在我们心里生成一轮新的暴雪。打破循环的唯一方法，是停止凝视。但谁能做到呢？恐惧让我们不得不凝视。”录音到这里中断，伴随着一阵刺耳的啸叫。\n难度：9','被遗忘的广播站','uncommon',_binary '\0','2026-08-28 04:48:41.582050',9,_binary '\0','山顶一座早已废弃的无线电广播站，天线已经折断，设备全部被拆空。角落里有一个掉落的铁皮柜。','你撬开铁皮柜，发现一盘老旧的钢丝录音带和一台手摇播放器。你播放录音，里面传来一个男人的声音，语气疲惫而绝望：“……这里是本岛第5轮次广播。如果你听到这段录音，说明我们又一次失败了。我要告诉后来者一件重要的事：那个眼睛不是神，也不是自然现象——是镜子。我们凝视它，它就在我们心里生成一轮新的暴雪。打破循环的唯一方法，是停止凝视。但谁能做到呢？恐惧让我们不得不凝视。”录音到这里中断，伴随着一阵刺耳的啸叫。',1,'基础包',52),(65,'2026-06-24 18:03:54.585000','地点描述：在堡垒遗址的内院中，一块被积雪和石板覆盖的区域下，你发现了土壤和枯萎的藤蔓——这是一座被故意掩埋的花园。\n可获得物资： 草药（8单位）\n历史秘密碎片：你发现花园角落埋着一块石碑，上面刻着：“筑墙者最后的秘密：我们不仅筑墙抵御暴雪，我们筑墙掩盖真相——这座岛的地下，埋着最初那个‘种子’。第一个来到这里的人，用某种东西种下了这场循环。如果我们能把它挖出来，也许就能结束一切。但我们害怕挖出的东西，所以我们选择了建墙在上面。”你的目光不由自主地看向脚下的大地。\n难度：5','被雪掩埋的花园（筑墙者遗产）','common',_binary '\0','2026-08-28 04:48:41.588036',5,_binary '\0','在堡垒遗址的内院中，一块被积雪和石板覆盖的区域下，你发现了土壤和枯萎的藤蔓——这是一座被故意掩埋的花园。','你发现花园角落埋着一块石碑，上面刻着：“筑墙者最后的秘密：我们不仅筑墙抵御暴雪，我们筑墙掩盖真相——这座岛的地下，埋着最初那个‘种子’。第一个来到这里的人，用某种东西种下了这场循环。如果我们能把它挖出来，也许就能结束一切。但我们害怕挖出的东西，所以我们选择了建墙在上面。”你的目光不由自主地看向脚下的大地。',1,'基础包',53),(66,'2026-06-24 18:03:54.599000','地点描述：小镇中心钟楼的顶层，大钟表面结满了厚厚的冰霜，指针永远停在11:58——差两分钟就到午夜。\n可获得物资：金属制品（100kg） ， 绳索（8米）\n历史秘密碎片：你在钟楼壁板上发现一行被反复刻划的字：“永远差两分钟。上一次暴雪来临时，钟停了。再上一次也是。每一次都停在11:58。两分钟，就是雪落下来、岛被洗白的时间。”下方有人用红笔加上了一行：“如果我们能在11:58之前把钟敲响，也许时间就能继续走下去。但谁来敲？谁敢敲？”\n难度：19\n这些事件碎片共同指向一个完整的宿命叙事弧线：\n暴雪是重置机制，而不是自然灾害（事件44、58、60）。\n三原型（筑墙者/扬帆者/血祭者）是历史重复的三种失败模式（事件46、47、48、55）。\n银币是观测信物和灵魂锚点，每一枚都属于一个轮回的参与者（事件50、51）。\n潮汐症是亡魂的轮回记忆泄漏（事件45、49）。\n打破循环的线索指向“停止恐惧/停止杀戮/停止凝视眼睛”（事件52、56、57），并暗示需要“三群人合一”或“许下新愿”。','被冻住的钟楼','legendary',_binary '\0','2026-08-28 04:48:41.599256',19,_binary '\0','小镇中心钟楼的顶层，大钟表面结满了厚厚的冰霜，指针永远停在11:58——差两分钟就到午夜。','你在钟楼壁板上发现一行被反复刻划的字：“永远差两分钟。上一次暴雪来临时，钟停了。再上一次也是。每一次都停在11:58。两分钟，就是雪落下来、岛被洗白的时间。”下方有人用红笔加上了一行：“如果我们能在11:58之前把钟敲响，也许时间就能继续走下去。但谁来敲？谁敢敲？”',1,'基础包',56),(67,'2026-08-28 04:48:41.017012','地点描述：风暴后新露出的悬崖底部洞穴，比之前探索过的更深。洞壁上布满了色彩剥落的壁画，描绘着三个群体：一群人在筑墙围城，一群人在造船远航，还有一群人在举行血腥仪式。三群人的中央，是一个巨大的、被雪花包围的圆形眼睛。\n可获得物资：煤油（3升），火把（2把）\n历史秘密碎片：壁画的最后一幅场景中，三群人全部倒在雪地中，而那个圆形眼睛上方，画着一条首尾相衔的蛇。旁边有一行用朱砂写的、极其古老的文字。你当然不认识，但你手中那枚银币突然微微发烫——仿佛它与这壁画之间，有着某种跨越轮回的共鸣。这一刻你确信：这枚银币不是信物，是墓碑。它属于上一个周期中某一个失败者。\n难度：18','远古壁画洞穴（核心揭示点）','legendary',_binary '\0','2026-08-28 04:48:41.017016',18,_binary '\0','风暴后新露出的悬崖底部洞穴，比之前探索过的更深。洞壁上布满了色彩剥落的壁画，描绘着三个群体：一群人在筑墙围城，一群人在造船远航，还有一群人在举行血腥仪式。三群人的中央，是一个巨大的、被雪花包围的圆形眼睛。','壁画的最后一幅场景中，三群人全部倒在雪地中，而那个圆形眼睛上方，画着一条首尾相衔的蛇。旁边有一行用朱砂写的、极其古老的文字。你当然不认识，但你手中那枚银币突然微微发烫——仿佛它与这壁画之间，有着某种跨越轮回的共鸣。这一刻你确信：这枚银币不是信物，是墓碑。它属于上一个周期中某一个失败者。',1,'基础包',44),(68,'2026-08-28 04:48:41.025852','地点描述：在旧矿道的最深处，你发现一个被炸塌后又重新挖开的密室。密室内有一座小型的熔炉和模具，模具的形状正是你手中那枚\"巨瞳\"银币。\n可获得物资：金属制品（200kg），煤油（6升）\n历史秘密碎片：你找到一张铸币记录：\"批次13——银币共33枚。用于\'锚定\'本轮次的24名参与者。每人一枚，不可丢弃。银币的作用不是祝福，是\'标记\'。当持有者死亡，银币会记录其死因和坐标，供\'观测者\'回收。\"记录末尾有一行潦草的手写：\"我们还在铸造，说明我们还在循环里。什么时候熔炉熄灭了，什么时候循环才真正结束。\"你握紧了口袋里那枚发烫的银币，第一次真正理解了\"诅咒信物\"的含义。\n难度：16','银币的铸造地（关键地点）','epic',_binary '\0','2026-08-28 04:48:41.025854',16,_binary '\0','在旧矿道的最深处，你发现一个被炸塌后又重新挖开的密室。密室内有一座小型的熔炉和模具，模具的形状正是你手中那枚\"巨瞳\"银币。','你找到一张铸币记录：\"批次13——银币共33枚。用于\'锚定\'本轮次的24名参与者。每人一枚，不可丢弃。银币的作用不是祝福，是\'标记\'。当持有者死亡，银币会记录其死因和坐标，供\'观测者\'回收。\"记录末尾有一行潦草的手写：\"我们还在铸造，说明我们还在循环里。什么时候熔炉熄灭了，什么时候循环才真正结束。\"你握紧了口袋里那枚发烫的银币，第一次真正理解了\"诅咒信物\"的含义。',1,'基础包',50),(69,'2026-08-28 04:48:41.030285','地点描述：在海岸洞穴的深处，一个被潮水冲刷出的石台上，压着一块石板，上面刻着一串长长的名单。\n可获得物资：帆布（2米），绳索（10米）\n历史秘密碎片：你费力地阅读那些模糊的名字，发现它们被划分为三列——\"筑墙者\"、\"扬帆者\"、\"血祭者\"。每一列的名字下面都标注着死因和\"观察编号\"。最新的一列末尾，空着一个名字位置，旁边写着一行字：\"第7轮次——摆渡船已启航，等待最后一名登船者。\"你数了数名单上的编号，发现你手中的银币背面，印着的正是\"7\"这个数字。\n难度：15','摆渡船的登船名单','epic',_binary '\0','2026-08-28 04:48:41.030288',15,_binary '\0','在海岸洞穴的深处，一个被潮水冲刷出的石台上，压着一块石板，上面刻着一串长长的名单。','你费力地阅读那些模糊的名字，发现它们被划分为三列——\"筑墙者\"、\"扬帆者\"、\"血祭者\"。每一列的名字下面都标注着死因和\"观察编号\"。最新的一列末尾，空着一个名字位置，旁边写着一行字：\"第7轮次——摆渡船已启航，等待最后一名登船者。\"你数了数名单上的编号，发现你手中的银币背面，印着的正是\"7\"这个数字。',1,'基础包',51),(70,'2026-08-28 04:48:41.035550','地点描述：在旧教堂地下墓穴更深一层，你发现一具被钉在墙上的骸骨，胸骨上钉着一块木牌。\n可获得物资：医疗资源（30单位），十字镐（1把）\n历史秘密碎片：木牌上刻着：\"我是第2轮次的天灾使者。我们被指示杀戮，但我杀到第7人时，听见了死者的话——他们让我看那个眼睛。我才明白：我们杀人，那个眼睛就\'食用\'死者的恐惧。我们越恐惧，暴雪就越猛烈。所以我停下了。他们把我钉在这里。我要告诉后来者：不要当血祭者，也不要被他们献祭。唯一的出路是让那个眼睛\'饿死\'。停止恐惧，停止屠杀。\"骸骨的手中，紧紧攥着一枚和你手中一模一样的银币——但它是破碎的。\n难度：15','血祭者的反叛遗言','epic',_binary '\0','2026-08-28 04:48:41.035552',15,_binary '\0','在旧教堂地下墓穴更深一层，你发现一具被钉在墙上的骸骨，胸骨上钉着一块木牌。','木牌上刻着：\"我是第2轮次的天灾使者。我们被指示杀戮，但我杀到第7人时，听见了死者的话——他们让我看那个眼睛。我才明白：我们杀人，那个眼睛就\'食用\'死者的恐惧。我们越恐惧，暴雪就越猛烈。所以我停下了。他们把我钉在这里。我要告诉后来者：不要当血祭者，也不要被他们献祭。唯一的出路是让那个眼睛\'饿死\'。停止恐惧，停止屠杀。\"骸骨的手中，紧紧攥着一枚和你手中一模一样的银币——但它是破碎的。',1,'基础包',55),(71,'2026-08-28 04:48:41.041003','地点描述：在岛屿正中央的平原上，孤零零地长着一棵巨大的橡树，树冠如伞，但所有枝丫都指向地面——像是倒着生长的。\n可获得物资：木材（5吨），绳索（6米）\n历史秘密碎片：树根处嵌着一块铁牌，上面用古英文写着：\"这里埋着第一颗\'种子\'。它不是树，不是石，不是金属。它是\'选择\'。第一个抵达这里的人，面对暴雪时，许了一个愿：\'让一切重来\'。于是岛屿答应了。从此以后，每一次暴雪都是\'重来\'的兑现。如果你能挖出它，也许能让它许一个不一样的愿——比如\'让一切结束\'。\"你伸手摸向树根旁的冻土，指尖传来一阵微弱的、脉冲般的颤动。\n难度：18','雪地中的孤树','legendary',_binary '\0','2026-08-28 04:48:41.041006',18,_binary '\0','在岛屿正中央的平原上，孤零零地长着一棵巨大的橡树，树冠如伞，但所有枝丫都指向地面——像是倒着生长的。','树根处嵌着一块铁牌，上面用古英文写着：\"这里埋着第一颗\'种子\'。它不是树，不是石，不是金属。它是\'选择\'。第一个抵达这里的人，面对暴雪时，许了一个愿：\'让一切重来\'。于是岛屿答应了。从此以后，每一次暴雪都是\'重来\'的兑现。如果你能挖出它，也许能让它许一个不一样的愿——比如\'让一切结束\'。\"你伸手摸向树根旁的冻土，指尖传来一阵微弱的、脉冲般的颤动。',1,'基础包',57),(72,'2026-08-28 04:48:41.045112','地点描述：幽灵船\"摆渡号\"的船底夹层中，你发现一个从未被海水浸没的小舱，里面有桌椅、烛台和一面青铜镜。\n可获得物资：煤油（5升），协议书（1张）\n历史秘密碎片：桌上摊着一本摊开的册子，册子上是历次轮回的\"记录员\"笔记。最新一页写着：\"第6轮次——全灭。筑墙者3人死于内讧，扬帆者7人死于迷航，血祭者4人死于反噬。观察席判定：本轮实验未达\'升华\'标准，启动重置。第7轮次投放物资：33枚银币，33个\'种子\'灵魂。等待开局。\"你正看着，铜镜中忽然映出一张不属于你的脸——那张脸微笑着，开口说出了你此刻的心声：\"你发现了。\"镜子中的那个人，穿着与你一模一样的衣服，但口袋里没有银币。而你口袋里的银币，烫得几乎要灼穿布料。\n难度：20','摆渡人的秘密舱室','legendary',_binary '\0','2026-08-28 04:48:41.045115',20,_binary '','幽灵船\"摆渡号\"的船底夹层中，你发现一个从未被海水浸没的小舱，里面有桌椅、烛台和一面青铜镜。','桌上摊着一本摊开的册子，册子上是历次轮回的\"记录员\"笔记。最新一页写着：\"第6轮次——全灭。筑墙者3人死于内讧，扬帆者7人死于迷航，血祭者4人死于反噬。观察席判定：本轮实验未达\'升华\'标准，启动重置。第7轮次投放物资：33枚银币，33个\'种子\'灵魂。等待开局。\"你正看着，铜镜中忽然映出一张不属于你的脸——那张脸微笑着，开口说出了你此刻的心声：\"你发现了。\"镜子中的那个人，穿着与你一模一样的衣服，但口袋里没有银币。而你口袋里的银币，烫得几乎要灼穿布料。',1,'基础包',60),(73,'2026-08-28 04:48:41.049294','地点描述：山脊上一座被积雪压垮的木制通信站，天线已经折断，设备全部被拆走，只剩下空荡荡的木质框架和一张倒下的桌子。\n可获得物资：木材（1吨），飞机部件·起落架（1个）\n历史秘密碎片：你在桌子的抽屉夹层中找到一张被折叠的纸条，上面用铅笔写着：“今天收到来自‘源门’方向的信号。不是摩斯电码，是某种……心跳一样的节律。我把它抄录下来了，但没有人能解读。也许它本来就是给‘门’那边的存在听的，不是给我们听的。”纸条背面画着一串波浪状的波形图，没有任何文字注释。\n难度：8','废弃的通信站','uncommon',_binary '\0','2026-08-28 04:48:41.049296',8,_binary '\0','山脊上一座被积雪压垮的木制通信站，天线已经折断，设备全部被拆走，只剩下空荡荡的木质框架和一张倒下的桌子。','你在桌子的抽屉夹层中找到一张被折叠的纸条，上面用铅笔写着：“今天收到来自‘源门’方向的信号。不是摩斯电码，是某种……心跳一样的节律。我把它抄录下来了，但没有人能解读。也许它本来就是给‘门’那边的存在听的，不是给我们听的。”纸条背面画着一串波浪状的波形图，没有任何文字注释。',2,'旧世界的末尾',61),(74,'2026-08-28 04:48:41.053272','地点描述：矿场深处一条废弃的支巷尽头，一具被冻在冰层中的矿工尸体，保持着向前爬行的姿势，手指向前方，指向一面被凿过的岩壁。\n可获得物资：金属制品（30kg），十字镐（1把）\n历史秘密碎片：你凿开冰层，在尸体的口袋里发现一块刻着数字“7”的黑色石头碎片。尸体的另一只手中紧握着一张被血浸透的纸，纸上只有一行字：“第十三枚石之心已经铸成，但锻炉说它‘太重了’，重到可能连门都承受不住。我决定把它藏在矿场最深处，不告诉任何人。如果有一天你找到了它，请不要用它——有些门，不应该被打开。”字迹后面的署名已经模糊，只能辨认出第一个字是“索”。\n难度：10','冰封的矿工尸体','rare',_binary '\0','2026-08-28 04:48:41.053274',10,_binary '\0','矿场深处一条废弃的支巷尽头，一具被冻在冰层中的矿工尸体，保持着向前爬行的姿势，手指向前方，指向一面被凿过的岩壁。','你凿开冰层，在尸体的口袋里发现一块刻着数字“7”的黑色石头碎片。尸体的另一只手中紧握着一张被血浸透的纸，纸上只有一行字：“第十三枚石之心已经铸成，但锻炉说它‘太重了’，重到可能连门都承受不住。我决定把它藏在矿场最深处，不告诉任何人。如果有一天你找到了它，请不要用它——有些门，不应该被打开。”字迹后面的署名已经模糊，只能辨认出第一个字是“索”。',2,'旧世界的末尾',62),(75,'2026-08-28 04:48:41.057369','地点描述：小镇边缘一座被藤蔓覆盖的石头谷仓，屋顶已经坍塌了一半，内部堆满了腐烂的干草和破碎的农具。空气中弥漫着一股陈旧的霉味。\n可获得物资：食物（10单位），医用酒精（10升）\n历史秘密碎片：你在谷仓角落的干草堆下发现一块被油布包裹的木板，上面用烧红的铁棍烙着几行字：“筑墙者以为墙能挡住暴雪，扬帆者以为海能通向自由，杀戮者以为刀能终结痛苦。他们全都错了。这里没有墙，没有海，没有刀——只有一扇门，和门后那个一直在等的东西。”木板底部刻着一个衔尾蛇符号，但蛇身已经断裂，仿佛被某种力量震碎。\n难度：12','被遗忘的谷仓','rare',_binary '\0','2026-08-28 04:48:41.057371',12,_binary '\0','小镇边缘一座被藤蔓覆盖的石头谷仓，屋顶已经坍塌了一半，内部堆满了腐烂的干草和破碎的农具。空气中弥漫着一股陈旧的霉味。','你在谷仓角落的干草堆下发现一块被油布包裹的木板，上面用烧红的铁棍烙着几行字：“筑墙者以为墙能挡住暴雪，扬帆者以为海能通向自由，杀戮者以为刀能终结痛苦。他们全都错了。这里没有墙，没有海，没有刀——只有一扇门，和门后那个一直在等的东西。”木板底部刻着一个衔尾蛇符号，但蛇身已经断裂，仿佛被某种力量震碎。',2,'旧世界的末尾',63),(76,'2026-08-28 04:48:41.062380','地点描述：小镇钟楼旁的旧灯塔顶端，一座早已锈死的风向标，箭头指向东北方向，但不管风怎么吹，它都不再转动。\n可获得物资：金属制品（10kg），绳索（10米）\n历史秘密碎片：你爬上塔顶，发现风向标的底座上刻着一行古英文：“当暴雪从北面来的时候，不要抬头看天。看地。”你低头看向塔下的地面，发现积雪覆盖的广场上，雪的纹理形成一个巨大的、几乎无法辨认的圆圈图案——但只有从塔顶才能看到全貌。你突然意识到，这座岛的建筑布局，可能不是随机的。\n难度：7','塔楼上的风向标','uncommon',_binary '\0','2026-08-28 04:48:41.062382',7,_binary '\0','小镇钟楼旁的旧灯塔顶端，一座早已锈死的风向标，箭头指向东北方向，但不管风怎么吹，它都不再转动。','你爬上塔顶，发现风向标的底座上刻着一行古英文：“当暴雪从北面来的时候，不要抬头看天。看地。”你低头看向塔下的地面，发现积雪覆盖的广场上，雪的纹理形成一个巨大的、几乎无法辨认的圆圈图案——但只有从塔顶才能看到全貌。你突然意识到，这座岛的建筑布局，可能不是随机的。',2,'旧世界的末尾',64),(77,'2026-08-28 04:48:41.066445','地点描述：教堂后方的杂物间里，一架被冻裂的管风琴，琴键错位，琴管中结满了冰凌。推开琴凳时，地面露出一块松动的木板。\n可获得物资：木材（1吨），蜡烛（10支）\n历史秘密碎片：你在木板下的暗格中发现一本乐谱，封面写着“霜之女——献给那位在暴雪中唱歌的人”。乐谱内页全部是空白，只有最后一页写着几行小字：“暴雪是终结。但我在暴雪中听到了歌声——不是风声，是有人在唱歌。我不知道是谁，但我知道，如果暴雪真的能终结一切，那个人就不会唱歌。”字迹纤细，像是女性的笔迹。\n难度：10','被冰封的乐器','rare',_binary '\0','2026-08-28 04:48:41.066446',10,_binary '\0','教堂后方的杂物间里，一架被冻裂的管风琴，琴键错位，琴管中结满了冰凌。推开琴凳时，地面露出一块松动的木板。','你在木板下的暗格中发现一本乐谱，封面写着“霜之女——献给那位在暴雪中唱歌的人”。乐谱内页全部是空白，只有最后一页写着几行小字：“暴雪是终结。但我在暴雪中听到了歌声——不是风声，是有人在唱歌。我不知道是谁，但我知道，如果暴雪真的能终结一切，那个人就不会唱歌。”字迹纤细，像是女性的笔迹。',2,'旧世界的末尾',65),(78,'2026-08-28 04:48:41.069812','地点描述：码头附近浅海区，一具被珊瑚和藤壶覆盖的铜质摆钟，被海浪冲到了礁石间。钟面已经严重腐蚀，指针早已消失。\n可获得物资：金属制品（50kg）\n历史秘密碎片：你费力地将摆钟翻过来，在底座上发现一行蚀刻的文字：“11:58。这是索莉亚最后一次看时间。她说过，如果钟停了，就不要再上发条——因为时间本身已经不需要被测量了。”你试着转动摆钟侧面的旋钮，它发出了清脆的“咔哒”声，然后沉寂了。你感到一阵莫名的寒意，仿佛有什么东西在你转动旋钮的同时，在某个你看不到的地方，睁开了眼睛。\n难度：14','沉没的计时器','epic',_binary '\0','2026-08-28 04:48:41.069814',14,_binary '\0','码头附近浅海区，一具被珊瑚和藤壶覆盖的铜质摆钟，被海浪冲到了礁石间。钟面已经严重腐蚀，指针早已消失。','你费力地将摆钟翻过来，在底座上发现一行蚀刻的文字：“11:58。这是索莉亚最后一次看时间。她说过，如果钟停了，就不要再上发条——因为时间本身已经不需要被测量了。”你试着转动摆钟侧面的旋钮，它发出了清脆的“咔哒”声，然后沉寂了。你感到一阵莫名的寒意，仿佛有什么东西在你转动旋钮的同时，在某个你看不到的地方，睁开了眼睛。',2,'旧世界的末尾',66),(79,'2026-08-28 04:48:41.072777','地点描述：小镇边缘一座被烧毁的石头建筑，只剩下焦黑的墙壁和坍塌的屋顶。内部的书架全部化为灰烬，只有一本被烧得只剩一半的书躺在废墟中央。「特殊：随机一份未被揭示的仪式记物」\n可获得物资：随机一份未被揭示的仪式记物，医用酒精（10升）\n历史秘密碎片：你小心翼翼地翻开那本烧焦的书，发现它能辨认的内容只有几段：“……‘石之心’的铸造需要七年的时间，但锻炉说，他其实只用了七个月。剩下的六年零五个月，他都在等待——等待石头自己决定是否愿意成为工具。他说，远古的血脉是有生命的，你不能强迫它，只能请求它。第十三枚石之心拒绝了请求，所以它被埋在了矿场最深处。”你试图翻到下一页，但书页已经炭化，一碰就碎成了粉末。\n难度：18','被烧毁的图书馆','legendary',_binary '\0','2026-08-28 04:48:41.072779',18,_binary '\0','小镇边缘一座被烧毁的石头建筑，只剩下焦黑的墙壁和坍塌的屋顶。内部的书架全部化为灰烬，只有一本被烧得只剩一半的书躺在废墟中央。「特殊：随机一份未被揭示的仪式记物」','你小心翼翼地翻开那本烧焦的书，发现它能辨认的内容只有几段：“……‘石之心’的铸造需要七年的时间，但锻炉说，他其实只用了七个月。剩下的六年零五个月，他都在等待——等待石头自己决定是否愿意成为工具。他说，远古的血脉是有生命的，你不能强迫它，只能请求它。第十三枚石之心拒绝了请求，所以它被埋在了矿场最深处。”你试图翻到下一页，但书页已经炭化，一碰就碎成了粉末。',2,'旧世界的末尾',67),(80,'2026-08-28 04:48:41.075854','地点描述：岛屿最高处一棵枯死巨树的顶端，有一座用树枝和兽皮搭建的简陋巢穴，视野极佳，可以俯瞰整个岛屿。巢穴内铺着厚厚的干草，中央有一个熄灭的灰烬堆。\n可获得物资：火把（1把），食物（5单位）\n历史秘密碎片：你在灰烬堆中找到一块被烧黑的兽骨，上面刻着：“第三百六十一次，我醒来时，发现自己站在同样的山顶，看着同样的雪。我决定不再下去。我在这里建了一个巢，每天看云，看鸟，看暴雪从北面来。我记下了每一次暴雪的时间——不是规律，是周期。如果我算得没错，下一次暴雪，会比上一次更早三天。这让我很不安。因为周期在缩短，而我不知道为什么。”兽骨背后刻着一串数字，看起来像是日期，但用的是你从未见过的纪年法。\n难度：12','守望者的巢穴','rare',_binary '\0','2026-08-28 04:48:41.075856',12,_binary '\0','岛屿最高处一棵枯死巨树的顶端，有一座用树枝和兽皮搭建的简陋巢穴，视野极佳，可以俯瞰整个岛屿。巢穴内铺着厚厚的干草，中央有一个熄灭的灰烬堆。','你在灰烬堆中找到一块被烧黑的兽骨，上面刻着：“第三百六十一次，我醒来时，发现自己站在同样的山顶，看着同样的雪。我决定不再下去。我在这里建了一个巢，每天看云，看鸟，看暴雪从北面来。我记下了每一次暴雪的时间——不是规律，是周期。如果我算得没错，下一次暴雪，会比上一次更早三天。这让我很不安。因为周期在缩短，而我不知道为什么。”兽骨背后刻着一串数字，看起来像是日期，但用的是你从未见过的纪年法。',2,'旧世界的末尾',68),(81,'2026-08-28 04:48:41.080100','地点描述：一条通往内陆的雪径上，散落着一辆损坏的雪橇，拉绳已经断裂，上面堆着几个空木箱和一个破损的皮箱。\n可获得物资：木材（1吨），医用酒精（10升），飞机部件·副驾座（1个）\n历史秘密碎片：你打开皮箱，发现里面装满了信件，全是同一个人的笔迹，收件人是一个叫“玛莎”的人。大部分信件都没有寄出，叠在一起，用一根旧皮绳捆着。你随意抽出一封，信上写着：“亲爱的玛莎，我发现了他们藏起来的真相——这座岛不是被发现的，是被‘放’在这里的。那些银色的盒子，每一个都是一段被删除的记忆。我必须把证据藏起来，藏在……”信件在这里中断，最后几个字被水渍完全浸染，无法辨认。你注意到信封的角落有一个小小的、淡金色的符号——一个衔尾蛇，但蛇的嘴巴是张开的，仿佛在吞噬什么。\n难度：16','被遗弃的雪橇（二号）','epic',_binary '\0','2026-08-28 04:48:41.080103',16,_binary '\0','一条通往内陆的雪径上，散落着一辆损坏的雪橇，拉绳已经断裂，上面堆着几个空木箱和一个破损的皮箱。','你打开皮箱，发现里面装满了信件，全是同一个人的笔迹，收件人是一个叫“玛莎”的人。大部分信件都没有寄出，叠在一起，用一根旧皮绳捆着。你随意抽出一封，信上写着：“亲爱的玛莎，我发现了他们藏起来的真相——这座岛不是被发现的，是被‘放’在这里的。那些银色的盒子，每一个都是一段被删除的记忆。我必须把证据藏起来，藏在……”信件在这里中断，最后几个字被水渍完全浸染，无法辨认。你注意到信封的角落有一个小小的、淡金色的符号——一个衔尾蛇，但蛇的嘴巴是张开的，仿佛在吞噬什么。',2,'旧世界的末尾',69),(82,'2026-08-28 04:48:41.084298','地点描述：矿场深处一个被炸塌的巷道，你用十字镐清理了碎石后，发现了一个狭窄的裂缝，可以勉强挤进去。裂缝后面是一个天然形成的洞穴，洞穴中央有一根从地面连接到顶部的巨大石柱，表面布满了不规则的螺旋纹路。\n可获得物资：煤油（50升）\n历史秘密碎片：你将耳朵贴在石柱上，听到了极其微弱的、节律性的振动——像心跳，但比心跳慢得多，大约每分钟只有四次。振动从脚底传来，从上方传来，从四面八方传来。你注意到石柱的底部刻着一行小字，是你认识的文字：“源门之下，是石之心。石之心之下，是地脉。地脉之下，是呼吸。呼吸之下——是沉默。”你感到石柱的振动在你的胸腔中产生了共鸣，你的心脏开始不自觉地跟随那个节律跳动，一种难以言喻的恐惧从你的脊椎爬升上来，迫使你迅速离开了裂缝。\n难度：18','地下的回声','legendary',_binary '\0','2026-08-28 04:48:41.084300',18,_binary '\0','矿场深处一个被炸塌的巷道，你用十字镐清理了碎石后，发现了一个狭窄的裂缝，可以勉强挤进去。裂缝后面是一个天然形成的洞穴，洞穴中央有一根从地面连接到顶部的巨大石柱，表面布满了不规则的螺旋纹路。','你将耳朵贴在石柱上，听到了极其微弱的、节律性的振动——像心跳，但比心跳慢得多，大约每分钟只有四次。振动从脚底传来，从上方传来，从四面八方传来。你注意到石柱的底部刻着一行小字，是你认识的文字：“源门之下，是石之心。石之心之下，是地脉。地脉之下，是呼吸。呼吸之下——是沉默。”你感到石柱的振动在你的胸腔中产生了共鸣，你的心脏开始不自觉地跟随那个节律跳动，一种难以言喻的恐惧从你的脊椎爬升上来，迫使你迅速离开了裂缝。',2,'旧世界的末尾',70),(83,'2026-08-28 04:48:41.087126','地点描述：岛屿最寒冷山谷的入口处，一块被冰层覆盖的巨石下，压着一个用兽皮缝制的包裹。包裹的表面已经冻得硬邦邦的，你用刀费力地撬开它。\n可获得物资：草药（10单位），食物（10单位）\n历史秘密碎片：包裹里有一块用骨头雕刻的护身符，形状是一个雪花，但雪花中央是一张扭曲的人脸，嘴张得很大，像是在尖叫。护身符的背面刻着几个字：“珀尔戈之道，即是终结。”旁边还有一行更小的字：“但我不知道，终结之后是什么。”包裹底部还有一张折叠的羊皮纸，上面用血画了一幅地图，标记着一条通往山谷深处的小路。地图边缘写着：“如果你想去那里，带上足够的柴火。因为那里不仅是冷的——那里是‘空’的。”\n难度：18','霜之子的遗物','legendary',_binary '\0','2026-08-28 04:48:41.087128',18,_binary '\0','岛屿最寒冷山谷的入口处，一块被冰层覆盖的巨石下，压着一个用兽皮缝制的包裹。包裹的表面已经冻得硬邦邦的，你用刀费力地撬开它。','包裹里有一块用骨头雕刻的护身符，形状是一个雪花，但雪花中央是一张扭曲的人脸，嘴张得很大，像是在尖叫。护身符的背面刻着几个字：“珀尔戈之道，即是终结。”旁边还有一行更小的字：“但我不知道，终结之后是什么。”包裹底部还有一张折叠的羊皮纸，上面用血画了一幅地图，标记着一条通往山谷深处的小路。地图边缘写着：“如果你想去那里，带上足够的柴火。因为那里不仅是冷的——那里是‘空’的。”',2,'旧世界的末尾',71),(84,'2026-08-28 04:48:41.090743','地点描述：码头旁一艘被遗弃的小渔船，船底破了一个大洞，船内堆着一张腐烂的渔网。渔网中缠绕着一些奇怪的杂物——贝壳、骨头、以及一枚发黑的银币。\n可获得物资：绳索（20米），银币（1枚）\n历史秘密碎片：你从渔网中取出那枚银币，发现它正面刻着衔尾蛇，背面刻着一个数字“0”。你从未见过编号为零的银币。银币的边缘有一行极小的字，需要用放大镜才能看清：“铸币人留。最后一枚，不记名，不编号。如果有一天有人找到了它，请把它丢进海里。银币不属于活人。”你握紧银币，感到一阵刺骨的凉意从掌心传来，像是握着一块刚从冰水中捞出来的石头。\n难度：9','被诅咒的渔网','uncommon',_binary '\0','2026-08-28 04:48:41.090745',9,_binary '\0','码头旁一艘被遗弃的小渔船，船底破了一个大洞，船内堆着一张腐烂的渔网。渔网中缠绕着一些奇怪的杂物——贝壳、骨头、以及一枚发黑的银币。','你从渔网中取出那枚银币，发现它正面刻着衔尾蛇，背面刻着一个数字“0”。你从未见过编号为零的银币。银币的边缘有一行极小的字，需要用放大镜才能看清：“铸币人留。最后一枚，不记名，不编号。如果有一天有人找到了它，请把它丢进海里。银币不属于活人。”你握紧银币，感到一阵刺骨的凉意从掌心传来，像是握着一块刚从冰水中捞出来的石头。',2,'旧世界的末尾',72),(85,'2026-08-28 04:48:41.094888','地点描述：森林深处一片被雪覆盖的空地中央，立着一块白色的石碑，表面光滑如镜，没有任何文字或图案。石碑周围没有脚印，也没有任何动物的痕迹，仿佛这片空地是被刻意清理出来的。获得「安静」状态（本局无法被调查）。\n可获得物资：无直接物资\n历史秘密碎片：你伸手触摸石碑的瞬间，指尖传来一阵温热——不是错觉，石碑的温度明显高于周围的空气。你绕着石碑走了一圈，发现它的背面有一行几乎看不见的浅刻字：“我站在这里，看着你们一次又一次地重复。第一次，我哭了。第二次，我笑了。第三次，我累了。第四次，我闭上了眼睛。第五次，我忘了自己是谁。第六次，我不再是‘我’。第七次——我变成了这块石头。如果你看到了这些字，不要摸我。因为我会记住你，就像我记住所有来过这里的人一样。”你感到石碑似乎在微微颤动，像是某种东西在沉睡中翻了个身。你迅速收回了手。\n难度：17','白色石碑','epic',_binary '\0','2026-08-28 04:48:41.094891',17,_binary '\0','森林深处一片被雪覆盖的空地中央，立着一块白色的石碑，表面光滑如镜，没有任何文字或图案。石碑周围没有脚印，也没有任何动物的痕迹，仿佛这片空地是被刻意清理出来的。获得「安静」状态（本局无法被调查）。','你伸手触摸石碑的瞬间，指尖传来一阵温热——不是错觉，石碑的温度明显高于周围的空气。你绕着石碑走了一圈，发现它的背面有一行几乎看不见的浅刻字：“我站在这里，看着你们一次又一次地重复。第一次，我哭了。第二次，我笑了。第三次，我累了。第四次，我闭上了眼睛。第五次，我忘了自己是谁。第六次，我不再是‘我’。第七次——我变成了这块石头。如果你看到了这些字，不要摸我。因为我会记住你，就像我记住所有来过这里的人一样。”你感到石碑似乎在微微颤动，像是某种东西在沉睡中翻了个身。你迅速收回了手。',2,'旧世界的末尾',73),(86,'2026-08-28 04:48:41.097949','地点描述：教堂地下墓穴最深处的墙壁上，有一块被水泥封住的砖石，你敲开它后，发现里面有一个小空洞，放着一封用油布包裹的信。\n可获得物资：蜡烛（10支），医疗资源（10份）\n历史秘密碎片：信封上写着“致下一位清醒者”，没有署名。你拆开信，里面只有一张纸，上面写着：“你看到这封信的时候，说明你已经走得很远了。但我要告诉你一件事：你走的这条路，不是我留下的那条。我留下的路，已经被我自己封死了。因为我发现，不是所有的真相都值得被知道。索莉亚是对的，也是错的。珀尔戈是错的，也是对的。他们俩都没能走到终点，因为他们都以为自己的路是唯一的路。但真正的路，不在他们中间——而在他们身后。回头看看，你脚下的那片地，下面埋着什么？”信的末尾没有署名，只有一个日期，你无法换算成你熟悉的任何时间。\n难度：20','封信','legendary',_binary '\0','2026-08-28 04:48:41.097952',20,_binary '','教堂地下墓穴最深处的墙壁上，有一块被水泥封住的砖石，你敲开它后，发现里面有一个小空洞，放着一封用油布包裹的信。','信封上写着“致下一位清醒者”，没有署名。你拆开信，里面只有一张纸，上面写着：“你看到这封信的时候，说明你已经走得很远了。但我要告诉你一件事：你走的这条路，不是我留下的那条。我留下的路，已经被我自己封死了。因为我发现，不是所有的真相都值得被知道。索莉亚是对的，也是错的。珀尔戈是错的，也是对的。他们俩都没能走到终点，因为他们都以为自己的路是唯一的路。但真正的路，不在他们中间——而在他们身后。回头看看，你脚下的那片地，下面埋着什么？”信的末尾没有署名，只有一个日期，你无法换算成你熟悉的任何时间。',2,'旧世界的末尾',74),(87,'2026-08-28 04:48:41.101888','地点描述：岛屿西侧一条被地震撕裂的峡谷，两侧岩壁露出新鲜的断层，但令人惊讶的是，断层上已经长满了深绿色的苔藓和藤蔓——这些植物看上去至少经历了数十年的生长，而地震的痕迹却像是昨天才留下的。峡谷底部有一条浅浅的溪流，水温温热，冒着蒸汽，水底铺着光滑的黑色卵石，卵石表面有细密的螺旋纹路。溪流为永久取水点，可作为营地。\n可获得物资：草药（10单位）\n历史秘密碎片：你在溪流边一块被苔藓半覆盖的岩壁上，发现了一组用锐器刻下的文字，字迹工整，像是某个过路者的记录：“第七次来这条峡谷。第一次是地震后第三天，整条峡谷像被刀劈开的伤口，寸草不生。第二次是第七天，裂缝里冒出温水，水温烫手。第三次是第二十天，崖壁上出现了第一粒苔藓。现在是第七次，整条峡谷已经被绿色覆盖，连地震的痕迹都快看不出来了。这绝不可能是自然恢复的速度——是地底的东西在‘愈合’。”文字末尾，刻着一行小字，像是自言自语：“血脉是活的。它受伤了，会自己修复。但它的修复方式，是让伤口长成新的皮肤，而不是让伤口消失。所以这座岛的地形总在变，表面。。。”你蹲下身，伸手触碰溪水，水温温热，像某种巨大生物的体温。\n难度：15','愈合的峡谷','epic',_binary '\0','2026-08-28 04:48:41.101891',15,_binary '\0','岛屿西侧一条被地震撕裂的峡谷，两侧岩壁露出新鲜的断层，但令人惊讶的是，断层上已经长满了深绿色的苔藓和藤蔓——这些植物看上去至少经历了数十年的生长，而地震的痕迹却像是昨天才留下的。峡谷底部有一条浅浅的溪流，水温温热，冒着蒸汽，水底铺着光滑的黑色卵石，卵石表面有细密的螺旋纹路。溪流为永久取水点，可作为营地。','你在溪流边一块被苔藓半覆盖的岩壁上，发现了一组用锐器刻下的文字，字迹工整，像是某个过路者的记录：“第七次来这条峡谷。第一次是地震后第三天，整条峡谷像被刀劈开的伤口，寸草不生。第二次是第七天，裂缝里冒出温水，水温烫手。第三次是第二十天，崖壁上出现了第一粒苔藓。现在是第七次，整条峡谷已经被绿色覆盖，连地震的痕迹都快看不出来了。这绝不可能是自然恢复的速度——是地底的东西在‘愈合’。”文字末尾，刻着一行小字，像是自言自语：“血脉是活的。它受伤了，会自己修复。但它的修复方式，是让伤口长成新的皮肤，而不是让伤口消失。所以这座岛的地形总在变，表面。。。”你蹲下身，伸手触碰溪水，水温温热，像某种巨大生物的体温。',2,'旧世界的末尾',75),(88,'2026-08-28 04:48:41.105307','地点描述：矿场东侧一片被古老塌方掩埋的区域，地表覆盖着厚厚的碎石和泥土，但奇怪的是，碎石缝隙中不断冒出细小的蒸汽，蒸汽中带着一股金属味。你搬开几块较大的岩石后，发现下方露出一段被压扁的铁轨，铁轨表面锈迹斑斑，但锈蚀层下露出金属光泽——仿佛铁轨在被埋了数百年后，正在重新“生长”出新的金属。\n可获得物资：金属制品（50kg），煤油（10升）\n历史秘密碎片：你在铁轨旁的一块石板下，发现了一本被油布包裹的矿工日志，纸张已经发黄，但字迹依然清晰。日志的主人署名“老矿工马尔科”，他在最后一页写道：“我被埋在塌方下面整整三两天天，水喝完了，灯也灭了，我以为自己要死了。但第三天，我摸到了岩壁——它变热了。不是地热，是那种……像皮肤一样的温度。我用手掌贴着岩壁，感觉它在脉动，像心跳。然后我听到了声音，不是耳朵听到的，是脑子里听到的：‘别怕，我会把你送出去。’我以为是幻觉，但我活了下来。他们把我挖出来的时候，我身上没有一处骨折，连刮伤都没有。他们说是运气好，但我知道——是地底那个东西，帮我愈合了。”\n难度：14','被掩埋的矿脉','epic',_binary '\0','2026-08-28 04:48:41.105310',14,_binary '\0','矿场东侧一片被古老塌方掩埋的区域，地表覆盖着厚厚的碎石和泥土，但奇怪的是，碎石缝隙中不断冒出细小的蒸汽，蒸汽中带着一股金属味。你搬开几块较大的岩石后，发现下方露出一段被压扁的铁轨，铁轨表面锈迹斑斑，但锈蚀层下露出金属光泽——仿佛铁轨在被埋了数百年后，正在重新“生长”出新的金属。','你在铁轨旁的一块石板下，发现了一本被油布包裹的矿工日志，纸张已经发黄，但字迹依然清晰。日志的主人署名“老矿工马尔科”，他在最后一页写道：“我被埋在塌方下面整整三两天天，水喝完了，灯也灭了，我以为自己要死了。但第三天，我摸到了岩壁——它变热了。不是地热，是那种……像皮肤一样的温度。我用手掌贴着岩壁，感觉它在脉动，像心跳。然后我听到了声音，不是耳朵听到的，是脑子里听到的：‘别怕，我会把你送出去。’我以为是幻觉，但我活了下来。他们把我挖出来的时候，我身上没有一处骨折，连刮伤都没有。他们说是运气好，但我知道——是地底那个东西，帮我愈合了。”',2,'旧世界的末尾',76),(89,'2026-08-28 04:48:41.109207','地点描述：岛屿中央一个被山体滑坡堵住出水口的湖泊，水位比往年高出许多，几乎要漫过堤坝。但奇怪的是，湖泊的水质异常清澈，能见度极高，可以清晰看到湖底沉睡着一些被淹没的树桩和建筑残骸——那些树桩上，竟然冒出了新芽。\n可获得物资：木材（2吨），食物（5单位，湖鱼）\n历史秘密碎片：你在湖边一棵被淹没一半的老柳树树干上，发现了一块被钉入树皮的铁牌，铁牌上刻着：“—479年，湖淹了。我祖祖父说，湖在他小时候就淹了。我祖父说，湖在他出生前就淹了。现在我也这么说——湖好像永远都在淹，但水下的树桩一直在发芽，水下的建筑残骸一直在长苔藓，好像这座湖在不断地‘遗忘’自己曾经淹没过什么。我怀疑，不是湖在涨水，是湖底在抬升——血脉在把湖底往上推，想让湖变回原来的陆地。但每次它快要成功的时候，山体就会再次滑坡，把水重新堵住。这不是自然的水文循环，这是一场拉锯战——她想治愈伤疤，但这座岛上的其他力量，在不断地制造新的伤口。”\n难度：18','湖泊的倒影','legendary',_binary '\0','2026-08-28 04:48:41.109209',18,_binary '\0','岛屿中央一个被山体滑坡堵住出水口的湖泊，水位比往年高出许多，几乎要漫过堤坝。但奇怪的是，湖泊的水质异常清澈，能见度极高，可以清晰看到湖底沉睡着一些被淹没的树桩和建筑残骸——那些树桩上，竟然冒出了新芽。','你在湖边一棵被淹没一半的老柳树树干上，发现了一块被钉入树皮的铁牌，铁牌上刻着：“—479年，湖淹了。我祖祖父说，湖在他小时候就淹了。我祖父说，湖在他出生前就淹了。现在我也这么说——湖好像永远都在淹，但水下的树桩一直在发芽，水下的建筑残骸一直在长苔藓，好像这座湖在不断地‘遗忘’自己曾经淹没过什么。我怀疑，不是湖在涨水，是湖底在抬升——血脉在把湖底往上推，想让湖变回原来的陆地。但每次它快要成功的时候，山体就会再次滑坡，把水重新堵住。这不是自然的水文循环，这是一场拉锯战——她想治愈伤疤，但这座岛上的其他力量，在不断地制造新的伤口。”',2,'旧世界的末尾',77),(90,'2026-08-28 04:48:41.113557','地点描述：岛屿北岸一片被藤蔓和积雪覆盖的岩石滩涂，退潮时露出一些被海水腐蚀的金属框架和混凝土基座，明显不是天然形成的。基座上有一些圆形的凹槽，似乎曾经固定过某种大型设备。\n可获得物资：金属制品（50kg），刺刀（1把）\n历史秘密碎片：你在一段被海水浸泡变形的金属管上，发现了一行用钢印打上去的编号和字母：“IRON-ANVIL-01”。你不认识这个编号的含义，但字母的字体极其工整，不像这座岛上的任何书写风格。你试着撬开旁边一块松动的混凝土板，发现下面压着一块巴掌大的金属铭牌，上面刻着：“普罗维登斯前哨站·北岸观测点”。\n难度：12','北岸的废墟','rare',_binary '\0','2026-08-28 04:48:41.113560',12,_binary '\0','岛屿北岸一片被藤蔓和积雪覆盖的岩石滩涂，退潮时露出一些被海水腐蚀的金属框架和混凝土基座，明显不是天然形成的。基座上有一些圆形的凹槽，似乎曾经固定过某种大型设备。','你在一段被海水浸泡变形的金属管上，发现了一行用钢印打上去的编号和字母：“IRON-ANVIL-01”。你不认识这个编号的含义，但字母的字体极其工整，不像这座岛上的任何书写风格。你试着撬开旁边一块松动的混凝土板，发现下面压着一块巴掌大的金属铭牌，上面刻着：“普罗维登斯前哨站·北岸观测点”。',3,'第四纪元',78),(91,'2026-08-28 04:48:41.117673','地点描述：森林深处一座被藤蔓和苔藓完全覆盖的石塔，塔身高约十米，顶部已经坍塌，但底座依然完整。塔身由一种你从未见过的黑色石材砌成，表面没有任何缝隙，仿佛是一整块石头雕刻而成的。塔基周围散落着一些破碎的金属片，上面刻着复杂的电路图案。\n可获得物资：金属制品（50kg），煤油（30升）\n历史秘密碎片：你清理掉塔基上的苔藓，发现底座上刻着一行文字，用的是你熟悉的语言：“情绪共鸣塔 — 编号07 — 实验时代：第四纪元 末 — 功耗：已耗尽 — 功能：采集区域内情绪波动，转换为电能存储。”文字下方有一个小小的符号：一个圆圈，中间有一道竖线，像是一只简化的眼睛，但瞳孔是一条横线——与你在其他地方见过的“巨瞳”符号截然不同。你用手触摸塔身，感到一阵极其微弱的嗡嗡声，像是某种设备在休眠了数千年后，仍然在消耗着最后的能量。你突然意识到，这座塔不是岛上的镇民建造的——它来自一个更早的、更发达的文明时期。\n难度：20','低语之塔的底座','legendary',_binary '\0','2026-08-28 04:48:41.117675',20,_binary '','森林深处一座被藤蔓和苔藓完全覆盖的石塔，塔身高约十米，顶部已经坍塌，但底座依然完整。塔身由一种你从未见过的黑色石材砌成，表面没有任何缝隙，仿佛是一整块石头雕刻而成的。塔基周围散落着一些破碎的金属片，上面刻着复杂的电路图案。','你清理掉塔基上的苔藓，发现底座上刻着一行文字，用的是你熟悉的语言：“情绪共鸣塔 — 编号07 — 实验时代：第四纪元 末 — 功耗：已耗尽 — 功能：采集区域内情绪波动，转换为电能存储。”文字下方有一个小小的符号：一个圆圈，中间有一道竖线，像是一只简化的眼睛，但瞳孔是一条横线——与你在其他地方见过的“巨瞳”符号截然不同。你用手触摸塔身，感到一阵极其微弱的嗡嗡声，像是某种设备在休眠了数千年后，仍然在消耗着最后的能量。你突然意识到，这座塔不是岛上的镇民建造的——它来自一个更早的、更发达的文明时期。',3,'第四纪元',79),(92,'2026-08-28 04:48:41.121770','地点描述：矿场深处一条被冰封的巷道尽头，冰层中冻着一台巨大的机器——它看起来像是一台熔炉，但结构远比岛上任何熔炉复杂。机器的外壳由银灰色的金属制成，表面没有任何锈迹，甚至反射着微弱的光泽。机器内部空无一物，但炉膛的壁上刻着密密麻麻的刻度线和计算公式。\n可获得物资：金属制品（100kg），医疗资源（10份）\n历史秘密碎片：你费了很大力气才凿开冰层，靠近那台机器。在机器的侧面，你发现了一块固定的铭牌，上面用古英文刻着：“铁砧小队·熔炉单元·编号03 — 铸造完成：13枚锚点 — 工程师：卡尔·E·H。”铭牌下方有几行手写的字，刻在金属表面上，笔迹与铭牌上的印刷体截然不同：“我们把这台熔炉留在这里，不是为了后来者，而是为了提醒自己——我们曾经用这座岛上的石头，铸造过一些不该被铸造的东西。如果有一天有人找到了它，请把它拆了，或者把它炸了。不要再让它工作。”你注意到，手写字迹的最后一笔划得很深，几乎划穿了金属，仿佛刻字的人在写下这句话时，内心充满了愤怒或恐惧。\n难度：20','被冻结的“铁砧”','legendary',_binary '\0','2026-08-28 04:48:41.121773',20,_binary '','矿场深处一条被冰封的巷道尽头，冰层中冻着一台巨大的机器——它看起来像是一台熔炉，但结构远比岛上任何熔炉复杂。机器的外壳由银灰色的金属制成，表面没有任何锈迹，甚至反射着微弱的光泽。机器内部空无一物，但炉膛的壁上刻着密密麻麻的刻度线和计算公式。','你费了很大力气才凿开冰层，靠近那台机器。在机器的侧面，你发现了一块固定的铭牌，上面用古英文刻着：“铁砧小队·熔炉单元·编号03 — 铸造完成：13枚锚点 — 工程师：卡尔·E·H。”铭牌下方有几行手写的字，刻在金属表面上，笔迹与铭牌上的印刷体截然不同：“我们把这台熔炉留在这里，不是为了后来者，而是为了提醒自己——我们曾经用这座岛上的石头，铸造过一些不该被铸造的东西。如果有一天有人找到了它，请把它拆了，或者把它炸了。不要再让它工作。”你注意到，手写字迹的最后一笔划得很深，几乎划穿了金属，仿佛刻字的人在写下这句话时，内心充满了愤怒或恐惧。',3,'第四纪元',80),(93,'2026-08-28 04:48:41.125959','地点描述：码头附近一片被潮汐冲刷的沙滩上，你踢到了一枚半埋在沙子里的银币，表面已经严重氧化发黑，图案几乎无法辨认。但当你把它捡起来时，你发现它的重量和触感，与你之前见过的所有银币都不同——它更轻，边缘更锋利，而且没有衔尾蛇图案。\n可获得物资：银币（1枚），维修工具包（2个）\n历史秘密碎片：你用海水洗净了银币表面的污垢，勉强辨认出它的正面刻着一个图案——不是衔尾蛇，而是一个圆圈，中间有一道竖线，与你在情绪共鸣塔上见过的符号相同。背面刻着一行极小的数字：“SAMPLE-07-DATE-UNKNOWN”。银币的边缘有一圈齿纹，齿纹的间隙中隐约刻着一行文字，你需要用放大镜才能看清：“第一次实验：33枚信标，13枚锚点。第二次实验：无。第三次实验：无。实验终止。原因：——因果链条已闭环。”\n难度：18','海床边上的硬币','legendary',_binary '\0','2026-08-28 04:48:41.125962',18,_binary '\0','码头附近一片被潮汐冲刷的沙滩上，你踢到了一枚半埋在沙子里的银币，表面已经严重氧化发黑，图案几乎无法辨认。但当你把它捡起来时，你发现它的重量和触感，与你之前见过的所有银币都不同——它更轻，边缘更锋利，而且没有衔尾蛇图案。','你用海水洗净了银币表面的污垢，勉强辨认出它的正面刻着一个图案——不是衔尾蛇，而是一个圆圈，中间有一道竖线，与你在情绪共鸣塔上见过的符号相同。背面刻着一行极小的数字：“SAMPLE-07-DATE-UNKNOWN”。银币的边缘有一圈齿纹，齿纹的间隙中隐约刻着一行文字，你需要用放大镜才能看清：“第一次实验：33枚信标，13枚锚点。第二次实验：无。第三次实验：无。实验终止。原因：——因果链条已闭环。”',3,'第四纪元',81),(94,'2026-08-28 04:48:41.130638','地点描述：山顶一片被风雪削平的岩石平台上，散落着一些被冻裂的金属仪器和断掉的线缆。平台的中央，有一个被积雪覆盖的混凝土基座，基座上有一个被撬开的铁箱，箱内早已空无一物。但铁箱的箱盖内侧，贴着一张被胶带固定在铁皮上的纸条，已经发黄变脆。\n可获得物资：金属制品（30kg），手电筒（1个），飞机部件·油箱（1个）\n历史秘密碎片：你小心翼翼地撕下那张纸条，发现上面用铅笔写着几行工整的字，字迹清晰，像是某个技术人员留下的维护记录：“第四纪元，第31次例行检查。所有气象监测设备运行正常。地脉波动指数：正常偏高。今日观测到异常：地脉核心方向的‘心跳’信号频率加快，从每分钟4次增加到每分钟5次。已记录，上报。另：发现北岸基地废墟中有新的坍塌，可能是动物活动所致。建议下次派人检查。”\n难度：12','气象站的残骸','rare',_binary '\0','2026-08-28 04:48:41.130641',12,_binary '\0','山顶一片被风雪削平的岩石平台上，散落着一些被冻裂的金属仪器和断掉的线缆。平台的中央，有一个被积雪覆盖的混凝土基座，基座上有一个被撬开的铁箱，箱内早已空无一物。但铁箱的箱盖内侧，贴着一张被胶带固定在铁皮上的纸条，已经发黄变脆。','你小心翼翼地撕下那张纸条，发现上面用铅笔写着几行工整的字，字迹清晰，像是某个技术人员留下的维护记录：“第四纪元，第31次例行检查。所有气象监测设备运行正常。地脉波动指数：正常偏高。今日观测到异常：地脉核心方向的‘心跳’信号频率加快，从每分钟4次增加到每分钟5次。已记录，上报。另：发现北岸基地废墟中有新的坍塌，可能是动物活动所致。建议下次派人检查。”',3,'第四纪元',82),(95,'2026-08-28 04:48:41.135209','地点描述：码头下方最深处的淤泥中，你捞出了一个被油布层层包裹的铅盒，铅盒表面已经严重腐蚀，但密封性依然完好。你费力地撬开铅盒，发现里面整齐地叠放着一叠纸张，纸张的边缘已经发黄，但字迹大部分清晰可辨。纸张的装订线已经腐朽，但纸张本身质地坚韧，像是某种特殊的材料。\n可获得物资：铁砧小队·记录员莉迪亚的私人笔记（残卷），刺刀（2把）\n历史秘密碎片：你翻开笔记，发现里面记录的内容大多是科学数据和实验日志，但偶尔夹杂着一些个人感受。你找到了一段被铅笔圈起来的文字：“今天艾琳问我，为什么要保留这些记录。我说，因为如果有一天我们失败了，至少有人知道我们做过什么。艾琳说，也许他们不需要知道。我说，也许他们需要。”另一段文字写道：“队长说，我们在这座岛上留下的东西，可能会被后来者误解。我说，误解总比遗忘好。队长没有回答。”笔记的最后一页，只有一句话，字迹潦草，像是匆忙写下的：“我们以为我们在观察这座岛，实际上，这座岛也在观察我们。”你合上笔记，感到一种难以言喻的沉重——这些文字来自一个遥远的、不属于这个时代的观察者，而他们留下的，不仅仅是科技，还有对这座岛的困惑与敬畏。\n难度：18','密封的铅盒','legendary',_binary '\0','2026-08-28 04:48:41.135211',18,_binary '\0','码头下方最深处的淤泥中，你捞出了一个被油布层层包裹的铅盒，铅盒表面已经严重腐蚀，但密封性依然完好。你费力地撬开铅盒，发现里面整齐地叠放着一叠纸张，纸张的边缘已经发黄，但字迹大部分清晰可辨。纸张的装订线已经腐朽，但纸张本身质地坚韧，像是某种特殊的材料。','你翻开笔记，发现里面记录的内容大多是科学数据和实验日志，但偶尔夹杂着一些个人感受。你找到了一段被铅笔圈起来的文字：“今天艾琳问我，为什么要保留这些记录。我说，因为如果有一天我们失败了，至少有人知道我们做过什么。艾琳说，也许他们不需要知道。我说，也许他们需要。”另一段文字写道：“队长说，我们在这座岛上留下的东西，可能会被后来者误解。我说，误解总比遗忘好。队长没有回答。”笔记的最后一页，只有一句话，字迹潦草，像是匆忙写下的：“我们以为我们在观察这座岛，实际上，这座岛也在观察我们。”你合上笔记，感到一种难以言喻的沉重——这些文字来自一个遥远的、不属于这个时代的观察者，而他们留下的，不仅仅是科技，还有对这座岛的困惑与敬畏。',3,'第四纪元',84),(96,'2026-08-28 04:48:41.138298','地点描述：矿场深处一个被塌方掩埋了数百年的地下工坊，入口隐藏在一面伪装成天然岩壁的铁门后。工坊内有一座熄灭多年的熔炉，炉膛中残留着黑色的矿渣，空气中弥漫着铁锈与焦糊味。墙壁上挂满了锈蚀的锤子和钳子，工具架上积着厚厚的灰尘。祭坛石已嵌入地面，需用十字镐撬出。\n可获得物资：金属制品（100kg），蜡烛（10支），祭坛石（1枚）\n历史秘密碎片：你在工坊操作台的暗格中发现了一本用油布包裹的皮面笔记，扉页上写着：“锻炉·记录第十三枚。”笔记中记载了铸造祭坛石的过程：“黑石从地脉深处采出，必须在炉中烧足七日，让石头的温度与心跳一致。我敲了十三枚，每一枚都有自己的声音。第十三枚的声音最沉，像门在叹息。”\n特殊：是\n难度：20','隐秘居所·沉没工坊','legendary',_binary '\0','2026-08-28 04:48:41.138300',20,_binary '','矿场深处一个被塌方掩埋了数百年的地下工坊，入口隐藏在一面伪装成天然岩壁的铁门后。工坊内有一座熄灭多年的熔炉，炉膛中残留着黑色的矿渣，空气中弥漫着铁锈与焦糊味。墙壁上挂满了锈蚀的锤子和钳子，工具架上积着厚厚的灰尘。祭坛石已嵌入地面，需用十字镐撬出。','你在工坊操作台的暗格中发现了一本用油布包裹的皮面笔记，扉页上写着：“锻炉·记录第十三枚。”笔记中记载了铸造祭坛石的过程：“黑石从地脉深处采出，必须在炉中烧足七日，让石头的温度与心跳一致。我敲了十三枚，每一枚都有自己的声音。第十三枚的声音最沉，像门在叹息。”',4,'隐秘居所',85),(97,'2026-08-28 04:48:41.142613','地点描述：一处被永冻冰层覆盖的山谷腹地，中央矗立着一座由黑色冰块和兽骨搭建的祭坛，周围散落着数十根冻裂的蜡烛，蜡泪凝固成扭曲的冰柱。祭坛表面刻满了逆五芒星和古文字，空气中弥漫着刺骨的寒意，即使穿着最厚的皮毛也无法抵御。\n可获得物资：蜡烛（20支），黑祭·灾厄降临记物\n历史秘密碎片：你在祭坛的基座下挖出一块冰封的皮革，展开后是一封用血写成的信，落款为“霜”——信中写道：“古老的血脉在寒冷中哭泣，我们以为那是力量。我们引导它，喂养它，让冬天成为周期。但当我们终于发现门后的东西时，它已经太胖了，胖到无法被塞回门缝。后来者，不要重复我们的错误——寒冷不是力量，是饥饿。”信的边缘结着厚厚的冰霜，你用体温融化它时，血字开始褪色，仿佛写这封信的人正在用最后的意志抹去自己的罪证。\n特殊：是\n难度：20','隐秘居所·祭坛','legendary',_binary '\0','2026-08-28 04:48:41.142615',20,_binary '','一处被永冻冰层覆盖的山谷腹地，中央矗立着一座由黑色冰块和兽骨搭建的祭坛，周围散落着数十根冻裂的蜡烛，蜡泪凝固成扭曲的冰柱。祭坛表面刻满了逆五芒星和古文字，空气中弥漫着刺骨的寒意，即使穿着最厚的皮毛也无法抵御。','你在祭坛的基座下挖出一块冰封的皮革，展开后是一封用血写成的信，落款为“霜”——信中写道：“古老的血脉在寒冷中哭泣，我们以为那是力量。我们引导它，喂养它，让冬天成为周期。但当我们终于发现门后的东西时，它已经太胖了，胖到无法被塞回门缝。后来者，不要重复我们的错误——寒冷不是力量，是饥饿。”信的边缘结着厚厚的冰霜，你用体温融化它时，血字开始褪色，仿佛写这封信的人正在用最后的意志抹去自己的罪证。',4,'隐秘居所',86),(98,'2026-08-28 04:48:41.147691','地点描述：一个被石笋和藤蔓掩盖的天然洞穴，洞口长满发光的苔藓。洞内空间不大，但异常干燥，中央有一张石桌和一把石椅，桌上摊开放着一本翻开的笔记，旁边散落着几支用秃的炭笔和一盏早已干涸的油灯。石壁上刻满了密密麻麻的算式和符号，看起来像是某种计算。\n可获得物资：蜡烛（10支），命运之轮·星轨逆转记物，灵魂摆渡·亡者回响记物\n历史秘密碎片：你蹲在石板上，用手擦拭掉表面的灰尘。同心圆最外圈刻着一行文字，但不是你认识的任何一种语言。你试图用手指描摹那些符文的形状，指尖传来一阵微弱的刺痛，像是被静电击中。你感到一种奇怪的熟悉感——仿佛这些符号曾经在你的梦中出现过，但你无法回忆起任何具体的画面。石板的边缘有一处被凿过的痕迹，似乎有人曾经试图破坏它，但没有成功。你注意到，凹槽内侧有一道细长的划痕，像是有人用指甲用力刻下的，形状像是一个箭头，指向洞穴的更深处——但那里只有一片黑暗，什么也看不见。\n特殊：是\n难度：20','隐秘居所·天然洞穴','legendary',_binary '\0','2026-08-28 04:48:41.147693',20,_binary '','一个被石笋和藤蔓掩盖的天然洞穴，洞口长满发光的苔藓。洞内空间不大，但异常干燥，中央有一张石桌和一把石椅，桌上摊开放着一本翻开的笔记，旁边散落着几支用秃的炭笔和一盏早已干涸的油灯。石壁上刻满了密密麻麻的算式和符号，看起来像是某种计算。','你蹲在石板上，用手擦拭掉表面的灰尘。同心圆最外圈刻着一行文字，但不是你认识的任何一种语言。你试图用手指描摹那些符文的形状，指尖传来一阵微弱的刺痛，像是被静电击中。你感到一种奇怪的熟悉感——仿佛这些符号曾经在你的梦中出现过，但你无法回忆起任何具体的画面。石板的边缘有一处被凿过的痕迹，似乎有人曾经试图破坏它，但没有成功。你注意到，凹槽内侧有一道细长的划痕，像是有人用指甲用力刻下的，形状像是一个箭头，指向洞穴的更深处——但那里只有一片黑暗，什么也看不见。',4,'隐秘居所',87),(99,'2026-08-28 04:48:41.152117','地点描述：码头下方一个被潮汐淹没又露出的地下密室，入口被一块刻着衔尾蛇的铸铁板封住，需要撬开锈蚀的锁链才能进入。密室内部陈设简陋，只有一张工作台、一架小型熔炉和一堆风化的模具。角落里堆着几十枚银币的胚料，表面已经氧化发黑。\n可获得物资：银币（1枚），金属制品（20kg）\n历史秘密碎片：你在工作台的抽屉里发现了一张被折叠多次的纸条，纸质粗糙，边缘已经破损。纸条上只有几行字，字迹潦草，像是匆忙写下的：“第十三枚铸完时，熔炉自己熄了。不是没有燃料，是火不想再烧了。我把它埋在码头下，如果你找到了它，别声张——有些东西，知道的人越少越好。”纸条背面没有署名，也没有日期。但你注意到，纸张的边缘有一道被烧过的焦痕，像是有人试图烧掉它，又在中途改变了主意。\n特殊：是\n难度：15','隐秘居所·铸币人的密室','epic',_binary '\0','2026-08-28 04:48:41.152119',15,_binary '','码头下方一个被潮汐淹没又露出的地下密室，入口被一块刻着衔尾蛇的铸铁板封住，需要撬开锈蚀的锁链才能进入。密室内部陈设简陋，只有一张工作台、一架小型熔炉和一堆风化的模具。角落里堆着几十枚银币的胚料，表面已经氧化发黑。','你在工作台的抽屉里发现了一张被折叠多次的纸条，纸质粗糙，边缘已经破损。纸条上只有几行字，字迹潦草，像是匆忙写下的：“第十三枚铸完时，熔炉自己熄了。不是没有燃料，是火不想再烧了。我把它埋在码头下，如果你找到了它，别声张——有些东西，知道的人越少越好。”纸条背面没有署名，也没有日期。但你注意到，纸张的边缘有一道被烧过的焦痕，像是有人试图烧掉它，又在中途改变了主意。',4,'隐秘居所',88),(100,'2026-08-28 04:48:41.156699','地点描述：岛屿东北侧一处被瀑布遮掩的洞穴，水流在冬季冻结成冰帘，形成天然的门。洞穴内部宽阔，墙壁上布满用矿物颜料绘制的壁画，描绘着第一批原住民跪坐在一团发光的地脉核心前聆听的场景。洞穴中央的地面上嵌着一块光滑的黑色石板，石板上刻着三个同心圆，圆心处有一个凹槽，正好可以嵌入一枚祭坛石。祭坛石已嵌入地面，需用十字镐撬出。\n可获得物资：草药（10单位），祭坛石（1枚）\n历史秘密碎片：你蹲在石板上，用手擦拭掉表面的灰尘，发现同心圆最外圈刻着一行用古文字写成的句子。你不认识这种文字，但你手中的祭坛石微微发热，仿佛在替你翻译。你感到脑海中浮现出一句话：“我们跪了一千年，才学会聆听。地脉不说话，它只是呼吸。我们让自己成为它呼吸的一部分，于是我们不再是人。但这是我们自己的选择——如果你不想成为石头，就不要在凹槽中放入任何东西。一旦放入，你将永远无法离开这间屋子。”你感到脚下的石板正在随着洞穴深处某种规律的脉冲轻轻震动，像心跳，也像呼吸。\n特殊：是\n难度：18','隐秘居所·初聆洞穴','legendary',_binary '\0','2026-08-28 04:48:41.156702',18,_binary '','岛屿东北侧一处被瀑布遮掩的洞穴，水流在冬季冻结成冰帘，形成天然的门。洞穴内部宽阔，墙壁上布满用矿物颜料绘制的壁画，描绘着第一批原住民跪坐在一团发光的地脉核心前聆听的场景。洞穴中央的地面上嵌着一块光滑的黑色石板，石板上刻着三个同心圆，圆心处有一个凹槽，正好可以嵌入一枚祭坛石。祭坛石已嵌入地面，需用十字镐撬出。','你蹲在石板上，用手擦拭掉表面的灰尘，发现同心圆最外圈刻着一行用古文字写成的句子。你不认识这种文字，但你手中的祭坛石微微发热，仿佛在替你翻译。你感到脑海中浮现出一句话：“我们跪了一千年，才学会聆听。地脉不说话，它只是呼吸。我们让自己成为它呼吸的一部分，于是我们不再是人。但这是我们自己的选择——如果你不想成为石头，就不要在凹槽中放入任何东西。一旦放入，你将永远无法离开这间屋子。”你感到脚下的石板正在随着洞穴深处某种规律的脉冲轻轻震动，像心跳，也像呼吸。',4,'隐秘居所',89);
/*!40000 ALTER TABLE `island_event` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `island_event_reward`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `island_event_reward` (
  `id` int NOT NULL AUTO_INCREMENT,
  `condition_desc` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `event_id` int NOT NULL,
  `item_id` int NOT NULL,
  `item_type` varchar(20) NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=518 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `island_event_reward` WRITE;
/*!40000 ALTER TABLE `island_event_reward` DISABLE KEYS */;
INSERT INTO `island_event_reward` VALUES (187,NULL,'2026-08-28 04:48:41.135922',95,4,'weapon',2),(359,NULL,'2026-08-28 04:50:10.571762',17,3,'material',10),(360,NULL,'2026-08-28 04:50:10.578231',17,25,'item',1),(361,NULL,'2026-08-28 04:50:10.590851',18,1,'material',5),(362,NULL,'2026-08-28 04:50:10.591825',18,7,'weapon',1),(363,NULL,'2026-08-28 04:50:10.598809',19,5,'material',8),(364,NULL,'2026-08-28 04:50:10.600028',19,9,'material',2),(365,NULL,'2026-08-28 04:50:10.606951',20,1,'item',5),(366,NULL,'2026-08-28 04:50:10.607797',20,8,'material',2),(367,NULL,'2026-08-28 04:50:10.616080',21,2,'material',5000),(368,NULL,'2026-08-28 04:50:10.617156',21,1,'material',3000),(369,NULL,'2026-08-28 04:50:10.617978',21,8,'material',2),(370,NULL,'2026-08-28 04:50:10.629119',23,1,'material',8),(371,NULL,'2026-08-28 04:50:10.629884',23,2,'material',5000),(372,NULL,'2026-08-28 04:50:10.636190',24,2,'material',5000),(373,NULL,'2026-08-28 04:50:10.641357',25,2,'ammo',4),(374,NULL,'2026-08-28 04:50:10.642162',25,7,'item',1),(375,NULL,'2026-08-28 04:50:10.648093',26,1,'item',10),(376,NULL,'2026-08-28 04:50:10.648877',26,2,'item',1),(377,NULL,'2026-08-28 04:50:10.655372',27,1,'material',1000),(378,NULL,'2026-08-28 04:50:10.656104',27,8,'material',5),(379,NULL,'2026-08-28 04:50:10.662870',28,5,'material',5),(380,NULL,'2026-08-28 04:50:10.663603',28,3,'material',5),(381,NULL,'2026-08-28 04:50:10.673605',30,1,'material',10),(382,NULL,'2026-08-28 04:50:10.679851',31,1,'material',1000),(383,NULL,'2026-08-28 04:50:10.680584',31,8,'material',8),(384,NULL,'2026-08-28 04:50:10.681215',31,3,'material',5),(385,NULL,'2026-08-28 04:50:10.687975',32,2,'material',10000),(386,NULL,'2026-08-28 04:50:10.688655',32,6,'material',10),(387,NULL,'2026-08-28 04:50:10.695110',33,6,'material',10),(388,NULL,'2026-08-28 04:50:10.695883',33,9,'material',3),(389,NULL,'2026-08-28 04:50:10.696506',33,3,'material',5),(390,NULL,'2026-08-28 04:50:10.703552',34,10,'item',3),(391,NULL,'2026-08-28 04:50:10.704239',34,6,'weapon',1),(392,NULL,'2026-08-28 04:50:10.710127',35,1,'item',20),(393,NULL,'2026-08-28 04:50:10.715511',36,8,'item',1),(394,NULL,'2026-08-28 04:50:10.721362',37,1,'item',10),(395,NULL,'2026-08-28 04:50:10.722018',37,8,'material',5),(396,NULL,'2026-08-28 04:50:10.728611',38,2,'material',2000),(397,NULL,'2026-08-28 04:50:10.729337',38,8,'material',2),(398,NULL,'2026-08-28 04:50:10.730006',38,15,'item',3),(399,NULL,'2026-08-28 04:50:10.736378',39,11,'item',4),(400,NULL,'2026-08-28 04:50:10.737038',39,13,'item',5),(401,NULL,'2026-08-28 04:50:10.743503',40,1,'material',20),(402,NULL,'2026-08-28 04:50:10.744276',40,3,'material',8),(403,NULL,'2026-08-28 04:50:10.744949',40,12,'item',1),(404,NULL,'2026-08-28 04:50:10.751200',41,5,'material',5),(405,NULL,'2026-08-28 04:50:10.751934',41,1,'item',20),(406,NULL,'2026-08-28 04:50:10.757458',42,2,'material',1000),(407,NULL,'2026-08-28 04:50:10.758225',42,9,'material',2),(408,NULL,'2026-08-28 04:50:10.764039',43,16,'item',3),(409,NULL,'2026-08-28 04:50:10.769446',44,7,'material',10000),(410,NULL,'2026-08-28 04:50:10.775170',45,1,'material',50),(411,NULL,'2026-08-28 04:50:10.775949',45,2,'material',3000),(412,NULL,'2026-08-28 04:50:10.782314',46,1,'material',8000),(413,NULL,'2026-08-28 04:50:10.783173',46,8,'material',12),(414,NULL,'2026-08-28 04:50:10.783996',46,10,'material',1),(415,NULL,'2026-08-28 04:50:10.790299',47,2,'ammo',4),(416,NULL,'2026-08-28 04:50:10.791327',47,5,'material',6),(417,NULL,'2026-08-28 04:50:10.792042',47,2,'weapon',1),(418,NULL,'2026-08-28 04:50:10.798392',48,1,'material',5000),(419,NULL,'2026-08-28 04:50:10.799120',48,2,'item',1),(420,NULL,'2026-08-28 04:50:10.810044',49,3,'material',30),(421,NULL,'2026-08-28 04:50:10.810766',49,1,'item',3),(422,NULL,'2026-08-28 04:50:10.817130',50,8,'item',1),(423,NULL,'2026-08-28 04:50:10.817905',50,25,'item',2),(424,NULL,'2026-08-28 04:50:10.823983',51,1,'material',1000),(425,NULL,'2026-08-28 04:50:10.824757',51,8,'material',1000),(426,NULL,'2026-08-28 04:50:10.831074',52,2,'material',2000),(427,NULL,'2026-08-28 04:50:10.831787',52,6,'material',5),(428,NULL,'2026-08-28 04:50:10.838130',53,1,'item',10),(429,NULL,'2026-08-28 04:50:10.838786',53,5,'material',5),(430,NULL,'2026-08-28 04:50:10.845318',54,10,'item',2),(431,NULL,'2026-08-28 04:50:10.851790',55,6,'weapon',1),(432,NULL,'2026-08-28 04:50:10.852619',55,9,'item',1),(433,NULL,'2026-08-28 04:50:10.859134',56,5,'material',3),(434,NULL,'2026-08-28 04:50:10.859930',56,11,'item',3),(435,NULL,'2026-08-28 04:50:10.866656',57,3,'material',6),(436,NULL,'2026-08-28 04:50:10.867798',57,1,'material',50),(437,NULL,'2026-08-28 04:50:10.874147',58,1,'material',200),(438,NULL,'2026-08-28 04:50:10.874991',58,3,'material',12),(439,NULL,'2026-08-28 04:50:10.875731',58,8,'material',4),(440,NULL,'2026-08-28 04:50:10.882550',67,8,'material',3),(441,NULL,'2026-08-28 04:50:10.883376',67,25,'item',2),(442,NULL,'2026-08-28 04:50:10.891953',59,1,'item',40),(443,NULL,'2026-08-28 04:50:10.892670',59,10,'item',1),(444,NULL,'2026-08-28 04:50:10.899121',60,1,'material',50),(445,NULL,'2026-08-28 04:50:10.899941',60,8,'item',1),(446,NULL,'2026-08-28 04:50:10.905664',61,9,'material',3),(447,NULL,'2026-08-28 04:50:10.906210',61,3,'material',12),(448,NULL,'2026-08-28 04:50:10.911321',62,1,'item',2),(449,NULL,'2026-08-28 04:50:10.916338',63,5,'material',5),(450,NULL,'2026-08-28 04:50:10.916983',63,2,'material',1000),(451,NULL,'2026-08-28 04:50:10.922079',68,1,'material',200),(452,NULL,'2026-08-28 04:50:10.922628',68,8,'material',6),(453,NULL,'2026-08-28 04:50:10.927839',69,9,'material',2),(454,NULL,'2026-08-28 04:50:10.928494',69,3,'material',10),(455,NULL,'2026-08-28 04:50:10.933978',64,1,'material',30),(456,NULL,'2026-08-28 04:50:10.934642',64,15,'item',5),(457,NULL,'2026-08-28 04:50:10.939706',65,11,'item',8),(458,NULL,'2026-08-28 04:50:10.944687',70,1,'item',30),(459,NULL,'2026-08-28 04:50:10.945290',70,8,'weapon',1),(460,NULL,'2026-08-28 04:50:10.950894',66,1,'material',100),(461,NULL,'2026-08-28 04:50:10.951531',66,3,'material',8),(462,NULL,'2026-08-28 04:50:10.956646',71,2,'material',5000),(463,NULL,'2026-08-28 04:50:10.957220',71,3,'material',6),(464,NULL,'2026-08-28 04:50:10.962479',72,8,'material',5),(465,NULL,'2026-08-28 04:50:10.963080',72,9,'item',1),(466,NULL,'2026-08-28 04:50:10.968814',73,2,'material',1000),(467,NULL,'2026-08-28 04:50:10.969524',73,41,'item',1),(468,NULL,'2026-08-28 04:50:10.974835',74,1,'material',30),(469,NULL,'2026-08-28 04:50:10.975405',74,8,'weapon',1),(470,NULL,'2026-08-28 04:50:10.980867',75,5,'material',10),(471,NULL,'2026-08-28 04:50:10.981436',75,14,'item',10),(472,NULL,'2026-08-28 04:50:10.987567',76,1,'material',10),(473,NULL,'2026-08-28 04:50:10.988171',76,3,'material',10),(474,NULL,'2026-08-28 04:50:10.993469',77,2,'material',1000),(475,NULL,'2026-08-28 04:50:10.994109',77,13,'item',10),(476,NULL,'2026-08-28 04:50:10.999728',78,1,'material',50),(477,NULL,'2026-08-28 04:50:11.005142',79,14,'item',10),(478,NULL,'2026-08-28 04:50:11.010491',80,25,'item',1),(479,NULL,'2026-08-28 04:50:11.011159',80,5,'material',5),(480,NULL,'2026-08-28 04:50:11.016945',81,2,'material',1000),(481,NULL,'2026-08-28 04:50:11.017612',81,14,'item',10),(482,NULL,'2026-08-28 04:50:11.018145',81,54,'item',1),(483,NULL,'2026-08-28 04:50:11.023721',82,8,'material',50),(484,NULL,'2026-08-28 04:50:11.029292',83,11,'item',10),(485,NULL,'2026-08-28 04:50:11.029875',83,5,'material',10),(486,NULL,'2026-08-28 04:50:11.036868',84,3,'material',20),(487,NULL,'2026-08-28 04:50:11.037567',84,50,'item',1),(488,NULL,'2026-08-28 04:50:11.047222',86,13,'item',10),(489,NULL,'2026-08-28 04:50:11.047804',86,1,'item',10),(490,NULL,'2026-08-28 04:50:11.053653',87,11,'item',10),(491,NULL,'2026-08-28 04:50:11.059089',88,1,'material',50),(492,NULL,'2026-08-28 04:50:11.059760',88,8,'material',10),(493,NULL,'2026-08-28 04:50:11.065727',89,2,'material',2000),(494,NULL,'2026-08-28 04:50:11.066437',89,5,'material',5),(495,NULL,'2026-08-28 04:50:11.072408',90,1,'material',50),(496,NULL,'2026-08-28 04:50:11.072998',90,4,'weapon',1),(497,NULL,'2026-08-28 04:50:11.078994',91,1,'material',50),(498,NULL,'2026-08-28 04:50:11.079791',91,8,'material',30),(499,NULL,'2026-08-28 04:50:11.085708',92,1,'material',100),(500,NULL,'2026-08-28 04:50:11.086295',92,1,'item',10),(501,NULL,'2026-08-28 04:50:11.091830',93,50,'item',1),(502,NULL,'2026-08-28 04:50:11.092446',93,8,'item',2),(503,NULL,'2026-08-28 04:50:11.098144',94,1,'material',30),(504,NULL,'2026-08-28 04:50:11.098720',94,2,'item',1),(505,NULL,'2026-08-28 04:50:11.099228',94,40,'item',1),(506,NULL,'2026-08-28 04:50:11.108978',96,1,'material',100),(507,NULL,'2026-08-28 04:50:11.109614',96,13,'item',10),(508,NULL,'2026-08-28 04:50:11.110164',96,27,'item',1),(509,NULL,'2026-08-28 04:50:11.116400',97,13,'item',20),(510,NULL,'2026-08-28 04:50:11.117100',97,34,'item',1),(511,NULL,'2026-08-28 04:50:11.122567',98,13,'item',10),(512,NULL,'2026-08-28 04:50:11.123065',98,36,'item',1),(513,NULL,'2026-08-28 04:50:11.123597',98,35,'item',1),(514,NULL,'2026-08-28 04:50:11.129677',99,50,'item',1),(515,NULL,'2026-08-28 04:50:11.130231',99,1,'material',20),(516,NULL,'2026-08-28 04:50:11.136196',100,11,'item',10),(517,NULL,'2026-08-28 04:50:11.136757',100,27,'item',1);
/*!40000 ALTER TABLE `island_event_reward` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `item` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `remark` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tradable` tinyint(1) NOT NULL DEFAULT '1',
  `tag` varchar(100) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `item` WRITE;
/*!40000 ALTER TABLE `item` DISABLE KEYS */;
INSERT INTO `item` VALUES (1,'医疗资源','份','基础医疗物资，急救重伤需5份','2026-04-27 11:36:23','2026-08-27 13:48:42',1,NULL,NULL),(2,'手电筒','个','金属外壳的便携照明工具，使用煤油或电池。夜间行动的基础工具。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(3,'手铐','个','铁制约束器具，可将一名无反抗能力的玩家束缚。被束缚者无法进行大部分行动，直到被释放。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(4,'哨子','个','铜制哨子，声音尖锐可传遍全岛。吹响后会在公屏显示哨音，可用于报警或召集同伴。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(5,'防弹衣','件','复合金属材质制成的防护背心。在暴力冲突中可将一次「重伤」降级为「受伤」，或将一次「受伤」无效化，每场冲突限用一次。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(6,'复合盾','个','轻质金属与帆布复合的防暴盾牌。一次「受伤」无效化，每场冲突限用一次。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(7,'信号枪','把','维里式单发信号枪，可发射彩色信号弹。发射后由主持人在公屏展示信号内容（不超过5个字），可用于求援或传递简单信息。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(8,'维修工具包','个','内含基础维修工具。每包提供10点维修资源，可修复损坏的机械或设施。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(9,'协议书','个','带法律效力的空白契约纸。玩家之间可自行签订契约协议，用协议书签订的协议不公开契约信息。违约将受到约定惩罚。每名玩家每天最多成为契约者一次。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(10,'朗姆酒','瓶','甘蔗酿造的烈酒，酒精度约40%。5瓶朗姆酒可以消除疲劳。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(11,'草药','个','岛上采集的药用植物，经干燥处理后保存。可用于简易治疗，等于3医疗资源。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(12,'渔网','张','麻绳编织的捕鱼网具。渔民可用其与渔船一起进行渔猎行动。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(13,'蜡烛','根','动物油脂或蜂蜡制成的照明物。提供基础夜间照明，比煤油更安静但亮度较低。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(14,'医用酒精','升','75%浓度的消毒酒精，每升可用于提供5点医疗资源。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(15,'火柴','盒','防水密封包装的火柴，每盒约50根。生火做饭、点灯取暖的基础消耗品。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(16,'铅笔','盒','木质铅笔。可用于书写信件、记录信息或绘制简易地图。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(17,'破损海图','张','年代久远的航海图，部分区域已损毁或褪色。仍可辨认大致航线与岛屿位置，是远洋航行的重要参考。','2026-04-27 11:36:23','2026-04-27 11:36:23',1,NULL,NULL),(18,'面包','份','面包师精心制作的便携餐食，松松软软量大管饱，营养均衡且便于携带。食用后可获得额外1个白天行动点，每人每天限吃一份。可以储存和交易，是后期高密度行动的重要战略资源。面包本身不提供热量，其核心价值在于让人挤出更多时间做事，而非填饱肚子。','2026-04-27 11:36:23','2026-05-02 19:26:21',1,NULL,NULL),(19,'矿场仓库钥匙','把','矿场仓库通行','2026-05-14 21:23:51','2026-05-17 00:00:00',1,NULL,NULL),(20,'燃料仓库钥匙','把','燃料仓库通行','2026-05-14 21:24:04','2026-05-14 21:24:22',1,NULL,NULL),(21,'镇武库钥匙','把','镇武库通行','2026-05-14 21:24:57','2026-05-14 21:24:57',1,NULL,NULL),(22,'码头集换站钥匙','把','码头集购站通行','2026-05-14 21:25:32','2026-05-14 21:25:32',1,NULL,NULL),(23,'反叛者基地钥匙','把','反叛者的物资基地','2026-05-14 21:26:03','2026-05-14 21:26:03',1,NULL,NULL),(24,'方舟钥匙','把','冒险者的物资基地','2026-05-14 21:32:41','2026-05-14 21:34:36',1,NULL,NULL),(25,'火把','把','手工艺人的产出物品，配合每个人都有的火柴可以用来夜间照明并取暖。亦可作为探索道具（+7探索值）。','2026-06-24 19:16:52','2026-06-24 19:16:52',1,NULL,NULL),(26,'诅咒硬币','个','绘制着蛇眼的硬币，无法丢弃','2026-06-24 22:31:35','2026-06-24 22:31:35',1,NULL,NULL),(27,'祭坛石','枚','地脉核心的封印碎片。持有即可产生地脉共鸣。可花费1次快速行动：将任意10单位资源（食物、燃料、木材、金属）转换为等量另一种资源；或为当前所在地点增加2点防御值。亦可作为仪式材料消耗1～3枚。原住民初始持有的祭坛石绑定个人仓库：不可被偷盗或被得知拥有，可交易或赠送。全游戏约5～7枚（26人5枚）。','2026-08-27 13:48:40','2026-08-27 13:50:10',1,NULL,NULL),(28,'通灵笔记','本','一本古旧的笔记，最后一页空白。据说拥有者可以借助它举行某种仪式。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(29,'发光矿石碎片','枚','一块发出微弱脉动光的矿石碎片，可作为信物使用。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(30,'鱼鳞外套','件','一件覆盖细密鳞片的外套。每天一次可作为防弹衣效果。不可交易，不可被偷盗或任何方式被得知拥有。','2026-08-27 13:48:40','2026-08-27 13:50:10',0,NULL,NULL),(31,'契约铁卷','卷','一卷用铁片串成的册子，记载着某种古老契约的完整条款。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(32,'革命宣言','份','一份用铅笔写在旧报纸边缘的宣言，字迹潦草但充满力量。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(33,'古老龙骨图','卷','一卷发黄的羊皮纸，画着龙骨结构图，关键节点标注了奇怪的符文。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(34,'灰烬预言书','本','一本被烧过但依然可读的皮面书，书页边缘焦黑，核心内容完整。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(35,'人皮册子残页','页','装订怪异的册子残页，大部分已腐烂，记载着某种禁忌的内容。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(36,'星象观测手稿','份','一叠详细记录星轨与星象的手稿，出自五十年前的一位灯塔看守之手。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(37,'尸油蜡烛','支','特制的蜡烛，燃烧时散发奇异的气味。据说是某些仪式的必需品。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(38,'深海鱼油蜡烛','支','以深海鱼油制成的蜡烛，点燃后火焰呈幽蓝色。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(39,'旧地图','张','一张残旧的地图，标注着某个地点的大致位置。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(40,'飞机部件·油箱','个','飞机用金属油箱，保存完好，可以安装使用。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(41,'飞机部件·起落架','个','飞机起落架组件，结构完整，可以安装使用。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(42,'笔记本','本','一本可以书写记录的笔记本，初始5页。不可交易。','2026-08-27 13:48:40','2026-08-27 13:48:40',0,NULL,NULL),(43,'钢笔','支','一支可以正常书写的钢笔。不可交易。','2026-08-27 13:48:40','2026-08-27 13:48:40',0,NULL,NULL),(44,'归墟罗盘','个','一枚刻满螺旋纹路的青铜盘，中心嵌着一颗永不下沉的黑色石子。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(45,'龙骨刻刀','把','一把由鲸骨打磨成的刻刀，刀柄镶嵌着一颗已石化的鱼眼珠。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(46,'灾厄之眼','枚','一枚黑色玻璃球，内部有不断旋转的暗红色雾气。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(47,'引魂烛台','座','一座三足青铜烛台，底座刻着扭曲的符文。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(48,'星轨轮盘','个','一个用黑曜石磨成的圆盘，表面刻着黄道十二宫符号，中心有一处凹槽。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(49,'烬火旗','面','一面被烧得只剩一半的旗帜，无论如何烧都不会彻底化为灰烬。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(50,'银币','枚','一枚刻着衔尾蛇图案的旧银币，握在手中有刺骨的凉意。据说银币不属于活人。','2026-08-27 13:48:40','2026-08-27 13:48:40',1,NULL,NULL),(51,'情绪抑制器','个','半头盔式银灰色合金装置，内衬黑色织物。侧面按钮与指示灯大多熄灭，一颗暗红色灯缓慢闪烁。内侧绣着「铁砧小队·标准配置·情绪抑制模块·型号MK-II」。装备后获得「情绪抑制」状态，持续到持有者主动解除或装备损坏。后续部分清醒仪式以此为源头，是保持清醒的原因之一。','2026-08-27 13:48:40','2026-08-27 13:50:10',1,NULL,NULL),(52,'共鸣石','枚','婴儿拳头大小深灰色卵石，握紧有节律震动，一端金属接口刻「白鸥小队·共鸣石·编号04」。消耗1次快速行动感知半径约200米内是否存在地脉异常点（祭坛石、地脉核心、仪式进行地点等：只告知有/无，不给位置）。每2天一次；用后眩晕耳鸣约半小时，期间检定-1。夜晚闭眼使用可能看见不属于这个时代的残片（白鸥小队「回声」残留），并获得持续1天的轻微「潮汐症」。','2026-08-27 13:48:40','2026-08-27 13:50:10',1,NULL,NULL),(53,'铁砧小队·记录员莉迪亚的私人笔记（残卷）','份','铁砧小队记录员莉迪亚留下的残卷笔记。夹杂实验日志与个人感受：艾琳问为何保留记录，她说失败后至少有人知道他们做过什么；队长担心后来者误解，她答误解总比遗忘好。最后一页写道：我们以为在观察这座岛，实际上这座岛也在观察我们。','2026-08-27 13:48:40','2026-08-27 13:50:10',1,NULL,NULL),(54,'飞机部件·副驾座','个','飞机副驾驶座组件，结构完整，可以安装使用。','2026-08-27 13:48:40','2026-08-27 13:50:10',1,NULL,NULL),(55,'避难所钥匙','把','开启避难所仓库的钥匙。持有者可像其它仓库一样搬入、搬出物资。','2026-08-27 13:48:40','2026-08-27 13:50:10',1,NULL,NULL);
/*!40000 ALTER TABLE `item` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `skills` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `description` text,
  `hidden` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `job` WRITE;
/*!40000 ALTER TABLE `job` DISABLE KEYS */;
INSERT INTO `job` VALUES (1,'镇长','射击','2026-04-26 22:13:35','2026-06-26 13:07:17','射击——在密谋，暴力冲突中，如装备远距离武器时增加1威胁值。如果没有射击，装备远距离武器时，武器威胁值减半，向下取整。',0),(2,'监狱长','格斗,急救','2026-04-26 22:13:35','2026-06-26 13:07:44','格斗——在密谋，暴力冲突中，如果没有装备，或者装备近距离武器，增加1威胁值。急救：花费5医疗资源，将“重伤”改为“受伤”标记。',0),(3,'警长','射击','2026-04-26 22:13:35','2026-06-26 13:07:41','射击——在密谋，暴力冲突中，如装备远距离武器时增加1威胁值。如果没有射击，装备远距离武器时，武器威胁值减半，向下取整。',0),(4,'隐藏统治者','无','2026-04-26 22:13:35','2026-05-02 22:44:57','无职业技能。',0),(6,'民兵','格斗','2026-05-02 22:47:15','2026-06-26 13:19:31','格斗——在密谋，暴力冲突中，如果没有装备，或者装备近距离武器，增加1威胁值。',0),(7,'巡夜人','格斗,巡逻','2026-05-02 22:49:32','2026-06-26 13:19:50','格斗——在密谋，暴力冲突中，如果没有装备，或者装备近距离武器，增加1威胁值。巡逻：夜间行动，选择一个地点，当晚该地点内非统治者阵营玩家夜晚行动成功率 -30%，巡夜人知晓其行动类型；需要当天未处于“劳工/过劳”。',0),(8,'农户','食物生产','2026-05-02 22:49:32','2026-06-26 13:20:21','食物生产：使用牲畜设施 获得食物15单位',0),(9,'伐木工','伐木','2026-05-02 22:49:32','2026-06-26 13:20:26','伐木：使用电锯5吨木材，否则1吨',0),(10,'矿工','挖掘','2026-05-02 22:49:32','2026-06-26 13:20:41','挖掘：使用电钻5吨石料，否则1吨',0),(11,'铁匠','炼铁','2026-05-02 22:49:32','2026-05-02 22:49:32','职业与技能在不满 48 人时不开放；具体效果未在资料中详细说明。',0),(12,'手工艺人','手工艺','2026-05-02 22:49:32','2026-06-26 13:20:51','手工艺：工具制备单制作一件或至多3件材料，物品或武器。',0),(13,'工匠','木石工艺','2026-05-02 22:49:32','2026-06-26 13:20:59','使用木板蒸汽箱，将5吨木材转化为3吨木板，消耗50kg燃料使用切石机，将1吨石料转化为15米石墙',0),(14,'渔民','捕鱼,格斗','2026-05-02 22:49:32','2026-06-26 13:29:05','格斗——在密谋，暴力冲突中，如果没有装备，或者装备近距离武器，增加1威胁值。捕鱼：在码头使用渔船设施 获得食物10单位',0),(15,'水手','航海,格斗','2026-05-02 22:49:32','2026-05-02 22:49:32','航海：码头使用货船设施获得 10kg 鱼肉；亦为远洋航行必要技能，对冒险者阵营有特殊用途。格斗：在密谋、暴力冲突中，如果装备近距离武器增加威胁值。如果调查玩家，可以选择在夜晚阶段骰 d6 寻找攻击机会，成功可发起小规模冲突；多人调查可袭击。',0),(16,'船长','远洋导航,射击','2026-05-02 22:49:32','2026-06-26 13:30:17','射击——在密谋，暴力冲突中，如装备远距离武器时增加1威胁值。如果没有射击，装备远距离武器时，武器威胁值减半，向下取整。海洋导航：为方舟终局结算提供好的结局倾向，可以查看今日所有的天灾牌。',0),(17,'装卸工','搬运,格斗','2026-05-02 22:49:32','2026-06-26 13:31:06','搬运：搬运量永远是其他职业的两倍。格斗——在密谋，暴力冲突中，如果没有装备，或者装备近距离武器，增加1威胁值。',0),(18,'采珠人','潜水,捕鱼','2026-05-02 22:49:32','2026-06-26 13:31:35','捕鱼：在码头使用渔船设施 获得食物10单位。潜水：每天白天行动时可以进行一次。需在码头使用，由主持人投d6决定结果：1-5，食物8单位，6 沉船遗物（随机一件较高价值物品，由主持人决定，如医疗资源、维修工具包、旧手枪+弹药、信号枪等）',0),(19,'神父','布道,医疗','2026-05-02 22:49:32','2026-06-26 13:32:31','布道：每天白天行动时一次。选择最多为3人，被布道的玩家在下一个行动中生产增加50%（渔猎，伐木，挖矿）/或者最多为3为玩家消除诅咒（被诅咒的玩家没有任何征兆，这是一个纯预判的技能效果）医疗：每天白天行动时一次。选择一位或至多5位“受伤”标记的玩家，目标消除“受伤”标记。每个花费3医疗资源，选择一位或多位过劳标记的玩家，消除过劳标记。每个花费2医疗资源。（可以混合总人数不超过5位）',0),(20,'赤脚医生','医疗,急救','2026-05-02 22:49:32','2026-06-26 13:32:42','急救：花费5医疗资源，将“重伤”改为“受伤”标记。医疗：每天白天行动时一次。选择一位或至多5位“受伤”标记的玩家，目标消除“受伤”标记。每个花费3医疗资源，选择一位或多位过劳标记的玩家，消除过劳标记。每个花费2医疗资源。（可以混合总人数不超过5位）',0),(21,'杂货店主','无','2026-05-02 22:49:32','2026-05-02 22:49:32','特殊性：初始拥有大量资源和商店功能；无职业技能。',0),(22,'旅店店主','烘焙','2026-05-02 22:49:32','2026-06-26 13:33:19','烘焙：需要 5 单位食物与 15kg 木材制作 1 份面包；面包当天额外获得 1 个白天行动点，每人每天限 1 次。',0),(23,'酒馆老板','无','2026-05-02 22:49:32','2026-05-02 22:49:32','特殊性：初始拥有大量酒类与医用酒精；无职业技能。',0),(24,'灯塔看守员','射击','2026-05-02 22:49:32','2026-06-26 13:33:40','射击——在密谋，暴力冲突中，如装备远距离武器时增加1威胁值。如果没有射击，装备远距离武器时，武器威胁值减半，向下取整。',0),(25,'面包师','烘焙','2026-05-02 22:49:32','2026-05-02 22:49:32','烘焙：需要 5 单位食物与 15kg 木材制作 1 份面包；面包当天额外获得 1 个白天行动点，每人每天限 1 次。',0),(26,'向导','急救,潜行','2026-05-02 22:49:32','2026-06-26 13:34:21','急救：花费5医疗资源，将“重伤”改为“受伤”标记。潜行（被动）：为谋略增加成功率，除了隐藏技能外无法被调查。',0),(27,'猎户','射击狩猎,潜行','2026-05-02 22:49:32','2026-06-26 13:34:45','射击狩猎：需要远程武器（无需子弹或弓箭）5kg肉。潜行（被动）：为谋略增加成功率，除了隐藏技能外无法被调查。',0),(28,'邮递员','潜行','2026-05-02 22:49:32','2026-06-26 13:34:53','潜行（被动）：为谋略增加成功率，除了隐藏技能外无法被调查。',0),(29,'守墓人','通灵','2026-05-02 22:49:32','2026-06-26 13:09:57','通灵：需消耗10根蜡烛和2升酒精举行仪式。\r\n每天白天行动时一次。与一位已死亡玩家建立临时私信交流，死亡玩家需要尽可能告知死前所有信息（由主持人保底提供信息）同时你有1/2概率会获得对方的技能。',0),(30,'气象观测员','天气预测','2026-05-02 22:49:32','2026-06-26 13:35:24','天气预测：你通过科学的手段发现异常的暴雪天气的来临，可以查看今日所有的天灾牌。为所有终局结算提供好的结局倾向。',0),(31,'占卜师','占星','2026-05-02 22:49:32','2026-06-26 13:35:46','占星：为避难所终局结算提供好的结局倾向。在全局游戏中你可以将一张天灾牌撕毁（不生效），或让一张危机事件牌撕毁（不生效）',0),(32,'设施维护人','维修','2026-05-02 22:49:32','2026-06-26 13:35:54','维修：每天可使用一次。修复一个被破坏的设施或者物品，花费5维修资源',0),(33,'教师','启蒙','2026-05-02 22:49:32','2026-06-26 13:08:28','启蒙:每天白天行动时一次。消耗2盒粉笔，选择除自己之外最多2名玩家，使其临时学会一项基础技能（从以下列表中选：急救、潜行、格斗、捕鱼、伐木、挖矿），从第一天夜晚回合生效持续到第二天白天回合结束。若该玩家已经拥有该技能则增产50%',0),(34,'治安官','射击','2026-05-02 22:49:32','2026-06-26 13:36:27','射击——在密谋，暴力冲突中，如装备远距离武器时增加1威胁值。如果没有射击，装备远距离武器时，武器威胁值减半，向下取整。',0),(35,'女巫','协议契约','2026-05-02 22:49:32','2026-05-02 22:49:32','为一位或多位玩家建立协议契约，可以指定违反协议的惩罚内容。',0),(36,'后勤官','调度','2026-06-26 13:11:22','2026-06-26 13:11:24','选择一处统治者控制的仓库，将其中最多100kg物资（任意类型）免费转移至另一处统治者仓库或自身仓库，不占用搬运行动，且不消耗移动配额。',0),(37,'大副','遗憾，格斗','2026-06-26 13:15:29','2026-06-26 13:15:57','若你与 船长职业的玩家在同一阵营，你在夜晚阶段，可以额外进行一次本日的 “调查玩家” 行动（用快速行动执行），且不消耗白天的行动次数。此效果每日限一次。若船长或大副阵营转变则失去该效果。\r\n若曾和船长玩家处于同一阵营之后船长玩家死亡，你在方舟结算时视为拥有技能 “海洋导航” 的效果。在密谋，暴力冲突中，如果没有装备，或者装备近距离武器，增加1威胁值。',0),(38,'债主','悬赏','2026-06-26 13:19:01','2026-06-26 13:19:01','消耗一行动，你消耗至少10单位（kg）的任意资源（如木材、食物、金属等）作为“悬赏金”，公开宣布悬赏一名 非己方阵营 的玩家。目标玩家必须在当天夜晚结算内 支付 悬赏金×1.5（向下取整）的资源给你，以消除悬赏。同一目标不可悬赏两次。\r\n若目标拒绝或未能支付，你将获得以下加成，直到悬赏被消除或你主动撤销：\r\n（1）信息掌控：与目标处于同一地点时，你得知该目标在此地点所有自由行动的结果（如探索、生产）。   （2）冲突代价：与目标发生冲突时，你的总战力+2。若你在此次冲突中获胜，可从其随身物品中 选择一件非关键物品（不能是武器或防具） 作为战利品带走。',0),(39,'烧炭工','烧炭','2026-06-26 13:44:25','2026-06-26 13:44:25','烧炭:使用煤炭炉，消耗一行动，使每150kg木材转为10单位燃料和相当于1医疗资源的1单位草木灰。每次行动至多转化750kg的木材。',0),(40,'鱼人','鱼鳞外套（被动）','2026-08-27 13:48:40','2026-08-27 13:50:10','潮汐之子。原住民。你幼时被矿场的老人从海边捡回；入水时皮肤会泛起暗蓝色纹路。\n初始：鱼鳞外套（每天一次防弹衣效果，不可交易、不可被偷盗或被得知拥有）；祭坛石×1（绑定个人仓库，不可被偷盗或被得知拥有，可交易或赠送）；随机仪式记物由主持人发放。\n身份永远隐藏，原住民之间默认互不知晓。若同时探索同一地点，或同处一地且现场无其他玩家，则自动互认。开局抽表面阵营与公共职业，并获得该职业的正常资源与技能。26人局固定2名（从鱼人/荒原狼/石之子中随机抽2个各1人，配置在平民席位）；48人局亦为2名。开局由主持人告知一处隐秘居所（与信天翁所知不同）。\n共同目标：首要不暴露原住民身份、进入避难所并活下去。成就「未启之门」：暴雪结束时无其他玩家执行二级仪式，且至少一名原住民成功举行过一次二级仪式。成就「地脉守护者」：暴雪结束时原住民阵营持有至少5枚祭坛石，且全游戏未举行任何仪式。收集全场祭坛石、抢先完成仪式，阻止铁门被打开。',1),(41,'荒原狼','野性追踪（被动）；刺刀威胁值2不可被偷盗','2026-08-27 13:48:40','2026-08-27 13:50:10','孤野的猎手。原住民。你出生在矿场后山的乱石堆，比镇上任何人更熟悉这座岛的每一道裂缝。\n初始：刺刀（威胁值2，不可被偷盗）；祭坛石×1（绑定个人仓库，不可被偷盗或被得知拥有，可交易或赠送）；随机仪式记物由主持人发放。\n身份永远隐藏，原住民之间默认互不知晓。若同时探索同一地点，或同处一地且现场无其他玩家，则自动互认。开局抽表面阵营与公共职业，并获得该职业的正常资源与技能。26人局固定2名（从鱼人/荒原狼/石之子中随机抽2个各1人，配置在平民席位）；48人局亦为2名。开局由主持人告知一处隐秘居所（与信天翁所知不同）。\n共同目标：首要不暴露原住民身份、进入避难所并活下去。成就「未启之门」：暴雪结束时无其他玩家执行二级仪式，且至少一名原住民成功举行过一次二级仪式。成就「地脉守护者」：暴雪结束时原住民阵营持有至少5枚祭坛石，且全游戏未举行任何仪式。收集全场祭坛石、抢先完成仪式，阻止铁门被打开。',1),(42,'石之子','石之皮肤（被动）；铁镐威胁值2','2026-08-27 13:48:40','2026-08-27 13:50:10','沉默的脊梁。原住民。你小时候掉进废弃巷道，第四天自己走出来，手里攥着发微光的矿石；从此不怕黑、不怕冷。\n初始：铁镐×1（威胁值2）；祭坛石×1（绑定个人仓库，不可被偷盗或被得知拥有，可交易或赠送）；随机仪式记物由主持人发放。\n身份永远隐藏，原住民之间默认互不知晓。若同时探索同一地点，或同处一地且现场无其他玩家，则自动互认。开局抽表面阵营与公共职业，并获得该职业的正常资源与技能。26人局固定2名（从鱼人/荒原狼/石之子中随机抽2个各1人，配置在平民席位）；48人局亦为2名。开局由主持人告知一处隐秘居所（与信天翁所知不同）。\n共同目标：首要不暴露原住民身份、进入避难所并活下去。成就「未启之门」：暴雪结束时无其他玩家执行二级仪式，且至少一名原住民成功举行过一次二级仪式。成就「地脉守护者」：暴雪结束时原住民阵营持有至少5枚祭坛石，且全游戏未举行任何仪式。收集全场祭坛石、抢先完成仪式，阻止铁门被打开。',1),(43,'飞行员','维修,驾驶员','2026-08-27 13:48:40','2026-08-27 13:50:10','钢铁与天空的重逢。外来者。维修：可修复设施或飞机部件，无需额外资源，可指导安装。驾驶员：可驾驶已修复的飞机。飞机修复需4个部件（发电机、螺旋桨、油箱、起落架），燃料150升煤油；坠机点仅飞行员初始知晓。快速行动：机库维修（夜晚，金属5kg+5点维修资源，每次最多装1个部件）、试飞（白天1其他行动或夜晚快速行动，最终一次性消耗煤油150升）。弱点：坠机点被发现后可能被破坏。胜利条件：集齐4部件并加注≥150升燃料，暴雪降临前或开始时起飞；成功则飞行员与登记平民单独胜利、不计入避难所/方舟。失败：暴雪降临时未修复则个人目标失败。4个飞机部件与维修资源20由DM手动记录发放。',0),(44,'信天翁','根源感知（被动）,替身（被动）','2026-08-27 13:48:40','2026-08-27 13:50:10','感知者、岛屿倾听者。身份隐藏。根源感知（被动）：开局知晓一块祭坛石的具体地点，并且知道一处隐秘居所（与原住民开局所知不同）。替身（被动）：开局可选一个公共职业并拥有其资源与技能。初始通灵笔记×1、蜡烛×10、酒精10升。胜利条件：至少成功进行过一次通灵笔记二级仪式，且游戏结束时没有直接暴露自己的身份。',1),(45,'调查记者','调查员,书写','2026-08-27 13:48:40','2026-08-27 13:50:10','真相的重量。调查员：白天调查玩家不消耗行动点（每天限1次）。书写：可制作并保存档案，档案不可被销毁。真相档案初始5页，每5kg木材扩1页，最多20页；可通过调查玩家、监听、挖掘、协议见证获取信息。胜利条件：档案≥15条有效信息（含≥2名不同阵营玩家真实阵营身份、1条阵营行动隐藏证据、1条天灾或地脉真相）；记者存活至暴雪结束，或档案暴雪后被找到。',1);
/*!40000 ALTER TABLE `job` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `job_initial_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_initial_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `job_id` int NOT NULL COMMENT '职业ID',
  `item_type` enum('item','weapon','ammo','material') NOT NULL COMMENT '物品类型',
  `item_id` int NOT NULL COMMENT '物品ID',
  `quantity` int NOT NULL DEFAULT '1' COMMENT '初始数量',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_job_item` (`job_id`,`item_type`,`item_id`),
  KEY `idx_job_id` (`job_id`),
  CONSTRAINT `job_initial_items_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `job` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=256 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='职业初始资源表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `job_initial_items` WRITE;
/*!40000 ALTER TABLE `job_initial_items` DISABLE KEYS */;
INSERT INTO `job_initial_items` VALUES (1,1,'item',5,1,'件','2026-05-02 22:50:05','2026-05-02 22:50:05'),(2,1,'weapon',1,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(3,1,'ammo',1,6,'枚','2026-05-02 22:50:05','2026-05-02 22:50:05'),(4,2,'item',3,2,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(5,2,'weapon',3,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(6,2,'item',5,1,'件','2026-05-02 22:50:05','2026-05-02 22:50:05'),(7,2,'item',2,2,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(8,2,'item',4,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(9,3,'weapon',3,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(10,3,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(11,3,'item',4,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(12,3,'item',5,1,'件','2026-05-02 22:50:05','2026-05-02 22:50:05'),(13,3,'weapon',1,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(14,3,'ammo',1,6,'枚','2026-05-02 22:50:05','2026-05-02 22:50:05'),(15,4,'item',5,1,'件','2026-05-02 22:50:05','2026-05-02 22:50:05'),(16,5,'item',3,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(17,5,'weapon',3,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(18,5,'item',5,1,'件','2026-05-02 22:50:05','2026-05-02 22:50:05'),(19,5,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(20,5,'material',5,2,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(21,5,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(22,5,'material',2,45,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(23,5,'weapon',1,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(24,5,'ammo',1,2,'枚','2026-05-02 22:50:05','2026-05-02 22:50:05'),(25,5,'item',1,10,'份','2026-05-02 22:50:05','2026-08-27 13:48:42'),(26,5,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(27,5,'item',10,5,'瓶','2026-05-02 22:50:05','2026-05-02 22:50:05'),(28,6,'item',6,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(29,6,'weapon',3,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(30,6,'material',5,2,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(31,6,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(32,6,'material',2,45,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(33,6,'weapon',1,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(34,6,'ammo',1,2,'枚','2026-05-02 22:50:05','2026-05-02 22:50:05'),(35,6,'item',1,10,'份','2026-05-02 22:50:05','2026-08-27 13:48:42'),(36,6,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(37,6,'item',10,5,'瓶','2026-05-02 22:50:05','2026-05-02 22:50:05'),(38,7,'item',4,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(39,7,'item',2,2,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(40,7,'item',6,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(41,7,'item',13,10,'根','2026-05-02 22:50:05','2026-05-02 22:50:05'),(42,7,'material',5,2,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(43,7,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(44,7,'material',2,45,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(45,7,'weapon',1,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(46,7,'ammo',1,2,'枚','2026-05-02 22:50:05','2026-05-02 22:50:05'),(47,7,'item',1,10,'份','2026-05-02 22:50:05','2026-08-27 13:48:42'),(48,7,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(49,7,'item',10,5,'瓶','2026-05-02 22:50:05','2026-05-02 22:50:05'),(50,8,'material',5,13,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(51,8,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(52,8,'weapon',9,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(53,8,'item',15,1,'盒','2026-05-02 22:50:05','2026-05-02 22:50:05'),(54,8,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(55,8,'material',2,150,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(56,9,'weapon',9,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(57,9,'weapon',10,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(58,9,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(59,9,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(60,9,'item',15,1,'盒','2026-05-02 22:50:05','2026-05-02 22:50:05'),(61,9,'material',5,8,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(62,9,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(63,9,'material',2,150,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(64,10,'weapon',8,3,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(65,10,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(66,10,'item',15,1,'盒','2026-05-02 22:50:05','2026-05-02 22:50:05'),(67,10,'material',5,8,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(68,10,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(69,10,'material',2,150,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(70,11,'weapon',4,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(71,11,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(72,11,'item',15,1,'盒','2026-05-02 22:50:05','2026-05-02 22:50:05'),(73,11,'material',5,8,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(74,11,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(75,11,'material',2,150,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(76,12,'material',1,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(77,12,'material',3,20,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(78,12,'material',9,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(79,12,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(80,12,'item',15,1,'盒','2026-05-02 22:50:05','2026-05-02 22:50:05'),(81,12,'material',5,8,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(82,12,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(83,12,'material',2,150,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(84,13,'material',5,8,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(85,13,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(86,13,'material',2,150,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(87,14,'weapon',6,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(88,14,'item',12,1,'张','2026-05-02 22:50:05','2026-05-02 22:50:05'),(89,14,'weapon',4,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(90,14,'material',3,20,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(91,14,'material',5,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(92,14,'material',2,80,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(93,14,'material',8,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(94,15,'weapon',4,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(95,15,'material',3,30,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(96,15,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(97,15,'item',12,1,'张','2026-05-02 22:50:05','2026-05-02 22:50:05'),(98,15,'material',5,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(99,15,'material',2,80,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(100,15,'material',8,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(101,16,'weapon',4,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(102,16,'item',7,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(103,16,'ammo',3,1,'枚','2026-05-02 22:50:05','2026-05-02 22:50:05'),(104,16,'item',17,1,'张','2026-05-02 22:50:05','2026-05-02 22:50:05'),(105,16,'material',5,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(106,16,'material',2,80,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(107,16,'material',8,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(108,16,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(109,17,'material',3,30,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(110,17,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(111,17,'weapon',4,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(112,17,'material',5,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(113,17,'material',2,80,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(114,17,'material',8,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(115,18,'weapon',4,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(116,18,'item',12,1,'张','2026-05-02 22:50:05','2026-05-02 22:50:05'),(117,18,'material',3,20,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(118,18,'material',5,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(119,18,'material',2,80,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(120,18,'material',8,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(121,19,'item',13,50,'支','2026-05-02 22:50:05','2026-05-02 22:50:05'),(122,19,'item',15,5,'盒','2026-05-02 22:50:05','2026-05-02 22:50:05'),(123,19,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(124,19,'material',5,3,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(125,19,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(126,19,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(127,19,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(128,20,'item',1,20,'份','2026-05-02 22:50:05','2026-08-27 13:48:42'),(129,20,'weapon',11,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(130,20,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(131,20,'material',5,3,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(132,20,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(133,20,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(134,20,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(135,21,'material',5,23,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(136,21,'item',10,10,'瓶','2026-05-02 22:50:05','2026-05-02 22:50:05'),(137,21,'material',3,100,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(138,21,'weapon',8,2,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(139,21,'weapon',9,2,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(140,21,'weapon',2,2,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(141,21,'ammo',2,4,'枚','2026-05-02 22:50:05','2026-05-02 22:50:05'),(142,21,'material',8,35,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(143,21,'material',2,350,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(144,21,'material',1,40,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(145,21,'material',6,30,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(146,21,'material',9,30,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(147,21,'item',16,5,'支','2026-05-02 22:50:05','2026-05-02 22:50:05'),(148,22,'material',5,18,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(149,22,'material',2,550,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(150,22,'material',8,105,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(151,23,'item',15,1,'盒','2026-05-02 22:50:05','2026-05-02 22:50:05'),(152,23,'item',14,10,'升','2026-05-02 22:50:05','2026-05-02 22:50:05'),(153,23,'material',5,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(154,23,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(155,23,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(156,23,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(157,24,'item',7,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(158,24,'ammo',3,2,'枚','2026-05-02 22:50:05','2026-05-02 22:50:05'),(159,24,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(160,24,'material',8,15,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(161,24,'item',17,1,'张','2026-05-02 22:50:05','2026-05-02 22:50:05'),(162,24,'material',5,3,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(163,24,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(164,24,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(165,25,'material',5,8,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(166,25,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(167,25,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(168,25,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(169,26,'weapon',4,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(170,26,'material',3,20,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(171,26,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(172,26,'material',5,2,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(173,26,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(174,26,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(175,26,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(176,27,'weapon',2,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(177,27,'ammo',2,4,'枚','2026-05-02 22:50:05','2026-05-02 22:50:05'),(178,27,'weapon',4,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(179,27,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(180,27,'material',5,2,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(181,27,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(182,27,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(183,27,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(184,28,'material',3,20,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(185,28,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(186,28,'item',4,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(187,28,'material',5,2,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(188,28,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(189,28,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(190,28,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(191,29,'weapon',8,1,'把','2026-05-02 22:50:05','2026-05-02 22:50:05'),(192,29,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(193,29,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(194,29,'item',13,10,'支','2026-05-02 22:50:05','2026-05-02 22:50:05'),(195,29,'material',5,2,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(196,29,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(197,29,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(198,29,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(199,30,'item',16,5,'支','2026-05-02 22:50:05','2026-05-02 22:50:05'),(200,30,'material',8,20,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(201,30,'material',9,20,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(202,30,'material',5,2,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(203,30,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(204,30,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(205,31,'item',13,10,'支','2026-05-02 22:50:05','2026-05-02 22:50:05'),(206,31,'item',15,1,'盒','2026-05-02 22:50:05','2026-05-02 22:50:05'),(207,31,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(208,31,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(209,31,'material',5,2,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(210,31,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(211,31,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(212,31,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(213,32,'item',8,2,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(214,32,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(215,32,'material',3,10,'米','2026-05-02 22:50:05','2026-05-02 22:50:05'),(216,32,'material',5,2,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(217,32,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(218,32,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(219,32,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(220,33,'item',16,5,'支','2026-05-02 22:50:05','2026-05-02 22:50:05'),(221,33,'item',2,1,'个','2026-05-02 22:50:05','2026-05-02 22:50:05'),(222,33,'material',5,2,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(223,33,'material',8,5,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(224,33,'material',2,50,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(225,33,'material',1,10,'kg','2026-05-02 22:50:05','2026-05-02 22:50:05'),(226,36,'item',5,1,'?','2026-06-26 13:53:19','2026-06-26 13:53:19'),(227,36,'item',6,1,'?','2026-06-26 13:53:19','2026-06-26 13:53:19'),(228,36,'item',4,1,'?','2026-06-26 13:53:19','2026-06-26 13:53:19'),(229,37,'material',5,5,'??','2026-06-26 13:53:34','2026-06-26 13:53:34'),(230,37,'material',2,80,'kg','2026-06-26 13:53:34','2026-06-26 13:53:34'),(231,37,'material',8,10,'??','2026-06-26 13:53:34','2026-06-26 13:53:34'),(232,37,'material',3,10,'?','2026-06-26 13:53:34','2026-06-26 13:53:34'),(233,38,'material',5,2,'??','2026-06-26 13:53:48','2026-06-26 13:53:48'),(234,38,'material',8,5,'?','2026-06-26 13:53:48','2026-06-26 13:53:48'),(235,38,'material',2,50,'kg','2026-06-26 13:53:48','2026-06-26 13:53:48'),(236,38,'material',1,10,'kg','2026-06-26 13:53:48','2026-06-26 13:53:48'),(237,39,'material',5,8,'??','2026-06-26 13:53:59','2026-06-26 13:53:59'),(238,39,'material',8,5,'??','2026-06-26 13:53:59','2026-06-26 13:53:59'),(239,39,'material',2,150,'kg','2026-06-26 13:53:59','2026-06-26 13:53:59'),(240,40,'item',30,1,'件','2026-08-27 13:48:40','2026-08-27 13:48:40'),(241,40,'item',27,1,'枚','2026-08-27 13:48:40','2026-08-27 13:48:40'),(242,41,'weapon',4,1,'把','2026-08-27 13:48:40','2026-08-27 13:48:40'),(243,41,'item',27,1,'枚','2026-08-27 13:48:40','2026-08-27 13:48:40'),(244,42,'weapon',15,1,'把','2026-08-27 13:48:40','2026-08-27 13:48:40'),(245,42,'item',27,1,'枚','2026-08-27 13:48:40','2026-08-27 13:48:40'),(246,43,'item',39,1,'张','2026-08-27 13:48:40','2026-08-27 13:48:40'),(247,43,'material',2,75,'kg','2026-08-27 13:48:40','2026-08-27 13:48:40'),(248,43,'material',3,10,'米','2026-08-27 13:48:40','2026-08-27 13:48:40'),(249,43,'material',5,3,'kg','2026-08-27 13:48:40','2026-08-27 13:48:40'),(250,44,'item',28,1,'本','2026-08-27 13:48:40','2026-08-27 13:48:40'),(251,44,'item',13,10,'根','2026-08-27 13:48:40','2026-08-27 13:48:40'),(252,44,'item',14,10,'升','2026-08-27 13:48:40','2026-08-27 13:48:40'),(253,45,'item',42,1,'本','2026-08-27 13:48:40','2026-08-27 13:48:40'),(254,45,'item',43,1,'支','2026-08-27 13:48:40','2026-08-27 13:48:40'),(255,45,'material',5,3,'kg','2026-08-27 13:48:40','2026-08-27 13:48:40');
/*!40000 ALTER TABLE `job_initial_items` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '地点名称',
  `area` varchar(20) NOT NULL COMMENT '所属区域：小镇/海岛/特殊',
  `description` text COMMENT '地点描述',
  `defense_value` int NOT NULL DEFAULT '0' COMMENT '防御值',
  `management` varchar(100) DEFAULT NULL COMMENT '管理方',
  `order_number` int NOT NULL DEFAULT '0' COMMENT '排序序号',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='地点表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `location` WRITE;
/*!40000 ALTER TABLE `location` DISABLE KEYS */;
INSERT INTO `location` VALUES (1,'警察局','小镇','一座木铁混合结构的平房，瓦楞铁皮屋顶，外墙刷着褪色的白漆。门廊上挂着一盏摇曳的煤油灯，屋内有一张办公桌、一个档案柜和一间狭小的临时牢房。墙上贴着殖民地政府的告示和几张泛黄的通缉令。',5,NULL,1,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(2,'镇长厅','小镇','两层殖民风格木楼，带有宽敞的阳台和百叶窗。楼下是办公室和接待室，楼上是行政长官的私人住所。墙上挂着英王乔治六世的肖像和殖民地地图。吊扇无力地转动着。',5,NULL,2,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(3,'邮局','小镇','一间低矮的木屋，窗前挂着\"皇家邮政\"的铜牌。屋内满是油墨和纸张的气味，木制柜台后是分拣信件的格子和一台莫尔斯电报机。墙上贴着轮船班次表和邮票样张。',3,NULL,3,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(4,'教堂','小镇','一座用珊瑚石和木材建造的小教堂，彩色玻璃窗描绘着基督与太平洋岛屿的景象。尖顶上的十字架在阳光下泛着白漆剥落后的斑驳。教堂内长椅简陋，但祭坛前摆着一架巨大的老旧管风琴，积满灰尘。',4,NULL,4,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(5,'灯塔','小镇','矗立在小镇岬角的白色石塔，约20米高。顶部的菲涅尔透镜在夜间旋转，光束扫过海面。塔底是灯塔看守员的住所。',7,NULL,5,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(6,'杂货店','小镇','一间堆满杂物的木板屋，从铁钉到糖果应有尽有，但货架已经半空。空气中弥漫着肥皂、腌鱼和煤油的味道。',0,NULL,6,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(7,'码头','小镇','有着几间木质简陋房屋和用旧木桩搭建的简陋码头，停着几艘渔船和一艘锈迹斑斑的货船。海浪拍打着木桩，发出单调的响声。远处海平面阴沉沉的。',3,NULL,7,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(8,'方舟','小镇','当方舟还未打造成功的那一刻，它更像一具尚未苏醒的骨架。你站在远处望去，最先撞入视线的是那略显粗糙的船头——弧度还不够圆润，几块硬木还露着刨花的毛茬，铜皮只包了一半，另一半用绳子临时捆着。甲板铺了两层，第三层的龙骨刚刚架起来，露出参差的肋木和没钉完的板缝。中间住人的舱室只有墙没有顶，阳光直直落进去，照见地上堆着的锯末和半截木尺；原本要种菜的顶层还空着，几捆芦苇杆斜靠在围栏上，等着编成遮棚。船尾的吊架竖起来了，但小艇还没挂上去，只有一副泡在水里的木架。帆布摊在甲板上，一个女人正低头缝着最后一道边，针脚歪歪扭扭。舵轮刚雕出个兽头的雏形，眼睛还没刻，嘴里衔着一截麻绳——绳的另一端系在岸边的树桩上，免得这半成品被水冲走。整条方舟静静泊在水湾里，随着波浪轻轻起伏，像个还没学会走路的孩子，笨拙，但让人看见力气。',1,NULL,8,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(9,'旅店','小镇','两层木质建筑，一楼是嘈杂的公共酒廊，二楼是狭小的客房。壁炉里的火永远烧不旺，空气中弥漫着廉价朗姆酒、汗水和发霉地毯混合的气味。公告板上贴满了寻人启事和过期的船期表。',2,NULL,9,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(10,'集市','小镇','镇中心的露天广场，只有零星几个木制摊位。平时冷冷清清，但当渔船归来或有补给船消息时，这里会短暂地热闹起来。',0,NULL,10,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(11,'酒吧','小镇','码头边的一间木质房屋昏暗的空间，看着门板还很结实里面有几盏油灯。这里是渔夫和矿工买醉的地方，墙上刻满了粗鄙的涂鸦。角落里有一台破旧的留声机，吱呀呀地放着过时的爵士乐。',3,NULL,11,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(12,'面包店','小镇','集市附近的木质结构店铺，后面是一个烘焙的石头屋子。进去这里倒是挺温暖的，里面有面包的香气。',2,NULL,12,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(13,'气象观测站','小镇','小镇边缘的一座独立铁皮屋，屋顶有风速仪和天线。屋内摆满了精密的（虽然老旧）仪器和手绘的气象图。',3,NULL,13,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(14,'教室','小镇','小教室的门半敞着，被海风吹得轻轻磕在门框上，发出沉闷的\"咚——咚——\"。阳光从破了一半的窗户斜射进来，照见地上东倒西歪的板凳，有几张翻倒了，桌腿朝天，像搁浅的螃蟹。天花板上的吊灯还在，灯泡却碎了，灯罩里塞着一团不知哪年哪月的鸟窝。透过那扇最大的窗户望去，能看见远处的码头和更远处的海——海还是那片海，只是教室里再也没有读书声了。',2,NULL,14,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(15,'伐木营地','海岛','岛内森林边缘的一片空地，堆满了砍伐的原木，有一座简易的木屋和一台生锈的蒸汽拖拉机。地上满是木屑和树桩。',4,NULL,15,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(16,'墓地','海岛','墓地很静，石碑像断掉的牙齿从荒草里斜伸出来。风扫过时，只有自己的脚步声在回应。',5,NULL,16,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(17,'猎人小屋','海岛','森林深处的一座原木小屋，墙外挂着各种兽皮，屋内弥漫着熏肉和火药的味道。壁炉上挂着一支双管猎枪。',3,NULL,17,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(18,'矿场','特殊','深入山腹的矿道与地面设施的综合体，包含管理室、矿场仓库和地下矿场。由统治者共同管理，是岛上最重要的资源产地和战略要地。',10,'统治者共同管理',18,'2026-05-14 16:32:12','2026-05-14 16:32:12'),(19,'监狱','特殊','小镇边缘的一座灰石建筑，铁门锈迹斑斑，窗户窄得像枪眼。门前挂着一盏永远不灭的煤油灯，灯下总坐着一个看守。里面是两排铁牢房，地上铺着发霉的稻草，墙角堆着脏得看不出颜色的毯子。墙上用木炭刻满了前囚犯的名字和诅咒，有些已经被重复刻了三四遍。空气里弥漫着尿骚味和铁锈味，偶尔有人敲一下铁栏杆，声音能传到半个镇子。',8,'统治者共同管理，监狱长常驻',19,'2026-05-14 16:32:12','2026-05-14 16:32:12');
/*!40000 ALTER TABLE `location` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `location_facility`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location_facility` (
  `id` int NOT NULL AUTO_INCREMENT,
  `location_id` int NOT NULL COMMENT '关联地点ID',
  `name` varchar(100) NOT NULL COMMENT '设施名称',
  `description` text COMMENT '设施描述',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `location_facility_ibfk_1` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='地点设施表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `location_facility` WRITE;
/*!40000 ALTER TABLE `location_facility` DISABLE KEYS */;
INSERT INTO `location_facility` VALUES (1,1,'燃料仓','一个巨大的铁皮储油罐，旁边是几排油桶。这里是全镇的能源命脉，由警察局派员看守。铁门上挂着大锁，周围拉着铁丝网。','2026-05-14 16:32:12','2026-05-14 16:32:12'),(2,1,'发电机','警察局配备的发电机组','2026-05-14 16:32:12','2026-05-14 16:32:12'),(3,2,'镇武库仓库','镇长厅内的武器库，存放着小镇的武装储备','2026-05-14 16:32:12','2026-05-14 16:32:12'),(4,2,'发电机','镇长厅配备的发电机组','2026-05-14 16:32:12','2026-05-14 16:32:12'),(5,3,'电报机','可以向外界发送信息的莫尔斯电报机','2026-05-14 16:32:12','2026-05-14 16:32:12'),(6,7,'渔船×3','三艘渔船，渔猎技能需要','2026-05-14 16:32:12','2026-05-14 16:32:12'),(7,7,'码头集购仓','需征求统治者同意，玩家可以询问统治者并购买物品','2026-05-14 16:32:12','2026-05-14 16:32:12'),(8,7,'阿弗雷号','轻型杂货船，总吨位约650吨，载重吨位约300吨，全长约42米，型宽约7米，吃水满载约4.2米，燃料30吨。配备螺旋桨2、发动机2、发电机1','2026-05-14 16:32:12','2026-05-14 16:32:12'),(9,10,'行刑台','统治者或者其他阵营可以在这里进行公开行刑行为','2026-05-14 16:32:12','2026-05-14 16:32:12'),(10,12,'烘焙炉','面包店后方的石头烘焙炉','2026-05-14 16:32:12','2026-05-14 16:32:12'),(11,15,'木板蒸汽箱','用于木材处理的蒸汽箱设备','2026-05-14 16:32:12','2026-05-14 16:32:12'),(12,15,'拖拉机','在伐木行动时辅助工作的蒸汽拖拉机','2026-05-14 16:32:12','2026-05-14 16:32:12'),(13,15,'发电机','伐木营地配备的发电机组','2026-05-14 16:32:12','2026-05-14 16:32:12'),(14,16,'坟堆','为了死者一个体面的后事','2026-05-14 16:32:12','2026-05-14 16:32:12'),(15,18,'切石机','矿场的石材切割设备','2026-05-14 16:32:12','2026-05-14 16:32:12'),(16,18,'管理室','矿场入口旁的木屋，里面有一张办公桌和一部电话（但线路已断）。墙上挂着矿井地图和工作安排表。','2026-05-14 16:32:12','2026-05-14 16:32:12'),(17,18,'矿场仓库','一个用厚木板搭建的棚屋，里面堆放着开采出来的矿石、工具和一些备用木材。门上挂着一把大锁。','2026-05-14 16:32:12','2026-05-14 16:32:12'),(18,18,'地下矿场（避难所）','深入山腹的矿道，墙壁上钉着木支架，每隔一段有一盏昏暗的油灯。深处被清理出一片空间，堆放着储备物资，这里就是计划中的\"避难所\"。','2026-05-14 16:32:12','2026-05-14 16:32:12'),(19,19,'监牢×8','地面上有着不明污渍的铁制监牢，看起来很牢固几乎不可能在空手情况下跑出去。里面关着几个人，听说是因为违反统治者被关起来了。','2026-05-14 16:32:12','2026-05-14 16:32:12'),(20,19,'看守室','内有桌子一张、煤油灯一盏、警棍一根','2026-05-14 16:32:12','2026-05-14 16:32:12'),(21,19,'审讯椅','铁制，带锁扣的审讯椅','2026-05-14 16:32:12','2026-05-14 16:32:12'),(22,5,'望远镜','灯塔顶层的望远镜，可远眺海面与岛岸。','2026-08-27 13:48:41','2026-08-27 13:48:41'),(23,10,'牲畜栏','集市一侧圈养牲畜的栏舍。','2026-08-27 13:48:41','2026-08-27 13:48:41'),(24,10,'烧炭炉','集市边用于烧制木炭的炉灶。','2026-08-27 13:48:41','2026-08-27 13:48:41'),(25,10,'棚屋','集市旁供人歇脚存放杂物的简易棚屋。','2026-08-27 13:48:41','2026-08-27 13:48:41'),(26,4,'礼拜堂','教堂内供祷告与仪式的侧厅。','2026-08-27 13:48:41','2026-08-27 13:48:41');
/*!40000 ALTER TABLE `location_facility` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `location_governance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location_governance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `actor_id` int DEFAULT NULL,
  `actor_kind` varchar(10) DEFAULT NULL,
  `actor_name` varchar(50) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `game_day` int NOT NULL,
  `location_id` int NOT NULL,
  `location_name` varchar(100) DEFAULT NULL,
  `source_faction_action_id` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `location_governance` WRITE;
/*!40000 ALTER TABLE `location_governance` DISABLE KEYS */;
/*!40000 ALTER TABLE `location_governance` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `location_npc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location_npc` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'NPC唯一标识符',
  `name` varchar(50) NOT NULL COMMENT 'NPC名字',
  `job` varchar(50) NOT NULL COMMENT 'NPC职业',
  `gender` enum('男','女') NOT NULL COMMENT '性别',
  `introduction` text COMMENT 'NPC介绍',
  `location_id` int NOT NULL COMMENT '所在地点ID',
  `attitude_ruler` enum('喜好','厌恶','忽视') NOT NULL DEFAULT '忽视' COMMENT '对统治者的态度',
  `attitude_rebel` enum('喜好','厌恶','忽视') NOT NULL DEFAULT '忽视' COMMENT '对反叛者的态度',
  `attitude_adventurer` enum('喜好','厌恶','忽视') NOT NULL DEFAULT '忽视' COMMENT '对冒险者的态度',
  `attitude_scourge` enum('喜好','厌恶','忽视') NOT NULL DEFAULT '忽视' COMMENT '对天灾使者的态度',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `avatar_url` varchar(255) DEFAULT NULL,
  `dialogue_style` text,
  `personality` text,
  `status` varchar(50) DEFAULT NULL,
  `daily_trade_limit` int DEFAULT NULL,
  `clue_keywords` text,
  `special_clue_content` text,
  PRIMARY KEY (`id`),
  KEY `idx_location_id` (`location_id`),
  KEY `idx_job` (`job`),
  CONSTRAINT `fk_npc_location` FOREIGN KEY (`location_id`) REFERENCES `location` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='地点NPC表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `location_npc` WRITE;
/*!40000 ALTER TABLE `location_npc` DISABLE KEYS */;
INSERT INTO `location_npc` VALUES (1,'克拉拉·南丁格尔','渔民','女','家中贫困的普通渔民，只希望镇上保持平静。她每天修补渔网，数着日子过，祈祷暴雪别落到她头上。',7,'忽视','忽视','喜好','厌恶','2026-05-14 20:44:38','2026-06-25 20:04:15',NULL,'声音小，经常低头说话，提到“暴雪”时会下意识攥紧衣角。','胆怯温和，只想安稳过日子。','正常',1,'lighthouse, tower, secret room','The old lighthouse has a hidden basement that was used by smugglers. The entrance is behind a loose brick on the north wall. Inside you\'ll find an old sea chart marking the location of a sunken ship.'),(2,'杰克·塔克','水手','男','曾在商船当水手，船沉后困在岛上，做梦都想再上一次船。他每天在码头踱步，盯着海平线发呆。',7,'忽视','厌恶','喜好','忽视','2026-05-14 20:44:38','2026-05-14 20:44:38',NULL,'说话带着海风味的粗犷，每三句话里有一句是“等船来了我就走”。','焦躁不安，像被困在笼子里的海鸟。','正常',1,NULL,NULL),(3,'鲍勃·塔克','装卸工','男','一直在港口讨生活的搬运工，膀大腰圆，嘴里永远叼着半根烟。他谁都不信，只信工钱和拳头。',7,'喜好','厌恶','忽视','忽视','2026-05-14 20:44:38','2026-05-23 01:29:01',NULL,'话不多，用“嗯”“行”“钱呢”三个词就能完成一次交易。','粗鲁务实，谁给钱多就给谁干活。','正常',1,NULL,NULL),(4,'托马斯·伍德','伐木工','男','沉默寡言的伐木工，靠砍树和做木工为生，只求安稳度日。他住在林中小屋，镇上的人很少见到他。',15,'喜好','厌恶','忽视','忽视','2026-05-14 20:44:38','2026-05-20 09:44:29',NULL,'答话永远慢半拍，好像你说话他要先翻译成木头语言。使用单音节词为主。','孤僻寡言，对政治毫无兴趣。','正常',1,NULL,NULL),(5,'卡尔·铁锤','矿工','男','脾气火爆的矿场工人，谁给好处就帮谁。他嗓门大、拳头硬，在矿场里混得开，没人敢惹他。',18,'喜好','厌恶','忽视','厌恶','2026-05-14 20:44:38','2026-06-25 19:54:21',NULL,'说话像在吼，每句话都带脏字，谈到“好处”时眼睛会亮起来。','暴躁直率，利益至上，不在乎对错。','正常',1,NULL,NULL),(6,'维克多·斯通','矿工','男','体格强壮的矿工，相信权力才是活下去的依靠。他崇拜强者，认为统治者镇得住场子，镇上才不至于乱套。',18,'喜好','厌恶','忽视','厌恶','2026-05-14 20:44:38','2026-06-24 11:44:07',NULL,'说话简短有力，像在砸石头。提到“统治者”时语气会放尊重点。','务实忠诚，迷信权力，看不起弱者。','正常',1,NULL,NULL),(7,'塞缪尔·格雷','农户','男','善良而质朴的普通农户，乐于帮助他人。他种的菜总有多余的分给邻居，从不计较回报。',10,'厌恶','忽视','喜好','忽视','2026-05-14 20:44:38','2026-05-14 20:44:38',NULL,'语速舒缓，像在慢悠悠地翻土。喜欢用“我总觉得啊”开头，但从不强加观点。','温和宽厚，发自内心地相信善良。','正常',1,NULL,NULL),(8,'弗雷德里克·波特','农户','男','性格孤僻的住在镇外的农户，对别人的生死毫不在意。他种自己的地，吃自己的粮，从不参与镇上任何事。',10,'厌恶','喜好','忽视','忽视','2026-05-14 20:44:38','2026-05-14 20:44:38',NULL,'能用点头摇头解决的绝不开腔，开了腔也是“关我什么事”。','冷漠自私，独来独往，不关心任何人。','正常',1,NULL,NULL),(9,'米玛·雷铁斯托','手工艺人','女','老实本分的手工艺人，喜欢待在自己的小屋偶尔出门。她编篮子、织布，手艺好但不爱张扬。',10,'厌恶','忽视','喜好','忽视','2026-05-14 20:44:38','2026-05-14 20:44:38',NULL,'说话轻声细语，手上永远在忙活——编东西、缝东西、磨东西。句子短，不议论人。','安静本分，不惹事也不怕事。','正常',1,NULL,NULL),(10,'汉斯·施密特','工匠','男','什么都能修的工匠，从钟表到农具都难不倒他，只认工钱不认人。他修东西时从不说话，修完报价，拿钱走人。',10,'喜好','忽视','忽视','厌恶','2026-05-14 20:44:38','2026-05-14 20:44:38',NULL,'除非在谈工钱，否则不开口。谈价格时句句精准，一句废话没有。','理性冷漠，技术至上，人情淡薄。','正常',1,NULL,NULL),(11,'乔克·汤姆','民兵','男','初始就跟着统治者干的监狱看守，一名很忠诚的下属。只是他有点小小的缺点，但统治者们也只能视而不见。',19,'喜好','厌恶','忽视','厌恶','2026-05-14 20:44:39','2026-05-14 20:44:39',NULL,'话多，喜欢吹嘘自己和统治者的关系，说到一半会突然压低声音说“其实我告诉你个小秘密”。','忠诚但管不住嘴，有小毛病但不致命。','正常',1,NULL,NULL),(12,'斯特·贝斯','民兵','女','初始就跟着统治者干活的一名很忠心的下属。她会一直遵从统治者的决定，除非她看不到希望。',19,'喜好','厌恶','忽视','厌恶','2026-08-19 14:56:00','2026-08-19 14:56:00',NULL,'话少，回答简洁。提到“统治者”时语气恭敬，提到“暴雪”时语气会变犹豫。','忠诚可靠，但有自己的底线。','正常',1,NULL,NULL);
/*!40000 ALTER TABLE `location_npc` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `lore_player_grant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lore_player_grant` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `granted_at` datetime(6) NOT NULL,
  `lore_slug` varchar(64) NOT NULL,
  `player_id` int NOT NULL,
  `viewed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKlaw0cy4b373n89nvts9tmvsrh` (`player_id`,`lore_slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `lore_player_grant` WRITE;
/*!40000 ALTER TABLE `lore_player_grant` DISABLE KEYS */;
/*!40000 ALTER TABLE `lore_player_grant` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `material` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `remark` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tag` varchar(100) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `material` WRITE;
/*!40000 ALTER TABLE `material` DISABLE KEYS */;
INSERT INTO `material` VALUES (1,'金属制品','kg','加工后的铁件、钉子、铁丝等金属材料。可用于锻造武器或工具，或修建设施的基础材料。','2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(2,'木材','kg','从岛上砍伐的原木，未经过加工。可直接作为燃料（25kg/天取暖），或加工成木板用于建筑。','2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(3,'绳索','米','麻绳或钢丝绳，直径1-2厘米。用于捆绑、拖拽、登山或船只系泊。可以提升探索成功程度。','2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(4,'木板','kg','原木经蒸汽箱加工后的标准化板材。用于建造避难所、修理船只或制作家具，比原木更易使用。','2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(5,'食物','kg','泛指各种可食用物资，包括面粉、鱼干、咸肉、土豆等。','2026-04-27 11:36:23','2026-05-16 12:00:00',NULL,NULL),(6,'沥青','kg','黑色粘稠的石油残渣，桶装保存。可用于修补船体裂缝、防水处理。','2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(7,'石料','kg','从采石场开采的岩石，大小不一。','2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(8,'燃料','升','统称可用于燃烧供能的物资，包括木柴、煤炭、燃料等。不同设备的燃料消耗标准不同，详见燃料消耗表。','2026-04-27 11:36:23','2026-05-17 00:00:00',NULL,NULL),(9,'帆布','米','厚实的亚麻或棉帆布，每卷宽1.5米。用于制作船帆、帐篷、防水布，或修补帆布类装备。','2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(10,'发动机','个','船用柴油发动机，方舟的核心动力设备，每台可使航行速度提升一档。','2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(11,'螺旋桨','个','三叶螺旋桨，直径1.5米。方舟推进装置，需与发动机配套使用，破损后可拆卸更换。','2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(12,'发电机','个','老旧柴油发电机，已闲置多年。可尝试修理后发电，为岛上提供有限电力，需持续消耗燃料。','2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(13,'草木灰','kg','烧炭工烧制燃料的副产物，1单位的草木灰等于1单位医疗资源。','2026-06-24 22:30:38','2026-06-24 22:30:38',NULL,NULL);
/*!40000 ALTER TABLE `material` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `milestone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `milestone` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '里程碑名称',
  `description` text NOT NULL COMMENT '里程碑描述',
  `is_completed` tinyint(1) DEFAULT '0' COMMENT '是否已完成',
  `completed_at` datetime DEFAULT NULL COMMENT '完成时间',
  `order_number` int NOT NULL COMMENT '排序序号',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order` (`order_number`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='反抗者里程碑表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `milestone` WRITE;
/*!40000 ALTER TABLE `milestone` DISABLE KEYS */;
INSERT INTO `milestone` VALUES (1,'团结平民','星星之火也可以燎原\r\n反抗者拥有一个初始协议书。\r\n反抗者应当与更多的玩家讨论，明确对方的特性，资源，加入阵营的意向，并且对其进行观察，辨别可能的内鬼。\r\n当包括初始反抗者在内的确认加入反抗者名单大于等于8人后（以签订了契约加入微信群聊为准，以死亡玩家应也计算在内），该里程碑事件完成。',0,NULL,1,'2026-05-14 10:40:18','2026-05-22 05:26:34'),(2,'解放我们的同伴','铁窗锁不住自由的心。目前在监狱里面的同伴都是曾经为了我们的革命事业献出自由乃是生命的同志。所以解放他们对于我们来讲至关重要。解救身在监狱中的那些同伴，他们将继续加入你们，并点燃这个岛上平民心中对于自由的渴望。当同伴被解救出来，该里程碑事件完成。',0,NULL,2,'2026-05-14 10:40:18','2026-08-27 13:50:32'),(3,'我们不是生来就应该如此','在统治者使用审判环节，若被审判人员为加入反抗者阵营中人。要尽力解救我们的同胞，避免让他被统治者所残害。当被审判的反抗者人员无罪释放，该里程碑事件完成。',0,NULL,3,'2026-05-14 10:40:18','2026-05-24 15:09:13'),(4,'反抗不是我们的目的，平等才是','不给人活路，那就掀桌子。你们或联系任意你们信任的人。向统治者进行施压，要求调整劳工名单或者让统治者分配一定的资源给其他镇民。当该施压投票超过半数被统治者同意，该里程碑事件完成。',0,NULL,4,'2026-05-14 10:40:18','2026-05-24 15:09:03'),(5,'正义属于我们','敌人的刀，也能转过来对着他们自己。有1名原本属于统治者阵营的玩家（或主持人控制的NPC）主动投靠反抗者，并提供信息或协助。该里程碑事件完成。',0,NULL,5,'2026-05-14 10:40:18','2026-08-27 13:50:32'),(6,'团结一切可以团结的力量','那些外来人，要么帮忙，要么别挡道。至少1名冒险者身份的玩家公开承诺在革命日当天加入反抗者起义，或至少2名冒险者承诺保持中立（不帮统治者）。完成上述条件后，该里程碑事件完成。',0,NULL,6,'2026-05-14 10:40:18','2026-08-27 13:50:32'),(7,'让人民觉醒','第一条血债，就是最好的宣言。当第一次有玩家因为统治者的直接行为（审判、冲突，抓捕等，由主持人判定）死亡或重伤后，主持人会秘密告知反抗者阵营这条消息。得知消息后，反抗者在当晚的夜间回合一名反叛者可以花费一行动点发起一次匿名投票，向全体玩家问一个问题：“统治者是否草菅人命？”投票规则：匿名投票，每人一票。选项为“是”或“否”。如果投票人数超过玩家总数的一半，且其中同意“是”的票数多于“否”，该里程碑完成。',0,NULL,7,'2026-05-14 10:40:18','2026-05-19 13:49:46');
/*!40000 ALTER TABLE `milestone` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `milestone_player_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `milestone_player_status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL COMMENT '玩家ID',
  `milestone_id` int NOT NULL COMMENT '里程碑ID',
  `has_viewed` tinyint(1) DEFAULT '0' COMMENT '玩家是否已查看',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_player_milestone` (`player_id`,`milestone_id`),
  KEY `milestone_id` (`milestone_id`),
  CONSTRAINT `milestone_player_status_ibfk_1` FOREIGN KEY (`milestone_id`) REFERENCES `milestone` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='玩家里程碑查看状态表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `milestone_player_status` WRITE;
/*!40000 ALTER TABLE `milestone_player_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `milestone_player_status` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `night_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `night_action` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL COMMENT '提交玩家ID',
  `player_name` varchar(50) DEFAULT NULL COMMENT '玩家名称快照',
  `faction` varchar(20) NOT NULL COMMENT '提交时阵营',
  `action_type` varchar(40) NOT NULL COMMENT '夜晚行动类型：night_personal_action/public_trial/conspiracy等',
  `payload` text COMMENT 'JSON输入数据',
  `result` text COMMENT '行动结果/DM结算',
  `status` enum('pending','feedbacked') NOT NULL DEFAULT 'pending' COMMENT '结算状态',
  `game_day` int NOT NULL DEFAULT '1' COMMENT '游戏天数',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_player_day` (`player_id`,`game_day`),
  KEY `idx_faction_day` (`faction`,`game_day`),
  KEY `idx_action_type` (`action_type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='夜晚行动表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `night_action` WRITE;
/*!40000 ALTER TABLE `night_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `night_action` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_daily_consumption`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_daily_consumption` (
  `id` int NOT NULL AUTO_INCREMENT,
  `npc_id` int NOT NULL,
  `game_day` int NOT NULL,
  `required_food_units` int NOT NULL DEFAULT '2',
  `required_fuel_kg` int NOT NULL DEFAULT '25',
  `consumed_food_units` int NOT NULL DEFAULT '0',
  `consumed_fuel_kg` int NOT NULL DEFAULT '0',
  `fuel_from_wood_kg` int NOT NULL DEFAULT '0',
  `fuel_from_fuel_kg` int NOT NULL DEFAULT '0',
  `requirements_met` tinyint(1) NOT NULL DEFAULT '0',
  `result_status` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_npc_day` (`npc_id`,`game_day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_daily_consumption` WRITE;
/*!40000 ALTER TABLE `npc_daily_consumption` DISABLE KEYS */;
/*!40000 ALTER TABLE `npc_daily_consumption` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_daily_dialogue_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_daily_dialogue_count` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `dialogue_count` int NOT NULL,
  `last_dialogue_time` datetime(6) DEFAULT NULL,
  `last_game_day` int NOT NULL,
  `npc_id` int NOT NULL,
  `player_id` int NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_daily_dialogue_count` WRITE;
/*!40000 ALTER TABLE `npc_daily_dialogue_count` DISABLE KEYS */;
/*!40000 ALTER TABLE `npc_daily_dialogue_count` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_daily_trade_count`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_daily_trade_count` (
  `id` int NOT NULL AUTO_INCREMENT,
  `game_day` int NOT NULL,
  `npc_id` int NOT NULL,
  `player_id` int NOT NULL,
  `trade_count` int NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_daily_trade_count` WRITE;
/*!40000 ALTER TABLE `npc_daily_trade_count` DISABLE KEYS */;
/*!40000 ALTER TABLE `npc_daily_trade_count` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_dialogue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_dialogue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `dialogue_round` int NOT NULL,
  `favor_change` int DEFAULT NULL,
  `npc_id` int NOT NULL,
  `npc_reply` text NOT NULL,
  `player_id` int NOT NULL,
  `player_message` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_dialogue` WRITE;
/*!40000 ALTER TABLE `npc_dialogue` DISABLE KEYS */;
/*!40000 ALTER TABLE `npc_dialogue` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_favor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_favor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `favor_value` int NOT NULL,
  `npc_id` int NOT NULL,
  `player_id` int NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_favor` WRITE;
/*!40000 ALTER TABLE `npc_favor` DISABLE KEYS */;
/*!40000 ALTER TABLE `npc_favor` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_favor_adjustment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_favor_adjustment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `adjustment_reason` text,
  `adjustment_type` varchar(20) DEFAULT NULL,
  `change_amount` int NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `new_value` int NOT NULL,
  `npc_id` int NOT NULL,
  `old_value` int NOT NULL,
  `operator_id` int DEFAULT NULL,
  `operator_name` varchar(50) DEFAULT NULL,
  `player_id` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_favor_adjustment` WRITE;
/*!40000 ALTER TABLE `npc_favor_adjustment` DISABLE KEYS */;
/*!40000 ALTER TABLE `npc_favor_adjustment` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_help_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_help_config` (
  `id` int NOT NULL AUTO_INCREMENT,
  `base_cost_item_id` int NOT NULL,
  `base_cost_quantity` int NOT NULL,
  `base_cost_type` varchar(20) NOT NULL,
  `cost_max_modifier` double DEFAULT NULL,
  `cost_min_modifier` double DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `duration_minutes` int DEFAULT NULL,
  `help_description` text,
  `help_name` varchar(100) NOT NULL,
  `help_type` varchar(50) NOT NULL,
  `min_favor_level` varchar(20) NOT NULL,
  `npc_id` int NOT NULL,
  `success_rate` double DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_help_config` WRITE;
/*!40000 ALTER TABLE `npc_help_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `npc_help_config` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_help_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_help_record` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cost_item_id` int NOT NULL,
  `cost_quantity` int NOT NULL,
  `cost_type` varchar(20) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `end_time` datetime(6) DEFAULT NULL,
  `favor_change` int DEFAULT NULL,
  `game_day` int NOT NULL,
  `help_name` varchar(100) NOT NULL,
  `help_type` varchar(50) NOT NULL,
  `npc_id` int NOT NULL,
  `player_id` int NOT NULL,
  `result_description` text,
  `start_time` datetime(6) DEFAULT NULL,
  `status` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_help_record` WRITE;
/*!40000 ALTER TABLE `npc_help_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `npc_help_record` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `npc_id` int NOT NULL,
  `item_type` varchar(20) NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_npc_item` (`npc_id`,`item_type`,`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=167 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_items` WRITE;
/*!40000 ALTER TABLE `npc_items` DISABLE KEYS */;
INSERT INTO `npc_items` VALUES (84,1,'item',12,1),(85,1,'weapon',4,1),(86,1,'weapon',6,1),(87,1,'material',2,80),(88,1,'material',3,20),(89,1,'material',5,5),(90,1,'material',8,10),(91,2,'item',2,1),(92,2,'item',12,1),(93,2,'weapon',4,1),(94,2,'material',2,80),(95,2,'material',3,30),(96,2,'material',5,5),(97,2,'material',8,10),(98,3,'item',2,1),(99,3,'weapon',4,1),(100,3,'material',2,80),(101,3,'material',3,30),(102,3,'material',5,5),(103,3,'material',8,10),(104,4,'item',2,1),(105,4,'item',15,1),(106,4,'weapon',9,1),(107,4,'weapon',10,1),(108,4,'material',2,150),(109,4,'material',3,10),(110,4,'material',5,8),(111,4,'material',8,5),(112,5,'item',2,1),(113,5,'item',15,1),(114,5,'weapon',8,3),(115,5,'material',2,150),(116,5,'material',5,8),(117,5,'material',8,5),(118,6,'item',2,1),(119,6,'item',15,1),(120,6,'weapon',8,3),(121,6,'material',2,150),(122,6,'material',5,8),(123,6,'material',8,5),(124,7,'item',15,1),(125,7,'weapon',9,1),(126,7,'material',2,150),(127,7,'material',3,10),(128,7,'material',5,13),(129,7,'material',8,5),(130,8,'item',15,1),(131,8,'weapon',9,1),(132,8,'material',2,150),(133,8,'material',3,10),(134,8,'material',5,13),(135,8,'material',8,5),(136,9,'item',2,1),(137,9,'item',15,1),(138,9,'material',1,5),(139,9,'material',2,150),(140,9,'material',3,20),(141,9,'material',5,8),(142,9,'material',8,5),(143,9,'material',9,10),(144,10,'material',2,150),(145,10,'material',5,8),(146,10,'material',8,5),(147,11,'item',1,10),(148,11,'item',6,1),(149,11,'item',10,5),(150,11,'weapon',1,1),(151,11,'weapon',3,1),(152,11,'ammo',1,2),(153,11,'material',2,45),(154,11,'material',3,10),(155,11,'material',5,2),(156,11,'material',8,5),(157,12,'item',1,10),(158,12,'item',6,1),(159,12,'item',10,5),(160,12,'weapon',1,1),(161,12,'weapon',3,1),(162,12,'ammo',1,2),(163,12,'material',2,45),(164,12,'material',3,10),(165,12,'material',5,2),(166,12,'material',8,5);
/*!40000 ALTER TABLE `npc_items` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_trade_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_trade_config` (
  `id` int NOT NULL AUTO_INCREMENT,
  `config_type` varchar(20) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `item_id` int NOT NULL,
  `item_type` varchar(20) NOT NULL,
  `max_favor` int DEFAULT NULL,
  `min_favor` int DEFAULT NULL,
  `npc_id` int NOT NULL,
  `probability` double DEFAULT NULL,
  `quantity` int NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_trade_config` WRITE;
/*!40000 ALTER TABLE `npc_trade_config` DISABLE KEYS */;
INSERT INTO `npc_trade_config` VALUES (137,'demand','2026-06-22 18:01:41.983000',2,'material',100,-100,1,1,8,'2026-06-22 18:01:41.983000'),(138,'supply','2026-06-22 18:01:41.987000',5,'material',100,20,1,1,2,'2026-06-22 18:01:41.987000'),(139,'demand','2026-06-22 20:10:15.737000',1,'item',100,-100,2,1,20,'2026-06-22 20:10:15.737000'),(140,'supply','2026-06-22 20:10:15.741000',1,'material',100,40,2,1,12,'2026-06-22 20:10:15.741000');
/*!40000 ALTER TABLE `npc_trade_config` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_trade_proposal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_trade_proposal` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `game_day` int NOT NULL,
  `give_items` text COLLATE utf8mb4_general_ci,
  `npc_id` int NOT NULL,
  `player_id` int NOT NULL,
  `remark` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `take_items` text COLLATE utf8mb4_general_ci,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_npc_player_day_proposal` (`npc_id`,`player_id`,`game_day`,`status`),
  KEY `idx_npc_proposal_status` (`npc_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_trade_proposal` WRITE;
/*!40000 ALTER TABLE `npc_trade_proposal` DISABLE KEYS */;
/*!40000 ALTER TABLE `npc_trade_proposal` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `npc_trade_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `npc_trade_record` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `demand_items` text,
  `favor_change` int DEFAULT NULL,
  `game_day` int NOT NULL,
  `npc_id` int NOT NULL,
  `player_id` int NOT NULL,
  `supply_items` text,
  `trade_time` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `npc_trade_record` WRITE;
/*!40000 ALTER TABLE `npc_trade_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `npc_trade_record` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `player`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `player` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `is_weak` tinyint(1) NOT NULL DEFAULT '0',
  `is_overworked` tinyint(1) NOT NULL DEFAULT '0',
  `is_injured` tinyint(1) NOT NULL DEFAULT '0',
  `is_severely_injured` tinyint(1) NOT NULL DEFAULT '0' COMMENT '重伤',
  `is_dead` tinyint(1) NOT NULL DEFAULT '0' COMMENT '死亡',
  `job_id` int NOT NULL,
  `skill_id` int DEFAULT NULL,
  `faction` enum('统治者','反叛者','冒险者','天灾使者','平民','外来者','原住民') NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `overnight_location_id` int DEFAULT NULL,
  `dm_notes` text,
  `hidden_job_id` int DEFAULT NULL,
  `trade_banned` tinyint(1) NOT NULL DEFAULT '0',
  `is_bound` tinyint(1) NOT NULL DEFAULT '0',
  `trade_ban_exempt` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `job_id` (`job_id`),
  KEY `skill_id` (`skill_id`),
  CONSTRAINT `player_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `job` (`id`),
  CONSTRAINT `player_ibfk_2` FOREIGN KEY (`skill_id`) REFERENCES `skill` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `player` WRITE;
/*!40000 ALTER TABLE `player` DISABLE KEYS */;
/*!40000 ALTER TABLE `player` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `player_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_action` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL COMMENT '行动玩家ID',
  `player_name` varchar(50) DEFAULT NULL COMMENT '玩家名称',
  `player_faction` varchar(20) DEFAULT NULL COMMENT '玩家阵营',
  `action_slot` tinyint NOT NULL COMMENT '行动槽位(1或2)',
  `action_type` varchar(30) NOT NULL COMMENT '行动类型',
  `target_id` int DEFAULT NULL COMMENT '目标ID(地点ID/玩家ID等)',
  `target_name` varchar(100) DEFAULT NULL COMMENT '目标名称',
  `npc_id` int DEFAULT NULL COMMENT '互动NPC的ID',
  `npc_name` varchar(50) DEFAULT NULL COMMENT '互动NPC名称',
  `notes` text COMMENT '备注说明',
  `result` text COMMENT '行动结果',
  `status` enum('pending','feedbacked') NOT NULL DEFAULT 'pending' COMMENT '反馈状态',
  `feedback_published` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已向玩家发布反馈',
  `game_day` int NOT NULL DEFAULT '1' COMMENT '游戏天数',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_player_id` (`player_id`),
  KEY `idx_action_type` (`action_type`),
  KEY `idx_status` (`status`),
  KEY `idx_game_day` (`game_day`),
  KEY `idx_player_day` (`player_id`,`game_day`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='玩家行动表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `player_action` WRITE;
/*!40000 ALTER TABLE `player_action` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_action` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `player_daily_consumption`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_daily_consumption` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL,
  `game_day` int NOT NULL,
  `required_food_units` int NOT NULL DEFAULT '2',
  `required_fuel_kg` int NOT NULL DEFAULT '25',
  `consumed_food_units` int NOT NULL DEFAULT '0',
  `consumed_fuel_kg` int NOT NULL DEFAULT '0',
  `fuel_from_wood_kg` int NOT NULL DEFAULT '0',
  `fuel_from_fuel_kg` int NOT NULL DEFAULT '0',
  `submitted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_player_day` (`player_id`,`game_day`),
  KEY `idx_game_day` (`game_day`),
  CONSTRAINT `player_daily_consumption_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='玩家每日进食与取暖消耗记录';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `player_daily_consumption` WRITE;
/*!40000 ALTER TABLE `player_daily_consumption` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_daily_consumption` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `player_exploration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_exploration` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `event_id` int DEFAULT NULL,
  `game_day` int NOT NULL,
  `player_id` int NOT NULL,
  `player_name` varchar(50) DEFAULT NULL,
  `result` text,
  `status` varchar(20) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `dice_result` int DEFAULT NULL,
  `invest_points` int DEFAULT NULL,
  `total_exploration_value` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `player_exploration` WRITE;
/*!40000 ALTER TABLE `player_exploration` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_exploration` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `player_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL,
  `item_type` enum('item','weapon','ammo','material') NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_player_type_item` (`player_id`,`item_type`,`item_id`),
  KEY `idx_player_type` (`player_id`,`item_type`),
  CONSTRAINT `player_items_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `player_items` WRITE;
/*!40000 ALTER TABLE `player_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_items` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `player_marker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_marker` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `visible_to_player` tinyint(1) NOT NULL DEFAULT '0',
  `note` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_player_marker_player` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `player_marker` WRITE;
/*!40000 ALTER TABLE `player_marker` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_marker` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `player_notebook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_notebook` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL,
  `title` varchar(80) NOT NULL DEFAULT '未命名',
  `body` text,
  `sort_order` int NOT NULL DEFAULT '0',
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_player_notebook_player` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `player_notebook` WRITE;
/*!40000 ALTER TABLE `player_notebook` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_notebook` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `player_npc_recognition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_npc_recognition` (
  `id` int NOT NULL AUTO_INCREMENT,
  `location_id` int DEFAULT NULL,
  `npc_id` int NOT NULL,
  `player_id` int NOT NULL,
  `recognized_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `player_npc_recognition` WRITE;
/*!40000 ALTER TABLE `player_npc_recognition` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_npc_recognition` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `player_stealth`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `player_stealth` (
  `id` int NOT NULL AUTO_INCREMENT,
  `player_id` int NOT NULL COMMENT '玩家ID',
  `player_name` varchar(50) DEFAULT NULL COMMENT '玩家名称',
  `game_day` int NOT NULL COMMENT '潜行生效的天数',
  `source_action_id` int DEFAULT NULL COMMENT '来源行动ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_player_day` (`player_id`,`game_day`),
  KEY `idx_game_day` (`game_day`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='玩家潜行状态表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `player_stealth` WRITE;
/*!40000 ALTER TABLE `player_stealth` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_stealth` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `quick_interaction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quick_interaction` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` text NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `dm_reply` text,
  `faction` varchar(20) NOT NULL,
  `game_day` int NOT NULL,
  `interaction_type` varchar(30) NOT NULL,
  `player_id` int NOT NULL,
  `player_name` varchar(50) DEFAULT NULL,
  `replied_at` datetime(6) DEFAULT NULL,
  `status` varchar(20) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `quick_interaction` WRITE;
/*!40000 ALTER TABLE `quick_interaction` DISABLE KEYS */;
/*!40000 ALTER TABLE `quick_interaction` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `rule_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rule_book` (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` text,
  `created_at` datetime(6) DEFAULT NULL,
  `order_num` int NOT NULL,
  `section` varchar(50) NOT NULL,
  `title` varchar(100) NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=156 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `rule_book` WRITE;
/*!40000 ALTER TABLE `rule_book` DISABLE KEYS */;
INSERT INTO `rule_book` VALUES (130,'白天自由行动（下午5点开始 7点结束）\r\n所有玩家选择两项自由行动\r\n1前往地点：选择一个地点进行探索，可以获得对应地点的信息（可能的资源信息（取决于设施），防御值，npc名单。同时可以选择使用非上锁的设施和地点npc简单交互。\r\n在第一天开始时会在自己的家内醒来，会知道自己所在地点的信息。\r\n同时前往地点后，网站会弹出QQ群二维码。开放地点群共该玩家在其中商量策略，每天地点群会在当天晚上12点清空。待第二天时候可加入新地点群。\r\n2调查玩家：选择一玩家，知晓对方的自由行动，1/2概率获知阵营行动，无法调查潜行技能玩家。无法调查昨天隐藏行动玩家。\r\n3生产：根据职业技能生产对应资源\r\n4使用特性：使用需要行动点的特性\r\n5使用职业技能：使用可能的职业技能。如果没有标有行动的技能不需要玩家行动就可以执行。\r\n6隐藏：隐藏起自己，第二天不会被调查，也无法被私聊，无法成为统治者与密谋的行动目标\r\n7搬运: 将物品从仓库移动到仓库或从仓库移动到自身，自身物品存放仓库不消耗行动点。\r\n\r\n主持人整理与反馈行动\r\n1在8点前结算“调查”，“特性”，“职业技能”，“调查玩家”。\r\n2在9点前结算结算“生产”',NULL,1,'每日游戏流程','每日游戏流程',NULL),(131,'白天自由行动（6:00-7:00）\r\n所有玩家选择两项自由行动。\r\n\r\n1.前往地点：选择一个地点进行探索，可以获得对应地点的信息（可能的资源信息取决于设施），防御值，NPC名单。同时可以选择使用非上锁的设施和地点NPC简单交互。\r\n在第一天开始时会在自己的家内醒来，会知道自己所在地点的信息。\r\n\r\n2.调查玩家：选择一玩家，知晓对方的自由行动，1/2概率获知阵营行动，无法调查潜行技能玩家。无法调查昨天隐藏行动玩家。\r\n\r\n3.生产：根据职业技能生产对应资源。\r\n\r\n4.使用特性：使用需要行动点的特性。\r\n\r\n5.使用职业技能：使用可能的职业技能。如果没有标有行动的技能不需要玩家行动就可以执行。\r\n\r\n6.隐藏：隐藏起自己，第二天不会被调查，也无法被私聊，无法成为统治者与密谋的行动目标。\r\n\r\n7.搬运：将物品从仓库移动到仓库或从仓库移动到自身，自身物品存放仓库不消耗行动点。\r\n\r\n主持人整理与反馈行动\r\n1.在8:00前结算\"调查\"、\"特性\"、\"职业技能\"、\"调查玩家\"。\r\n2.结算\"生产\"',NULL,2,'自由行动','白天自由行动',NULL),(132,'自由讨论（5:00开始）\r\n在这个时间段开放地点语音频道，任何玩家可以自由选择频道进行语音讨论。\r\n\r\n自由讨论规则\r\n1.尽可能使用语音或者小群。\r\n2.如达成\"协议\"，需告知主持人，使得\"协议\"技能或使用协议书生效。\r\n3.禁止在此阶段进行任何的场外录音行为。',NULL,3,'自由讨论','自由讨论',NULL),(133,'协议——某些讨论的结果需要告知主持人\r\n\r\n1.加入阵营：一位玩家接受另一位所属阵营的玩家的邀请，并加入阵营群。这种情况非初始阵营玩家可能背叛。\r\n\r\n2.契约协议：两位或多位玩家在群聊或者kook频道都在场的的情况下，达成合作的意向与合作目标，并由其中一位玩家与女巫沟通（需要女巫在场并且同意），完成契约协议，或者使用协议书。如果违反协议内容，则会受到严苛的惩罚（由女巫或协议书使用者决定）。契约协议必须是一个完整的句子，不能是多条不相干的内容。每人每天最多签订一个契约。\r\n只有女巫（男巫）可以签订契约，若不使用协议书签订内容会被公开。但只公开内容不公开谁签订的契约。\r\n\r\n3.物品交换：两位或多位玩家交换物品。\r\n\r\n4.冒险者、反抗者、统治者阵营初始拥有1个协议书。\r\n\r\n什么不是协议？\r\n1.信息讨论：职业、拥有物品、行为、线索等等信息都不是协议。\r\n2.口头协作：两位或多位玩家达成合作的意向，临时加入阵营。',NULL,4,'协议','协议',NULL),(134,'夜间阶段（8点到所有结算完毕）\r\n在该阶段，玩家的行动与可能的暴力冲突根据其顺序结算，与结算事件相关的玩家需要去往对应的地点群，进行结算。而无关的玩家可以继续进行自由讨论。\r\n1 .探索阶段\r\n在夜晚阶段，你可以输入探索小岛行动，你会得到一些关于小岛的背景与秘密信息以及各种类型的资源。但是你将会跳过夜晚阶段的其他行动。 在持有物品:手电筒，绳索，火把，帆布物品时会提高探索发现高价值物品的概率。 \r\n2.玩家默认所在夜晚地点为自己家中。如果白天有前往地点行动，可选择是否在对应地点过夜（需在行动中勾选登记）。如需在夜晚变更过夜地点，需消耗夜晚行动点。主持人计算可能的冲突，并确认是否发生阵营行动与暴力冲突。\r\n3.结算阵营行动与暴力冲突\r\n夜间行动时生产建造搬运类优先结算，战斗与冲突最后结算。\r\n如果想要指定杀某个人就要在白天行动时使用调查明确对方的去向。如果是为了杀人去的某地点但是对方不在可以选择是否发起攻击，如果不攻击本行动点不会返还。\r\n如果发生A想杀→B想杀→C的情况。\r\n会判定为先结算B→C，再结算A→B。在此类情况下不会发生混战情况。\r\n如果A想杀→C，B想杀→C\r\n会判定为A和B攻击C，AB是否进行战斗是在AB攻击C之后询问两方意见的。此时因为不在对应地点内，防守方战斗应不计地点防御值。\r\n4.统治者需要商议第二天劳工名单，并在夜晚结算之前给与主持人。\r\n5.阵营告示主持人可能要公开的信息\r\n6.主持人公开可以公开的夜间阶段总结信息\r\n例如死亡人数，但不会告知死亡地点和何人死亡。哪里被袭击等等。\r\n7.消耗燃料与食物\r\n每人每天的基础燃料消耗是15kg木材或者1kg燃料，如因其他技能或者天灾出现极寒情况。基础消耗调整为30kg木材。\r\n每人每天的基础食物消耗是2单位。\r\n8.结算所有资源与设施情况',NULL,5,'夜间阶段','夜间阶段',NULL),(135,'一、群组\r\n1.四个阵营组建微信群组，可以在任意时间段自由讨论。如果在自由讨论阶段平民明确加入阵营并签订协议，通知主持人并拉入对应阵营群聊。\r\n2.所有的暴力冲突由主持人拉冲突参与者建小群，冲突结束后解散。\r\n3.所有人都在的微信群在游戏开始后禁止讨论。\r\n\r\n二、kook语音频道\r\n自由讨论阶段的语音频道，由玩家自主组织。\r\n\r\n三、kook公屏（集市）\r\n自由讨论阶段的文字频道，记住文字频道会留下记录，谨慎讨论。\r\n\r\n四、kook留言板\r\n在游戏中，统治者与冒险者可以在该频道发布信息，例如招募、资源征集等等。\r\n\r\n禁止一切形式的私自拉群行为。',NULL,6,'群组与交流','群组与交流',NULL),(136,'资源交换：核心原则\r\n\r\n1.自由自主的交换：玩家间交易遵旨自愿、自由、自主的原则。玩家可以在任何可能的交流场景达成资源交换的意图。所有交换双方是自愿、自由的。\r\n\r\n2.见证人：所有资源交换需要告知主持人，由主持人见证确保双方资源交换属实，只需要告知一下就可以。\r\n\r\n3.信息不对称：交换双方对资源真实价值、稀缺度和自身需求的信息不同。\r\n\r\n4.物资交换登记：交换任意一方需在网站页面上填写对应的物资数量，并发给主持人对应交易的kook截屏即为物资交换完成。\r\n\r\n参考\r\n- 摆摊：玩家可在KOOK公屏（集市）发布文字信息。发布[求购]急需医疗资源，可用木材或情报交换。\r\n- 公开拍卖：统治者或拥有大量资源的玩家可发起资源出售，自由设定商品单与交易形式。',NULL,7,'资源交换','资源交换',NULL),(137,'一、玩家与玩家仓库资源转移\r\n在夜晚阶段自由交换，但是需告知主持人。\r\n\r\n二、玩家与仓库资源转移\r\n- 小镇内地点转移：一人一天不影响玩家行动的情况下50kg，跳过玩家行动300kg。\r\n- 岛屿地点转移：一人一天不影响玩家行动的情况下30kg，跳过玩家行动300kg。\r\n\r\n三、仓库与仓库资源转移\r\n- 小镇内地点：一人一天不影响玩家行动的情况下100kg，跳过玩家行动可以搬运500kg。不同的载具可以额外增加搬运量。\r\n- 岛屿地点：一人一天不影响玩家行动的情况下50kg。跳过玩家行动可以搬运300kg。不同的载具可以额外增加搬运量。\r\n\r\n四、生产资源原则\r\n- 自主原则：在网站行动选择哪个行动进行生产。\r\n- 强迫原则：如果因其他玩家强迫行动生产，被强迫方可以告知主持人，将生产资源添加到自己的仓库。',NULL,8,'资源移动','资源移动',NULL),(138,'战斗规则:\r\n一、计算总战力\r\n总战力 = 参战人数 + 武器威胁值之和 + 地点防御值（仅有守方） + 技能/特性加成\r\n技能加成：\r\n- 格斗（使用近战武器）：+1\r\n- 射击（使用远程武器）：+1\r\n地点防御值：守方直接加在总战力里，攻方不加。如果触发里应外合则失效。\r\n防弹衣/盾：不加战力，用于抵消受伤。可将一次「重伤」降级为「受伤」，或将一次「受伤」无效化。一人仅能穿戴其中之一，在一场战斗生效一次。\r\n\r\n二、最终攻击力判定\r\n攻方最终战力 = 攻方总战力 + 每人投掷1d6\r\n守方最终战力 = 守方总战力 + 每人投掷1d6\r\n差值 = 攻方最终 - 守方最终\r\n调整值 = 差值 × 3 ÷ 人数（向上取整）\r\n\r\n三、根据调整值决定战斗结果\r\n范围	结果名称	攻方	守方\r\n≥7	大胜	无伤	1人死亡，其余受伤\r\n4-6	胜利	无伤	1-2人重伤，其余受伤\r\n1-3	小胜	无伤	全部受伤\r\n0	僵持	1人受伤	1人受伤\r\n-1～-3	小败	全部受伤	无伤\r\n-4～-6	失败	1-2人重伤，其余受伤	无伤\r\n≤-7	大败	1人死亡，其余受伤	无伤\r\n\r\n四、额外命中伤害\r\n玩家如果使用武器进行攻击投掷时，会根据投掷的1d6加值来额外判定受伤情况。如果投掷值小于武器的威胁值（加值），则会优先选择对健康对方玩家随机造成一次受伤判定。受攻击玩家进行一次1d6投掷判定值，根据下表判定受伤情况。\r\n（玩家在单次战斗轮中仅会结算一次受伤：若在战力比拼中已受伤，则额外命中不会再叠成重伤；但额外命中得到重伤可以覆盖之前的受伤效果。）\r\n\r\n判定值	1	2	3	4	5	6\r\n威胁值1	未命中	未命中	受伤	受伤	受伤	受伤\r\n威胁值2	未命中	未命中	未命中	受伤	受伤	重伤\r\n威胁值3	未命中	未命中	未命中	受伤	受伤	重伤\r\n威胁值4	未命中	未命中	未命中	未命中	重伤	重伤\r\n威胁值5	未命中	未命中	未命中	受伤	受伤	重伤\r\n威胁值6	未命中	未命中	未命中	未命中	重伤	重伤+虚弱\r\n威胁值10	未命中	受伤	受伤	重伤	重伤	死亡\r\n\r\n武器威胁值对应（以武器图鉴为准）：\r\n威胁值1：警棍，十字镐，手术刀\r\n威胁值2：斧头，刺刀，水手刀（水果刀）\r\n威胁值3：鱼叉/矛\r\n威胁值4：电锯，猎弓\r\n威胁值5：制式手枪，炸弹外围\r\n威胁值6：猎枪\r\n威胁值10：炸弹内围\r\n\r\n五、伤害说明\r\n受伤：获得「受伤」标记（无法生产，格斗无效），可被医疗消除。\r\n重伤：获得「重伤」标记（无法行动，每夜阶段结束时若不急救则死亡）。急救消耗5医疗资源，将重伤转为受伤。\r\n虚弱：每日消耗未满足会导致虚弱，二次虚弱会死亡。\r\n死亡：直接移除角色。\r\n\r\n六、战斗事例\r\n示例均先计算调整值再定档。\r\n\r\n示例1（1v1）\r\n攻方1人（步枪威胁值4），守方1人（手枪威胁值2，地点防御2）\r\n攻方总战力=1+4=5，守方=1+2+2=5\r\n掷骰：攻方3→8，守方1→6，差值=2\r\n调整值=2×3÷2=3 → 小胜\r\n结果：守方受伤，攻方无伤。\r\n\r\n示例2（多人，大胜）\r\n攻方5人，武器威胁和=15，守方2人，武器威胁和=4，地点防御3\r\n攻方战力=5+15=20，守方=2+4+3=9\r\n攻方掷骰合计+6→26，守方+1→10，差值=16\r\n调整值=16×3÷7≈6.86 → 向上取整为7 → 大胜\r\n结果：守方1人死亡，另1人受伤。攻方无伤。\r\n\r\n七、死战规则\r\n死战释义：双方继续下一轮的攻击与防御，直到一方所有人受伤则强制结束死战状态（除了第一轮以外，防守方的地点防御值会除二并向上取整）。\r\n正常情况下，双方中只要均愿意继续打，则死战会存在。\r\n如果一方失败后可以选择败逃，战斗将结束。\r\n如果死战一直继续，会持续至死战结束条件：一方所有人受伤。\r\n整场战斗胜负判定由最后一场判定结果。\r\n大白话：要么把对面全打趴下，要么把对面打跑。',NULL,9,'战斗规则','战斗规则',NULL),(139,'一、状态说明\r\n- 受伤：获得「受伤」标记（无法生产，格斗无效），可被医疗消除。\r\n- 重伤：获得「重伤」标记（无法行动，每夜阶段结束时若不急救则死亡）。急救消耗5医疗资源，将重伤转为受伤。\r\n- 虚弱：每日消耗未满足会导致虚弱，二次虚弱会死亡。\r\n- 死亡：直接移除角色。\r\n\r\n二、战斗事例\r\n示例均先计算调整值再定档。\r\n\r\n示例1（1v1）\r\n攻方1人（步枪威胁值4），守方1人（手枪威胁值2，地点防御2）\r\n攻方总战力=1+4=5，守方=1+2+2=5\r\n掷骰：攻方3→8，守方1→6，差值=2\r\n调整值=2×3÷2=3 → 小胜\r\n结果：守方受伤，攻方无伤。\r\n\r\n示例2（多人，大胜）\r\n攻方5人，武器威胁和=15，守方2人，武器威胁和=4，地点防御3\r\n攻方战力=5+15=20，守方=2+4+3=9\r\n攻方掷骰合计+6→26，守方+1→10，差值=16\r\n调整值=16×3÷7 → 向上取整为7 → 大胜\r\n结果：守方1人死亡，另1人受伤。攻方无伤。',NULL,10,'伤亡规则','伤亡规则',NULL),(140,'在该阶段，玩家的行动与可能的暴力冲突根据其顺序结算，与结算事件相关的玩家需要去往对应的地点群，进行结算。而无关的玩家可以继续进行自由讨论。\r\n1 .探索阶段\r\n在夜晚阶段，你可以输入探索小岛行动，你会得到一些关于小岛的背景与秘密信息以及各种类型的资源。但是你将会跳过夜晚阶段的其他行动。 在持有物品:手电筒，绳索，火把，帆布物品时会提高探索发现高价值物品的概率。 \r\n2.玩家默认所在夜晚地点为自己家中。如果白天有前往地点行动，可选择是否在对应地点过夜（需在行动中勾选登记）。如需在夜晚变更过夜地点，需消耗夜晚行动点。主持人计算可能的冲突，并确认是否发生阵营行动与暴力冲突。\r\n3.结算阵营行动与暴力冲突\r\n夜间行动时生产建造搬运类优先结算，战斗与冲突最后结算。\r\n如果想要指定杀某个人就要在白天行动时使用调查明确对方的去向。如果是为了杀人去的某地点但是对方不在可以选择是否发起攻击，如果不攻击本行动点不会返还。\r\n如果发生A想杀→B想杀→C的情况。\r\n会判定为先结算B→C，再结算A→B。在此类情况下不会发生混战情况。\r\n如果A想杀→C，B想杀→C\r\n会判定为A和B攻击C，AB是否进行战斗是在AB攻击C之后询问两方意见的。此时因为不在对应地点内，防守方战斗应不计地点防御值。\r\n4.统治者需要商议第二天劳工名单，并在夜晚结算之前给与主持人。\r\n5.阵营告示主持人可能要公开的信息\r\n6.主持人公开可以公开的夜间阶段总结信息\r\n例如死亡人数，但不会告知死亡地点和何人死亡。哪里被袭击等等。\r\n7.消耗燃料与食物\r\n每人每天的基础燃料消耗是15kg木材或者1kg燃料，如因其他技能或者天灾出现极寒情况。基础消耗调整为30kg木材。\r\n每人每天的基础食物消耗是2单位。\r\n8.结算所有资源与设施情况',NULL,11,'夜间结算','夜间结算阶段规则',NULL),(141,'一、天灾倒计时\r\n通过一个0到100的数字，作为\"天灾\"的进度，当任何游戏阶段到达100时，当天夜晚阶段的最后，进入游戏结算。同时这个进度会影响游戏中六面骰的概率。同时，通过一套天灾牌额外增加天灾点数，与各结局最终的存活难度。\r\n- 每天默认推进33点，第三天推进34点。\r\n- 主持人会抽取3张秘密天灾牌，由杀戮者选择1张触发。特色技能可以查看天灾牌。\r\n\r\n二、六面骰\r\n在游戏中有很多行为或者判定需要骰6面骰来决定是否成功或决定判断结果，例如射击、天灾使者特殊规则、特性中的随机奖励。',NULL,12,'天灾系统','天灾系统',NULL),(142,'天灾牌\r\n1 低温侵袭\r\n某处墙体结冰，寒气渗入。本天所有燃料消耗增加100%，木材消耗量15kg→30kg。\r\n2灾难蔓延\r\n增加5天暴雪持续时间，方舟航行难度增加航行时间加2天。\r\n3粮仓鼠患 \r\n由天灾使者选择两个仓库\r\n仓库中储存的粮食被老鼠啃食，损失20%的食物储备（向下取整）\r\n4燃料泄漏 \r\n储油桶老化破裂，损失一处仓库的20%的燃料储备（优先扣除煤油/燃油）\r\n5工具锈蚀 \r\n生产工具普遍老化。当天所有生产行动（渔猎、伐木、挖矿等）产量-50%。\r\n6海水倒灌 \r\n风暴潮淹没码头设施，沿海仓库的部分物资被冲走（损失20%），方舟受损30%。\r\n7水源污染 \r\n岛上淡水水源被动物尸体污染，所有玩家当天需额外消耗1升煤油（烧开水）或面临患病风险\r\n8信仰崩塌 \r\n神父以及占卜师等精神领袖陷入自我怀疑，当天无法使用“布道”或“占星”技能。若第三天抽中不影响终局结算加成。\r\n9燃料受潮：露天堆放的木柴被雨淋湿。随机一个仓库或玩家损失30kg木材。\r\n10逃役\r\n一名劳工趁夜色逃走了。统治者当天指定的劳工名单中，随机一人自动失效（不会劳作，也不会计入劳工）。主持人随机选择，不公开是谁。该玩家知道自己被逃役释放，当天正常进行行动。\r\n11祭品\r\n有人在教堂门口发现一只被割喉的黑羊。第二天必定触发两张额外天灾牌（也就是第二天触发3张天灾牌）。\r\n12屋顶坍塌\r\n某栋小镇建筑（随机）的屋顶因积雪过厚而垮塌，压坏内部设施。\r\n效果：主持人随机选择一个小镇地点，该地点的防御值永久-2，且内部一个随机设施损坏（如发电机、烘焙炉、电报机等），需消耗 50kg木材 和 1次维修行动 修复。\r\n13道路冰封\r\n一夜之间，连接各主要地点的土路冻成镜面，车和人都打滑难行。\r\n当天所有地点之间的移动搬运量减半（任何运输行动效率-50%）。',NULL,13,'天灾牌','天灾牌',NULL),(143,'一、NPC基础规则\r\n- 会添加生产类NPC，NPC初始拥有不同阵营倾向。\r\n- NPC在不同的地点，玩家使用调查地点行动后知晓其地点存在的NPC列表。统治者开局知道所有NPC列表与其职业。\r\n- 对话行动可以与不同的NPC互动，获得不同的信息、效果，或者请求帮助。由主持人决定。\r\n\r\n二、态度说明\r\n- 喜好：该NPC会加入、帮助此阵营玩家。\r\n- 厌恶：该NPC会忽视、敌对此阵营玩家，不会提供帮助，反对被当做劳工等。\r\n- 忽视：该NPC对此阵营无感，不帮助也不会加入，如果被强迫，可能对寻找喜好阵营帮助。',NULL,15,'NPC规则','NPC规则',NULL),(144,'——你拥有这个岛屿上的巨大话语权与暴力力量，但是你无法肆意妄为，因为在暗地里，反抗者与天灾使者正在积蓄力量，你必须给予足够的空间与利益来收买更多的人来对抗反抗者与天灾使者。天灾使者自翊正义但掩盖不了他们是混沌的人，只想着杀人。也许你也可以称呼他们另一个名字——杀戮者\r\n阵营行动\r\n统治者行动只要可以执行就不限次数\r\n1安排人员——统治者可以安排一位玩家或者喜好统治者的npc执行自由行动，并强制共享自由行动的结果信息。玩家可以拒绝，这样做，统治者将有合理的理由进行审判。\r\n2安排看守——统治者在夜晚阶段之前安排人员选择一个地点，通常是仓库或统治者所在地。玩家可以拒绝，这样做，统治者将有合理的理由进行审判。每位看守为一个地点防御值增加3，以及携带唯一武器威胁值的防御值。注意，如果看守叛变会触发里应外合。\r\n阵营机制\r\n劳工：\r\n夜间阶段开始之前（每天18点前）统治者阵营讨论出一份由其他玩家组成的劳工名单，人数为0～10人（24人，0～6人，48人，0～10人）。\r\n\r\n成为劳工的玩家第二天白天行动将在矿场强制劳动，并添加“过劳”标记。该玩家的夜间行动可以进行，此时“过劳”标记已经生效\r\n\r\n统治者可以安排劳工进行\r\n建设避难所行动\r\n\r\n劳工类型	基础值	职业加成	压榨加成	最终成果\r\n普通劳工	4	0	0	4\r\n职业劳工	4	+1	0	5\r\n普通（压榨）	4	0	+3	7\r\n职业（压榨）	4	+1	+3	8\r\n\r\n统治者可以自由选择劳工的换班形式。一天一轮或不进行轮换。（但是要记住，食物与资源的生产仍然需要人手，而过度的压制会加强反抗者的势力，或是让所有阵营联合起来）\r\n\r\n过劳标记：\r\n拥有过劳标记无法执行生产行动。拥有过劳标记在进行劳工的行动，投1d6投，判定为1则死亡。过劳标记在第三天消除。也就是说，必须隔一天进行劳作\r\n\r\n压榨机制（统治者特权）\r\n·次数限制：无所需特性情况下统治者每天最多可以对 3名劳工 使用压榨。\r\n效果：被压榨劳工的建造值按上表翻倍（4→7 或 5→8），但立即获得「受伤」标记。\r\n受伤后果：无法进行生产行动，格斗技能无效。\r\n策略提示：压榨可以快速推进建造值，但会增加医疗负担和激起反抗情绪。\r\n\r\n矿场场景：\r\n矿场场景中成为劳工的玩家会失去第二天的自由行动，同时无法进行自由讨论。但是所有劳工可以在自由讨论阶段在矿场场景自由讨论。\r\n统治者可以在任何时间参与劳工的自由讨论。\r\n\r\n劳工规则：\r\n成为劳工的玩家白天无法使用自由行动点，夜晚行动点可以使用。\r\n作为劳工可以选择以下四种选项之一：\r\n1，正常工作+0\r\n骰1d6，私发正常工作的劳工事件\r\n2，消极工作-1\r\n骰1d6，私发消极工作的劳工事件\r\n3，努力工作+3\r\n骰1d6，骰出6不受伤\r\n4，逃役（进度变为0）\r\n骰1d6，骰出6成功逃役\r\n暴力机关：\r\n统治者与其下属控制着仓库与几乎所有的火器，在冲突中占据绝对的优势。\r\n在游戏开始，每位统治者拥有一把韦伯利 .38手枪与7发子弹。\r\n在游戏开始，仓库拥有大量的热武器。统治者可以自由分配武器，自由保存武器存放场景。\r\n\r\n你们初始就可以支配两名npc的行动\r\n1.乔克（监狱看守）初始武器:警棍，初始技能：无\r\n2.恩琪（民兵）初始武器:猎弓，弓箭2，初始技能：射击\r\n\r\n公开宣传：\r\n任何时候，统治者可以在频道公屏发布消息帖子。\r\n\r\n夜晚机制\r\n公开审判：\r\n统治者如果拥有对某个玩家的“合理”罪证信息（例如反抗统治者或天灾使者阵营，逃劳役等等）——可以选择在夜间阶段在集市召开公开审判。需要占用你们一人的夜间行动点召开，占用行动点的人为审判发起人。每次审判只可以审判一人。\r\n\r\n在审判期间，玩家可以在QQ内讨论。统治者可以选择性地收取民众的想法。或者选择公开投票的发生进行审判。\r\n\r\n审判结果最终由统治者决定，但如果不顺应民意可能会失去民众的信任。\r\n审判有以下几种结果\r\n1永久劳工。此玩家在后续游戏中一直成为劳工。\r\n2监禁。由统治者决定该玩家被囚禁在监狱，监禁时间无法进行任何自由行动。但需要保证他的基本存活。他的生存物资会从统治者仓库每日结算时自动扣除。\r\n3死刑。该玩家死亡。（不顺应民意使用此种结果请务必三思）\r\n4剥夺资产。该玩家的所有物品转移到统治者控制的仓库。\r\n5无罪。\r\n也许是真的无辜又或者你们为了其他人而妥协了。\r\n额外行动:\r\n作为统治者夜晚出行虽然不完全安全但如果非要这么做的话也不是不行。使用手电筒在夜晚时间你可以执行白天回合的一个任意行动，或者尝试杀掉某个绊脚石。\r\n此环节无法寻找npc进行对话，npc在没有前置沟通的情况下会默认回家睡觉。\r\n\r\n\r\n下属：\r\n统治者可以收买其他玩家，为自己做事。可以许诺资源，武器，阵营身份，或是权力。\r\n\r\n胜利条件\r\n目标1 扑灭反抗者与天灾使者，限制冒险者的发展，尽可能收买平民。\r\n目标2 建设避难所，在暴雪之前储备尽可能多的资源。\r\n目标3 让所有“自己人”和自己进入避难所。并且在暴雪将至阶段活下来。',NULL,16,'阵营机制','阵营机制-统治者',NULL),(145,'你不是暴徒，你是被迫举枪的平民。\r\n当统治者的铁腕压得整座岛屿喘不过气——劳工被压榨、资源被垄断、异见者被关进牢房，你选择了另一条路：反抗。\r\n反抗者不是天生的叛逆者，而是那些受够了沉默代价的人。你们在暗处联络同胞，用破坏和密谋削弱统治者的控制，用舆论和施压点燃平民的怒火。你们不追求权力，只追求平等与自由。\r\n你们可以与除了统治者之外的所有阵营交流沟通，收集更多的平民力量。如果有必要潜入统治者进行情报刺探也是不错的选择。\r\n阵营行动\r\n3选一\r\n1额外劳动：如果当天白天有行动的执行的生产，可以额外增加一半产出。\r\n2暗中联络：选择1-3位玩家，由主持人统一代发一条秘密信息。什么都可以，不超过50字符即可（以wps字符计算为准）\r\n3额外行动——作为反抗者你已经习惯在黑暗中行动，你不需要手电筒即可进行夜晚行动。在夜晚时间你可以执行白天回合的一个任意行动，或者尝试杀掉某个反抗革命的人。\r\n此环节无法寻找npc进行对话，npc在没有前置沟通的情况下会默认回家睡觉。\r\n\r\n初始资源：反叛者拥有猎枪 ×1，猎枪弹 ×2，猎弓 ×2，箭矢 ×4\r\n阵营机制\r\n向统治者施压：\r\n在夜间阶段，任何玩家都可以团结其他玩家发起对统治者的施压，通过在公屏中发声的方式。而如果反抗者拥有合理的理由（通常是统治者的暴政或贪腐），则可以通过宣传来扩大施压的声音，以罢工或其他方式以此威胁。理由通常需要在自由行动阶段进行调查获得。\r\n通常，施压的目标有，“一个合理的劳工换班机制”，“扩大民兵”，“让资源由全体镇民管理”等等。\r\n在夜晚阶段开始前计算统一参加施压的人群，如果同意施压的人群超过玩家半数，统治者就必须妥协。\r\n记住，反抗者不应该直接参与施压，一旦身份暴露，就有被坑杀的可能。应当在自由讨论阶段合理的利用舆论。\r\n\r\n夜间回合\r\n可以做也可以空过，可以从下述三个行动中选择一个执行\r\n\r\n1进行密谋：\r\n反抗者可以与其他阵营或平民联合组织一次秘密行动。在自由行动与自由讨论阶段，想要进行密谋的玩家确定想要参与的玩家。在夜间阶段想要产于的玩家私聊主持，确定最终参与人员。人员越多成功概率越高，被阻止的损失更高。\r\n\r\n袭击地点：需要组织者确定袭击地点。可探索地点和统治者仓库（不显示在地图上）\r\n每一位参与者增加一点成功率，参与者每一个拥有“潜行”技能增加1点成功率。每一位参与者佩戴唯一一把武器，增加武器对应“威慑点”的成功率。\r\n每个地点拥有基础防御值。统治者在目标地点的每一位玩家增加3点防御值，每一位玩家佩戴的唯一一把武器，增加武器对应“威慑点”的防御值。\r\n\r\n在夜间阶段结算密谋，比较成功率与防御值的。\r\n如果成功率大于防御值超过3点则密谋成功。\r\n如果超过9点，行动成功，但行动暴露，所有参与成员名称公开。\r\n如果不超过3点，则失败。如果有，则需要放弃一把武器。\r\n如果成功率小于防御值，则行动失败。参与行动者可以选择受降或者暴力反抗。\r\n\r\n如果成功，玩家可以选择破坏该地点，或选择搜刮。搜刮会直接烧毁该地点，在之后的游戏中，无法前往，无法使用该地点的设施，导致npc死亡。搜刮则可以带走地点的所有资源。\r\n\r\n破坏：选择一个地点的一个或多个设施，使其无法使用。施工维修技能和维修资源后才可以重新投入使用。如果目标地点被安排看守，则无法破坏。\r\n\r\n如果有民兵或治安官或看守里应外合，则减少3点防御值。\r\n\r\n2暗杀统治者：需要组织者确定统治者所在的地点。\r\n每一位参与者增加一点成功率，参与者每一个拥有“潜行”技能增加1点成功率。每一位参与者佩戴武器，增加武器对应“威慑点”的成功率。\r\n\r\n每个地点拥有基础防御值。统治者在目标地点的每一位玩家增加3点防御值，每一位玩家佩戴的唯一一把武器，增加武器对应“威慑点”的防御值。\r\n\r\n在夜间阶段结算密谋，比较成功率与防御值的\r\n如果成功率大于防御值超过3点则密谋成功，目标统治者死亡。\r\n如果超过9点，则目标统治者死亡，但行动暴露，所有参与成员名称公开。\r\n如果不超过3点，则失败。如果有，则需要放弃一把武器。或者暴力冲突\r\n如果成功率小于防御值，则行动失败。参与行动者可以选择受降或者暴力反抗。\r\n\r\n如果统治者死亡，统治者阵营可以选择是否公开死亡消息。\r\n\r\n如果有玩家能够里应外合，则减少3点防御值。\r\n\r\n3解救人员：需要组织者确定被关押人员所在的地点。\r\n每一位参与者增加一点成功率，参与者每一个拥有“潜行”技能增加3点成功率。每一位参与者佩戴唯一一把武器，增加武器对应“威慑点”的成功率。\r\n\r\n每个地点拥有基础防御值。统治者在目标地点的每一位玩家增加3点防御值，每一位玩家佩戴的唯一一把武器，增加武器对应“威慑点”的防御值。\r\n\r\n在夜间阶段结算密谋，比较成功率与防御值的\r\n如果成功率大于防御值超过3点则密谋成功，解救该地点成员。\r\n如果超过9点，密谋成功，解救该地点成员，但行动暴露，所有参与成员名称公开。\r\n如果不超过3点，则失败。如果有，则需要放弃一把武器。\r\n如果成功率小于防御值，则行动失败，参与行动者可以选择受降或者暴力反抗。\r\n\r\n如果有玩家或者NPC里应外合，则减少3点防御值。\r\n里程碑\r\n策划暴力革命掀起反抗的火种，当然需要完成一定的事件，赢得大家的青睐。\r\n在下列里程碑事件之中，完成任意其中三个。即可在当天或之后的阵营回合之中选择策划暴力革命。\r\n策划暴力革命：\r\n当反抗者认为自身的人员与武装力量能够直接对抗统治者与其走狗和武装力量，就可以发起一场彻底的革命。\r\n在此次冲突中，所有参与冲突的反抗者阵营成员战斗值+1，没有累加上限。\r\n每多完成比三个里程碑多一个的里程碑，总战力额外+2，上限+4。\r\n在确定日期当天，所有想要参与的玩家私信主持人，决定最终参与者。在夜晚阶段，结算目标地点当天的统治者阵营的人员，进入暴力革命与暴力冲突阶段。\r\n\r\n里程碑事件\r\n1团结平民： \r\n星星之火也可以燎原\r\n反抗者拥有一个初始协议书。\r\n反抗者应当与更多的玩家讨论，明确对方的特性，资源，加入阵营的意向，并且对其进行观察，辨别可能的内鬼。\r\n当包括初始反抗者在内的确认加入反抗者名单大于等于8人后（以签订了契约加入微信群聊为准，以死亡玩家应也计算在内），该里程碑事件完成。\r\n\r\n2解放我们的同伴。\r\n铁窗锁不住自由的心。\r\n目前在监狱里面的同伴都是曾经为了我们的革命事业献出自由乃是生命的同志。所以解放他们对于我们来讲至关重要。解救身在监狱中的那些同伴，他们将继续加入你们，并点燃这个岛上平民心中对于自由的渴望。\r\n当同伴被解救出来，该里程碑事件完成。\r\n3我们不是生来就应该如此\r\n在统治者使用审判环节，若被审判人员为加入反抗者阵营中人。要尽力解救我们的同胞，避免让他被统治者所残害。\r\n当被审判的反抗者人员被无罪释放，该里程碑事件完成。\r\n4反抗不是我们的目的，平等才是。\r\n不给人活路，那就掀桌子。\r\n你们或联系任意你们信任的人。向统治者进行施压，要求调整劳工名单或者让统治者分配一定的资源给其他镇民。\r\n当该施压投票超过半数被统治者同意，该里程碑事件完成。\r\n5正义属于我们\r\n敌人的刀，也能转过来对着他们自己。\r\n有1名原本属于统治者阵营的玩家（或主持人控制的NPC）主动投靠反抗者，并提供信息或协助。该里程碑事件完成。\r\n6团结一切可以团结的力量。\r\n那些外来人，要么帮忙，要么别挡道。\r\n至少1名冒险者身份的玩家公开承诺在革命日当天加入反抗者起义，或至少2名冒险者承诺保持中立（不帮统治者）。需以契约为证。\r\n完成上述条件后，该里程碑事件完成。\r\n7让人民觉醒\r\n第一条血债，就是最好的宣言。\r\n当第一次有玩家因为统治者的直接行为（审判、冲突，抓捕等，由主持人判定）死亡或重伤后，主持人会秘密告知反抗者阵营这条消息。\r\n得知消息后，反抗者在当晚的夜间回合一名反叛者可以花费一行动点发起一次匿名投票，向全体玩家问一个问题：\r\n“统治者是否草菅人命？”\r\n投票规则：\r\n匿名投票，每人一票。\r\n选项为“是”或“否”。\r\n·如果投票人数超过玩家总数的一半，且其中同意“是”的票数多于“否”，该里程碑完成。该投票统治者无法参加。\r\n胜利条件\r\n目标1 推翻统治者，与冒险者争夺资源，揪出天灾使者，团结尽可能多的平民。\r\n目标2 获得武装力量，占领仓库，在暴雪之前储备尽可能多的资源。\r\n目标3 尽可能让所有人进入避难所。在暴雪将至阶段活下来。',NULL,17,'阵营机制','阵营机制-反抗者',NULL),(146,'——在集体大会中，支持建设避难所的平民远高于建设大船，但是你依旧坚持这场灾难不会结束。而随着统治者暴力的加强，更多人会明白，建设避难所是一个糟糕的决定。建设方舟：一艘20世纪的帆船已经破旧不堪，但是仍然比归属于渔民与船队的渔船大得多，或许可以召集人手修复好帆船，在暴雨来临前让更多人逃离。\r\n\r\n阵营行动\r\n4选1\r\n1额外调查：如果当天执行的调查地点，调查玩家。调查地点改为两个，调查玩家改为两名。\r\n2额外劳动：如果当天有至少任意一个行动点执行的生产，可以额外增加一半产出。\r\n3看守方舟——冒险者在白天行动阶段可以使用行动点作为方舟看守，在夜晚阶段为方舟建造地点增加对于武器与技能的防御值。\r\n4方舟建设：在阵营回合可以进行方舟建造，在第三天开始时加入冒险者的人员都可以用自己所拥有的任意数量行动点进行方舟建造。\r\n\r\n 初始资源：拥有猎弓2，12只箭，1只矛，一把手枪，4发手枪子弹。\r\n阵营机制\r\n1收集物资\r\n在游戏中，冒险者需要整合成员已有的资源，与其他阵营与玩家交换资源，生产资源，公开宣传以募集资源，直接冲突争夺资源，来获得建设方舟的材料与出航的必要物资。\r\n建设方舟的总共资源（25点载重的情况）\r\n木材25吨\r\n金属制品 10吨\r\n密封材料:沥青100kg\r\n发动机 至少1个，最多3个\r\n螺旋桨2个\r\n发电机1个\r\n\r\n2.技能资源（出海需要的技能，为终局结算提供更多的优势。\r\n航海\r\n海洋导航\r\n天气预报\r\n渔猎\r\n \r\n\r\n\r\n3.建设与载重方案\r\n船身大小：冒险者可以选择不同的建设方案来匹配人数。\r\n初始已完成5吨木材，1吨金属制品资源的建设。（根据参与人数改变）\r\n \r\n以25吨木材的大小为基础设计，为25点载重。更小的船型会更加劣势。\r\n在完成20点基础载重之后，每增加2吨木材，1吨金属制品与5公斤密封材料，可以增加2点载重。\r\n每缺少2吨木材或1吨金属制品或5公斤密封材料，减少3点载重，百分之2.5方舟完成度，只需缺少一条资源条目。资源短缺是短板效应，按最低缺少计算。\r\n \r\n建设规则：\r\n加入冒险者任意一人可以在阵营行动时花费一行动点投入不超过单日最高数量的任意数量资源进行建造:\r\n每天投入最高为\r\n木材5吨\r\n金属制品2吨\r\n密封材料30kg\r\n\r\n若材料不足需白天花费一人一行动点工作量推进:\r\n1吨木材\r\n500kg铁制品建造进度\r\n5kg密封材料\r\n \r\n3出航准备\r\na每1点载重一人，可以乘载一人\r\nb每1点载重，10单位食物\r\nc每1点载重，100kg燃料\r\nd每1点载重，50kg密封材料\r\ne每1点载重，1吨木材\r\nf医疗资源，武器，等物品不计算重量。\r\n \r\n海上时间\r\n注意，某些危机事件可能增加航行天数。每多一天就需要额外抽取一张危机事件牌。\r\n1个发动机	8天航行时间\r\n2个发动机	6天航行时间\r\n3个发动机	4天航行时间\r\n在没有发动机出航或者只有一个发动机的时候，可以制造帆来辅助航行。在具有两个发动机时帆的作用消失。\r\n单帆:\r\n消耗50m绳索和10米帆布。收集好材料后需要一个人夜晚阵营回合建造帆，之后就可以使用。\r\n效果:提供移速加成\r\n在没有发动机的时候，航行时间为10天。\r\n在只有一个发动机的时候，航行时间为7天。\r\n\r\n一个发动机时，消耗燃料100kg\r\n两个发动机时，消耗燃料200kg\r\n三个发动机时，消耗燃料300kg\r\n\r\n夜晚行动\r\n可以做可以不做。\r\n向统治者施压：\r\n在夜间阶段，任何冒险者阵营玩家都可以团结其他玩家发起对统治者的施压，通过在公屏中发声的方式。而如果冒险者拥有合理的理由（通常是统治者的暴政或贪腐，或是地下避难所的不可实施性），则可以通过宣传来扩大施压的声音，以罢工或其他方式以此威胁。——理由通常需要在自由行动阶段进行调查获得。\r\n\r\n通常，施压的目标有，“一个合理的劳工换班机制”，“让资源由全体镇民管理”，“增加方舟建设资源”等等。\r\n\r\n在夜晚阶段计算统一参加施压的人群，如果同意施压的人群超过玩家半数，统治者就必须妥协。\r\n\r\n公开宣传：\r\n任何时候，冒险者可以在频道公屏发布消息帖子，冒险者可以宣传造船进度，直接为方舟计划拉取人员支持与资源支持。\r\n\r\n\r\n进行密谋：\r\n1袭击地点：需要组织者确定地点。\r\n每一位参与者增加一点成功率，参与者每一个拥有“潜行”技能增加1点成功率。每一位参与者佩戴唯一一把武器，增加武器对应“威慑点”的成功率。\r\n\r\n每个地点拥有基础防御值。统治者在目标地点的每一位玩家增加3点防御值，每一位玩家佩戴的唯一一把武器，增加武器对应“威慑点”的防御值。\r\n\r\n在夜间阶段结算密谋，比较成功率与防御值的。\r\n如果成功率大于防御值超过3点则密谋成功。\r\n如果超过9点，行动成功，但行动暴露，所有参与成员名称公开。\r\n如果不超过3点，则失败。如果有，则需要放弃一把武器。\r\n如果成功率小于防御值，则行动失败。参与行动者可以选择受降或者暴力反抗。\r\n\r\n如果成功，玩家可以选择破坏该地点，或选择搜刮。搜刮会直接烧毁该地点，在之后的游戏中，无法前往，无法使用该地点的设施，导致npc死亡。搜刮则可以带走地点的所有资源。\r\n\r\n如果有民兵或治安官或看守里应外合，则减少3点防御值。\r\n\r\n2建造方舟\r\n规则如上\r\n胜利条件\r\n目标1：选择与反抗者或统治者结盟，拉拢更多的平民。\r\n目标2：获得更多的资源建设方舟。\r\n目标3：在暴雪将至前出海，活下去。',NULL,18,'阵营机制','阵营机制-冒险者',NULL),(147,'你们是天灾的使者，是净化这里的存在。这里已经是腐烂得无可救药了。统治者做着梦幻想统治永远存在却又看不起所有的居民；反抗者自以为正义实际上上位之后会不会变成统治者那些人也尤未可知；冒险者空有一腔热血但是方舟会去往哪里谁能知道。而且你们中有人知道的是大家……在这里的所有人——都是罪人。\r\n罪在哪里？\r\n眼睁睁看着邻居被送去审判，你闭了嘴，你是罪人。\r\n为了多领一份口粮，偷偷举报了别人，你是罪人。\r\n明知这座岛的规则是吃人的，你还是选择顺从，而不是站出来，你是罪人。\r\n统治者犯的罪是傲慢，反抗者犯的罪是自私，冒险者犯的罪是盲目，而普通人犯的罪是——沉默。\r\n所以，我们是执行者。\r\n所以是暴雪吗？是天灾吗？不！这是净化。\r\n阵营行动\r\n1破坏：选择一个地点的一个设施，使其无法使用。如果目标地点被安排安排监管，无法破坏\r\n2额外调查：如果当天执行的调查地点，调查玩家。调查地点改为两个，调查玩家改为两名。\r\n3诅咒:花费一件威胁值4以上的武器，选择2位玩家，知晓该玩家的阵营。该玩家被标记「诅咒」。\r\n每天最多两次\r\n\r\n阵营机制\r\n阻止胜利：\r\n天灾使者既可以是统治者的走狗，施加暴行，激化统治者与平民的矛盾，延缓建设的进度，也可以假扮反抗者或冒险者，分化各个阵营的力量或凝聚力。最终目的，都是增加玩家死亡，推进命运，减缓地下避难所与方舟的建设进度。尽可能让灾难杀死所有人。\r\n天灾使者知晓当天天灾牌的内容。\r\n正义的潜伏\r\n瘟疫使者特性的天灾使者可以以天灾使者的身份加入其他阵营，并使用两套阵营规则。仍然使用天灾使者的胜利条件。可以无视契约协议的惩罚一次，你是神的皮，瘟疫不涉及机身。\r\n天灾的馈赠\r\n饥荒使者特性的天灾使者可以在夜晚行动前往天灾指引地点找到天灾的馈赠，你会获得一批意料之外的物资，毕竟你是神的口，饥荒不涉及己身。\r\n锋锐的爪牙\r\n战争使者特性的天灾使者可以在触发死战的当场战斗中获得格斗和射击技能，如果本身拥有该技能则转变为威胁值+1。你是神的爪，把战争带给世人吧。\r\n\r\n夜晚回合\r\n进行密谋：\r\n1袭击地点：每一位参与者增加一点成功率，参与者每一个拥有“潜行”技能增加3点成功率。每一位参与者佩戴唯一一把武器，增加武器对应“威慑点”的成功率。\r\n\r\n每个地点拥有基础防御值。统治者布置在目标地点的每一位玩家增加3点防御值，每一位玩家佩戴的唯一一把武器，增加武器对应“威慑点”的防御值。\r\n\r\n在夜间阶段结算密谋，比较成功率与防御值的。\r\n如果成功率大于防御值超过3点则密谋成功。\r\n如果超过9点，行动成功，但行动暴露，所有参与成员名称公开。\r\n如果不超过3点，则失败。如果有，则需要放弃一把武器。\r\n如果成功率小于防御值，则行动失败。参与行动者可以选择受降或者暴力反抗。\r\n\r\n如果成功，玩家可以选择破坏该地点，或选择搜刮。搜刮会直接烧毁该地点，在之后的游戏中，无法前往，无法使用该地点的设施，导致npc死亡。搜刮则可以带走地点的所有资源\r\n     \r\n2制造恐怖：在夜晚阶段，天灾阵营可以发起一次制造恐怖。需要组织者确定袭击地点或玩家。袭击玩家需要对方拥有诅咒，至少一位参与者参与。\r\n袭击地点，则至少需要两位参与者。\r\n制造恐怖的基础成功率取决于场上诅咒的数量，和参与者的数量。\r\n每有一个诅咒（包括普通诅咒和瘟疫诅咒。）成功概率+1\r\n每额外多一名参与者，成功概率+1\r\n使用1d6骰子投出数值+成功概率。结果大等于6既为成功。无视所有的防具，战力差距。\r\n在第一天时有平民玩家因为使者制造恐怖而死亡时，对方将受到天灾的感召。阵营身份变更为天灾使者继续进行游戏。（仅限一人）\r\n保留对方原有特性和技能。\r\n如果失败，参与者将暴露身份。身份被目标地点所属玩家与目标玩家知晓。不会告知你的具体身份是天灾使者。只会告知玩家袭击了对方，没有成功。\r\n同时所有被诅咒标记玩家在公屏公开。\r\n如果成功，如果目标拥有诅咒，目标玩家死亡。如果是目标地点，由参与者选择破坏1d6数量的资源品名或设施。\r\n\r\n如果目标死亡，统治者阵营可以选择是否公开死亡消息。\r\n\r\n神契：\r\n当命运之轮到达100，触发暴雪将至。\r\n杀戮者共有三个神启身份对应其他玩家的特性，名为:瘟疫，战争和饥荒。如果剩下的杀戮玩家只剩下一位他变为死亡骑士，特性更改为死亡骑士。\r\n\r\n胜利条件\r\n目标1 隐藏在人群中，蛊惑平民，制造信息迷雾，破坏其他阵营的策略。\r\n目标2 阻止方舟与避难所的建设，破坏资源与仓库。\r\n目标3 混入终局结算，成为天灾的眼睛',NULL,19,'阵营机制','阵营机制-天灾使者',NULL),(148,'阵营机制\r\n加入阵营：\r\n平民玩家可以自由选择加入反抗者或是冒险者的阵营，或是成为统治者的下属。\r\n\r\n口头契约：\r\n玩家与玩家之间可以口头协议加入阵营，但无法使用阵营行动与机制。但在这种情况下，平民玩家可以通过口头契约加入多个阵营。\r\n\r\n自组织：平民玩家可以尝试形成团体，为一个目标行动。\r\n\r\n加入阵营与背叛：\r\n平民玩家可以通过各种方式，加入某个阵营。加入对应阵营的玩家可以使用阵营机制与阵营行动。可以在行动阶段告知主持人决定背叛，在夜晚阶段由主持人结束背叛阵营事件，并且踢出阵营群聊。发无再使用阵营机制与阵营行动。\r\n\r\n夜晚行动\r\n进行密谋：\r\n1袭击地点：需要组织者确定地点。\r\n每一位参与者增加一点成功率，参与者每一个拥有“潜行”技能增加1点成功率。每一位参与者佩戴唯一一把武器，增加武器对应“威慑点”的成功率。\r\n每个地点拥有基础防御值。统治者在目标地点的每一位玩家增加3点防御值，每一位玩家佩戴的唯一一把武器，增加武器对应“威慑点”的防御值。\r\n\r\n在夜间阶段结算密谋，比较成功率与防御值的。\r\n如果成功率大于防御值超过3点则密谋成功。\r\n如果超过9点，行动成功，但行动暴露，所有参与成员名称公开。\r\n如果不超过3点，则失败。如果有，则需要放弃一把武器。\r\n如果成功率小于防御值，则行动失败。参与行动者可以选择受降或者暴力反抗。\r\n\r\n如果成功，玩家可以选择破坏该地点，或选择搜刮。搜刮会直接烧毁该地点，在之后的游戏中，无法前往，无法使用该地点的设施，导致npc死亡。搜刮则可以带走地点的所有资源\r\n如果有民兵或治安官或看守里应外合，则减少3点防御值。\r\n\r\n\r\n探索岛屿\r\n在夜晚阶段，你可以输入探索小岛行动，你会得到一些关于小岛的背景与秘密信息以及各种类型的资源。但是你将会跳过夜晚阶段的其他行动。\r\n在持有物品:手电筒，绳索，火把，蜡烛时会提高探索发现高价值物品的概率。\r\n每种物品只可提供最高7的加成，物品合计加值最高为15。\r\n在此会由一个6面骰子+额外探索物品探索值决定走向何处。\r\n有1-20探索难度的若干个地点供大家探索。\r\n探索地点每个地点都为唯一地点，被探索后不再能被其他人探索，只有20点的特殊探索地点可以反复前往。\r\n每次探索都会消耗持有的道具。\r\n胜利条件\r\n目标1 你也要死吗？不，请活下去，直到最后\r\n目标2 加入其他阵营，为一个新的目标而斗争，共享阵营结算结局。\r\n\r\n',NULL,20,'阵营机制','阵营机制-平民',NULL),(149,'船身大小：冒险者可以选择不同的建设方案来匹配人数。\r\n初始已完成5吨木材，1吨金属制品资源的建设。（根据参与人数改变）\r\n \r\n以25吨木材的大小为基础设计，为25点载重。更小的船型会更加劣势。\r\n在完成20点基础载重之后，每增加2吨木材，1吨金属制品与5公斤密封材料，可以增加2点载重。\r\n每缺少2吨木材或1吨金属制品或5公斤密封材料，减少3点载重，百分之2.5方舟完成度，只需缺少一条资源条目。资源短缺是短板效应，按最低缺少计算。\r\n \r\n建设规则：\r\n加入冒险者任意一人可以在阵营行动时花费一行动点投入不超过单日最高数量的任意数量资源进行建造:\r\n每天投入最高为\r\n木材5吨\r\n金属制品2吨\r\n密封材料30kg\r\n\r\n若材料不足需白天花费一人一行动点工作量推进:\r\n1吨木材\r\n500kg铁制品建造进度\r\n5kg密封材料\r\n \r\n3出航准备\r\na每1点载重一人，可以乘载一人\r\nb每1点载重，10单位食物\r\nc每1点载重，100kg燃料\r\nd每1点载重，50kg密封材料\r\ne每1点载重，1吨木材\r\nf医疗资源，武器，等物品不计算重量。\r\n \r\n海上时间\r\n注意，某些危机事件可能增加航行天数。每多一天就需要额外抽取一张危机事件牌。\r\n1个发动机	8天航行时间\r\n2个发动机	6天航行时间\r\n3个发动机	4天航行时间\r\n在没有发动机出航或者只有一个发动机的时候，可以制造帆来辅助航行。在具有两个发动机时帆的作用消失。\r\n单帆:\r\n消耗50m绳索和10米帆布。收集好材料后需要一个人夜晚阵营回合建造帆，之后就可以使用。\r\n效果:提供移速加成\r\n在没有发动机的时候，航行时间为10天。\r\n在只有一个发动机的时候，航行时间为7天。\r\n\r\n一个发动机时，消耗燃料100kg\r\n两个发动机时，消耗燃料200kg\r\n三个发动机时，消耗燃料300kg',NULL,21,'方舟建造','方舟建造',NULL),(150,'战斗类:\r\n格斗——在密谋，暴力冲突中，如果没有装备，或者装备近距离武器，增加1威胁值。\r\n射击——在密谋，暴力冲突中，如装备远距离武器时增加1威胁值。如果没有射击，装备远距离武器时，武器威胁值减半，向下取整。\r\n\r\n生产类（在白天行动阶段使用生产行动，如需设施需要对应设施完好）\r\n捕鱼：在码头使用渔船设施 获得食物10单位\r\n食物生产：使用牲畜设施 获得食物15单位\r\n伐木：使用电锯5吨木材，否则1吨\r\n挖掘：使用电钻5吨石料，否则1吨\r\n手工艺：工具制备单制作一件或至多3件材料，物品或武器。制作列表如下\r\n复合盾	3kg金属制品，3kg木材	1副\r\n鱼叉/矛	5kg金属制品，5kg木材	1支\r\n规制箭矢	3kg木材，3kg金属制品	3支\r\n猎弓	5kg金属制品，15kg木材	1把\r\n火把	5kg木材，1m帆布	1把\r\n木石工艺:使用木板蒸汽箱，将5吨木材转化为3吨木板，消耗50kg燃料使用切石机，将1吨石料转化为15米石墙\r\n射击狩猎：需要远程武器（无需子弹或弓箭）5kg肉。\r\n烧炭:使用煤炭炉，消耗一行动，使每150kg木材转为10单位燃料和相当于1医疗资源的1单位草木灰。每次行动至多转化750kg的木材。\r\n\r\n功能类（在白天阶段联系主持人使用，或者在快速行动中使用）\r\n潜行（被动）：为谋略增加成功率，除了隐藏技能外无法被调查。\r\n\r\n启蒙:每天白天行动时一次。消耗2盒粉笔，选择除自己之外最多2名玩家，使其临时学会一项基础技能（从以下列表中选：急救、潜行、格斗、捕鱼、伐木、挖矿），从第一天夜晚回合生效持续到第二天白天回合结束。若该玩家已经拥有该技能则增产50%\r\n\r\n布道：每天白天行动时一次。选择最多为3人，被布道的玩家在下一个行动中生产增加50%（渔猎，伐木，挖矿）/或者最多为3为玩家消除诅咒（被诅咒的玩家没有任何征兆，这是一个纯预判的技能效果）\r\n\r\n急救：花费5医疗资源，将“重伤”改为“受伤”标记。\r\n\r\n医疗：每天白天行动时一次。选择一位或至多5位“受伤”标记的玩家，目标消除“受伤”标记。每个花费3医疗资源，选择一位或多位过劳标记的玩家，消除过劳标记。每个花费2医疗资源。（可以混合总人数不超过5位）\r\n\r\n通灵：需消耗10根蜡烛和2升酒精举行仪式。\r\n每天白天行动时一次。与一位已死亡玩家建立临时私信交流，死亡玩家需要尽可能告知死前所有信息（由主持人保底提供信息）同时你有1/2概率会获得对方的技能。\r\n\r\n协议契约：为一位或多位玩家建立协议契约。可以指定违反协议的惩罚内容\r\n\r\n潜水：每天白天行动时可以进行一次。需在码头使用，由主持人投d6决定结果：1-5，食物8单位，6 沉船遗物（随机一件较高价值物品，由主持人决定，如医疗资源、维修工具包、旧手枪+弹药、信号枪等）\r\n\r\n维修：每天可使用一次。修复一个被破坏的设施或者物品，花费5维修资源\r\n\r\n搬运（被动）:搬运量永远是其他职业的两倍。\r\n\r\n调度:选择一处统治者控制的仓库，将其中最多100kg物资（任意类型）免费转移至另一处统治者仓库或自身仓库，不占用搬运行动，且不消耗移动配额。\r\n\r\n伪装（被动）：你从不在岛上抛头露面，你可以隐藏成为一个统治者组外的玩家职业并获得该职业技能。\r\n\r\n特殊（特殊技能需要自由行动中的技能行动执行）\r\n海洋导航：为方舟终局结算提供好的结局倾向，可以查看今日所有的天灾牌。\r\n\r\n偷盗：选择一位玩家，获得对方的秘密资源信息，选择一件物品获得。需要投掷1d6+1检定在5以上即可获得对方一件物品。\r\n天气预测：你通过科学的手段发现异常的暴雪天气的来临，可以查看今日所有的天灾牌。为所有终局结算提供好的结局倾向。\r\n\r\n占星：为避难所终局结算提供好的结局倾向。在全局游戏中你可以将一张天灾牌撕毁（不生效），或让一张危机事件牌撕毁（不生效）\r\n\r\n烘焙:需要10单位的食物和15kg木材可以制作一份面包。面包:当天额外获得1白天行动点，每人每天最多使用1次。\r\n\r\n巡逻:夜晚行动，若你目前是非阵营玩家想使用该技能而不想加入阵营可以用第二天的一个行动补觉（体现为第二天的一个自由行动将变为其他且只能睡觉）使用该技能。\r\n选择一个地点，当晚该地点内非统治者阵营玩家的夜晚行动成功率-30%，巡夜人知晓其行动类型。需要巡夜人当天未处于“劳工”或“过劳”状态。\r\n\r\n遗憾：若你与 船长职业的玩家在同一阵营，你在夜晚阶段，可以额外进行一次本日的 “调查玩家” 行动（用快速行动执行），且不消耗白天的行动次数。此效果每日限一次。若船长或大副阵营转变则失去该效果。\r\n若曾和船长玩家处于同一阵营之后船长玩家死亡，你在方舟结算时视为拥有技能 “海洋导航” 的效果。\r\n\r\n悬赏：消耗一行动，你消耗至少10单位（kg）的任意资源（如木材、食物、金属等）作为“悬赏金”，公开宣布悬赏一名 非己方阵营 的玩家。目标玩家必须在当天夜晚结算内 支付 悬赏金×1.5（向下取整）的资源给你，以消除悬赏。同一目标不可悬赏两次。\r\n若目标拒绝或未能支付，你将获得以下加成，直到悬赏被消除或你主动撤销：\r\n信息掌控：与目标处于同一地点时，你得知该目标在此地点所有自由行动的结果（如探索、生产）。   （2）冲突代价：与目标发生冲突时，你的总战力+2。若你在此次冲突中获胜，可从其随身物品中 选择一件非关键物品（不能是武器或防具） 作为战利品带走。',NULL,22,'技能表','技能表',NULL),(151,'一、状态标记\r\n- 过劳：拥有过劳标记无法执行生产行动、调查玩家和隐匿。拥有过劳标记在当天夜晚行动和第二天进行需要行动点的生产行动时，投1d6骰子，判定为1则死亡。过劳标记在第三天消除。也就是说，必须隔一天进行劳作。5瓶朗姆酒可以消除过劳状态。\r\n- 受伤：无法进行生产行动，格斗技能无效。\r\n- 重伤（致命伤害）：在夜晚阶段如果没有被急救，将死亡。\r\n- 束缚：无法执行自由行动和夜间行动，除非束缚被解除。\r\n- 虚弱：无法生产，格斗、射击技能无效，第三天消除，或者喝酒。\r\n- 诅咒标记：只有天灾使者知晓效果。\r\n\r\n二、其他\r\n- 赐福1：每次战斗，免疫第一次被命中的攻击骰。默认为1威胁，可以与近战武器堆叠。',NULL,23,'标记系统','标记系统',NULL),(152,'一、进入避难所\r\n在第三天夜晚环节前往避难所。并被避难所的所属玩家或阵营同意进入。\r\n在进入避难所时除统治者之外的玩家需从个人仓库选择5-10种，不超过5000kg重量的物品直接转移到避难所仓库作为进入的投诚。若投诚之后还有剩余物资，选择1-2件可以偷偷带入避难所。\r\n在反抗者夺取避难所控制权时，可以自由设定要不要把玩家所有资产充公。\r\n\r\n二、登上方舟\r\n在任意一天夜晚阶段用行动点前往方舟。并被方舟的所属冒险者阵营同意登上方舟。所有除武器装备之外所有资源将自动转移到冒险者阵营仓库（不能超出方舟载重）。\r\n\r\n三、特别注意\r\n- 避难所不能在天灾值到达100之前启动关门机制。\r\n- 方舟可以在天灾值到达100之前开船离开，如果天灾值到达100强制登船离开。开船行为不可逆，不可以开船之后掉头回到小岛。\r\n- 避难所和方舟的关门与开船机制都在每天的阵营行动和夜晚回合之后。（半夜关门和半夜走）每天最后一个行动结算。',NULL,24,'终局结算','进入避难所与方舟',NULL),(153,'避难所结局结算\r\n\r\n第一阶段：暴雪持续时间判定\r\n暴雪不会立刻结束，其持续时间决定了避难所需要承受的总考验时长。\r\n- 基础持续时间：90天。\r\n- 杀戮者干预：每位存活的杀戮者（天灾使者）玩家，将额外触发一张危机事件牌。\r\n- 天灾诅咒：每一个进入避难所玩家所拥有的诅咒标记，会额外抽取一张危机事件牌。\r\n- 暴雪持续时间（D）= 90 +（已触发天灾牌数量）+（天灾使者进入避难所人数×5）。\r\n\r\n第二阶段：避难所基础资源需要\r\n固定每人10日消耗：\r\n- 食物：每人需要25000大卡。\r\n- 燃料：每人需要100kg木材或50公斤煤炭或等价热量。\r\n- 照明与设备：固定消耗5升煤油。\r\n- 人力需求：进入避难所的人数×（暴雪持续天数/10）\r\n\r\n危机处理：\r\n抽取最终天数/10天的危机事件牌。（如是小数按向下取整计算）\r\n例如天灾最终持续天数为95天。95÷10=9.5，向下取整为9。\r\n混入了一个天灾使者额外加1危机事件牌。最终抽取9+1=10张危机事件牌。\r\n牌堆构成：危机事件牌 + 来自技能的希望牌（拥有占星和天气预测的玩家各提供1张正面事件牌加入牌堆）。\r\n\r\n第三阶段：终局资源结算与生存检定\r\n结算完所有危机事件牌后。通过三种资源确定最终存活人数。\r\n最终幸存人数 = 初始进入人数 × 生存系数（S）\r\n\r\n生存系数（S）由以下几个关键资源的充足率决定，每项系数初始为1.0，根据短缺程度扣减：\r\n\r\n1.食物充足率（F）\r\nF = 实际食物储备总量（大卡）/（总人口 × 2单位食物/天 × D）\r\n影响：若F < 1.0，则S = S × F。例如：食物只够70%的需求，则幸存人数直接打7折。\r\n\r\n2.燃料充足率（H）\r\nH = 实际燃料储备总热量/（总人口 × 每日基础燃料热量 × D）\r\n若H < 1.0，则S = S ×（H^0.5）。（平方根意味着燃料短缺的影响稍缓，但会导致冻伤和疾病）。燃料严重短缺时（例如H<0.5），主持人可额外判定直接冻死一定比例玩家（如5%-10%）。\r\n\r\n3.医疗与秩序系数（M）\r\n- 医疗资源储备：每10份医疗资源，使M增加0.05（上限+0.2）。\r\n- \"患病\"标记：结算时，每存在一个此标记，使M减少0.02。\"患病\"标记来源于危机事件牌。\r\n- 特殊职业或特性：拥有布道、医疗、占星的玩家并存活，可以为群体提供0.1的士气加成。\r\n- S = S ×（1.0 + M）。M可以是正数或负数。\r\n\r\n最终结局与阵营胜利关联：\r\n【新纪元的基石】（对应S ≥ 0.8）\r\n反抗者：由其主导，则达成人民之声与地下黎明结局。\r\n统治者：由其主导，则达成地下黎明结局。无阵营：地下黎明。\r\n\r\n【惨白的黎明】（对应0.5 ≤ S < 0.8）\r\n反抗者：由其主导，则达成人民之声结局。\r\n统治者：由其主导，则达成王的废墟结局。无阵营：挽歌结局。\r\n\r\n【地狱归来的幸存者】（对应0.2 ≤ S < 0.5）\r\n统治者：由其主导，则达成王的废墟结局。\r\n杀戮者：达成天灾的馈赠结局。\r\n\r\n【寂静的坟墓】（对应S < 0.2）\r\n杀戮者：达成天灾的馈赠结局。',NULL,25,'终局结算','避难所结局结算',NULL),(154,'方舟结局结算\r\n当冒险者阵营成功建造可以出航的方舟，并在暴雪来临前启航，游戏进入此结算流程。这是一个基于资源、技能、事件检定的叙事性终局。\r\n\r\n第一阶段：启航准备\r\n结算基础：\r\n- 最终登船玩家名单、各玩家携带的私人资源。\r\n- 方舟公共储备：食物（大卡）、燃料、医疗资源、工具、备用船材（木材、金属制品）等。\r\n\r\n第二阶段：航行阶段事件检定\r\n- 固定消耗：每人每天消耗2单位食物。\r\n- 燃料：根据发动机数量、航行天数和航速计算。如果公共储备无法满足消耗可以拆除一部分船只（减少船体完整度5%来补充一吨燃料）补足。\r\n- 抽取并结算航行事件：\r\n  牌堆构成：危机事件牌 + 来自技能的希望牌（拥有天气预测、海洋导航技能的玩家各提供1张正面事件牌加入牌堆）。\r\n  抽取数量：杀戮者干预——每位成功登船的杀戮者玩家，额外触发一张危机事件牌。危机事件抽取：航行天数×1+船上每个\"诅咒\"标记一张。\r\n- 阶段结算：如果船体完整度降至0%，或食物完全耗尽，则航行失败，或燃料无法完成动态增加的航行天数，直接进入【出海死亡】结局。\r\n\r\n第三阶段：登陆检定与最终结局\r\n判定完所有事件牌。最终生存系数（S）计算：\r\n- 基础生存率：S = 1.0\r\n- 资源修正：食物F = 实际食物储备总量（大卡）/（总人口 × 2500大卡/天 × D）。若F < 1，则S = S × F。\r\n- 船体完整度修正：H = 船体完整度（%） / 100。若H < 1，则S = S × H。\r\n- 技能与秩序修正（M）：正面——每拥有一项关键技能（渔猎、海洋导航、天气预测）+0.05；负面——每一个\"患病\"标记使M减少0.02。\"患病\"标记会在危机事件牌中产生。\r\n- 最终S = S_initial ×（资源修正）×（1 + M），S值范围通常在0到1.5之间。\r\n\r\n最终结局判定：\r\n\r\n【诺亚方舟】\r\n条件：S ≥ 1.1。船体完整度>70%，资源充足，士气高昂。\r\n\"桅杆指向崭新的海岸线。方舟几乎完好，储备尚丰。人们相互扶持着踏上了坚实的土地。\"\r\n结局：远航者\r\n\r\n【出海逃生——幸存者】\r\n条件：0.5 ≤ S < 1.1。船体有一定损坏，资源紧张，减不减员按各种物资储备结算。\r\n\"船勉强冲上沙滩，龙骨发出最后的呻吟。每个人都精疲力尽。回首望去，故乡已沉入海平线之下。但前方，是陌生的、充满未知的土地。你们活下来了。\"\r\n结局：黎明之前\r\n\r\n【出海死亡——深海长眠】（失败结局）\r\n条件：S < 0.5或船沉、资源耗尽。\r\n\"……指南针失灵，风暴永无止息。最后一片帆被撕碎，船舱开始进水。在绝望的呼喊与冰冷的海水之间，方舟的梦想连同它的乘客，一同沉入永恒的寂静。\"\r\n结局：深海长眠',NULL,26,'终局结算','方舟结局结算',NULL),(155,'一、核心原则\n超游行为是指玩家利用游戏角色不可能获得的信息或渠道（即“超出角色认知”），来为自己或所在阵营谋取优势，从而破坏游戏公平性与沉浸感的行为。\n所有行为判定均以 “你的角色在游戏内能否合理知晓或做到” 为标准。\n惩罚的目的并非针对玩家本人，而是为了维护游戏环境的健康，确保所有参与者都能享受公平、沉浸的生存博弈体验。\n玩家死亡后，如无特别情况，将被移除游戏阵营群与kook频道，仅保留v游戏协调群，作为幽灵存在，并且无法发表与游戏内发言。\n二、超游行为列表（严禁事项）\n第一类：信息泄露与私下沟通\n1，跨阵营秘密信息交换：未经主持人建立临时频道或拉群。不同阵营玩家通过kook频道外渠道（如微信、QQ）交换游戏关键信息（如阵营身份、职业特性、持有道具、行动计划、调查结果等）。\n第二类：利用外部信息\n1，共享主持人私信内容：将主持人或者网页反馈的行动结果、资源变更、战斗详情、特殊线索内容等，通过“截图”、“复制文字”这两种方式分享到公告频道或者分享给其他不应知晓的玩家。\n例外：可以通过转述游戏信息，与其他玩家交流自己的行动，资源信息和行动反馈。\n例外：游戏规则明确允许的公开信息（如“公开宣传”内容）或技能效果（如“讲故事的人”告知的内容）除外。如果你不确定，请不要分享。\n根据玩家现实情况推断游戏行为：例如，因为现实中知道某人擅长欺骗，或因其在群聊中的发言风格，就在游戏内断定其为“天灾使者”或“背叛者”，并采取行动，而无任何游戏内通过“调查玩家”或“前往地点”获得的证据。\n例外：基于该玩家在游戏内已公开或在可获知范围内的发言（如公开宣传、审判发言）进行推断。\n利用规则漏洞或未公开设定：通过反复阅读或分析规则文档，发现并利用设计上的非预期优势，且该行为不符合规则叙述的常理或主持人意图。\n例外：利用规则中明确写明但被其他玩家忽略的机制（如“规则没写，就是能做”），不算超游，但建议先向主持人确认。\n第三类：行动与时间线作弊\n1，非规定时间提交或修改行动：在主持人规定的行动提交截止时间后，私自联系主持人要求修改或补交自由行动、技能使用或密谋参与，除非有主持人事先同意的特殊情况（如网络故障已报备）。\n根据已结算结果“事后诸葛亮”：例如，在主持人私信告知你某地点的NPC已被调动后，你才在公共讨论区宣称“我早就计划去那里调查了”。\n第四类：角色扮演与沉浸破坏\n1，公开游戏内私密信息：故意在公开场合（公屏、大型语音频道）大声朗读或截图展示你的角色资源仓库清单、秘密阵营身份、特性技能效果等，除非游戏机制明确要求或允许公开（如“公开宣传”）。\n2，以现实身份代替角色发言：在游戏讨论中使用“我（现实名字）认为”、“我（现实身份）觉得”等方式进行交流，而非以角色身份思考和发言。例如：“我觉得GM这个规则有问题”应私信主持人，而非在公屏讨论。\n3，恶意质疑或纠缠主持人裁决：在主持人已根据规则做出明确裁决后，仍反复在公开频道争辩、试图以现实辩论影响游戏内判定结果。\n正确做法：对裁决有疑问，应私信主持人礼貌询问。\n第五类：恶意破坏游戏进程\n1，冒充主持人或发布虚假官方指令：在任何频道（公屏、阵营群聊）发布看似来自主持人的虚假公告、指令或要求。\n2，行为或言论恶意针对玩家本人：在游戏内或游戏外，因为游戏内冲突（对方阵营行动导致你损失、对方欺骗了你）而对玩家本人进行现实人身攻击、辱骂或恶意诋毁。\n例外：在游戏内以角色身份进行扮演式威胁或谴责（如“我绝不会放过那个背叛者”）不算超游。\n三、给所有玩家的建议\n1沉浸第一：时刻问自己：“我的角色现在知道什么？会怎么做？”\n2沟通透明：如需进行游戏允许外的特殊互动，先私信主持人申请，由主持人裁定是否以及如何实现。\n3尊重规则与主持人：主持人是游戏的仲裁者。对裁决有疑问可私信礼貌询问，但最终应尊重主持人的决定，主持人有对规则最终解释权。\n4共同维护环境：如果你怀疑其他玩家有超游行为，请私信主持人提供具体证据或描述，而非在公开频道指责。',NULL,27,'超游细则','超游细则',NULL);
/*!40000 ALTER TABLE `rule_book` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `selected_catastrophe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `selected_catastrophe` (
  `id` int NOT NULL AUTO_INCREMENT,
  `deck_id` int NOT NULL COMMENT '牌组ID',
  `player_id` int DEFAULT NULL COMMENT '选择的玩家ID（天灾使者）',
  `selected_at` datetime DEFAULT NULL COMMENT '选择时间',
  `is_active` tinyint(1) DEFAULT '0' COMMENT '是否正在生效',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `deck_id` (`deck_id`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `selected_catastrophe_ibfk_1` FOREIGN KEY (`deck_id`) REFERENCES `catastrophe_deck` (`id`) ON DELETE CASCADE,
  CONSTRAINT `selected_catastrophe_ibfk_2` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='已选择的天灾牌表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `selected_catastrophe` WRITE;
/*!40000 ALTER TABLE `selected_catastrophe` DISABLE KEYS */;
/*!40000 ALTER TABLE `selected_catastrophe` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `shelter_daily_labor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shelter_daily_labor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `game_day` int NOT NULL COMMENT '游戏天数',
  `worker_kind` varchar(10) NOT NULL DEFAULT 'player' COMMENT 'player|npc',
  `worker_id` int NOT NULL COMMENT '玩家ID或NPC ID',
  `build_value` int NOT NULL DEFAULT '0' COMMENT '当日贡献建造值',
  `is_exploited` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否压榨（建造值翻倍等由主持人裁定）',
  `is_escaped` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否逃役（不计入劳工）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_slacking` bit(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_shelter_labor_day_worker` (`game_day`,`worker_kind`,`worker_id`),
  KEY `idx_game_day` (`game_day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='避难所每日劳工名单（总建造值=SUM(build_value)，含玩家与NPC）';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `shelter_daily_labor` WRITE;
/*!40000 ALTER TABLE `shelter_daily_labor` DISABLE KEYS */;
/*!40000 ALTER TABLE `shelter_daily_labor` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `shelter_labor_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shelter_labor_day` (
  `game_day` int NOT NULL COMMENT '游戏天数',
  `verified` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'DM是否已结算确认',
  `verified_at` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`game_day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='避难所每日劳工结算状态';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `shelter_labor_day` WRITE;
/*!40000 ALTER TABLE `shelter_labor_day` DISABLE KEYS */;
/*!40000 ALTER TABLE `shelter_labor_day` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `shelter_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shelter_progress` (
  `id` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `current_build_value` int NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `shelter_progress` WRITE;
/*!40000 ALTER TABLE `shelter_progress` DISABLE KEYS */;
/*!40000 ALTER TABLE `shelter_progress` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `shelter_stock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shelter_stock` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `item_type` enum('item','weapon','ammo','material') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '物品类型：item道具/weapon武器/ammo弹药/material材料',
  `item_id` int NOT NULL COMMENT '物品ID，关联对应类型表的主键',
  `quantity` int NOT NULL DEFAULT '0' COMMENT '物品数量',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) COMMENT '创建时间',
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_shelter_stock_type_item` (`item_type`,`item_id`),
  KEY `idx_item_type` (`item_type`),
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=217 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='统治者避难所物资库存表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `shelter_stock` WRITE;
/*!40000 ALTER TABLE `shelter_stock` DISABLE KEYS */;
INSERT INTO `shelter_stock` VALUES (210,'material',1,500,'2026-08-27 13:50:32.691330','2026-08-27 13:50:32.691330'),(211,'material',2,200,'2026-08-27 13:50:32.691330','2026-08-27 13:50:32.691330'),(212,'material',3,100,'2026-08-27 13:50:32.691330','2026-08-27 13:50:32.691330'),(213,'material',4,50,'2026-08-27 13:50:32.691330','2026-08-27 13:50:32.691330'),(214,'item',1,50,'2026-08-27 13:50:32.691330','2026-08-27 13:50:32.691330'),(215,'item',2,10,'2026-08-27 13:50:32.691330','2026-08-27 13:50:32.691330'),(216,'material',5,200,'2026-08-27 13:50:32.691330','2026-08-27 13:50:32.691330');
/*!40000 ALTER TABLE `shelter_stock` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `skill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `skill` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '技能名称',
  `function` text NOT NULL COMMENT '技能效果描述',
  `faction` enum('平民','统治者','冒险者','反叛者','天灾使者','外来者','原住民') NOT NULL DEFAULT '平民',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `idx_faction` (`faction`)
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='个人技能表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `skill` WRITE;
/*!40000 ALTER TABLE `skill` DISABLE KEYS */;
INSERT INTO `skill` VALUES (1,'囤积症','你屋里堆满了舍不得扔的旧报纸、空罐头和麻绳。获得额外的资源【金属制品1000kg，煤油100升，帆布50米，麻绳50米】','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(2,'情报贩子','你和村里的几个孩子是铁哥们，总能先知道些风声。可以每天指定npc「阿丹」执行调查玩家行动，不占用你的主要行动。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(3,'扮演：圣徒','你是小镇最虔诚的人。你相信神会拯救所有人，请聆听神父的声音。你会知道他是否能够信任。这是一个公开的扮演特性，请遵守圣徒的规律，他可能代表着一种话语权。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(4,'秘密钥匙','你拥有小镇一个废弃房屋的地下室钥匙。所有人都不知道还有这样一个地方。若你终局来临时没有进入庇护所或者避难所，你可以在这里储存够你存活90天及以上的物资进入个人结算结局。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(5,'第六感','你在岛上活了几十年，谁对你有恶意你闻都闻出来。效果：你能够知道对你使用调查的玩家名称','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(6,'偷窃癖','你喜欢偷东西的感觉，你获得技能偷盗。效果：偷盗：选择一位玩家，获得对方的秘密资源物品信息。需要投掷1d6+1检定在5以上即可获得对方一件物品。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(7,'潮汐症','每年冬天，当第一场暴风雪封岛，你就开始犯病。睡不着，吃不下，整夜整夜坐在窗前听风声，总觉得海浪声里有人的喊叫。你知道那是幻觉——那年冬天你爹的船没回来，你站在码头听了三天三夜。镇上人说你是“潮汐症”，不吉利，躲着你走。你不怪他们。有些东西，离近了会传染。效果：任何玩家死亡，你会第一时间得到死亡玩家与死亡地点。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(8,'曾经是走私者的线人','你知道岛上谁在夜里往岸上搬东西，知道哪条船不靠码头靠礁石，知道仓库哪面墙的锁是坏的。你替他们望风、递消息、在酒馆里吆喝“有巡警”的时候，他们就往你口袋里塞几个硬币。效果：你知道通往码头仓库与燃料仓库的暗道，可以避开巡逻人员和看守。也许这些东西对杀戮者或者反抗者很有用。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(9,'银币','你有一枚银币。不是你赚的，不是你捡的，是——不知道从哪来的。你醒来的时候，它就攥在你手里，攥得掌心发红。你试过花掉，第二天它又回到你口袋；你试过扔掉，第二天它又出现在枕头底下；你试过送人，那人第二天发烧，银币又回来了。你不敢再试了。你怕的不是这枚银币，是它要你做什么。效果：银币不可丢弃、不可交易、不可偷窃。它“选择”留在你身边。全局，你可使用银币进行一次“许愿”。向主持人提出一个要求，如“明天生产+20%”“消除xxx的诅咒”“今日天灾牌无效”，主持人根据需要尽可能地满足要求，越是破坏平衡的愿望越可能带来强大的个人负面因素。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(10,'回声','你能听见别人听不见的东西。不是耳朵好，是那种——不该听见的东西。酒馆里有人说悄悄话，你能听见；码头有人夜里密谋，你能听见；教堂地窖里神父自言自语，你也能听见。你不敢说。说了，你就是怪物。你把这些声音存在脑子里，像存钱。有一天，你要用它们换点什么。效果:在游戏开始时选择3名玩家你会得到他们全部的初始阵营信息。但不一一对应。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(11,'爱狗人','你妈生你的时候难产死了，你爹喝了二十年酒，去年也死了。你吃百家饭长大。你认为狗比人好——狗不骗你，狗不嫌你，狗给你暖脚。你养了一只狗，它是你的重要伙伴。效果：初始拥有一只狗，可以给它取名字。它计算为2威胁值。狗不会被偷走，会一直跟着你。在有人试图偷盗你时会打断对方行为。','平民','2026-05-02 23:09:27','2026-05-18 23:59:29'),(12,'海藻医生','你奶奶教你的：海藻能止血，昆布能退烧，石莼能敷伤口。镇上人笑你是“海带大夫”，但冬天码头有人被缆绳打断腿的时候，第一个喊的是你。你采了一辈子海藻，尝了一辈子海藻，知道哪片礁石上的能治病，哪片的有毒。你不知道自己算不算医生，但你知道，没有你，这个冬天要多死几个人。效果：获得“医疗”技能','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(13,'百宝袋','你兜里永远揣着各种各样的物品。效果：一次机会，你可以选择5个物品列表中的非武器的非重复物品，获得其标准单位数量的物品。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(14,'望远镜','你有个军用望远镜，能看清远处。效果：每天1次，可私聊主持人“行动点x时使用特性望（xz地点）”，获知当时有谁在那里。无法获知矿场，避难所等地下结构。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(15,'海的呼唤','你不对劲。不是生病，是那种——不该有的不对劲。上个月码头有条狗对着你狂吠，你瞪了它一眼，它夹着尾巴跑了，跑之前尿了一地。上周酒馆老张摸你肩膀，你碰了他一下，他回家后发烧三天。你自己也怕。你开始半夜往海边跑，对着月亮发呆，觉得海在叫你。你知道这不正常，但不知道这算什么。效果：你获得一个“诅咒标记”可以被布道去除。诅咒无法再影响你，你永远无法成为天灾使者的诅咒目标。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(16,'鱼骨占卜','你奶奶传下来的手艺。不是那些神神叨叨的巫术——是把吃剩的鱼骨头洗干净，扔在桌上，看它们落地的样子。你说这能看出鱼汛、天气、谁家要死人。信的人当真，不信的人当笑话。但去年你说老李家的船别出海，他偏去了，没回来。那之后，找你的人多了，怕你的人也多了。效果：初始获得3个特殊鱼骨。可消耗“鱼骨”为他人占卜，需要对方同意。占卜的结果由主持人暗中判定。（为3选一随机不重复触发。对方的全部协议内容，对方的阵营信息，对方的特性信息）','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(17,'幸运贝壳','你有一串穿孔的贝壳，说是祖上传下来保平安的。效果：拥有两颗幸运贝壳，一颗可以用来躲避一次伤害，一颗可以用来在没有食物时捡到2单位食物。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(18,'遗书','你觉得世道不太平，早把后事安排好了。效果：每天可修改一次遗书私聊主持人，死后自动发给你指定的人或者公开。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(19,'单恋者','你深爱着另一个人，你可以为他（她）付出一切。在游戏开始前选择一名玩家作为你的暗恋对象。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(20,'仇人','你恨着一位统治者，你知晓隐藏统治者的身份。你憎恨着他也同时为自己准备了一条出路，你白天回合可以选择花费一个行动点进行“消失”。夜晚回合无法被调查，无法被攻击。但第二天你仍然会回到游戏之中。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(21,'扮演·大善','你坚定地相信神的意志，认为神不会抛弃人们，你不愿意任何人受难和死去，并且诚心地愿望帮助他人。这是一个公开的扮演特性，请遵守善意的规律，它代表着一种话语权。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(22,'忠诚','你的理念告诉你，当你选择了哪一条路，将不会存在背叛。一旦你加入了某个阵营就无法退出，同时你会给阵营带来意想不到的一定加成。统治者：你担任劳工或者守卫的时候，目标地点额外+2防御值。反抗者：你参与的“密谋”增加1点成功率。冒险者：你参与“方舟建设”时，当日总工作量提高10%。冒险者阵营“看守方舟”时防御值+1。天灾使者（若允许平民加入）：你的“诅咒”目标在被诅咒期间，无法对你发起任何攻击或密谋。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(23,'账房先生','你算账清楚，记忆力好。效果：游戏开始时，你获得一份模糊的物资统计：知晓所有仓库的总资源排名（如“燃料最多的是燃料仓库，食物最多的是码头”），但不知具体数字和所属玩家。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(24,'老好人','大家都不太防备你。效果：当你使用“调查玩家”时，如果目标玩家未进行“隐藏”，你不用投1/2概率，直接获知其阵营行动（但不包括具体内容，仅知“进行了生产”“进行了隐藏”等）。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(25,'酒蒙子','你离不开酒。效果：游戏开始时额外获得20瓶朗姆酒。每天必须消耗2瓶朗姆酒，否则第二天白天行动点-1。（朗姆酒可交易）','平民','2026-05-02 23:09:27','2026-05-22 16:41:45'),(26,'即兴演说','你说话能打动人。效果：在“公开审判”中，如果你的发言被主持人认为有说服力，你可以在投票阶段额外增加/减少1票有效影响力（由主持人裁定）。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(27,'老水手','你曾经出过海。效果：你获得“航海”技能。如果你已拥有，则获得“海洋导航”。在“出海”结算时，你为船只提供一次抗风暴加成（减少一次危机事件）。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(28,'梦魇','你经常做噩梦，梦见暴雪。效果：每天晚上，你随机获知一张未被触发的天灾牌的名称（不触发效果）。同一天灾牌不会重复获知。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(29,'穷光蛋','你什么资产都没有。效果：你初始资源减半（食物、燃料等基础配置减半）。但你不会被任何人调查出有价值的资产信息（调查你只能得到“一无所有”），也不会被“偷窃癖”偷走任何东西（因为你没有）。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(30,'守财奴','你舍不得花。效果：你每天可以多保存25%的食物（每日消耗时按1.5食物计算。）代价：你无法主动赠送资源给其他玩家（必须交换）。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(31,'讲故事的人','你脑子里有很多故事。效果：每天一次，你可以给去往的某地点某NPC讲一个故事。NPC心情变好后，可能会告诉你一条他“本来不想说”的无关紧要信息（如“昨天码头来了几个人”）。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(32,'好奇心重','你什么都想知道。效果：你每天可以多问主持人一个“是/否”问题（关于游戏设定、地点、NPC，不涉及玩家阵营和行动）。主持人必须如实回答。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(33,'不满已久','这些年忍够了。矿场、码头、粮仓……凭什么他们说了算？该换个活法了。效果：游戏开始时，你知晓反抗者阵营其中一个成员的名字。如果你成功加入反抗者阵营，你获得一个一次性效果：在反抗者发起的第一次密谋中，你增加2点成功率（而不是常规的1点）。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(34,'渴望出海','这岛要完了，但我不想死在这儿。跟着大船走，哪怕当个水手也行。游戏开始时，你知晓冒险者阵营两个成员的名字。如果你成功加入冒险者阵营，你获得一个一次性效果：在“方舟建设”行动中，你可以选择一次贡献量翻倍（一天算两天）。','平民','2026-05-02 23:09:27','2026-05-02 23:09:27'),(35,'虚伪的仁慈','如果主持人告知你其他玩家粮食不足，你必须提供维持对方一天的食物需求。如果对方接受了你的救助，你可以控制对方第二天的一个行动点去向。对方只会知道“受特性影响该行动点无效”。','统治者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(36,'暴君','你可以每天额外压榨一名劳工。','统治者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(37,'铁腕','效果：你主持的“公开审判”中，投票环节你的个人票数算作3票（而不是1票）。','统治者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(38,'恩主','效果：每天一次，你可以免除一名劳工的“过劳”状态（他今天劳作后不会积累过劳标记）。','统治者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(39,'窃听者','效果：每天夜晚阶段，你可以选择一条非统治者阵营的私人群组（如反抗者群、冒险者群），主持人随机抽取该群当天的一段对话（不超过5条）匿名发给你。你不会知道说话者是谁。','统治者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(40,'暗桩','效果：游戏开始时，你秘密选择一名NPC（非玩家）作为你的“暗桩”。你可以每天向主持人询问一次“暗桩报告”。包括有哪些人来过他所在的地方，和什么NPC进行了交互。','统治者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(41,'镇守','效果：当你亲自在某地点过夜（夜晚阶段结束时你位于该地点），该地点的防御值+3。','统治者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(42,'点名','每天开始前，你可以宣布一个玩家的名字。该玩家当天无法进行“隐藏”行动（如果已经隐藏，则自动暴露）。','统治者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(43,'藏料','效果：游戏开始时，你在码头秘密藏了额外资源：木材20吨、金属制品5吨、密封材料10kg。这些资源只有你知道位置，不会被其他阵营搜刮。','冒险者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(44,'号召','效果：每天一次，你可以向一名平民玩家发出“上船邀请”。如果对方同意临时加入冒险者阵营，对方获得一次免费“建设方舟”行动。','冒险者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(45,'探风','效果：每天一次，你可以询问主持人“今天是否有玩家在码头或海边活动”。主持人回答“有人”或“没人”，不透露具体是谁。','冒险者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(46,'听潮','效果：每天夜晚阶段结束时，你可以询问主持人“今晚是否有玩家在码头进行了非公开行动（如密谋、隐藏、偷盗）”。主持人回答“是”或“否”。','冒险者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(47,'备材','效果：全局一次，当你的阵营在进行“方舟建设”时缺少某一种资源（如缺木材、缺金属），你可以使用“备材”。主持人会告知你岛上哪个地点（不精确到NPC）可以找到该资源的下落（如“矿场仓库有金属”或“伐木营地有木材”）。','冒险者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(48,'同路人','效果：每天一次，你可以询问主持人“今天是否有平民玩家加入了某个阵营（你可以指定一个阵营，如反抗者）”。主持人回答“有”或“没有”。','冒险者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(49,'摸底','效果：每天一次，选择一名玩家。主持人私聊告知你：该玩家今天是否进行了“生产”行动，以及产出是否上交给了统治者（“上交了”“没上交”）。','反叛者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(50,'硬骨头','效果：全局一次，如果你被统治者选为劳工，你可以选择“反抗”。当天你不会被计入劳工名单，统治者会得知你未能成功被征为劳工。','反叛者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(51,'正义宣传','效果：每天一次，当统治者宣布劳工名单后，你可以选择其中一名劳工。该劳工当天建造值-50%（向下取整）。统治者不会自动知道是谁干的，但可以调查或者排除出来。','反叛者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(52,'老面孔','效果：游戏开始时，你随机知晓一名监狱/关押地点看守NPC的名字和弱点（如“他晚上会喝酒”“他贪财”）。你可以利用这个信息，在劫狱时让该看守“暂时离开岗位”（需消耗一次行动点），使目标地点的防御值-2。','反叛者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(53,'舆论','效果：每天一次，你可以通过主持人在公屏发布一条“民间声音”（如“矿工们今天不想干活”“码头有人在议论镇长”不超过20个字。）。这条信息会被视为“NPC的态度”，统治者如果无视，可能影响部分NPC对他们的态度。','反叛者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(54,'集结号','效果：当劫狱和公开审判两个里程碑都完成后，你可以在劳工傍晚回合宣布“起义”。起义当天，所有反抗者阵营成员的“威胁值”+1（不限武器）。','反叛者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(55,'瘟疫','效果：你将永远拥有“瘟疫诅咒”。每天一次，你可以对一名玩家施加“瘟疫诅咒”。该玩家不会立即死亡，但会在终局结算时产生以下影响：如果该玩家在避难所中，避难所的食物消耗增加5%（因为他污染了存粮）；如果该玩家在方舟上，方舟的可能的医疗资源需求+50%（因为他传染他人）；如果该玩家死亡，“瘟疫诅咒”会随机传染给另一名存活玩家（终局结算时生效）。多个“瘟疫诅咒”效果叠加。被诅咒的玩家不会知道，但会感到“身体不适”。','天灾使者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(56,'战争','效果：全局一次，当你参与一场“冲突，起义，劫狱”非自身阵营引发对抗和暴力的行动时，你可以宣布“战争降临”。该场冲突中，所有参与者的威胁值翻倍（包括敌我），且冲突结束后，无论胜负，所有参与者都会获得一个“受伤”标记。之后战争的阴影也笼罩在人们心上，触发全局效果“战争”。如果你本人在冲突中死亡，“战争”效果依然持续到冲突结束。','天灾使者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(57,'饥荒','效果：全局一次，你可以花费一个行动点“饥荒降临”。选择一种资源类型（食物、燃料、木材、金属制品、医疗资源），主持人从所有仓库（4个统治者仓库、反抗者、冒险者）中随机两个仓库销毁该资源的10%（最低保留1单位）。此特性使用后，所有玩家会收到公屏提示：“一场诡异的霉病席卷了粮仓/燃料/仓库……”，但不知道是谁干的。','天灾使者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(58,'死亡骑士','触发条件：当天灾使者阵营只剩最后一名存活成员时，若有天灾使者挂机第一天第二天都挂机也认为他满足死亡条件。玩家可以在当天任意阶段（白天/夜晚/结算前）私信主持人，选择是否“成为死亡骑士”。若没有回答默认拒绝。拒绝：无事发生，游戏继续。同意：全屏公告——“天灾的低语响彻岛屿：有人接过了死亡骑士的缰绳。”效果：你可以选择以下两个效果之一：如果游戏进入终局结算（暴雪将至），你可以暗中联系主持人“终焉宣告”。选择以下效果之一：对避难所：避难所的所有防御值和资源储备在结算时视为80%（食物、燃料只计算80%）；对方舟：方舟在出海结算时额外遭遇2次危机事件。此效果在终局结算时自动生效，无需额外行动。如果你在终局前死亡，此效果依然生效（你已成为死亡骑士，诅咒已落下）。','天灾使者','2026-05-02 23:09:27','2026-05-02 23:09:27'),(59,'聆讯者','效果：受到了天灾的启示因此知道了很多外人不知道的信息，你不能在第1，2天加入任何阵营。不得加入杀戮者阵营。','平民','2026-05-22 16:49:49','2026-05-22 16:49:49'),(60,'神明的眼睛（公开）','神想知道这场游戏祂能得到什么乐子，当你知道12人（不包括自己）的阵营时。神明会给予你特殊的奖赏。\r\n每天可以提交最多两次名单，会得到错误几个的提示。\r\n利用神明的恩赐活下去。','平民','2026-05-22 16:50:43','2026-05-22 16:50:43'),(61,'血脉共鸣','你与地脉的联系比同类更深，岛屿的呼吸即是你的心跳。【效果】：当你与另一名原住民在同一地点且无其他玩家在场时，你们可以花费一次公共行动进行\"短暂共鸣\"。共鸣后，双方各自获得对方当前持有的一枚祭坛石的具体位置感知（仅感知到\"在哪\"，无法得知更多信息）。每天限一次。','原住民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(62,'古老血脉','你的祖先曾与地脉立下过血誓，当危机降临时，大地会回应你的呼唤。【效果】：当你在战斗中受到致命伤害（重伤或即将死亡），你可以选择激活此特性，献祭一枚祭坛石（如果持有）。激活后，你获得\"石之躯\"状态，免疫一次致命伤害，并在原地留下一个\"石壳\"伪装（看起来像一座普通的石像，持续24小时）。石壳期间，你无法行动，但无法被任何方式攻击或调查。这是你保命的最后手段。','原住民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(63,'地脉狩猎者','你知晓如何追踪地脉力量的流向，祭坛石在你眼中如同黑夜里的火炬。【效果】：每天一次，你可以花费一个快速行动，进行一次\"地脉追踪\"。主持人会告知你，距离你当前地点最近的祭坛石的大致方位（东南西北）和距离远近（\"很近\"或\"很远\"）。此特性无法在矿场或地下结构中使用。','原住民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(64,'沉默的看门人','你守护着岛屿的秘密，也深知它的弱点。当有人试图开启铁门时，你体内的血脉会发出警告。【效果】：当任何玩家（包括你）在\"隐秘居所\"或\"地脉核心\"举行仪式时，你会自动感知到该仪式正在发生，并知晓仪式所在的具体地点。此效果无消耗，但不会告知你举行仪式的人是谁。','原住民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(65,'信号残响','（飞行员专属）你的飞机残骸中还有一块未损坏的通讯模块，能接收到微弱的、不属于这个时代的讯号。【效果】：每天一次，你可以选择\"收听\"一次。主持人会从旧世界广播库中随机抽取一段不超过10秒的音频片段（内容可以是天气预警、一段模糊的对话、或一段音乐）私聊告知你。这段讯号虽然残缺，但可能会暗示未来24小时内可能发生的某个事件（如\"暴风雪将至\"、\"码头有异动\"等），具体内容由主持人根据游戏进程随机生成。此特性不消耗行动点。','外来者','2026-08-28 04:50:11','2026-08-28 04:50:11'),(66,'共振感知','（信天翁专属）你的身体即是岛屿的晴雨表，地脉的每一次脉动都会在你的皮肤上留下痕迹。【效果】：当你进入一个拥有\"地脉异常点\"（如祭坛石、仪式的残余能量、地脉核心、旧世界科技造物）的区域时，你的皮肤会泛起微弱的蓝色荧光（只有你自己能看到）。主持人会私下告知你：\"你感到皮肤一阵刺痛，像是有什么东西在附近唤醒了你。\" 此特性不会告知你具体位置，但能让你知道\"这里有问题\"。','外来者','2026-08-28 04:50:11','2026-08-28 04:50:11'),(67,'真相的代价','（调查记者专属）你写下的一切都会被记录，而你记录下的真相越沉重，你的笔就越无法停下。【效果】：当你成功获得一条有效信息并记录在档案中时，你可以选择\"深入挖掘\"。主持人会额外告知你与该信息相关的、更隐晦的一个细节（例如，你调查到\"A在码头与B交易\"，深入挖掘后，你会得知\"B交易时显得很紧张，像是怕什么人看到\"）。此特性每天限用一次，且每次使用后，你的档案页会额外消耗1页（即消耗2页才能记录此次深入挖掘的完整信息）。','外来者','2026-08-28 04:50:11','2026-08-28 04:50:11'),(68,'时空错位','你醒来时，口袋里多了一样不属于这个时代的东西——一枚尚未磨损的硬币、一张印着陌生文字的票根、或一块不会走的手表。【效果】：游戏开始时，你获得一件\"时空遗物\"（由主持人从预设列表中随机抽取）。该遗物本身无直接功能，但当你与NPC进行交易或对话时，可以出示它。NPC会表现出\"困惑\"或\"敬畏\"，并可能因此透露一条额外的信息（由主持人根据场景裁定）。遗物不可交易、不可偷窃、不可丢弃，它会一直跟着你，直到游戏结束。','外来者','2026-08-28 04:50:11','2026-08-28 04:50:11'),(69,'不属于此的记忆','你偶尔会梦到不属于自己人生的片段——某个陌生人的童年、某场你没参加的战斗、某条你从未走过的街道。这些碎片会在你清醒时偶尔闪现。【效果】：每天一次，你可以向主持人询问\"今天，我是否会对某个地点或某个玩家产生\'既视感\'？\" 主持人回答\"是\"或\"否\"。如果答案为\"是\"，则当你于当天第一次前往该地点或与该玩家对话时，你会获得一条模糊的、关于该地点或该玩家的额外信息（如\"你感觉这个人的手曾经沾过血\"或\"你好像记得这个仓库里藏过什么东西\"）。此信息由主持人根据游戏进程随机生成，可能有用，也可能无用。','外来者','2026-08-28 04:50:11','2026-08-28 04:50:11'),(70,'孤星的直觉','你不属于任何阵营，也不信任任何人。这种孤独让你对周围的威胁格外敏感。【效果】：当一名玩家对你使用\"调查\"或\"监听\"类行动时，你会感到一阵莫名的不安，如同有人在你背后凝视。主持人会私聊你：\"你感觉有人在盯着你。\" 你无法获知具体是谁，但可以意识到自己正在被观察。','外来者','2026-08-28 04:50:11','2026-08-28 04:50:11'),(71,'异乡人的口音','你说话的方式、用词的习惯，甚至你沉默的节奏，都让本地人觉得你\"不是这里的人\"。但这也让你的话听起来更难以被忽视。【效果】：当你与一名NPC进行对话时，你可以选择\"用异乡口音说话\"。NPC会感到好奇，并愿意多听你说几句。你可以借此多问一个问题（如\"你最近见过什么奇怪的人吗？\"或\"你知道镇上谁在夜里偷偷挖东西吗？\"），NPC必须如实回答（但可能以模糊或隐喻的方式）。此特性每天限用一次。','外来者','2026-08-28 04:50:11','2026-08-28 04:50:11'),(72,'最后的锚点','你随身携带一件来自\"故乡\"的私人物品——一张照片、一枚徽章、一块石头。它不会给你任何力量，但只要你握着它，你就不会忘记自己是谁，也不会被这座岛上的\"低语\"彻底吞噬。【效果】：当你受到\"记忆模糊\"、\"记忆剥离\"或\"记忆污染\"类效果影响时，你可以选择激活此特性，立即免疫该次效果。此特性全场仅可使用一次。使用后，该物品化为灰烬，你失去了它，但你保住了那段记忆。','外来者','2026-08-28 04:50:11','2026-08-28 04:50:11'),(73,'守夜','你习惯了在夜里醒着。别人睡觉的时候，你坐在窗边，听风声，听雪落，听那些不该有的声音。【效果】：每天夜晚阶段，你可以选择\"守夜\"。守夜期间，你无法进行任何夜间行动，但你会获得以下信息：当晚有多少玩家在你所在地点活动（值具体数量与玩家名）。如果当晚有玩家试图对你进行\"袭击\"，你会提前得知，并可以选择逃离该地点。如果是遭遇冲突，则无法避免。','平民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(74,'旧地图','你爷爷留下了一张手绘地图，上面标注了一些他\"觉得有意思\"的地方。纸已经发黄，墨迹褪色，但你还能辨认出几处标记。【效果】：游戏开始时，你获得一个随机隐藏地点的位置。该地点可能存在资源、道具或线索。你无法确认具体是什么，但你知道那里\"有东西\"。可以花费快速行动前往。','平民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(75,'收藏家','你收集一切看起来\"可能有用的东西\"。别人眼中的垃圾，你眼中的宝藏。【效果】：游戏开始时，你额外获得5个\"随机杂物\"物品（从预设的杂物列表中随机抽取）。每次探索行动，你都可以额外获得一件杂物。','平民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(76,'记仇','你记性很好，尤其是谁得罪过你。你不需要报复，只需要记住。【效果】：当一名玩家对你进行过\"偷盗\"、\"袭击\"、\"审判\"或\"密谋\"中的任意行为后，你会自动获得该玩家的\"标记\"。此后，你对该玩家进行\"调查\"时，你可以直接知晓该玩家的秘密身份。该标记持续到游戏结束，或该玩家死亡。','平民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(77,'流浪者','你没有固定的家。你睡过码头、矿场、教堂的长椅、甚至墓地的屋檐下。哪里都能睡，哪里都不属于你。【效果】：你可以在夜晚过夜判定在任何地点过夜（无需前往任何地点）。如果你在专属地点过夜，并且没有被赶出，第二天你获得一个\"休息充分\"状态——当天白天行动点+1。但如果你连续两天在同一个地点过夜，第二天不再获得加成。','平民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(78,'幸存者直觉','你经历过太多危险，身体已经学会了在危险来临前做出反应。不是预知，是身体比脑子先知道。【效果】：每天一次，当你在白天行动中选择前往一个地点时，你可以向主持人询问\"该地点今天是否有危险\"（如\"是否有玩家计划袭击该地点\"或\"是否有天灾牌即将影响该地点\"）。主持人回答\"有\"或\"没有\"，不告知具体细节。此特性只能使用一次，用完后第二天恢复。','平民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(79,'磨刀匠','你磨过的刀比吃过的饭还多。你知道每一把刀的脾气——有的刀喜欢快，有的刀喜欢稳，有的刀不想被磨。【效果】：每天一次，你可以选择为一名玩家（包括你自己）的近战武器进行\"磨砺\"。被磨砺的武器，威胁值+1。但磨刀需要消耗5kg木材（用于生火加热）和1份医疗资源（用于冷却）。如果你当天没有磨刀，你可以在第二天进行一次\"快速磨砺\"——在当天可以使用两次。','平民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(80,'抄写员','你替别人写信、写契约、写遗书，你见过太多人的笔迹，也见过太多人笔迹中的颤抖。【效果】：在游戏开始时，你获得一份契约书。','平民','2026-08-28 04:50:11','2026-08-28 04:50:11'),(81,'算命先生','你不是真的能算命。你只是很会观察人——他的坐姿、他的眼神、他说话时摸鼻子的次数。你把这些观察包装成\"命理\"，然后卖给他。【效果】：每天一次，你可以选择一名玩家进行一次\"算命\"。主持人会秘密告知你：该玩家今天是否说了谎，或者隐藏了重要信息（仅限与你对话时的文字内容），主持人会回答是或者否。','平民','2026-08-28 04:50:11','2026-08-28 04:50:11');
/*!40000 ALTER TABLE `skill` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `special_clue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `special_clue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `clue_code` varchar(50) DEFAULT NULL,
  `content` text NOT NULL,
  `cooldown_minutes` int NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `is_active` bit(1) NOT NULL,
  `keywords` text NOT NULL,
  `match_mode` varchar(20) DEFAULT NULL,
  `priority` int NOT NULL,
  `probability_weight` int NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK_ddf90mam93pawimn1jc3rkjpx` (`clue_code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `special_clue` WRITE;
/*!40000 ALTER TABLE `special_clue` DISABLE KEYS */;
INSERT INTO `special_clue` VALUES (1,'CLUE_TEST001','???????????????????,?????????????',10,'2026-06-25 16:11:36.004000','????',_binary '','??,hidden,??','FUZZY',1,80,'2026-06-25 16:11:36.004000'),(2,'CLUE_SECRET001','There is a hidden treasure map in the old lighthouse basement. It leads to forgotten gold.',0,'2026-06-25 16:11:53.246000','Secret location clue',_binary '','secret,treasure,hidden','FUZZY',1,100,'2026-06-25 16:11:53.246000');
/*!40000 ALTER TABLE `special_clue` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `trade`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trade` (
  `id` int NOT NULL AUTO_INCREMENT,
  `from_player_id` int NOT NULL COMMENT '发起方玩家ID',
  `to_player_id` int NOT NULL COMMENT '接收方玩家ID',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='交易主表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `trade` WRITE;
/*!40000 ALTER TABLE `trade` DISABLE KEYS */;
/*!40000 ALTER TABLE `trade` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `trade_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trade_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `trade_id` int NOT NULL COMMENT '关联的交易ID',
  `item_type` enum('item','weapon','ammo','material') NOT NULL COMMENT '物品类型',
  `item_id` int NOT NULL COMMENT '物品ID',
  `quantity` int NOT NULL DEFAULT '1' COMMENT '物品数量',
  `direction` enum('give','take') NOT NULL COMMENT '物品方向：give-给予, take-索取',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `name` varchar(255) DEFAULT NULL,
  `unit` varchar(255) DEFAULT NULL,
  `item_key` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_trade_id` (`trade_id`),
  KEY `idx_item` (`item_type`,`item_id`),
  CONSTRAINT `trade_items_ibfk_1` FOREIGN KEY (`trade_id`) REFERENCES `trade` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='交易物品明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `trade_items` WRITE;
/*!40000 ALTER TABLE `trade_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `trade_items` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `role` enum('dm','player') NOT NULL,
  `player_id` int DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'hey','695390489','dm',NULL,'2026-04-26 22:13:35','2026-05-22 18:18:31',1);
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `warehouse_ark`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouse_ark` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_type` enum('item','weapon','ammo','material') NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_warehouse_ark_type_item` (`item_type`,`item_id`),
  KEY `idx_item_type` (`item_type`),
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库-冒险者阵营仓库';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `warehouse_ark` WRITE;
/*!40000 ALTER TABLE `warehouse_ark` DISABLE KEYS */;
INSERT INTO `warehouse_ark` VALUES (6,'weapon',7,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(7,'ammo',4,12,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(8,'weapon',6,1,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(9,'weapon',1,1,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(10,'ammo',1,2,'2026-08-27 13:50:32','2026-08-27 13:50:32');
/*!40000 ALTER TABLE `warehouse_ark` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `warehouse_armory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouse_armory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_type` enum('item','weapon','ammo','material') NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_warehouse_armory_type_item` (`item_type`,`item_id`),
  KEY `idx_item_type` (`item_type`),
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库-镇武库（镇长厅）';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `warehouse_armory` WRITE;
/*!40000 ALTER TABLE `warehouse_armory` DISABLE KEYS */;
INSERT INTO `warehouse_armory` VALUES (13,'weapon',1,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(14,'ammo',1,4,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(15,'weapon',2,1,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(16,'ammo',2,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(17,'weapon',7,1,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(18,'ammo',4,4,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(19,'weapon',4,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(20,'weapon',3,3,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(21,'item',6,4,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(22,'item',5,1,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(23,'item',3,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(24,'material',12,1,'2026-08-27 13:50:32','2026-08-27 13:50:32');
/*!40000 ALTER TABLE `warehouse_armory` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `warehouse_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouse_config` (
  `id` int NOT NULL AUTO_INCREMENT,
  `warehouse_key` varchar(50) NOT NULL COMMENT '仓库标识键',
  `warehouse_name` varchar(50) NOT NULL COMMENT '仓库名称',
  `table_name` varchar(50) NOT NULL COMMENT '对应数据库表名',
  `key_item_id` int NOT NULL COMMENT '对应钥匙的item表ID',
  `icon` varchar(20) DEFAULT '' COMMENT '图标',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序',
  PRIMARY KEY (`id`),
  UNIQUE KEY `warehouse_key` (`warehouse_key`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `warehouse_config` WRITE;
/*!40000 ALTER TABLE `warehouse_config` DISABLE KEYS */;
INSERT INTO `warehouse_config` VALUES (1,'general','矿场仓库','warehouse_general',19,'box',1),(2,'fuel','燃料仓库','warehouse_fuel',20,'fuel',2),(3,'armory','镇武库','warehouse_armory',21,'sword',3),(4,'dock','码头集购仓','warehouse_dock',22,'anchor',4),(5,'rebel','反抗者阵营仓库','warehouse_rebel',23,'flag',5),(6,'ark','冒险者阵营仓库','warehouse_ark',24,'ship',6);
/*!40000 ALTER TABLE `warehouse_config` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `warehouse_dock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouse_dock` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_type` enum('item','weapon','ammo','material') NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_warehouse_dock_type_item` (`item_type`,`item_id`),
  KEY `idx_item_type` (`item_type`),
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库-码头集购仓';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `warehouse_dock` WRITE;
/*!40000 ALTER TABLE `warehouse_dock` DISABLE KEYS */;
INSERT INTO `warehouse_dock` VALUES (13,'material',5,800,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(14,'item',18,1,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(15,'item',10,20,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(16,'item',14,5,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(17,'item',1,20,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(18,'item',11,3,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(19,'item',12,1,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(20,'weapon',6,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(21,'item',7,1,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(22,'ammo',3,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(23,'item',17,1,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(24,'material',11,3,'2026-08-27 13:50:32','2026-08-27 13:50:32');
/*!40000 ALTER TABLE `warehouse_dock` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `warehouse_fuel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouse_fuel` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_type` enum('item','weapon','ammo','material') NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_warehouse_fuel_type_item` (`item_type`,`item_id`),
  KEY `idx_item_type` (`item_type`),
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库-燃料仓库（警察局）';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `warehouse_fuel` WRITE;
/*!40000 ALTER TABLE `warehouse_fuel` DISABLE KEYS */;
INSERT INTO `warehouse_fuel` VALUES (7,'material',8,500,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(8,'material',2,50000,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(9,'item',15,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(10,'item',13,20,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(11,'item',2,8,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(12,'material',6,50,'2026-08-27 13:50:32','2026-08-27 13:50:32');
/*!40000 ALTER TABLE `warehouse_fuel` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `warehouse_general`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouse_general` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_type` enum('item','weapon','ammo','material') NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_warehouse_general_type_item` (`item_type`,`item_id`),
  KEY `idx_item_type` (`item_type`),
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库-矿场仓库';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `warehouse_general` WRITE;
/*!40000 ALTER TABLE `warehouse_general` DISABLE KEYS */;
INSERT INTO `warehouse_general` VALUES (11,'material',1,50000,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(12,'material',2,5000,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(13,'material',7,5000,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(14,'material',4,100,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(15,'material',3,100,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(16,'material',9,100,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(17,'weapon',8,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(18,'weapon',9,1,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(19,'item',8,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(20,'material',12,1,'2026-08-27 13:50:32','2026-08-27 13:50:32');
/*!40000 ALTER TABLE `warehouse_general` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `warehouse_rebel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `warehouse_rebel` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_type` enum('item','weapon','ammo','material') NOT NULL,
  `item_id` int NOT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_warehouse_rebel_type_item` (`item_type`,`item_id`),
  KEY `idx_item_type` (`item_type`),
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='仓库-反抗者阵营仓库';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `warehouse_rebel` WRITE;
/*!40000 ALTER TABLE `warehouse_rebel` DISABLE KEYS */;
INSERT INTO `warehouse_rebel` VALUES (6,'weapon',2,1,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(7,'ammo',2,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(8,'weapon',7,2,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(9,'ammo',4,4,'2026-08-27 13:50:32','2026-08-27 13:50:32'),(10,'material',6,20,'2026-08-27 13:50:32','2026-08-27 13:50:32');
/*!40000 ALTER TABLE `warehouse_rebel` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `weapon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `weapon` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `remark` text,
  `threat_level` int NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tag` varchar(100) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `weapon` WRITE;
/*!40000 ALTER TABLE `weapon` DISABLE KEYS */;
INSERT INTO `weapon` VALUES (1,'制式手枪','把','韦伯利.38口径转轮手枪，英军标准配发。威胁值5，远程武器。',5,'2026-04-27 11:36:23','2026-05-19 22:49:10',NULL,NULL),(2,'猎枪','把','12号口径单管或双管猎枪，用于狩猎鸟类和小型动物。威胁值6，远程武器。',6,'2026-04-27 11:36:23','2026-05-02 19:21:45',NULL,NULL),(3,'警棍','个','硬木制成的短棍，长50厘米。威胁值1，非致命武器，可用于制服而非杀死目标。',1,'2026-04-27 11:36:23','2026-05-02 19:20:27',NULL,NULL),(4,'刺刀','把','军用制式刺刀，长约20厘米。威胁值2。',2,'2026-04-27 11:36:23','2026-05-02 19:21:50',NULL,NULL),(5,'水手刀','把','多功能刀具（规则索引亦称水果刀）。威胁值2。',2,'2026-04-27 11:36:23','2026-05-02 19:21:53',NULL,NULL),(6,'鱼叉/矛','个','铁头木柄的捕鱼工具，长110厘米。威胁值3，既可捕鱼也可作为近战武器，渔民的标配。',3,'2026-04-27 11:36:23','2026-08-27 13:50:10',NULL,NULL),(7,'猎弓','张','简单木质主体金属包角的反曲猎弓。威胁值4，无声远程武器。',4,'2026-04-27 11:36:23','2026-05-02 19:22:03',NULL,NULL),(8,'十字镐','把','采矿用的双头镐具，长65厘米，重5kg。威胁值1，主要用来挖掘石料，紧急时也可作为武器。',1,'2026-04-27 11:36:23','2026-05-02 19:21:04',NULL,NULL),(9,'斧头','把','伐木用双面斧，长65厘米。威胁值2，砍树是本职工作，砍人也不是不行。',2,'2026-04-27 11:36:23','2026-05-02 19:22:11',NULL,NULL),(10,'电锯','把','二冲程汽油动力链锯，噪音巨大。威胁值4，伐木效率高（持有时5吨木材/天，否则1吨），但需要燃油且会暴露位置。',4,'2026-04-27 11:36:23','2026-05-02 19:22:15',NULL,NULL),(11,'手术刀','把','医用不锈钢手术刀，套装含多型号刀片。威胁值1，精准切割工具，在医疗行动中不可或缺。',1,'2026-04-27 11:36:23','2026-05-02 19:21:20',NULL,NULL),(12,'炸药','kg','工业硝铵炸药。威胁值极高：炸弹外围按威胁值5、内围按威胁值10结算额外命中；战力计算默认按内围10计入（可由主持人按场景调整）。',10,'2026-04-27 11:36:23','2026-04-27 11:36:23',NULL,NULL),(13,'电钻','把','电动钻机，用于开采石料。生产工具（挖掘时5吨，否则1吨）。威胁值1。',1,'2026-08-08 00:00:00','2026-08-08 00:00:00',NULL,NULL),(15,'铁镐','把','结实的铁镐，可用于挖掘，紧急时也可作为武器。威胁值2。',2,'2026-08-27 13:48:40','2026-08-27 13:50:10',NULL,NULL);
/*!40000 ALTER TABLE `weapon` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

