-- 职业初始资源表结构及数据初始化脚本
-- 根据职业及初始资源.txt文件生成

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- 创建职业初始资源表(job_initial_items)
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职业初始资源表';

-- ----------------------------
-- 职业初始资源数据录入
-- ----------------------------

-- 注意：以下数据根据job表的插入顺序对应job_id
-- job_id: 1=镇长, 2=监狱长, 3=警长, 4=隐藏统治者, 5=治安官, 6=民兵, 7=巡夜人
-- job_id: 8=农户, 9=伐木工, 10=矿工, 11=铁匠, 12=手工艺人, 13=工匠
-- job_id: 14=渔民, 15=水手, 16=船长, 17=装卸工, 18=采珠人
-- job_id: 19=神父, 20=赤脚医生, 21=杂货店主, 22=旅店店主, 23=酒馆老板, 24=灯塔看守员, 25=面包师
-- job_id: 26=向导, 27=猎户, 28=邮递员, 29=守墓人, 30=气象观测员, 31=占卜师, 32=设施维护人, 33=教师

-- 1. 镇长(射击)：防弹衣1，手枪（6发子弹）
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(1, 'item', 5, 1, '件'),    -- 防弹衣
(1, 'weapon', 1, 1, '把'),  -- 制式手枪
(1, 'ammo', 1, 6, '枚');    -- 手枪弹

-- 2. 监狱长（格斗，急救）:手铐2，警棍1，防弹衣1，手电筒2，哨子1
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(2, 'item', 3, 2, '个'),    -- 手铐
(2, 'weapon', 3, 1, '个'),  -- 警棍
(2, 'item', 5, 1, '件'),    -- 防弹衣
(2, 'item', 2, 2, '个'),    -- 手电筒
(2, 'item', 4, 1, '个');    -- 哨子

-- 3. 警长(射击)：警棍1，手电筒1，哨子1，防弹衣1，手枪（6发子弹）
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(3, 'weapon', 3, 1, '个'),  -- 警棍
(3, 'item', 2, 1, '个'),    -- 手电筒
(3, 'item', 4, 1, '个'),    -- 哨子
(3, 'item', 5, 1, '件'),    -- 防弹衣
(3, 'weapon', 1, 1, '把'),  -- 制式手枪
(3, 'ammo', 1, 6, '枚');    -- 手枪弹

-- 4. 隐藏统治者：防弹衣1
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(4, 'item', 5, 1, '件');    -- 防弹衣

-- 5. 治安官（射击）：手铐1，警棍1，防弹衣1，手电筒1，食物2kg，燃料5kg，木材45kg，手枪（2发），医疗资源10份，绳索10米，朗姆酒5瓶
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(5, 'item', 3, 1, '个'),    -- 手铐
(5, 'weapon', 3, 1, '个'),  -- 警棍
(5, 'item', 5, 1, '件'),    -- 防弹衣
(5, 'item', 2, 1, '个'),    -- 手电筒
(5, 'material', 5, 2, 'kg'), -- 食物
(5, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(5, 'material', 2, 45, 'kg'), -- 木材
(5, 'weapon', 1, 1, '把'),  -- 制式手枪
(5, 'ammo', 1, 2, '枚'),    -- 手枪弹
(5, 'item', 1, 10, '份'),   -- 医疗资源
(5, 'material', 3, 10, '米'), -- 绳索
(5, 'item', 10, 5, '瓶');   -- 朗姆酒

-- 6. 民兵（格斗）：复合盾1，警棍1，食物2kg，燃料5kg，木材45kg，手枪（2发），医疗资源10份，绳索10米，朗姆酒5瓶
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(6, 'item', 6, 1, '个'),    -- 复合盾
(6, 'weapon', 3, 1, '个'),  -- 警棍
(6, 'material', 5, 2, 'kg'), -- 食物
(6, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(6, 'material', 2, 45, 'kg'), -- 木材
(6, 'weapon', 1, 1, '把'),  -- 制式手枪
(6, 'ammo', 1, 2, '枚'),    -- 手枪弹
(6, 'item', 1, 10, '份'),   -- 医疗资源
(6, 'material', 3, 10, '米'), -- 绳索
(6, 'item', 10, 5, '瓶');   -- 朗姆酒

-- 7. 巡夜人（格斗，巡逻）:哨子1，手电筒2，复合盾1，蜡烛10根，食物2kg，燃料5kg，木材45kg，手枪（2发），医疗资源10份，绳索10米，朗姆酒5瓶
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(7, 'item', 4, 1, '个'),    -- 哨子
(7, 'item', 2, 2, '个'),    -- 手电筒
(7, 'item', 6, 1, '个'),    -- 复合盾
(7, 'item', 13, 10, '根'),  -- 蜡烛
(7, 'material', 5, 2, 'kg'), -- 食物
(7, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(7, 'material', 2, 45, 'kg'), -- 木材
(7, 'weapon', 1, 1, '把'),  -- 制式手枪
(7, 'ammo', 1, 2, '枚'),    -- 手枪弹
(7, 'item', 1, 10, '份'),   -- 医疗资源
(7, 'material', 3, 10, '米'), -- 绳索
(7, 'item', 10, 5, '瓶');   -- 朗姆酒

-- 8. 农户（食物生产）：面包5kg(食物)，绳索10米，斧头1，火柴1盒，食物8kg，燃料5kg，木材150kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(8, 'material', 5, 13, 'kg'), -- 食物(面包5kg+食物8kg)
(8, 'material', 3, 10, '米'), -- 绳索
(8, 'weapon', 9, 1, '把'),  -- 斧头
(8, 'item', 15, 1, '盒'),   -- 火柴
(8, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(8, 'material', 2, 150, 'kg'); -- 木材

-- 9. 伐木工（伐木）：斧头1，电锯1，绳索10米，手电筒1，火柴1盒，食物8kg，燃料5kg，木材150kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(9, 'weapon', 9, 1, '把'),  -- 斧头
(9, 'weapon', 10, 1, '把'), -- 电锯
(9, 'material', 3, 10, '米'), -- 绳索
(9, 'item', 2, 1, '个'),    -- 手电筒
(9, 'item', 15, 1, '盒'),   -- 火柴
(9, 'material', 5, 8, 'kg'), -- 食物
(9, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(9, 'material', 2, 150, 'kg'); -- 木材

-- 10. 矿工（挖掘）：镐子2(十字镐)，十字镐1，手电筒1，火柴1盒，食物8kg，燃料5kg，木材150kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(10, 'weapon', 8, 3, '把'), -- 十字镐(镐子2+十字镐1)
(10, 'item', 2, 1, '个'),   -- 手电筒
(10, 'item', 15, 1, '盒'),  -- 火柴
(10, 'material', 5, 8, 'kg'), -- 食物
(10, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(10, 'material', 2, 150, 'kg'); -- 木材

-- 11. 铁匠（炼铁）:刺刀1，绳索10米，火柴1盒，食物8kg，燃料5kg，木材150kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(11, 'weapon', 4, 1, '把'), -- 刺刀
(11, 'material', 3, 10, '米'), -- 绳索
(11, 'item', 15, 1, '盒'),  -- 火柴
(11, 'material', 5, 8, 'kg'), -- 食物
(11, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(11, 'material', 2, 150, 'kg'); -- 木材

-- 12. 手工艺人（手工艺）：金属制品5kg，绳索20米，帆布10米，手电筒1，火柴1盒，食物8kg，燃料5kg，木材150kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(12, 'material', 1, 5, 'kg'), -- 金属制品
(12, 'material', 3, 20, '米'), -- 绳索
(12, 'material', 9, 10, '米'), -- 帆布
(12, 'item', 2, 1, '个'),    -- 手电筒
(12, 'item', 15, 1, '盒'),   -- 火柴
(12, 'material', 5, 8, 'kg'), -- 食物
(12, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(12, 'material', 2, 150, 'kg'); -- 木材

-- 13. 工匠（木石工艺）:食物8kg，燃料5kg，木材150kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(13, 'material', 5, 8, 'kg'), -- 食物
(13, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(13, 'material', 2, 150, 'kg'); -- 木材

-- 14. 渔民（捕鱼，格斗）：鱼叉1，渔网1副，刺刀1，绳索10米，食物5kg，木材80kg，燃料10kg，绳索10米
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(14, 'weapon', 6, 1, '个'),  -- 鱼叉/矛
(14, 'item', 12, 1, '张'),   -- 渔网
(14, 'weapon', 4, 1, '把'),  -- 刺刀
(14, 'material', 3, 20, '米'), -- 绳索(10+10)
(14, 'material', 5, 5, 'kg'), -- 食物
(14, 'material', 2, 80, 'kg'), -- 木材
(14, 'material', 8, 10, 'kg'); -- 燃料(煤油)

-- 15. 水手（航海，格斗）：刺刀1，绳索20米，手电筒1，渔网1，食物5kg，木材80kg，燃料10kg，绳索10米
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(15, 'weapon', 4, 1, '把'),  -- 刺刀
(15, 'material', 3, 30, '米'), -- 绳索(20+10)
(15, 'item', 2, 1, '个'),    -- 手电筒
(15, 'item', 12, 1, '张'),   -- 渔网
(15, 'material', 5, 5, 'kg'), -- 食物
(15, 'material', 2, 80, 'kg'), -- 木材
(15, 'material', 8, 10, 'kg'); -- 燃料(煤油)

-- 16. 船长（远洋导航，射击）:刺刀1，信号枪1，信号弹1，破损海图1，食物5kg，木材80kg，燃料10kg，绳索10米
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(16, 'weapon', 4, 1, '把'),  -- 刺刀
(16, 'item', 7, 1, '把'),    -- 信号枪
(16, 'ammo', 3, 1, '枚'),    -- 信号弹
(16, 'item', 17, 1, '张'),   -- 破损海图
(16, 'material', 5, 5, 'kg'), -- 食物
(16, 'material', 2, 80, 'kg'), -- 木材
(16, 'material', 8, 10, 'kg'), -- 燃料(煤油)
(16, 'material', 3, 10, '米'); -- 绳索

-- 17. 装卸工（搬运，斗殴）:绳索20米，手电筒1，刺刀1，食物5kg，木材80kg，燃料10kg，绳索10米
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(17, 'material', 3, 30, '米'), -- 绳索(20+10)
(17, 'item', 2, 1, '个'),    -- 手电筒
(17, 'weapon', 4, 1, '把'),  -- 刺刀
(17, 'material', 5, 5, 'kg'), -- 食物
(17, 'material', 2, 80, 'kg'), -- 木材
(17, 'material', 8, 10, 'kg'); -- 燃料(煤油)

-- 18. 采珠人（潜水，捕鱼）:刺刀1，渔网1副，绳索10米，食物5kg，木材80kg，燃料10kg，绳索10米
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(18, 'weapon', 4, 1, '把'),  -- 刺刀
(18, 'item', 12, 1, '张'),   -- 渔网
(18, 'material', 3, 20, '米'), -- 绳索(10+10)
(18, 'material', 5, 5, 'kg'), -- 食物
(18, 'material', 2, 80, 'kg'), -- 木材
(18, 'material', 8, 10, 'kg'); -- 燃料(煤油)

-- 19. 神父（布道，医疗）:蜡烛50支，火柴5盒，绳索10米，食物3kg，燃料5kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(19, 'item', 13, 50, '支'),  -- 蜡烛
(19, 'item', 15, 5, '盒'),   -- 火柴
(19, 'material', 3, 10, '米'), -- 绳索
(19, 'material', 5, 3, 'kg'), -- 食物
(19, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(19, 'material', 2, 50, 'kg'), -- 木材
(19, 'material', 1, 10, 'kg'); -- 金属制品

-- 20. 赤脚医生（医疗，急救）:医疗资源20份，手术刀1套，绳索10米，食物3kg，燃料5kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(20, 'item', 1, 20, '份'),   -- 医疗资源
(20, 'weapon', 11, 1, '把'), -- 手术刀
(20, 'material', 3, 10, '米'), -- 绳索
(20, 'material', 5, 3, 'kg'), -- 食物
(20, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(20, 'material', 2, 50, 'kg'), -- 木材
(20, 'material', 1, 10, 'kg'); -- 金属制品

-- 21. 杂货店主（囤货）:食物23kg，朗姆酒10瓶，绳索100米，镐子2，斧头2，猎枪2，猎枪弹4，燃料35kg，木材350kg，金属制品40kg，沥青30kg，帆布30米，铅笔5支
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(21, 'material', 5, 23, 'kg'), -- 食物
(21, 'item', 10, 10, '瓶'),  -- 朗姆酒
(21, 'material', 3, 100, '米'), -- 绳索
(21, 'weapon', 8, 2, '把'),  -- 十字镐(镐子)
(21, 'weapon', 9, 2, '把'),  -- 斧头
(21, 'weapon', 2, 2, '把'),  -- 猎枪
(21, 'ammo', 2, 4, '枚'),    -- 猎枪弹
(21, 'material', 8, 35, 'kg'), -- 燃料(煤油)
(21, 'material', 2, 350, 'kg'), -- 木材
(21, 'material', 1, 40, 'kg'), -- 金属制品
(21, 'material', 6, 30, 'kg'), -- 沥青
(21, 'material', 9, 30, '米'), -- 帆布
(21, 'item', 16, 5, '支');   -- 铅笔

-- 22. 旅店店主（囤货）:食物18kg，木材550kg，燃料105kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(22, 'material', 5, 18, 'kg'), -- 食物
(22, 'material', 2, 550, 'kg'), -- 木材
(22, 'material', 8, 105, 'kg'); -- 燃料(煤油)

-- 23. 酒馆老板（囤货）:火柴1盒，医用酒精10升，食物5kg，燃料5kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(23, 'item', 15, 1, '盒'),   -- 火柴
(23, 'item', 14, 10, '升'),  -- 医用酒精
(23, 'material', 5, 5, 'kg'), -- 食物
(23, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(23, 'material', 2, 50, 'kg'), -- 木材
(23, 'material', 1, 10, 'kg'); -- 金属制品

-- 24. 灯塔看守员（射击）:信号枪1，信号弹2发，手电筒1，燃料15kg，破损海图1，食物3kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(24, 'item', 7, 1, '把'),    -- 信号枪
(24, 'ammo', 3, 2, '枚'),    -- 信号弹
(24, 'item', 2, 1, '个'),    -- 手电筒
(24, 'material', 8, 15, 'kg'), -- 燃料(煤油)
(24, 'item', 17, 1, '张'),   -- 破损海图
(24, 'material', 5, 3, 'kg'), -- 食物
(24, 'material', 2, 50, 'kg'), -- 木材
(24, 'material', 1, 10, 'kg'); -- 金属制品

-- 25. 面包师（烘焙）:食物8kg，燃料5kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(25, 'material', 5, 8, 'kg'), -- 食物
(25, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(25, 'material', 2, 50, 'kg'), -- 木材
(25, 'material', 1, 10, 'kg'); -- 金属制品

-- 26. 向导（急救，潜行）:刺刀1，绳索20米，手电筒1，食物2kg，燃料5kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(26, 'weapon', 4, 1, '把'),  -- 刺刀
(26, 'material', 3, 20, '米'), -- 绳索
(26, 'item', 2, 1, '个'),    -- 手电筒
(26, 'material', 5, 2, 'kg'), -- 食物
(26, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(26, 'material', 2, 50, 'kg'), -- 木材
(26, 'material', 1, 10, 'kg'); -- 金属制品

-- 27. 猎户（射击，潜行）:猎枪1，猎枪弹4发，刺刀1，绳索10米，食物2kg，燃料5kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(27, 'weapon', 2, 1, '把'),  -- 猎枪
(27, 'ammo', 2, 4, '枚'),    -- 猎枪弹
(27, 'weapon', 4, 1, '把'),  -- 刺刀
(27, 'material', 3, 10, '米'), -- 绳索
(27, 'material', 5, 2, 'kg'), -- 食物
(27, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(27, 'material', 2, 50, 'kg'), -- 木材
(27, 'material', 1, 10, 'kg'); -- 金属制品

-- 28. 邮递员（潜行）:绳索20米，手电筒1，哨子1，食物2kg，燃料5kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(28, 'material', 3, 20, '米'), -- 绳索
(28, 'item', 2, 1, '个'),    -- 手电筒
(28, 'item', 4, 1, '个'),    -- 哨子
(28, 'material', 5, 2, 'kg'), -- 食物
(28, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(28, 'material', 2, 50, 'kg'), -- 木材
(28, 'material', 1, 10, 'kg'); -- 金属制品

-- 29. 守墓人（通灵）:十字镐1，手电筒1，绳索10米，蜡烛10支，食物2kg，燃料5kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(29, 'weapon', 8, 1, '把'),  -- 十字镐
(29, 'item', 2, 1, '个'),    -- 手电筒
(29, 'material', 3, 10, '米'), -- 绳索
(29, 'item', 13, 10, '支'),  -- 蜡烛
(29, 'material', 5, 2, 'kg'), -- 食物
(29, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(29, 'material', 2, 50, 'kg'), -- 木材
(29, 'material', 1, 10, 'kg'); -- 金属制品

-- 30. 气象观测员（天气预测）:铅笔5支，燃料20kg，帆布20米，食物2kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(30, 'item', 16, 5, '支'),   -- 铅笔
(30, 'material', 8, 20, 'kg'), -- 燃料(煤油，额外5升)
(30, 'material', 9, 20, '米'), -- 帆布
(30, 'material', 5, 2, 'kg'), -- 食物
(30, 'material', 2, 50, 'kg'), -- 木材
(30, 'material', 1, 10, 'kg'); -- 金属制品

-- 31. 占卜师（占星）:蜡烛10支，火柴1盒，绳索10米，手电筒1，食物2kg，燃料5kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(31, 'item', 13, 10, '支'),  -- 蜡烛
(31, 'item', 15, 1, '盒'),   -- 火柴
(31, 'material', 3, 10, '米'), -- 绳索
(31, 'item', 2, 1, '个'),    -- 手电筒
(31, 'material', 5, 2, 'kg'), -- 食物
(31, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(31, 'material', 2, 50, 'kg'), -- 木材
(31, 'material', 1, 10, 'kg'); -- 金属制品

-- 32. 设施维护人（维修）:维修工具包2，手电筒1，绳索10米，食物2kg，燃料5kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(32, 'item', 8, 2, '个'),    -- 维修工具包
(32, 'item', 2, 1, '个'),    -- 手电筒
(32, 'material', 3, 10, '米'), -- 绳索
(32, 'material', 5, 2, 'kg'), -- 食物
(32, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(32, 'material', 2, 50, 'kg'), -- 木材
(32, 'material', 1, 10, 'kg'); -- 金属制品

-- 33. 教师（启蒙）:粉笔2盒，铅笔5支，手电筒1，食物2kg，燃料5kg，木材50kg，金属制品10kg
INSERT INTO `job_initial_items` (`job_id`, `item_type`, `item_id`, `quantity`, `unit`) VALUES
(33, 'item', 16, 5, '支'),   -- 铅笔(粉笔暂未在数据库中)
(33, 'item', 2, 1, '个'),    -- 手电筒
(33, 'material', 5, 2, 'kg'), -- 食物
(33, 'material', 8, 5, 'kg'), -- 燃料(煤油)
(33, 'material', 2, 50, 'kg'), -- 木材
(33, 'material', 1, 10, 'kg'); -- 金属制品

SET FOREIGN_KEY_CHECKS=1;