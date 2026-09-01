-- 更新物品图鉴 remark（已有数据库执行；全新安装以 snowisland.sql 为准）
-- 威胁值文案与 weapon.threat_level / 参考资料对齐；便当已更名为面包

UPDATE `item` SET `name` = '医疗资源', `unit` = '份', `remark` = '基础医疗物资，急救重伤需5份' WHERE `id` = 1;
UPDATE `item` SET `remark` = '金属外壳的便携照明工具，使用煤油或电池。夜间行动的基础工具。' WHERE `id` = 2;
UPDATE `item` SET `remark` = '铁制约束器具，可将一名无反抗能力的玩家束缚。被束缚者无法进行大部分行动，直到被释放。' WHERE `id` = 3;
UPDATE `item` SET `remark` = '铜制哨子，声音尖锐可传遍全岛。吹响后会在公屏显示哨音，可用于报警或召集同伴。' WHERE `id` = 4;
UPDATE `item` SET `remark` = '复合金属材质制成的防护背心。在暴力冲突中可将一次「重伤」降级为「受伤」，或将一次「受伤」无效化，每场冲突限用一次。' WHERE `id` = 5;
UPDATE `item` SET `remark` = '轻质金属与帆布复合的防暴盾牌。一次「受伤」无效化，每场冲突限用一次。' WHERE `id` = 6;
UPDATE `item` SET `remark` = '维里式单发信号枪，可发射彩色信号弹。发射后由主持人在公屏展示信号内容（不超过5个字），可用于求援或传递简单信息。' WHERE `id` = 7;
UPDATE `item` SET `remark` = '内含基础维修工具。每包提供10点维修资源，可修复损坏的机械或设施。' WHERE `id` = 8;
UPDATE `item` SET `remark` = '带法律效力的空白契约纸。玩家之间可自行签订契约协议，用协议书签订的协议不公开契约信息。违约将受到约定惩罚。每名玩家每天最多成为契约者一次。' WHERE `id` = 9;
UPDATE `item` SET `remark` = '甘蔗酿造的烈酒，酒精度约40%。5瓶朗姆酒可以消除疲劳。' WHERE `id` = 10;
UPDATE `item` SET `remark` = '岛上采集的药用植物，经干燥处理后保存。可用于简易治疗，等于3医疗资源。' WHERE `id` = 11;
UPDATE `item` SET `remark` = '麻绳编织的捕鱼网具。渔民可用其与渔船一起进行渔猎行动。' WHERE `id` = 12;
UPDATE `item` SET `remark` = '动物油脂或蜂蜡制成的照明物。提供基础夜间照明，比煤油更安静但亮度较低。' WHERE `id` = 13;
UPDATE `item` SET `remark` = '75%浓度的消毒酒精，每升可用于提供5点医疗资源。' WHERE `id` = 14;
UPDATE `item` SET `remark` = '防水密封包装的火柴，每盒约50根。生火做饭、点灯取暖的基础消耗品。' WHERE `id` = 15;
UPDATE `item` SET `remark` = '木质铅笔。可用于书写信件、记录信息或绘制简易地图。' WHERE `id` = 16;
UPDATE `item` SET `remark` = '年代久远的航海图，部分区域已损毁或褪色。仍可辨认大致航线与岛屿位置，是远洋航行的重要参考。' WHERE `id` = 17;
UPDATE `item` SET `name` = '面包', `remark` = '面包师精心制作的便携餐食，松松软软量大管饱，营养均衡且便于携带。食用后可获得额外1个白天行动点，每人每天限吃一份。可以储存和交易，是后期高密度行动的重要战略资源。面包本身不提供热量，其核心价值在于让人挤出更多时间做事，而非填饱肚子。' WHERE `id` = 18;
UPDATE `item` SET `remark` = '手工艺人的产出物品，配合每个人都有的火柴可以用来夜间照明并取暖。亦可作为探索道具（+7探索值）。' WHERE `id` = 25;

UPDATE `weapon` SET `remark` = '韦伯利.38口径转轮手枪，英军标准配发。威胁值5，远程武器。' WHERE `id` = 1;
UPDATE `weapon` SET `remark` = '12号口径单管或双管猎枪，用于狩猎鸟类和小型动物。威胁值6，远程武器。' WHERE `id` = 2;
UPDATE `weapon` SET `remark` = '硬木制成的短棍，长50厘米。威胁值1，非致命武器，可用于制服而非杀死目标。' WHERE `id` = 3;
UPDATE `weapon` SET `remark` = '军用制式刺刀，长约20厘米。威胁值2。' WHERE `id` = 4;
UPDATE `weapon` SET `remark` = '多功能刀具（规则索引亦称水果刀）。威胁值2。' WHERE `id` = 5;
UPDATE `weapon` SET `remark` = '铁头木柄的捕鱼工具，长110厘米。威胁值3，既可捕鱼也可作为近战武器，渔民的标配。' WHERE `id` = 6;
UPDATE `weapon` SET `remark` = '简单木质主体金属包角的反曲猎弓。威胁值4，无声远程武器。' WHERE `id` = 7;
UPDATE `weapon` SET `remark` = '采矿用的双头镐具，长65厘米，重5kg。威胁值1，主要用来挖掘石料，紧急时也可作为武器。' WHERE `id` = 8;
UPDATE `weapon` SET `remark` = '伐木用双面斧，长65厘米。威胁值2，砍树是本职工作，砍人也不是不行。' WHERE `id` = 9;
UPDATE `weapon` SET `remark` = '二冲程汽油动力链锯，噪音巨大。威胁值4，伐木效率极高（30吨原木/天），但需要燃油且会暴露位置。' WHERE `id` = 10;
UPDATE `weapon` SET `remark` = '医用不锈钢手术刀，套装含多型号刀片。威胁值1，精准切割工具，在医疗行动中不可或缺。' WHERE `id` = 11;
UPDATE `weapon` SET `remark` = '工业硝铵炸药。威胁值极高：炸弹外围按威胁值5、内围按威胁值10结算额外命中；战力计算默认按内围10计入（可由主持人按场景调整）。' WHERE `id` = 12;

UPDATE `ammo` SET `remark` = '.38/200口径手枪弹药，每发为韦伯利手枪专用。装填后可使手枪的威胁值生效。' WHERE `id` = 1;
UPDATE `ammo` SET `remark` = '12号口径霰弹，每发内含多颗铅弹。装填后可使猎枪的威胁值生效。' WHERE `id` = 2;
UPDATE `ammo` SET `remark` = '红/绿两色信号弹，每发可发射一次。用信号枪发射后，由主持人在公屏展示信号内容。' WHERE `id` = 3;
UPDATE `ammo` SET `remark` = '木质箭杆配金属箭头，每支为猎弓专用。装填后可使猎弓的威胁值生效。' WHERE `id` = 4;

UPDATE `material` SET `name` = '燃料', `remark` = '统称可用于燃烧供能的物资，包括木柴、煤炭、燃料等。不同设备的燃料消耗标准不同，详见燃料消耗表。' WHERE `id` = 8;
UPDATE `material` SET `remark` = '加工后的铁件、钉子、铁丝等金属材料。可用于锻造武器或工具，或修建设施的基础材料。' WHERE `id` = 1;
UPDATE `material` SET `remark` = '从岛上砍伐的原木，未经过加工。可直接作为燃料（25kg/天取暖），或加工成木板用于建筑。' WHERE `id` = 2;
UPDATE `material` SET `remark` = '麻绳或钢丝绳，直径1-2厘米。用于捆绑、拖拽、登山或船只系泊。探索时投入10个可提供+2探索值。' WHERE `id` = 3;
UPDATE `material` SET `remark` = '原木经蒸汽箱加工后的标准化板材。用于建造避难所、修理船只或制作家具，比原木更易使用。' WHERE `id` = 4;
UPDATE `material` SET `remark` = '泛指各种可食用物资，包括面粉、鱼干、咸肉、土豆等。' WHERE `id` = 5;
UPDATE `material` SET `remark` = '黑色粘稠的石油残渣，桶装保存。可用于修补船体裂缝、防水处理。' WHERE `id` = 6;
UPDATE `material` SET `remark` = '从采石场开采的岩石，大小不一。' WHERE `id` = 7;
UPDATE `material` SET `remark` = '厚实的亚麻或棉帆布，每卷宽1.5米。用于制作船帆、帐篷、防水布，或修补帆布类装备。' WHERE `id` = 9;
UPDATE `material` SET `remark` = '船用柴油发动机，方舟的核心动力设备，每台可使航行速度提升一档。' WHERE `id` = 10;
UPDATE `material` SET `remark` = '三叶螺旋桨，直径1.5米。方舟推进装置，需与发动机配套使用，破损后可拆卸更换。' WHERE `id` = 11;
UPDATE `material` SET `remark` = '老旧柴油发电机，已闲置多年。可尝试修理后发电，为岛上提供有限电力，需持续消耗燃料。' WHERE `id` = 12;
UPDATE `material` SET `remark` = '烧炭工烧制燃料的副产物，1单位的草木灰等于1单位医疗资源。' WHERE `id` = 13;

UPDATE `catastrophe_card` SET `description` = REPLACE(`description`, '煤油/燃油', '煤油/燃料') WHERE `description` LIKE '%煤油/燃油%';

UPDATE `item` SET `remark` = '地脉核心的封印碎片。持有即可产生地脉共鸣。可花费1次快速行动：将任意10单位资源（食物、燃料、木材、金属）转换为等量另一种资源；或为当前所在地点增加2点防御值。亦可作为仪式材料消耗1～3枚。原住民初始持有的祭坛石绑定个人仓库：不可被偷盗或被得知拥有，可交易或赠送。全游戏约5～7枚（26人5枚）。' WHERE `name` = '祭坛石';
UPDATE `item` SET `remark` = '一件覆盖细密鳞片的外套。每天一次可作为防弹衣效果。不可交易，不可被偷盗或任何方式被得知拥有。', `tradable` = 0 WHERE `name` = '鱼鳞外套';
UPDATE `item` SET `remark` = '半头盔式银灰色合金装置，内衬黑色织物。侧面按钮与指示灯大多熄灭，一颗暗红色灯缓慢闪烁。内侧绣着「铁砧小队·标准配置·情绪抑制模块·型号MK-II」。装备后获得「情绪抑制」状态，持续到持有者主动解除或装备损坏。后续部分清醒仪式以此为源头，是保持清醒的原因之一。' WHERE `name` = '情绪抑制器';
UPDATE `item` SET `remark` = '婴儿拳头大小深灰色卵石，握紧有节律震动，一端金属接口刻「白鸥小队·共鸣石·编号04」。消耗1次快速行动感知半径约200米内是否存在地脉异常点（祭坛石、地脉核心、仪式进行地点等：只告知有/无，不给位置）。每2天一次；用后眩晕耳鸣约半小时，期间检定-1。夜晚闭眼使用可能看见不属于这个时代的残片（白鸥小队「回声」残留），并获得持续1天的轻微「潮汐症」。' WHERE `name` = '共鸣石';
UPDATE `weapon` SET `threat_level` = 2, `remark` = '结实的铁镐，可用于挖掘，紧急时也可作为武器。威胁值2。' WHERE `id` = 15 OR `name` = '铁镐';

