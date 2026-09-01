package com.example.snowisland.service;

import com.example.snowisland.entity.GameState;
import com.example.snowisland.entity.Job;
import com.example.snowisland.entity.Location;
import com.example.snowisland.entity.LocationNpc;
import com.example.snowisland.entity.Player;
import com.example.snowisland.entity.ShelterDailyLabor;
import com.example.snowisland.entity.ShelterLaborDay;
import com.example.snowisland.entity.ShelterStock;
import com.example.snowisland.repository.GameStateRepository;
import com.example.snowisland.repository.JobRepository;
import com.example.snowisland.repository.LocationNpcRepository;
import com.example.snowisland.repository.LocationRepository;
import com.example.snowisland.repository.PlayerRepository;
import com.example.snowisland.repository.ShelterDailyLaborRepository;
import com.example.snowisland.repository.ShelterLaborDayRepository;
import com.example.snowisland.repository.ShelterStockRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import javax.persistence.Query;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ShelterService {

    private static final Set<String> PROFESSIONAL_JOB_NAMES = new HashSet<>(Arrays.asList(
            "农户", "伐木工", "矿工", "铁匠", "手工艺人", "工匠"
    ));

    private static final int NORMAL_BASE_VALUE = 4;
    private static final int PROFESSIONAL_BASE_VALUE = 5;
    private static final int OPPRESSION_BONUS = 3;

    /** 好感度等级：厌恶 < 忽视 < 喜好 */
    private static LocationNpc.Attitude downgradeAttitude(LocationNpc.Attitude current) {
        switch (current) {
            case 喜好: return LocationNpc.Attitude.忽视;
            case 忽视: return LocationNpc.Attitude.厌恶;
            default: return current;
        }
    }

    private static LocationNpc.Attitude upgradeAttitude(LocationNpc.Attitude current) {
        switch (current) {
            case 厌恶: return LocationNpc.Attitude.忽视;
            case 忽视: return LocationNpc.Attitude.喜好;
            default: return current;
        }
    }

    private static final Object[][] DEFAULT_STOCK = {
            {ShelterStock.ItemType.material, 2, 45},
            {ShelterStock.ItemType.material, 7, 32},
            {ShelterStock.ItemType.item, 1, 80},
            {ShelterStock.ItemType.item, 2, 4},
            {ShelterStock.ItemType.item, 3, 2},
            {ShelterStock.ItemType.item, 4, 3},
            {ShelterStock.ItemType.item, 5, 1},
            {ShelterStock.ItemType.item, 6, 1},
            {ShelterStock.ItemType.item, 7, 1},
            {ShelterStock.ItemType.item, 8, 5},
            {ShelterStock.ItemType.item, 9, 2},
            {ShelterStock.ItemType.item, 10, 10},
            {ShelterStock.ItemType.item, 11, 12},
            {ShelterStock.ItemType.item, 12, 2},
            {ShelterStock.ItemType.item, 13, 18},
            {ShelterStock.ItemType.item, 14, 3},
            {ShelterStock.ItemType.item, 15, 6},
            {ShelterStock.ItemType.item, 16, 4},
            {ShelterStock.ItemType.item, 17, 1},
            {ShelterStock.ItemType.weapon, 1, 1},
            {ShelterStock.ItemType.weapon, 2, 1},
            {ShelterStock.ItemType.weapon, 3, 2},
            {ShelterStock.ItemType.weapon, 4, 1},
            {ShelterStock.ItemType.weapon, 6, 1},
            {ShelterStock.ItemType.weapon, 7, 1},
            {ShelterStock.ItemType.weapon, 8, 2},
            {ShelterStock.ItemType.weapon, 9, 1},
            {ShelterStock.ItemType.material, 4, 24},
            {ShelterStock.ItemType.material, 3, 35},
            {ShelterStock.ItemType.material, com.example.snowisland.util.ItemCatalog.FOOD_MATERIAL_ID, 127},
            {ShelterStock.ItemType.material, com.example.snowisland.util.ItemCatalog.FUEL_MATERIAL_ID, 40},
    };

    @Autowired
    private ShelterStockRepository shelterStockRepository;

    @Autowired
    private EntityManager entityManager;

    @Autowired
    private ShelterSupplyService shelterSupplyService;

    @Autowired
    private ShelterDailyLaborRepository shelterDailyLaborRepository;

    @Autowired
    private ShelterLaborDayRepository shelterLaborDayRepository;

    @Autowired
    private PlayerRepository playerRepository;

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    private GameStateRepository gameStateRepository;

    @Autowired
    private LocationRepository locationRepository;

    @Autowired
    private LocationNpcRepository npcRepository;

    public int getCurrentGameDay() {
        GameState state = gameStateRepository.findFirstByOrderByIdAsc();
        if (state == null || state.getCurrentDay() == null) {
            return 1;
        }
        return state.getCurrentDay();
    }

    public int getTotalBuildValue() {
        return shelterDailyLaborRepository.sumVerifiedBuildValue();
    }

    public boolean isDayVerified(int gameDay) {
        return shelterLaborDayRepository.findById(gameDay)
                .map(d -> Boolean.TRUE.equals(d.getVerified()))
                .orElse(false);
    }

    public List<Integer> getLaborPlayerIdsForDay(int gameDay) {
        return shelterDailyLaborRepository.findByGameDayOrderByWorkerKindAscWorkerIdAsc(gameDay).stream()
                .filter(l -> "player".equalsIgnoreCase(l.getWorkerKind()) && !Boolean.TRUE.equals(l.getEscaped()))
                .map(ShelterDailyLabor::getWorkerId)
                .collect(Collectors.toList());
    }

    public boolean isPlayerLaborerForDay(int playerId, int gameDay) {
        return shelterDailyLaborRepository.findByGameDayOrderByWorkerKindAscWorkerIdAsc(gameDay).stream()
                .anyMatch(l -> "player".equalsIgnoreCase(l.getWorkerKind())
                        && playerId == l.getWorkerId()
                        && !Boolean.TRUE.equals(l.getEscaped()));
    }

    private Map<String, Object> denyIfDayVerified(int gameDay) {
        Map<String, Object> out = new LinkedHashMap<>();
        if (isDayVerified(gameDay)) {
            out.put("success", false);
            out.put("message", "第 " + gameDay + " 天已结算，无法再修改劳工名单");
            return out;
        }
        return null;
    }

    @Transactional
    public Map<String, Object> getSummary(Integer viewGameDay) {
        Map<String, Object> out = new LinkedHashMap<>();

        List<ShelterStock> rows = shelterStockRepository.findAllByOrderByItemTypeAscItemIdAsc();
        if (rows.isEmpty()) {
            seedDefaultStock();
            rows = shelterStockRepository.findAllByOrderByItemTypeAscItemIdAsc();
        }

        List<Map<String, Object>> inventory = new ArrayList<>();
        for (ShelterStock row : rows) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("stockId", row.getId());
            item.put("itemType", row.getItemType().name());
            item.put("itemId", row.getItemId());
            item.put("quantity", row.getQuantity());
            enrichItemInfo(item);
            inventory.add(item);
        }

        shelterSupplyService.ensureReady();

        int currentGameDay = getCurrentGameDay();
        int gameDay = viewGameDay != null && viewGameDay >= 1 ? viewGameDay : currentGameDay;
        Map<Integer, Player> playersById = playerRepository.findAll().stream()
                .collect(Collectors.toMap(Player::getId, p -> p, (a, b) -> a));
        Map<Integer, String> jobNames = jobRepository.findAll().stream()
                .collect(Collectors.toMap(Job::getId, Job::getName, (a, b) -> a));

        List<Map<String, Object>> dailyLabor = buildLaborRowMaps(
                shelterDailyLaborRepository.findByGameDayOrderByWorkerKindAscWorkerIdAsc(gameDay),
                playersById,
                jobNames,
                loadNpcsById()
        );

        out.put("success", true);
        out.put("currentGameDay", currentGameDay);
        out.put("gameDay", gameDay);
        out.put("dayVerified", isDayVerified(gameDay));
        out.put("currentBuildValue", getTotalBuildValue());
        out.put("inventory", inventory);
        out.put("foodSupply", shelterSupplyService.buildShelterFoodSupply());
        out.put("energyReserve", shelterSupplyService.buildShelterEnergyReserve());
        out.put("laborCandidates", buildLaborCandidates(jobNames));
        out.put("dailyLabor", dailyLabor);
        out.put("buildLogs", buildLogsGroupedByDay(playersById, jobNames));
        out.put("laborDays", buildLaborDayOptions(currentGameDay));
        return out;
    }

    @Transactional
    public Map<String, Object> setLaborRoster(Integer gameDay, List<Integer> playerIds) {
        Map<String, Object> out = new LinkedHashMap<>();
        if (gameDay == null || gameDay < 1) {
            out.put("success", false);
            out.put("message", "无效的游戏天数");
            return out;
        }
        if (playerIds == null) {
            playerIds = Collections.emptyList();
        }
        Set<Integer> seen = new HashSet<>();
        for (Integer playerId : playerIds) {
            if (playerId == null) {
                out.put("success", false);
                out.put("message", "劳工条目缺少 playerId");
                return out;
            }
            if (!seen.add(playerId)) {
                out.put("success", false);
                out.put("message", "重复的玩家: " + playerId);
                return out;
            }
            if (!playerRepository.findById(playerId).isPresent()) {
                out.put("success", false);
                out.put("message", "玩家不存在: " + playerId);
                return out;
            }
        }
        if (isDayVerified(gameDay)) {
            out.put("success", false);
            out.put("message", "第 " + gameDay + " 天已结算，无法再修改劳工名单");
            return out;
        }

        mergeLaborRoster(gameDay, playerIds);
        ensureLaborDayRow(gameDay, false);

        return enrichLaborResponse(out, gameDay);
    }

    @Transactional
    public Map<String, Object> setLaborRosterWithExploit(Integer gameDay, List<Map<String, Object>> laborers) {
        Map<String, Object> out = new LinkedHashMap<>();
        if (gameDay == null || gameDay < 1) {
            out.put("success", false);
            out.put("message", "无效的游戏天数");
            return out;
        }
        if (laborers == null) {
            laborers = Collections.emptyList();
        }
        if (isDayVerified(gameDay)) {
            out.put("success", false);
            out.put("message", "第 " + gameDay + " 天已结算，无法再修改劳工名单");
            return out;
        }

        int exploitCount = 0;
        Set<String> seenWorkers = new HashSet<>();
        List<WorkerRef> refs = new ArrayList<>();
        Map<String, Map<String, Object>> rowByKey = new LinkedHashMap<>();
        Map<Integer, LocationNpc> npcsById = loadNpcsById();
        for (Map<String, Object> row : laborers) {
            WorkerRef ref = WorkerRef.fromRow(row);
            String err = validateWorker(ref);
            if (err != null) {
                out.put("success", false);
                out.put("message", err);
                return out;
            }
            if (!seenWorkers.add(ref.key())) {
                out.put("success", false);
                out.put("message", "重复的劳工: " + ref.key());
                return out;
            }
            boolean exploited = toBool(row.get("exploited"));
            boolean slacking = toBool(row.get("slacking"));
            if (exploited) {
                exploitCount++;
            }

            // 厌恶状态NPC自动标记逃役
            boolean escaped = toBool(row.get("escaped"));
            if ("npc".equalsIgnoreCase(ref.kind) && !escaped) {
                LocationNpc npc = npcsById.get(ref.id);
                if (npc != null && npc.getAttitudeRuler() == LocationNpc.Attitude.厌恶) {
                    escaped = true;
                }
            }

            refs.add(ref);
            Map<String, Object> patch = new LinkedHashMap<>();
            patch.put("workerKind", ref.kind);
            patch.put("workerId", ref.id);
            patch.put("exploited", exploited);
            patch.put("slacking", slacking);
            patch.put("escaped", escaped);
            rowByKey.put(ref.key(), patch);
        }
        if (exploitCount > 3) {
            out.put("success", false);
            out.put("message", "最多压榨3名劳工");
            return out;
        }

        mergeWorkers(gameDay, refs, rowByKey);
        ensureLaborDayRow(gameDay, false);
        out.put("message", "劳工名单已保存");
        return enrichLaborResponse(out, gameDay);
    }

    @Transactional
    public Map<String, Object> setDailyLabor(Integer gameDay, List<Map<String, Object>> laborers) {
        Map<String, Object> out = new LinkedHashMap<>();
        if (gameDay == null || gameDay < 1) {
            out.put("success", false);
            out.put("message", "无效的游戏天数");
            return out;
        }
        if (laborers == null) {
            laborers = Collections.emptyList();
        }
        if (isDayVerified(gameDay)) {
            out.put("success", false);
            out.put("message", "第 " + gameDay + " 天已确认结算，无法再修改劳工名单");
            return out;
        }

        Set<String> seenWorkers = new HashSet<>();
        Map<Integer, LocationNpc> npcsById = loadNpcsById();
        for (Map<String, Object> row : laborers) {
            WorkerRef ref = WorkerRef.fromRow(row);
            String err = validateWorker(ref);
            if (err != null) {
                out.put("success", false);
                out.put("message", err);
                return out;
            }
            if (!seenWorkers.add(ref.key())) {
                out.put("success", false);
                out.put("message", "重复的劳工: " + ref.key());
                return out;
            }
            // 厌恶状态NPC自动标记逃役
            if ("npc".equalsIgnoreCase(ref.kind)) {
                boolean escaped = toBool(row.get("escaped"));
                if (!escaped) {
                    LocationNpc npc = npcsById.get(ref.id);
                    if (npc != null && npc.getAttitudeRuler() == LocationNpc.Attitude.厌恶) {
                        row.put("escaped", true);
                    }
                }
            }
        }

        mergeDailyLabor(gameDay, laborers);
        ensureLaborDayRow(gameDay, isDayVerified(gameDay));

        out.put("message", "劳工名单已保存");
        return enrichLaborResponse(out, gameDay);
    }

    /**
     * DM：结算前预览建造值与将施加的状态（不落库）。
     */
    public Map<String, Object> previewLaborSettlement(Integer gameDay) {
        Map<String, Object> out = new LinkedHashMap<>();
        if (gameDay == null || gameDay < 1) {
            out.put("success", false);
            out.put("message", "无效的游戏天数");
            return out;
        }
        if (isDayVerified(gameDay)) {
            out.put("success", false);
            out.put("message", "第 " + gameDay + " 天已结算");
            return out;
        }
        List<ShelterDailyLabor> rows = shelterDailyLaborRepository.findByGameDayOrderByWorkerKindAscWorkerIdAsc(gameDay);
        if (rows.isEmpty()) {
            out.put("success", false);
            out.put("message", "第 " + gameDay + " 天尚无劳工记录");
            return out;
        }
        Map<Integer, Player> playersById = playerRepository.findAll().stream()
                .collect(Collectors.toMap(Player::getId, p -> p, (a, b) -> a));
        Map<Integer, Job> jobsById = jobRepository.findAll().stream()
                .collect(Collectors.toMap(Job::getId, j -> j, (a, b) -> a));

        Map<String, Object> preview = buildSettlementPreview(gameDay, rows, playersById, jobsById, loadNpcsById());
        out.put("success", true);
        out.putAll(preview);
        return out;
    }

    @Transactional
    public Map<String, Object> verifyLaborDay(Integer gameDay) {
        Map<String, Object> out = new LinkedHashMap<>();
        if (gameDay == null || gameDay < 1) {
            out.put("success", false);
            out.put("message", "无效的游戏天数");
            return out;
        }
        if (isDayVerified(gameDay)) {
            out.put("success", false);
            out.put("message", "第 " + gameDay + " 天已结算");
            return out;
        }
        List<ShelterDailyLabor> rows = shelterDailyLaborRepository.findByGameDayOrderByWorkerKindAscWorkerIdAsc(gameDay);
        if (rows.isEmpty()) {
            out.put("success", false);
            out.put("message", "第 " + gameDay + " 天尚无劳工记录");
            return out;
        }

        Map<Integer, Player> playersById = playerRepository.findAll().stream()
                .collect(Collectors.toMap(Player::getId, p -> p, (a, b) -> a));
        Map<Integer, Job> jobsById = jobRepository.findAll().stream()
                .collect(Collectors.toMap(Job::getId, j -> j, (a, b) -> a));

        Map<Integer, LocationNpc> npcsById = loadNpcsById();
        Map<String, Object> preview = buildSettlementPreview(gameDay, rows, playersById, jobsById, npcsById);

        for (ShelterDailyLabor labor : rows) {
            if (!"player".equalsIgnoreCase(labor.getWorkerKind())) {
                boolean escaped = Boolean.TRUE.equals(labor.getEscaped());
                boolean exploited = Boolean.TRUE.equals(labor.getExploited());
                boolean slacking = Boolean.TRUE.equals(labor.getSlacking());
                LocationNpc npc = npcsById.get(labor.getWorkerId());
                String npcJob = npc != null ? npc.getJob() : null;
                boolean productionJob = ShelterLaborCalculator.isProductionLaborJobByName(npcJob);
                int buildValue = ShelterLaborCalculator.calculateBuildValue(productionJob, exploited, escaped, slacking);
                labor.setBuildValue(buildValue);
                shelterDailyLaborRepository.save(labor);

                // NPC劳工好感度变更
                if (npc != null && !escaped) {
                    if (exploited) {
                        // 直接压榨：统治者好感度设为厌恶，反叛者好感度设为喜好
                        npc.setAttitudeRuler(LocationNpc.Attitude.厌恶);
                        npc.setAttitudeRebel(LocationNpc.Attitude.喜好);
                    } else {
                        // 普通劳工选择：统治者好感度降一级，反叛者好感度升一级
                        npc.setAttitudeRuler(downgradeAttitude(npc.getAttitudeRuler()));
                        npc.setAttitudeRebel(upgradeAttitude(npc.getAttitudeRebel()));
                    }
                    npcRepository.save(npc);
                }
                continue;
            }
            Player player = playersById.get(labor.getWorkerId());
            if (player == null) {
                continue;
            }
            boolean escaped = Boolean.TRUE.equals(labor.getEscaped());
            boolean exploited = Boolean.TRUE.equals(labor.getExploited());
            boolean slacking = Boolean.TRUE.equals(labor.getSlacking());
            int buildValue = ShelterLaborCalculator.calculateBuildValue(player, jobsById, exploited, escaped, slacking);
            labor.setBuildValue(buildValue);
            shelterDailyLaborRepository.save(labor);

            if (escaped) {
                continue;
            }
            if (Boolean.TRUE.equals(player.getIsOverworked())) {
                int currentInjured = player.getIsInjured() != null ? player.getIsInjured() : 0;
                player.setIsInjured(currentInjured + 1);
            } else {
                player.setIsOverworked(true);
            }
            if (exploited) {
                int currentInjured = player.getIsInjured() != null ? player.getIsInjured() : 0;
                player.setIsInjured(currentInjured + 1);
            }
            playerRepository.save(player);
        }

        ShelterLaborDay day = shelterLaborDayRepository.findById(gameDay).orElseGet(() -> {
            ShelterLaborDay d = new ShelterLaborDay();
            d.setGameDay(gameDay);
            return d;
        });
        day.setVerified(true);
        day.setVerifiedAt(LocalDateTime.now());
        shelterLaborDayRepository.save(day);

        out.put("message", "第 " + gameDay + " 天建造已结算");
        out.put("settlementPreview", preview);
        return enrichLaborResponse(out, gameDay);
    }

    private Map<String, Object> buildSettlementPreview(
            int gameDay,
            List<ShelterDailyLabor> rows,
            Map<Integer, Player> playersById,
            Map<Integer, Job> jobsById,
            Map<Integer, LocationNpc> npcsById
    ) {
        List<Map<String, Object>> workers = new ArrayList<>();
        List<String> warnings = new ArrayList<>();
        int dayTotal = 0;

        for (ShelterDailyLabor labor : rows) {
            boolean escaped = Boolean.TRUE.equals(labor.getEscaped());
            boolean exploited = Boolean.TRUE.equals(labor.getExploited());
            boolean slacking = Boolean.TRUE.equals(labor.getSlacking());
            boolean productionJob;
            String displayName;
            String jobNameLabel;
            boolean isNpc = "npc".equalsIgnoreCase(labor.getWorkerKind());
            if (isNpc) {
                LocationNpc npc = npcsById.get(labor.getWorkerId());
                if (npc == null) {
                    continue;
                }
                jobNameLabel = npc.getJob() != null ? npc.getJob() : "—";
                productionJob = ShelterLaborCalculator.isProductionLaborJobByName(jobNameLabel);
                displayName = npc.getName();
            } else {
                Player player = playersById.get(labor.getWorkerId());
                if (player == null) {
                    continue;
                }
                productionJob = ShelterLaborCalculator.isProductionLaborJob(player, jobsById);
                displayName = player.getName();
                jobNameLabel = player.getJobId() != null && jobsById.get(player.getJobId()) != null
                        ? jobsById.get(player.getJobId()).getName() : "—";
            }
            int buildValue = ShelterLaborCalculator.calculateBuildValue(productionJob, exploited, escaped, slacking);
            if (!escaped) {
                dayTotal += buildValue;
            }

            Map<String, Object> w = new LinkedHashMap<>();
            w.put("workerKind", labor.getWorkerKind());
            w.put("workerId", labor.getWorkerId());
            w.put("playerId", labor.getPlayerId());
            w.put("name", displayName);
            w.put("jobName", jobNameLabel);
            w.put("laborType", ShelterLaborCalculator.laborTypeLabel(productionJob, exploited));
            w.put("buildValueBreakdown", ShelterLaborCalculator.buildValueBreakdown(productionJob, exploited, escaped, slacking));
            w.put("baseValue", ShelterLaborCalculator.BASE_BUILD_VALUE);
            w.put("jobBonus", productionJob && !escaped ? ShelterLaborCalculator.PRODUCTION_JOB_BONUS : 0);
            w.put("exploitBonus", exploited && !escaped ? ShelterLaborCalculator.EXPLOIT_BONUS : 0);
            w.put("slackingPenalty", slacking && !escaped ? ShelterLaborCalculator.SLACKING_PENALTY : 0);
            w.put("buildValue", buildValue);
            w.put("productionJob", productionJob);
            w.put("exploited", exploited);
            w.put("slacking", slacking);
            w.put("escaped", escaped);
            w.put("isNpc", isNpc);
            w.put("willApplyOverworked", !escaped && !isNpc);
            w.put("willApplyInjured", !escaped && exploited && !isNpc);
            Player player = isNpc ? null : playersById.get(labor.getWorkerId());
            w.put("wasAlreadyOverworked", player != null && Boolean.TRUE.equals(player.getIsOverworked()));
            w.put("wasAlreadyInjured", player != null && Boolean.TRUE.equals(player.getIsInjured()));

            if (player != null && !escaped && Boolean.TRUE.equals(player.getIsOverworked())) {
                w.put("overworkDeathWarning", true);
                warnings.add(displayName + " 此前已有「过劳」标记：请投 1d6，结果为 1 则死亡。");
            } else {
                w.put("overworkDeathWarning", false);
            }
            workers.add(w);
        }

        Map<String, Object> preview = new LinkedHashMap<>();
        preview.put("gameDay", gameDay);
        preview.put("dayTotal", dayTotal);
        preview.put("workers", workers);
        preview.put("warnings", warnings);
        return preview;
    }

    private Map<String, Object> enrichLaborResponse(Map<String, Object> out, int gameDay) {
        Map<Integer, Player> playersById = playerRepository.findAll().stream()
                .collect(Collectors.toMap(Player::getId, p -> p, (a, b) -> a));
        Map<Integer, String> jobNames = jobRepository.findAll().stream()
                .collect(Collectors.toMap(Job::getId, Job::getName, (a, b) -> a));

        out.put("success", true);
        out.put("gameDay", gameDay);
        out.put("currentGameDay", getCurrentGameDay());
        out.put("dayVerified", isDayVerified(gameDay));
        out.put("currentBuildValue", getTotalBuildValue());
        out.put("dailyLabor", buildLaborRowMaps(
                shelterDailyLaborRepository.findByGameDayOrderByWorkerKindAscWorkerIdAsc(gameDay),
                playersById,
                jobNames,
                loadNpcsById()
        ));
        out.put("buildLogs", buildLogsGroupedByDay(playersById, jobNames));
        out.put("laborDays", buildLaborDayOptions(getCurrentGameDay()));
        return out;
    }

    /**
     * Upsert roster without delete-all-then-insert (avoids UK violations on repeated saves).
     */
    private void mergeLaborRoster(int gameDay, List<Integer> playerIds) {
        List<WorkerRef> workers = new ArrayList<>();
        for (Integer playerId : playerIds) {
            workers.add(new WorkerRef("player", playerId));
        }
        mergeWorkers(gameDay, workers, Collections.emptyMap());
    }

    private void mergeDailyLabor(int gameDay, List<Map<String, Object>> laborers) {
        List<WorkerRef> refs = new ArrayList<>();
        Map<String, Map<String, Object>> rowByKey = new LinkedHashMap<>();
        for (Map<String, Object> row : laborers) {
            WorkerRef ref = WorkerRef.fromRow(row);
            refs.add(ref);
            rowByKey.put(ref.key(), row);
        }
        mergeWorkers(gameDay, refs, rowByKey);
    }

    private void mergeWorkers(int gameDay, List<WorkerRef> targets, Map<String, Map<String, Object>> rowByKey) {
        List<ShelterDailyLabor> existingRows =
                shelterDailyLaborRepository.findByGameDayOrderByWorkerKindAscWorkerIdAsc(gameDay);
        Map<String, ShelterDailyLabor> existingByKey = new LinkedHashMap<>();
        for (ShelterDailyLabor row : existingRows) {
            existingByKey.put(WorkerRef.fromLabor(row).key(), row);
        }
        Set<String> targetKeys = new LinkedHashSet<>();
        for (WorkerRef ref : targets) {
            targetKeys.add(ref.key());
        }

        for (ShelterDailyLabor row : existingRows) {
            if (!targetKeys.contains(WorkerRef.fromLabor(row).key())) {
                shelterDailyLaborRepository.delete(row);
            }
        }
        entityManager.flush();

        Map<Integer, Player> playersById = playerRepository.findAll().stream()
                .collect(Collectors.toMap(Player::getId, p -> p, (a, b) -> a));
        Map<Integer, Job> jobsById = jobRepository.findAll().stream()
                .collect(Collectors.toMap(Job::getId, j -> j, (a, b) -> a));

        for (WorkerRef ref : targets) {
            ShelterDailyLabor labor = existingByKey.get(ref.key());
            if (labor == null) {
                labor = new ShelterDailyLabor();
                labor.setGameDay(gameDay);
                labor.setWorkerKind(ref.kind);
                labor.setWorkerId(ref.id);
                labor.setBuildValue(0);
                labor.setExploited(false);
                labor.setEscaped(false);
                labor.setSlacking(false);
            }
            Map<String, Object> row = rowByKey.get(ref.key());
            if (row != null) {
                boolean exploited = toBool(row.get("exploited"));
                boolean escaped = toBool(row.get("escaped"));
                boolean slacking = toBool(row.get("slacking"));
                int buildValue;
                if ("npc".equalsIgnoreCase(ref.kind)) {
                    String npcJobName = null;
                    LocationNpc npc = npcRepository.findById(ref.id).orElse(null);
                    if (npc != null) {
                        npcJobName = npc.getJob();
                    }
                    boolean productionJob = ShelterLaborCalculator.isProductionLaborJobByName(npcJobName);
                    buildValue = ShelterLaborCalculator.calculateBuildValue(productionJob, exploited, escaped, slacking);
                } else {
                    Player player = playersById.get(ref.id);
                    buildValue = ShelterLaborCalculator.calculateBuildValue(player, jobsById, exploited, escaped, slacking);
                }
                if (row.containsKey("buildValue")) {
                    Integer manual = toInt(row.get("buildValue"));
                    if (manual != null) {
                        buildValue = manual;
                    }
                }
                labor.setBuildValue(buildValue);
                labor.setExploited(exploited);
                labor.setEscaped(escaped);
                labor.setSlacking(slacking);
            }
            shelterDailyLaborRepository.save(labor);
        }
    }

    private void ensureLaborDayRow(int gameDay, boolean verified) {
        if (!shelterLaborDayRepository.findById(gameDay).isPresent()) {
            ShelterLaborDay day = new ShelterLaborDay();
            day.setGameDay(gameDay);
            day.setVerified(verified);
            if (verified) {
                day.setVerifiedAt(LocalDateTime.now());
            }
            shelterLaborDayRepository.save(day);
        }
    }

    private List<Map<String, Object>> buildLaborDayOptions(int currentGameDay) {
        Set<Integer> days = new TreeSet<>();
        for (int d = 1; d <= Math.max(1, currentGameDay); d++) {
            days.add(d);
        }
        shelterDailyLaborRepository.findAllByOrderByGameDayDescWorkerKindAscWorkerIdAsc()
                .forEach(l -> days.add(l.getGameDay()));
        List<Map<String, Object>> options = new ArrayList<>();
        for (Integer day : days) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("gameDay", day);
            m.put("verified", isDayVerified(day));
            options.add(m);
        }
        options.sort((a, b) -> Integer.compare((Integer) b.get("gameDay"), (Integer) a.get("gameDay")));
        return options;
    }

    private List<Map<String, Object>> buildLaborRowMaps(
            List<ShelterDailyLabor> labors,
            Map<Integer, Player> playersById,
            Map<Integer, String> jobNames,
            Map<Integer, LocationNpc> npcsById
    ) {
        Map<Integer, Job> jobsById = jobRepository.findAll().stream()
                .collect(Collectors.toMap(Job::getId, j -> j, (a, b) -> a));
        List<Map<String, Object>> result = new ArrayList<>();
        for (ShelterDailyLabor labor : labors) {
            WorkerRef ref = WorkerRef.fromLabor(labor);
            boolean exploited = Boolean.TRUE.equals(labor.getExploited());
            boolean escaped = Boolean.TRUE.equals(labor.getEscaped());
            boolean slacking = Boolean.TRUE.equals(labor.getSlacking());
            boolean productionJob;
            String name;
            String jobName;
            String jobSkills = "";
            Integer jobId = null;

            if ("npc".equalsIgnoreCase(ref.kind)) {
                LocationNpc npc = npcsById.get(ref.id);
                if (npc == null) {
                    continue;
                }
                jobName = npc.getJob() != null ? npc.getJob() : "—";
                productionJob = ShelterLaborCalculator.isProductionLaborJobByName(jobName);
                name = npc.getName();
            } else {
                Player player = playersById.get(ref.id);
                if (player == null) {
                    continue;
                }
                productionJob = ShelterLaborCalculator.isProductionLaborJob(player, jobsById);
                name = player.getName();
                jobId = player.getJobId();
                Job job = jobId != null ? jobsById.get(jobId) : null;
                jobName = jobId != null ? jobNames.getOrDefault(jobId, "—") : "—";
                jobSkills = job != null ? job.getSkills() : "";
            }
            int computed = ShelterLaborCalculator.calculateBuildValue(productionJob, exploited, escaped, slacking);

            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id", labor.getId());
            row.put("workerKind", ref.kind);
            row.put("workerId", ref.id);
            row.put("workerKey", ref.key());
            row.put("isNpc", "npc".equalsIgnoreCase(ref.kind));
            row.put("playerId", labor.getPlayerId());
            row.put("name", name);
            row.put("jobId", jobId);
            row.put("jobName", jobName);
            row.put("jobSkills", jobSkills);
            row.put("productionJob", productionJob);
            row.put("laborType", ShelterLaborCalculator.laborTypeLabel(productionJob, exploited));
            row.put("buildValueBreakdown", ShelterLaborCalculator.buildValueBreakdown(productionJob, exploited, escaped, slacking));
            row.put("computedBuildValue", computed);
            row.put("buildValue", labor.getBuildValue() != null ? labor.getBuildValue() : computed);
            row.put("exploited", exploited);
            row.put("slacking", slacking);
            row.put("escaped", escaped);
            if ("player".equalsIgnoreCase(ref.kind)) {
                Player player = playersById.get(ref.id);
                boolean isProfessional = isProfessionalLaborer(player, jobNames);
                row.put("isProfessional", isProfessional);
                row.put("baseBuildValue", calcBuildValue(isProfessional, false, false));
                row.put("isWeak", Boolean.TRUE.equals(player.getIsWeak()));
                row.put("isOverworked", Boolean.TRUE.equals(player.getIsOverworked()));
                row.put("isInjured", player.getIsInjured() != null ? player.getIsInjured() : 0);
            }
            result.add(row);
        }
        return result;
    }

    private List<Map<String, Object>> buildLogsGroupedByDay(
            Map<Integer, Player> playersById,
            Map<Integer, String> jobNames
    ) {
        Map<Integer, List<ShelterDailyLabor>> byDay = new TreeMap<>(Comparator.reverseOrder());
        Map<Integer, LocationNpc> npcsById = loadNpcsById();
        for (ShelterDailyLabor labor : shelterDailyLaborRepository.findAllByOrderByGameDayDescWorkerKindAscWorkerIdAsc()) {
            byDay.computeIfAbsent(labor.getGameDay(), k -> new ArrayList<>()).add(labor);
        }

        List<Map<String, Object>> logs = new ArrayList<>();
        for (Map.Entry<Integer, List<ShelterDailyLabor>> entry : byDay.entrySet()) {
            boolean verified = isDayVerified(entry.getKey());
            int dayTotal = 0;
            List<Map<String, Object>> workers = new ArrayList<>();
            for (ShelterDailyLabor labor : entry.getValue()) {
                WorkerRef ref = WorkerRef.fromLabor(labor);
                String name;
                String jobName;
                boolean isProfessional;
                if ("npc".equalsIgnoreCase(ref.kind)) {
                    LocationNpc npc = npcsById.get(ref.id);
                    if (npc == null) {
                        continue;
                    }
                    name = npc.getName();
                    jobName = npc.getJob() != null ? npc.getJob() : "—";
                    isProfessional = false;
                } else {
                    Player player = playersById.get(ref.id);
                    if (player == null) {
                        continue;
                    }
                    name = player.getName();
                    jobName = player.getJobId() != null ? jobNames.getOrDefault(player.getJobId(), "—") : "—";
                    isProfessional = player.getJobId() != null;
                }
                int value = labor.getBuildValue() != null ? labor.getBuildValue() : 0;
                if (verified) {
                    dayTotal += value;
                }
                Map<String, Object> w = new LinkedHashMap<>();
                w.put("workerKind", ref.kind);
                w.put("workerId", ref.id);
                w.put("playerId", labor.getPlayerId());
                w.put("name", name);
                w.put("jobName", jobName);
                if (verified) {
                    w.put("value", value);
                }
                if ("npc".equalsIgnoreCase(ref.kind)) {
                    w.put("isProfessional", isProfessional);
                } else {
                    Player player = playersById.get(ref.id);
                    w.put("isProfessional", isProfessionalLaborer(player, jobNames));
                }
                w.put("isOppressed", Boolean.TRUE.equals(labor.getExploited()));
                w.put("escaped", Boolean.TRUE.equals(labor.getEscaped()));
                workers.add(w);
            }
            if (workers.isEmpty()) {
                continue;
            }
            Map<String, Object> log = new LinkedHashMap<>();
            log.put("day", entry.getKey());
            log.put("verified", verified);
            log.put("dayTotal", verified ? dayTotal : null);
            log.put("workers", workers);
            logs.add(log);
        }
        return logs;
    }

    private List<Map<String, Object>> buildLaborCandidates(Map<Integer, String> jobNames) {
        List<Map<String, Object>> rows = new ArrayList<>();
        Map<Integer, String> locationNames = locationRepository.findAll().stream()
                .collect(Collectors.toMap(Location::getId, Location::getName, (a, b) -> a));

        for (Player player : playerRepository.findAll()) {
            if (player.getFaction() == Player.Faction.统治者) {
                continue;
            }
            boolean isProfessional = isProfessionalLaborer(player, jobNames);
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("kind", "player");
            row.put("workerKind", "player");
            row.put("id", player.getId());
            row.put("workerId", player.getId());
            row.put("workerKey", WorkerRef.key("player", player.getId()));
            row.put("name", player.getName());
            row.put("faction", player.getFaction() != null ? player.getFaction().name() : null);
            row.put("jobId", player.getJobId());
            Job job = player.getJobId() != null ? jobRepository.findById(player.getJobId()).orElse(null) : null;
            row.put("jobName", player.getJobId() != null ? jobNames.getOrDefault(player.getJobId(), "—") : "—");
            row.put("isProfessional", isProfessional);
            row.put("baseBuildValue", calcBuildValue(isProfessional, false, false));
            row.put("jobSkills", job != null ? job.getSkills() : "");
            row.put("productionJob", ShelterLaborCalculator.isProductionLaborJob(player,
                    job != null ? Collections.singletonMap(job.getId(), job) : Collections.emptyMap()));
            row.put("isWeak", Boolean.TRUE.equals(player.getIsWeak()));
            row.put("isOverworked", Boolean.TRUE.equals(player.getIsOverworked()));
            row.put("isInjured", player.getIsInjured() != null ? player.getIsInjured() : 0);
            rows.add(row);
        }

        for (LocationNpc npc : npcRepository.findAll()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("kind", "npc");
            row.put("workerKind", "npc");
            row.put("id", npc.getId());
            row.put("workerId", npc.getId());
            row.put("workerKey", WorkerRef.key("npc", npc.getId()));
            row.put("name", npc.getName());
            String npcJob = npc.getJob() != null ? npc.getJob() : "—";
            row.put("jobName", npcJob);
            row.put("jobSkills", "");
            row.put("productionJob", ShelterLaborCalculator.isProductionLaborJobByName(npcJob));
            String loc = locationNames.getOrDefault(npc.getLocationId(), "未知地点");
            row.put("locationName", loc);
            row.put("label", npc.getName() + " · " + loc);
            row.put("attitudeRuler", npc.getAttitudeRuler() != null ? npc.getAttitudeRuler().name() : "忽视");
            row.put("attitudeRebel", npc.getAttitudeRebel() != null ? npc.getAttitudeRebel().name() : "忽视");
            row.put("hatesRuler", npc.getAttitudeRuler() == LocationNpc.Attitude.厌恶);
            rows.add(row);
        }

        rows.sort(Comparator.comparing(m -> String.valueOf(m.get("name"))));
        return rows;
    }

    private boolean isProfessionalLaborer(Player player, Map<Integer, String> jobNames) {
        if (player == null || player.getJobId() == null) return false;
        String jobName = jobNames.getOrDefault(player.getJobId(), "");
        return PROFESSIONAL_JOB_NAMES.contains(jobName);
    }

    private int calcBuildValue(boolean isProfessional, boolean exploited, boolean escaped) {
        if (escaped) return 0;
        int base = isProfessional ? PROFESSIONAL_BASE_VALUE : NORMAL_BASE_VALUE;
        if (exploited) base += OPPRESSION_BONUS;
        return base;
    }

    private Map<Integer, LocationNpc> loadNpcsById() {
        return npcRepository.findAll().stream()
                .collect(Collectors.toMap(LocationNpc::getId, n -> n, (a, b) -> a));
    }

    private String validateWorker(WorkerRef ref) {
        if (ref == null || ref.id == null) {
            return "劳工条目缺少标识";
        }
        if ("player".equalsIgnoreCase(ref.kind)) {
            Optional<Player> player = playerRepository.findById(ref.id);
            if (!player.isPresent()) {
                return "玩家不存在: " + ref.id;
            }
            if (player.get().getFaction() == Player.Faction.统治者) {
                return "统治者不能作为劳工";
            }
            return null;
        }
        if ("npc".equalsIgnoreCase(ref.kind)) {
            if (!npcRepository.findById(ref.id).isPresent()) {
                return "NPC不存在: " + ref.id;
            }
            return null;
        }
        return "无效的劳工类型: " + ref.kind;
    }

    private static final class WorkerRef {
        final String kind;
        final Integer id;

        WorkerRef(String kind, Integer id) {
            this.kind = kind != null ? kind.toLowerCase(Locale.ROOT) : "player";
            this.id = id;
        }

        String key() {
            return key(kind, id);
        }

        static String key(String kind, Integer id) {
            return (kind != null ? kind.toLowerCase(Locale.ROOT) : "player") + ":" + id;
        }

        static WorkerRef fromRow(Map<String, Object> row) {
            String kind = row.containsKey("workerKind")
                    ? String.valueOf(row.get("workerKind")).trim().toLowerCase(Locale.ROOT)
                    : "player";
            Integer id = toIntStatic(row.get("workerId"));
            if (id == null) {
                id = toIntStatic(row.get("playerId"));
            }
            if (kind.isEmpty() || "null".equals(kind)) {
                kind = "player";
            }
            return new WorkerRef(kind, id);
        }

        static WorkerRef fromLabor(ShelterDailyLabor labor) {
            String kind = labor.getWorkerKind() != null ? labor.getWorkerKind() : "player";
            return new WorkerRef(kind, labor.getWorkerId());
        }

        private static Integer toIntStatic(Object o) {
            if (o == null || "".equals(o)) {
                return null;
            }
            if (o instanceof Number) {
                return ((Number) o).intValue();
            }
            try {
                return Integer.parseInt(String.valueOf(o));
            } catch (NumberFormatException e) {
                return null;
            }
        }
    }

    private static Integer toInt(Object o) {
        if (o == null || "".equals(o)) {
            return null;
        }
        if (o instanceof Number) {
            return ((Number) o).intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(o));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static boolean toBool(Object o) {
        if (o == null) {
            return false;
        }
        if (o instanceof Boolean) {
            return (Boolean) o;
        }
        String s = String.valueOf(o).trim();
        return "true".equalsIgnoreCase(s) || "1".equals(s);
    }

    private void enrichItemInfo(Map<String, Object> item) {
        String itemType = (String) item.get("itemType");
        Integer itemId = (Integer) item.get("itemId");
        String tableName;
        switch (itemType) {
            case "weapon": tableName = "weapon"; break;
            case "ammo": tableName = "ammo"; break;
            case "material": tableName = "material"; break;
            default: tableName = "item"; break;
        }
        try {
            Query query = entityManager.createNativeQuery(
                    "SELECT name, unit, remark FROM " + tableName + " WHERE id = ?1");
            query.setParameter(1, itemId);
            List<Object[]> results = query.getResultList();
            if (!results.isEmpty()) {
                item.put("name", results.get(0)[0]);
                item.put("unit", results.get(0)[1]);
                item.put("description", results.get(0)[2]);
            } else {
                item.put("name", "未知物品");
                item.put("unit", "");
                item.put("description", "");
            }
        } catch (Exception e) {
            item.put("name", "未知物品");
            item.put("unit", "");
            item.put("description", "");
        }
    }

    @Transactional
    public Map<String, Object> resetShelter() {
        Map<String, Object> out = new LinkedHashMap<>();
        try {
            shelterDailyLaborRepository.deleteAll();
            shelterLaborDayRepository.deleteAll();
            shelterStockRepository.deleteAllInBatch();
            entityManager.flush();
            entityManager.clear();
            seedDefaultStock();
            out.put("success", true);
            out.put("message", "避难所建设数据已重置为初始状态");
            return out;
        } catch (Exception e) {
            out.put("success", false);
            out.put("message", "重置失败: " + e.getMessage());
            return out;
        }
    }

    protected void seedDefaultStock() {
        for (Object[] row : DEFAULT_STOCK) {
            ShelterStock s = new ShelterStock();
            s.setItemType((ShelterStock.ItemType) row[0]);
            s.setItemId((Integer) row[1]);
            s.setQuantity((Integer) row[2]);
            shelterStockRepository.save(s);
        }
    }

    public Map<String, Object> getShelterItemCatalog() {
        Map<String, Object> out = new LinkedHashMap<>();
        @SuppressWarnings("unchecked")
        List<Object[]> raw = entityManager.createNativeQuery(
                "SELECT 'item' as type, id, name, unit FROM item "
                        + "UNION ALL SELECT 'weapon', id, name, unit FROM weapon "
                        + "UNION ALL SELECT 'ammo', id, name, unit FROM ammo "
                        + "UNION ALL SELECT 'material', id, name, unit FROM material "
                        + "ORDER BY type, id"
        ).getResultList();
        List<Map<String, Object>> items = new ArrayList<>();
        for (Object[] row : raw) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("itemType", row[0]);
            item.put("itemId", ((Number) row[1]).intValue());
            item.put("name", row[2]);
            item.put("unit", row[3]);
            items.add(item);
        }
        out.put("success", true);
        out.put("items", items);
        return out;
    }

    @Transactional
    public Map<String, Object> upsertShelterStock(String itemType, Integer itemId, Integer quantity) {
        Map<String, Object> out = new LinkedHashMap<>();
        if (itemType == null || itemType.trim().isEmpty() || itemId == null) {
            out.put("success", false);
            out.put("message", "参数不完整");
            return out;
        }
        if (quantity == null || quantity < 0) {
            out.put("success", false);
            out.put("message", "数量不能为负数");
            return out;
        }
        ShelterStock.ItemType type;
        try {
            type = ShelterStock.ItemType.valueOf(itemType.trim().toLowerCase(Locale.ROOT));
        } catch (IllegalArgumentException e) {
            out.put("success", false);
            out.put("message", "无效的物品类型");
            return out;
        }
        Optional<ShelterStock> opt = shelterStockRepository.findByItemTypeAndItemId(type, itemId);
        if (quantity == 0) {
            opt.ifPresent(shelterStockRepository::delete);
            out.put("success", true);
            out.put("message", "已从避难所库存移除");
            return out;
        }
        ShelterStock row = opt.orElseGet(() -> {
            ShelterStock s = new ShelterStock();
            s.setItemType(type);
            s.setItemId(itemId);
            return s;
        });
        row.setQuantity(quantity);
        shelterStockRepository.save(row);
        out.put("success", true);
        out.put("message", "库存已更新");
        return out;
    }

    @Transactional
    public Map<String, Object> removeShelterStock(String itemType, Integer itemId) {
        Map<String, Object> out = new LinkedHashMap<>();
        if (itemType == null || itemType.trim().isEmpty() || itemId == null) {
            out.put("success", false);
            out.put("message", "参数不完整");
            return out;
        }
        ShelterStock.ItemType type;
        try {
            type = ShelterStock.ItemType.valueOf(itemType.trim().toLowerCase(Locale.ROOT));
        } catch (IllegalArgumentException e) {
            out.put("success", false);
            out.put("message", "无效的物品类型");
            return out;
        }
        shelterStockRepository.findByItemTypeAndItemId(type, itemId)
                .ifPresent(shelterStockRepository::delete);
        out.put("success", true);
        out.put("message", "已从避难所库存移除");
        return out;
    }
}
