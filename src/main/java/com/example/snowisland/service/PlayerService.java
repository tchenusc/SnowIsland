package com.example.snowisland.service;

import com.example.snowisland.entity.Player;
import com.example.snowisland.util.PlayerStatusCatalog;
import com.example.snowisland.entity.PlayerItem;
import com.example.snowisland.entity.User;
import com.example.snowisland.entity.Job;
import com.example.snowisland.entity.Skill;
import com.example.snowisland.repository.PlayerItemRepository;
import com.example.snowisland.repository.PlayerRepository;
import com.example.snowisland.repository.UserRepository;
import com.example.snowisland.repository.JobRepository;
import com.example.snowisland.repository.SkillRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.util.*;

@Service
public class PlayerService {
    private static final String[] PLAYER_ID_TABLES = {
            "player_action",
            "player_exploration",
            "player_stealth",
            "player_npc_recognition",
            "game_activity_log",
            "clue_trigger_log",
            "faction_action",
            "night_action",
            "quick_interaction",
            "player_notebook",
            "npc_dialogue",
            "npc_favor_adjustment",
            "player_marker",
            "npc_help_record",
            "npc_trade_proposal",
            "npc_trade_record",
            "lore_player_grant",
            "npc_daily_dialogue_count",
            "npc_daily_trade_count",
            "npc_favor",
            "player_daily_consumption",
            "player_items",
            "ark_construction_log",
            "milestone_player_status"
    };

    @Autowired
    private PlayerRepository playerRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PlayerItemRepository playerItemRepository;

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    private SkillRepository skillRepository;

    @Autowired
    private PlayerSupplyService playerSupplyService;

    @Autowired
    private PlayerMarkerService playerMarkerService;

    @Autowired
    private TradeRestrictionService tradeRestrictionService;

    @PersistenceContext
    private EntityManager entityManager;

    private Map<String, Map<Integer, String>> itemNames = new HashMap<>();
    private Map<String, Map<Integer, String>> itemUnits = new HashMap<>();
    private Map<String, Map<Integer, String>> itemRemarks = new HashMap<>();
    private Map<Integer, Integer> weaponThreatLevels = new HashMap<>();

    public PlayerService() {
        initItemData();
    }

    private void initItemData() {
        itemNames.put("item", new HashMap<>());
        itemNames.put("weapon", new HashMap<>());
        itemNames.put("ammo", new HashMap<>());
        itemNames.put("material", new HashMap<>());

        itemUnits.put("item", new HashMap<>());
        itemUnits.put("weapon", new HashMap<>());
        itemUnits.put("ammo", new HashMap<>());
        itemUnits.put("material", new HashMap<>());

        itemRemarks.put("item", new HashMap<>());
        itemRemarks.put("weapon", new HashMap<>());
        itemRemarks.put("ammo", new HashMap<>());
        itemRemarks.put("material", new HashMap<>());
    }

    public void loadItemNames() {
        List<Object[]> items = entityManager.createNativeQuery(
            "SELECT 'item' as type, id, name, unit, remark FROM item " +
            "UNION ALL SELECT 'weapon', id, name, unit, remark FROM weapon " +
            "UNION ALL SELECT 'ammo', id, name, unit, remark FROM ammo " +
            "UNION ALL SELECT 'material', id, name, unit, remark FROM material"
        ).getResultList();

        for (Object[] row : items) {
            String type = (String) row[0];
            Integer id = ((Number) row[1]).intValue();
            String name = (String) row[2];
            String unit = (String) row[3];
            String remark = row[4] != null ? String.valueOf(row[4]) : "";
            itemNames.get(type).put(id, name);
            itemUnits.get(type).put(id, unit);
            itemRemarks.get(type).put(id, remark);
        }

        weaponThreatLevels.clear();
        @SuppressWarnings("unchecked")
        List<Object[]> weapons = entityManager.createNativeQuery(
                "SELECT id, threat_level FROM weapon"
        ).getResultList();
        for (Object[] row : weapons) {
            weaponThreatLevels.put(((Number) row[0]).intValue(), ((Number) row[1]).intValue());
        }
    }

    public List<Map<String, Object>> getPlayerItems(Integer playerId) {
        loadItemNames();
        List<PlayerItem> playerItems = playerItemRepository.findByPlayerId(playerId);
        List<Map<String, Object>> result = new ArrayList<>();

        for (PlayerItem pi : playerItems) {
            String type = pi.getItemType().name().toLowerCase();
            int itemId = pi.getItemId();
            Map<String, Object> item = new HashMap<>();
            item.put("id", itemId);
            item.put("type", type);
            item.put("quantity", pi.getQuantity());
            String name = itemNames.get(type).getOrDefault(itemId, "未知物品");
            item.put("name", name);
            item.put("unit", itemUnits.get(type).getOrDefault(itemId, "个"));
            item.put("remark", itemRemarks.get(type).getOrDefault(itemId, ""));
            if ("weapon".equals(type)) {
                item.put("threatLevel", weaponThreatLevels.getOrDefault(itemId, 0));
            }
            result.add(item);
        }

        return result;
    }

    public List<Player> getAllPlayers() {
        List<Player> players = playerRepository.findAll();
        for (Player player : players) {
            if (player.getJobId() != null) {
                jobRepository.findById(player.getJobId()).ifPresent(job -> player.setJobName(job.getName()));
            }
        }
        return players;
    }

    public List<Map<String, Object>> getPlayersForTrade() {
        List<Player> players = playerRepository.findAll();
        List<Map<String, Object>> result = new ArrayList<>();
        for (Player player : players) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", player.getId());
            map.put("name", player.getName());
            if (player.getJobId() != null) {
                jobRepository.findById(player.getJobId()).ifPresent(job -> map.put("jobName", job.getName()));
            }
            if (!map.containsKey("jobName")) {
                map.put("jobName", null);
            }
            result.add(map);
        }
        return result;
    }

    public Player getPlayerById(Integer id) {
        return playerRepository.findById(id).orElse(null);
    }

    @Transactional
    public Map<String, Object> createPlayer(Player player, String loginUsername) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            Player savedPlayer = playerRepository.save(player);
            
            // 创建对应的用户账号
            User user = new User();
            user.setUsername("player" + savedPlayer.getId());
            user.setPassword("test123");
            user.setRole(User.Role.PLAYER);
            user.setPlayerId(savedPlayer.getId());
            userRepository.save(user);
            
            result.put("success", true);
            result.put("player", savedPlayer);
            result.put("username", "player" + savedPlayer.getId());
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "创建玩家失败: " + e.getMessage());
        }
        
        return result;
    }

    @Transactional
    public Map<String, Object> updatePlayer(Integer id, Player player) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            Player existingPlayer = playerRepository.findById(id).orElse(null);
            if (existingPlayer == null) {
                result.put("success", false);
                result.put("message", "玩家不存在");
                return result;
            }
            
            // Partial update: frontend (e.g. Player.vue profile save) only sends edited fields.
            // Do not overwrite with null — would violate NOT NULL on faction / clear job & skill.
            if (player.getName() != null) {
                existingPlayer.setName(player.getName());
            }
            if (player.getIsWeak() != null) {
                existingPlayer.setIsWeak(player.getIsWeak());
            }
            if (player.getIsOverworked() != null) {
                existingPlayer.setIsOverworked(player.getIsOverworked());
            }
            if (player.getIsInjured() != null) {
                existingPlayer.setIsInjured(player.getIsInjured());
            }
            if (player.getJobId() != null) {
                existingPlayer.setJobId(player.getJobId());
            }
            if (player.getSkillId() != null) {
                existingPlayer.setSkillId(player.getSkillId());
            }
            if (player.getFaction() != null) {
                existingPlayer.setFaction(player.getFaction());
            }
            
            playerRepository.save(existingPlayer);
            result.put("success", true);
            result.put("player", existingPlayer);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "更新玩家失败: " + e.getMessage());
        }
        
        return result;
    }

    @Transactional
    public Map<String, Object> deletePlayer(Integer id) {
        Map<String, Object> result = new HashMap<>();
        try {
            if (id == null || !playerRepository.existsById(id)) {
                result.put("success", false);
                result.put("message", "玩家不存在");
                return result;
            }
            purgePlayerDependents(id);
            entityManager.flush();
            entityManager.clear();
            playerRepository.deleteById(id);
            result.put("success", true);
            result.put("message", "删除成功");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            result.put("success", false);
            result.put("message", "删除失败: " + e.getMessage());
        }
        return result;
    }

    private void purgePlayerDependents(Integer playerId) {
        for (String table : PLAYER_ID_TABLES) {
            executeScopedSql("DELETE FROM " + table + " WHERE player_id = :playerId", playerId);
        }
        executeScopedSql(
                "DELETE FROM shelter_daily_labor WHERE worker_kind = 'player' AND worker_id = :playerId",
                playerId);
        executeScopedSql(
                "DELETE FROM location_governance WHERE actor_kind = 'player' AND actor_id = :playerId",
                playerId);
        executeScopedSql(
                "DELETE ti FROM trade_items ti INNER JOIN trade t ON ti.trade_id = t.id "
                        + "WHERE t.from_player_id = :playerId OR t.to_player_id = :playerId",
                playerId);
        executeScopedSql(
                "DELETE FROM trade WHERE from_player_id = :playerId OR to_player_id = :playerId",
                playerId);
        executeScopedSql(
                "UPDATE ark_sail SET built_by_player_id = NULL WHERE built_by_player_id = :playerId",
                playerId);
        executeScopedSql(
                "UPDATE ark_sail SET work_action_player_id = NULL WHERE work_action_player_id = :playerId",
                playerId);
        executeScopedSql(
                "UPDATE selected_catastrophe SET player_id = NULL WHERE player_id = :playerId",
                playerId);
        executeScopedSql("DELETE FROM `user` WHERE player_id = :playerId", playerId);
    }

    private void executeScopedSql(String sql, Integer playerId) {
        try {
            entityManager.createNativeQuery(sql)
                    .setParameter("playerId", playerId)
                    .executeUpdate();
        } catch (Exception e) {
            if (isMissingTable(e)) {
                return;
            }
            if (e instanceof RuntimeException) {
                throw (RuntimeException) e;
            }
            throw new RuntimeException(e);
        }
    }

    private boolean isMissingTable(Throwable error) {
        Throwable current = error;
        while (current != null) {
            String message = current.getMessage();
            if (message != null
                    && (message.contains("doesn't exist")
                    || message.contains("Unknown table")
                    || message.contains("does not exist"))) {
                return true;
            }
            current = current.getCause();
        }
        return false;
    }

    @Transactional
    public Map<String, Object> migrateFaction() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            List<Player> players = playerRepository.findAll();
            int updatedCount = 0;
            
            for (Player player : players) {
                if (player.getFaction() != null && player.getFaction().name().equals("杀戮者")) {
                    player.setFaction(Player.Faction.天灾使者);
                    playerRepository.save(player);
                    updatedCount++;
                }
            }
            
            result.put("success", true);
            result.put("message", "阵营迁移完成");
            result.put("updatedCount", updatedCount);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "迁移失败: " + e.getMessage());
        }
        
        return result;
    }

    public Map<String, Object> getPlayerDetails(Integer id) {
        return getPlayerDetails(id, null);
    }

    public Map<String, Object> getPlayerDetails(Integer id, Integer requesterUserId) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            Player player = playerRepository.findById(id).orElse(null);
            if (player == null) {
                result.put("success", false);
                result.put("message", "玩家不存在");
                return result;
            }

            result.put("success", true);
            result.put("id", player.getId());
            result.put("name", player.getName());
            result.put("isWeak", player.getIsWeak());
            result.put("isOverworked", player.getIsOverworked());
            result.put("isInjured", player.getIsInjured() != null ? player.getIsInjured() : 0);
            result.put("isSeverelyInjured", player.getIsSeverelyInjured());
            result.put("isDead", player.getIsDead());
            result.put("isBound", Boolean.TRUE.equals(player.getIsBound()));
            boolean boundActive = tradeRestrictionService.isBoundActive(player);
            result.put("statuses", PlayerStatusCatalog.buildStatusList(player, boundActive));
            result.putAll(PlayerStatusCatalog.combatFlags(player, boundActive));
            result.put("faction", player.getFaction() != null ? player.getFaction().name() : null);
            result.put("jobId", player.getJobId());
            result.put("skillId", player.getSkillId());
            result.put("createdAt", player.getCreatedAt());
            result.put("updatedAt", player.getUpdatedAt());

            if (player.getJobId() != null) {
                Job job = jobRepository.findById(player.getJobId()).orElse(null);
                if (job != null) {
                    result.put("job", job.getName());
                    result.put("jobSkills", job.getSkills());
                    result.put("jobDescription", job.getDescription());
                }
            }

            if (player.getHiddenJobId() != null && canSeeHiddenJob(id, requesterUserId)) {
                Job hiddenJob = jobRepository.findById(player.getHiddenJobId()).orElse(null);
                if (hiddenJob != null) {
                    result.put("hiddenJob", hiddenJob.getName());
                    result.put("hiddenJobSkills", hiddenJob.getSkills());
                    result.put("hiddenJobDescription", hiddenJob.getDescription());
                }
            }

            if (player.getSkillId() != null) {
                Skill skill = skillRepository.findById(player.getSkillId()).orElse(null);
                if (skill != null) {
                    result.put("personalSkill", skill.getName());
                    result.put("personalSkillFunction", skill.getFunction());
                }
            }

            String avatar = "🧑";
            if (player.getFaction() != null) {
                switch (player.getFaction()) {
                    case 统治者: avatar = "⚔️"; break;
                    case 反叛者: avatar = "🔮"; break;
                    case 冒险者: avatar = "🗡️"; break;
                    case 天灾使者: avatar = "✨"; break;
                    case 平民: avatar = "🏹"; break;
                    case 外来者: avatar = "🧳"; break;
                    case 原住民: avatar = "🌿"; break;
                }
            }
            result.put("avatar", avatar);
            result.put("markers", playerMarkerService.listForPlayer(id));
            List<String> tradeBanReasons = tradeRestrictionService.reasonsFor(player);
            result.put("tradeBanned", Boolean.TRUE.equals(player.getTradeBanned()));
            result.put("tradeBanReasons", tradeBanReasons);
            result.put("tradeBanActive", !tradeBanReasons.isEmpty());

        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "获取玩家信息失败: " + e.getMessage());
        }
        
        return result;
    }

    private boolean canSeeHiddenJob(Integer playerId, Integer requesterUserId) {
        if (requesterUserId == null || playerId == null) {
            return false;
        }
        User user = userRepository.findById(requesterUserId).orElse(null);
        if (user == null) {
            return false;
        }
        if (User.Role.DM.equals(user.getRole())) {
            return true;
        }
        return playerId.equals(user.getPlayerId());
    }

    /** Dashboard food (kg) and fuel from player_items material 5 / 8. */
    public Map<String, Object> getPersonalResources(Integer playerId) {
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("playerId", playerId);

        Map<String, Object> stock = playerSupplyService.getPersonalResourceTotals(playerId);
        result.put("foodKg", stock.getOrDefault("foodKg", 0));
        result.put("fuelKg", stock.getOrDefault("fuelKg", 0));
        result.put("woodKg", stock.getOrDefault("woodKg", 0));
        result.put("fuelLiters", stock.getOrDefault("fuelLiters", 0));
        result.put("foodSupply", playerSupplyService.buildPlayerFoodSupply(playerId));
        result.put("energyReserve", playerSupplyService.buildPlayerEnergyReserve(playerId));

        return result;
    }
}
