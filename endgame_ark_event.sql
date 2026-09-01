/*
Navicat MySQL Data Transfer

Source Server         : cc
Source Server Version : 50717
Source Host           : localhost:3306
Source Database       : snowisland

Target Server Type    : MYSQL
Target Server Version : 50717
File Encoding         : 65001

Date: 2026-06-27 12:03:49
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for endgame_ark_event
-- ----------------------------
DROP TABLE IF EXISTS `endgame_ark_event`;
CREATE TABLE `endgame_ark_event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `sort_order` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Records of endgame_ark_event
-- ----------------------------
INSERT INTO `endgame_ark_event` VALUES ('1', '巨浪拍舷', '一道突如其来的侧浪狠狠拍打船身，甲板上的物资被冲得七零八落，几个水手差点落水。\n\n效果：随机损失5%的食物（被浪卷走）。若拥有\"航海\"技能玩家或额外消耗50kg燃料紧急调整航向，可将损失降至0。', '危机', '1', null, null);
INSERT INTO `endgame_ark_event` VALUES ('2', '帆布撕裂', '强风将主帆撕开一道大口子，帆布在风中啪啪作响，船速骤降。\n\n效果：本日及后续航行天数增加1天（因减速）。若消耗10米帆布或\"维修\"技能玩家现场缝补，可免于增加天数。若无帆船（纯发动机），此事件无效，重新抽取。', '危机', '2', null, null);
INSERT INTO `endgame_ark_event` VALUES ('3', '淡水变质', '储存的桶装淡水出现绿藻和异味，部分已不可饮用。\n\n效果：损失10%的食物储备。消耗5份医疗资源或200kg木材可净化剩余淡水，将损失降至5%。否则获得1个\"患病\"标记。', '危机', '3', null, null);
INSERT INTO `endgame_ark_event` VALUES ('4', '发动机过热', '因长时间高负荷运转，发动机冷却系统失效，缸体发红，必须停机。\n\n效果：若不修复，航行强制暂停1天（需原地等待冷却）。消耗1个维修工具包或拥有\"维修\"技能玩家可当场修复，不损失时间。', '危机', '4', null, null);
INSERT INTO `endgame_ark_event` VALUES ('5', '晕船蔓延', '连续颠簸让超过一半人晕船呕吐，体力下降，士气低迷。\n\n效果：获得1个\"患病\"标记（严重晕船）。若拥有\"医疗\"技能玩家或消耗5份朗姆酒可缓解。', '危机', '5', null, null);
INSERT INTO `endgame_ark_event` VALUES ('6', '暗礁险情', '海面下隐约看到黑色礁石轮廓，舵手紧急打舵。\n\n效果：若拥有\"海洋导航\"技能玩家，可安全绕行。否则船底擦伤，船体完整度下降5%，并损失5%燃料（泄漏）。', '危机', '6', null, null);
INSERT INTO `endgame_ark_event` VALUES ('7', '食物中毒', '一批腌肉在高温下变质，多人食用后腹痛腹泻。\n\n效果：获得1个\"患病\"标记，并损失10%食物（变质部分丢弃）。消耗5份医疗资源可救治所有人，避免患病标记。', '危机', '7', null, null);
INSERT INTO `endgame_ark_event` VALUES ('8', '内部盗窃', '有人趁夜偷走部分燃料和食物，藏在个人箱子里。被发现后引发争执。\n\n效果：若不消耗2个朗姆酒则损失5%燃料和5%食物（被窃并挥霍），且随机1名玩家受伤（斗殴）。', '危机', '8', null, null);
INSERT INTO `endgame_ark_event` VALUES ('9', '螺旋桨缠绕', '漂浮的渔网或海草缠住了螺旋桨，动力下降，船体抖动。\n\n效果：需有玩家或拥有\"格斗\"/\"潜水\"技能玩家下水清理，或搁置耗时加1天。可消耗1个维修工具包远程切断。', '危机', '9', null, null);
INSERT INTO `endgame_ark_event` VALUES ('10', '暴风雨迷航', '一场无预报的暴风雨遮天蔽日，指南针失灵，航向偏移。\n\n效果：若拥有\"天气预测\"技能玩家或海图（特殊物品），可校准航向，无损失。否则航行天数增加1天，并额外消耗10%燃料。', '危机', '10', null, null);
INSERT INTO `endgame_ark_event` VALUES ('11', '舱底进水', '船底板接缝处渗水，水泵来不及抽排，水位缓慢上升。\n\n效果：消耗500kg木材和1个维修技能可堵漏。否则每过1天，船体完整度下降5%且获得1个\"患病\"标记（潮湿寒冷）。', '危机', '11', null, null);
INSERT INTO `endgame_ark_event` VALUES ('12', '传染病爆发', '一种类似流感的疾病在密闭船舱中迅速传播，咳嗽声此起彼伏。\n\n效果：获得1个\"患病\"标记。消耗5份医疗资源或拥有\"医疗\"或\"布道\"玩家可控制疫情，只获得1个\"患病\"标记。', '危机', '12', null, null);
INSERT INTO `endgame_ark_event` VALUES ('13', '桅杆断裂', '一阵强风拦腰折断主桅，帆具垮塌，甲板一片狼藉。\n\n效果：船体完整度下降10%。若拥有500kg木材可临时修复，只增加1天。', '危机', '13', null, null);
INSERT INTO `endgame_ark_event` VALUES ('14', '漂浮的救援物资', '桅杆上的瞭望手突然大喊：\"左舷海面上有漂浮的桶！\"你们靠近后发现，那正是你们之前通过邮局电报机向外发送求救信号的回应——一艘货轮在暴风雪来临前抛下了救援物资桶，上面还绑着一面沾着冰霜的旗帜。\n\n效果：获得20单位食物+50kg燃料（煤油/柴油）+10份医疗资源。若船上拥有\"天气预测\"或\"海洋导航\"技能玩家，还能额外找到1个维修工具包。这些物资直接进入方舟公共仓库。', '希望', '14', null, null);
INSERT INTO `endgame_ark_event` VALUES ('15', '顺风加速', '风向突然转为顺风，帆面鼓满，船头像切开黄油一样劈开浪花。舵手兴奋地吹起口哨。\n\n效果：航行天数减少1天。同时，本日不消耗额外燃料（发动机可停机半天）。', '希望', '15', null, null);
INSERT INTO `endgame_ark_event` VALUES ('16', '海鸟引路', '一群海鸟盘旋在船头方向，不时俯冲入水。经验丰富的水手说：\"跟着它们，前面必有浅滩或岛屿。\"\n\n效果：第二天航海检定自动成功（相当于一次免费绕开险情）。', '希望', '16', null, null);
INSERT INTO `endgame_ark_event` VALUES ('17', '漂浮的救援物资', '桅杆上的瞭望手突然大喊：\"左舷海面上有漂浮的桶！\"你们靠近后发现，那正是你们之前通过邮局电报机向外发送求救信号的回应——一艘货轮在暴风雪来临前抛下了救援物资桶，上面还绑着一面沾着冰霜的旗帜。\n\n效果：获得20单位食物+50kg燃料（煤油/柴油）+10份医疗资源。若船上拥有\"天气预测\"或\"海洋导航\"技能玩家，还能额外找到1个维修工具包。这些物资直接进入方舟公共仓库。', '希望', '17', null, null);
INSERT INTO `endgame_ark_event` VALUES ('18', '漂浮的救援物资', '桅杆上的瞭望手突然大喊：\"左舷海面上有漂浮的桶！\"你们靠近后发现，那正是你们之前通过邮局电报机向外发送求救信号的回应——一艘货轮在暴风雪来临前抛下了救援物资桶，上面还绑着一面沾着冰霜的旗帜。\n\n效果：获得20单位食物+50kg燃料（煤油/柴油）+10份医疗资源。若船上拥有\"天气预测\"或\"海洋导航\"技能玩家，还能额外找到1个维修工具包。这些物资直接进入方舟公共仓库。', '希望', '18', null, null);
INSERT INTO `endgame_ark_event` VALUES ('19', '漂浮的救援物资', '桅杆上的瞭望手突然大喊：\"左舷海面上有漂浮的桶！\"你们靠近后发现，那正是你们之前通过邮局电报机向外发送求救信号的回应——一艘货轮在暴风雪来临前抛下了救援物资桶，上面还绑着一面沾着冰霜的旗帜。\n\n效果：获得20单位食物+50kg燃料（煤油/柴油）+10份医疗资源。若船上拥有\"天气预测\"或\"海洋导航\"技能玩家，还能额外找到1个维修工具包。这些物资直接进入方舟公共仓库。', '希望', '19', null, null);
