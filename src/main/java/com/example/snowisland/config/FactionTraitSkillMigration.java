package com.example.snowisland.config;

import com.example.snowisland.entity.Skill;
import com.example.snowisland.repository.SkillRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.util.Arrays;
import java.util.List;

/**
 * 原住民 / 外来者阵营专属特性，以及无阵营限制的扩展特性。幂等：按 skill.name 判断是否已存在。
 */
@Component
@Order(17)
public class FactionTraitSkillMigration implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(FactionTraitSkillMigration.class);

    private static final String TARGET_ENUM =
            "ENUM('平民','统治者','冒险者','反叛者','天灾使者','外来者','原住民') NOT NULL DEFAULT '平民'";

    private static final class SkillSeed {
        final String name;
        final String function;
        final String faction;

        SkillSeed(String name, String function, String faction) {
            this.name = name;
            this.function = function;
            this.faction = faction;
        }
    }

    private static final List<SkillSeed> SEEDS = Arrays.asList(
        new SkillSeed("血脉共鸣",
            "你与地脉的联系比同类更深，岛屿的呼吸即是你的心跳。【效果】：当你与另一名原住民在同一地点且无其他玩家在场时，你们可以花费一次公共行动进行\"短暂共鸣\"。共鸣后，双方各自获得对方当前持有的一枚祭坛石的具体位置感知（仅感知到\"在哪\"，无法得知更多信息）。每天限一次。",
            "原住民"),
        new SkillSeed("古老血脉",
            "你的祖先曾与地脉立下过血誓，当危机降临时，大地会回应你的呼唤。【效果】：当你在战斗中受到致命伤害（重伤或即将死亡），你可以选择激活此特性，献祭一枚祭坛石（如果持有）。激活后，你获得\"石之躯\"状态，免疫一次致命伤害，并在原地留下一个\"石壳\"伪装（看起来像一座普通的石像，持续24小时）。石壳期间，你无法行动，但无法被任何方式攻击或调查。这是你保命的最后手段。",
            "原住民"),
        new SkillSeed("地脉狩猎者",
            "你知晓如何追踪地脉力量的流向，祭坛石在你眼中如同黑夜里的火炬。【效果】：每天一次，你可以花费一个快速行动，进行一次\"地脉追踪\"。主持人会告知你，距离你当前地点最近的祭坛石的大致方位（东南西北）和距离远近（\"很近\"或\"很远\"）。此特性无法在矿场或地下结构中使用。",
            "原住民"),
        new SkillSeed("沉默的看门人",
            "你守护着岛屿的秘密，也深知它的弱点。当有人试图开启铁门时，你体内的血脉会发出警告。【效果】：当任何玩家（包括你）在\"隐秘居所\"或\"地脉核心\"举行仪式时，你会自动感知到该仪式正在发生，并知晓仪式所在的具体地点。此效果无消耗，但不会告知你举行仪式的人是谁。",
            "原住民"),
        new SkillSeed("信号残响",
            "（飞行员专属）你的飞机残骸中还有一块未损坏的通讯模块，能接收到微弱的、不属于这个时代的讯号。【效果】：每天一次，你可以选择\"收听\"一次。主持人会从旧世界广播库中随机抽取一段不超过10秒的音频片段（内容可以是天气预警、一段模糊的对话、或一段音乐）私聊告知你。这段讯号虽然残缺，但可能会暗示未来24小时内可能发生的某个事件（如\"暴风雪将至\"、\"码头有异动\"等），具体内容由主持人根据游戏进程随机生成。此特性不消耗行动点。",
            "外来者"),
        new SkillSeed("共振感知",
            "（信天翁专属）你的身体即是岛屿的晴雨表，地脉的每一次脉动都会在你的皮肤上留下痕迹。【效果】：当你进入一个拥有\"地脉异常点\"（如祭坛石、仪式的残余能量、地脉核心、旧世界科技造物）的区域时，你的皮肤会泛起微弱的蓝色荧光（只有你自己能看到）。主持人会私下告知你：\"你感到皮肤一阵刺痛，像是有什么东西在附近唤醒了你。\" 此特性不会告知你具体位置，但能让你知道\"这里有问题\"。",
            "外来者"),
        new SkillSeed("真相的代价",
            "（调查记者专属）你写下的一切都会被记录，而你记录下的真相越沉重，你的笔就越无法停下。【效果】：当你成功获得一条有效信息并记录在档案中时，你可以选择\"深入挖掘\"。主持人会额外告知你与该信息相关的、更隐晦的一个细节（例如，你调查到\"A在码头与B交易\"，深入挖掘后，你会得知\"B交易时显得很紧张，像是怕什么人看到\"）。此特性每天限用一次，且每次使用后，你的档案页会额外消耗1页（即消耗2页才能记录此次深入挖掘的完整信息）。",
            "外来者"),
        new SkillSeed("时空错位",
            "你醒来时，口袋里多了一样不属于这个时代的东西——一枚尚未磨损的硬币、一张印着陌生文字的票根、或一块不会走的手表。【效果】：游戏开始时，你获得一件\"时空遗物\"（由主持人从预设列表中随机抽取）。该遗物本身无直接功能，但当你与NPC进行交易或对话时，可以出示它。NPC会表现出\"困惑\"或\"敬畏\"，并可能因此透露一条额外的信息（由主持人根据场景裁定）。遗物不可交易、不可偷窃、不可丢弃，它会一直跟着你，直到游戏结束。",
            "外来者"),
        new SkillSeed("不属于此的记忆",
            "你偶尔会梦到不属于自己人生的片段——某个陌生人的童年、某场你没参加的战斗、某条你从未走过的街道。这些碎片会在你清醒时偶尔闪现。【效果】：每天一次，你可以向主持人询问\"今天，我是否会对某个地点或某个玩家产生'既视感'？\" 主持人回答\"是\"或\"否\"。如果答案为\"是\"，则当你于当天第一次前往该地点或与该玩家对话时，你会获得一条模糊的、关于该地点或该玩家的额外信息（如\"你感觉这个人的手曾经沾过血\"或\"你好像记得这个仓库里藏过什么东西\"）。此信息由主持人根据游戏进程随机生成，可能有用，也可能无用。",
            "外来者"),
        new SkillSeed("孤星的直觉",
            "你不属于任何阵营，也不信任任何人。这种孤独让你对周围的威胁格外敏感。【效果】：当一名玩家对你使用\"调查\"或\"监听\"类行动时，你会感到一阵莫名的不安，如同有人在你背后凝视。主持人会私聊你：\"你感觉有人在盯着你。\" 你无法获知具体是谁，但可以意识到自己正在被观察。",
            "外来者"),
        new SkillSeed("异乡人的口音",
            "你说话的方式、用词的习惯，甚至你沉默的节奏，都让本地人觉得你\"不是这里的人\"。但这也让你的话听起来更难以被忽视。【效果】：当你与一名NPC进行对话时，你可以选择\"用异乡口音说话\"。NPC会感到好奇，并愿意多听你说几句。你可以借此多问一个问题（如\"你最近见过什么奇怪的人吗？\"或\"你知道镇上谁在夜里偷偷挖东西吗？\"），NPC必须如实回答（但可能以模糊或隐喻的方式）。此特性每天限用一次。",
            "外来者"),
        new SkillSeed("最后的锚点",
            "你随身携带一件来自\"故乡\"的私人物品——一张照片、一枚徽章、一块石头。它不会给你任何力量，但只要你握着它，你就不会忘记自己是谁，也不会被这座岛上的\"低语\"彻底吞噬。【效果】：当你受到\"记忆模糊\"、\"记忆剥离\"或\"记忆污染\"类效果影响时，你可以选择激活此特性，立即免疫该次效果。此特性全场仅可使用一次。使用后，该物品化为灰烬，你失去了它，但你保住了那段记忆。",
            "外来者"),
        new SkillSeed("守夜",
            "你习惯了在夜里醒着。别人睡觉的时候，你坐在窗边，听风声，听雪落，听那些不该有的声音。【效果】：每天夜晚阶段，你可以选择\"守夜\"。守夜期间，你无法进行任何夜间行动，但你会获得以下信息：当晚有多少玩家在你所在地点活动（值具体数量与玩家名）。如果当晚有玩家试图对你进行\"袭击\"，你会提前得知，并可以选择逃离该地点。如果是遭遇冲突，则无法避免。",
            "平民"),
        new SkillSeed("旧地图",
            "你爷爷留下了一张手绘地图，上面标注了一些他\"觉得有意思\"的地方。纸已经发黄，墨迹褪色，但你还能辨认出几处标记。【效果】：游戏开始时，你获得一个随机隐藏地点的位置。该地点可能存在资源、道具或线索。你无法确认具体是什么，但你知道那里\"有东西\"。可以花费快速行动前往。",
            "平民"),
        new SkillSeed("收藏家",
            "你收集一切看起来\"可能有用的东西\"。别人眼中的垃圾，你眼中的宝藏。【效果】：游戏开始时，你额外获得5个\"随机杂物\"物品（从预设的杂物列表中随机抽取）。每次探索行动，你都可以额外获得一件杂物。",
            "平民"),
        new SkillSeed("记仇",
            "你记性很好，尤其是谁得罪过你。你不需要报复，只需要记住。【效果】：当一名玩家对你进行过\"偷盗\"、\"袭击\"、\"审判\"或\"密谋\"中的任意行为后，你会自动获得该玩家的\"标记\"。此后，你对该玩家进行\"调查\"时，你可以直接知晓该玩家的秘密身份。该标记持续到游戏结束，或该玩家死亡。",
            "平民"),
        new SkillSeed("流浪者",
            "你没有固定的家。你睡过码头、矿场、教堂的长椅、甚至墓地的屋檐下。哪里都能睡，哪里都不属于你。【效果】：你可以在夜晚过夜判定在任何地点过夜（无需前往任何地点）。如果你在专属地点过夜，并且没有被赶出，第二天你获得一个\"休息充分\"状态——当天白天行动点+1。但如果你连续两天在同一个地点过夜，第二天不再获得加成。",
            "平民"),
        new SkillSeed("幸存者直觉",
            "你经历过太多危险，身体已经学会了在危险来临前做出反应。不是预知，是身体比脑子先知道。【效果】：每天一次，当你在白天行动中选择前往一个地点时，你可以向主持人询问\"该地点今天是否有危险\"（如\"是否有玩家计划袭击该地点\"或\"是否有天灾牌即将影响该地点\"）。主持人回答\"有\"或\"没有\"，不告知具体细节。此特性只能使用一次，用完后第二天恢复。",
            "平民"),
        new SkillSeed("磨刀匠",
            "你磨过的刀比吃过的饭还多。你知道每一把刀的脾气——有的刀喜欢快，有的刀喜欢稳，有的刀不想被磨。【效果】：每天一次，你可以选择为一名玩家（包括你自己）的近战武器进行\"磨砺\"。被磨砺的武器，威胁值+1。但磨刀需要消耗5kg木材（用于生火加热）和1份医疗资源（用于冷却）。如果你当天没有磨刀，你可以在第二天进行一次\"快速磨砺\"——在当天可以使用两次。",
            "平民"),
        new SkillSeed("抄写员",
            "你替别人写信、写契约、写遗书，你见过太多人的笔迹，也见过太多人笔迹中的颤抖。【效果】：在游戏开始时，你获得一份契约书。",
            "平民"),
        new SkillSeed("算命先生",
            "你不是真的能算命。你只是很会观察人——他的坐姿、他的眼神、他说话时摸鼻子的次数。你把这些观察包装成\"命理\"，然后卖给他。【效果】：每天一次，你可以选择一名玩家进行一次\"算命\"。主持人会秘密告知你：该玩家今天是否说了谎，或者隐藏了重要信息（仅限与你对话时的文字内容），主持人会回答是或者否。",
            "平民")
    );

    @PersistenceContext
    private EntityManager entityManager;

    @Autowired
    private SkillRepository skillRepository;

    @Override
    @Transactional
    public void run(String... args) {
        try {
            widenSkillFaction();
            int inserted = 0;
            for (SkillSeed seed : SEEDS) {
                if (skillRepository.existsByName(seed.name)) {
                    continue;
                }
                Skill skill = new Skill();
                skill.setName(seed.name);
                skill.setFunction(seed.function);
                skill.setFaction(seed.faction);
                skillRepository.save(skill);
                inserted++;
            }
            logger.info("阵营专属/扩展特性迁移完成，新增 {} 条", inserted);
        } catch (Exception e) {
            logger.error("阵营专属/扩展特性迁移失败: {}", e.getMessage(), e);
        }
    }

    private void widenSkillFaction() {
        @SuppressWarnings("unchecked")
        List<Object[]> rows = entityManager.createNativeQuery(
                "SELECT DATA_TYPE, COLUMN_TYPE FROM information_schema.COLUMNS " +
                "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'skill' AND COLUMN_NAME = 'faction'"
        ).getResultList();
        if (rows.isEmpty()) {
            logger.warn("skill.faction 列不存在，跳过枚举扩展");
            return;
        }
        Object[] row = rows.get(0);
        String dataType = row[0] != null ? String.valueOf(row[0]).toLowerCase() : "";
        String columnType = row[1] != null ? String.valueOf(row[1]) : "";
        if (!"enum".equals(dataType)) {
            logger.info("skill.faction 类型为 {}，无需扩 ENUM", dataType);
            return;
        }
        if (columnType.contains("外来者") && columnType.contains("原住民")) {
            logger.info("skill.faction 已包含外来者/原住民，跳过");
            return;
        }
        entityManager.createNativeQuery(
                "ALTER TABLE skill MODIFY COLUMN faction " + TARGET_ENUM
        ).executeUpdate();
        logger.info("已将 skill.faction 扩展为含 外来者/原住民 的 ENUM");
    }
}
