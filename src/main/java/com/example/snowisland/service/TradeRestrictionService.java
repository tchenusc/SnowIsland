package com.example.snowisland.service;

import com.example.snowisland.entity.Player;
import com.example.snowisland.entity.PlayerMarker;
import com.example.snowisland.repository.PlayerMarkerRepository;
import com.example.snowisland.repository.PlayerRepository;
import com.example.snowisland.util.PlayerStatusCatalog;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Central trade-ban evaluation: current-day laborer, severely injured, 束缚 marker, manual flag.
 */
@Service
public class TradeRestrictionService {

    public static final String REASON_LABORER = "今日劳工";
    public static final String REASON_SEVERE = "重伤";
    public static final String REASON_BOUND = "束缚";
    public static final String REASON_MANUAL = "手动禁止";

    @Autowired
    private ShelterService shelterService;

    @Autowired
    private GameStateService gameStateService;

    @Autowired
    private PlayerMarkerRepository playerMarkerRepository;

    @Autowired
    private PlayerRepository playerRepository;

    public List<String> reasonsFor(Player player) {
        if (player == null || player.getId() == null) {
            return Collections.emptyList();
        }
        List<String> reasons = new ArrayList<>();
        if (!Boolean.TRUE.equals(player.getTradeBanExempt())) {
            int day = gameStateService.getCurrentDay();
            if (shelterService.isPlayerLaborerForDay(player.getId(), day)) {
                reasons.add(REASON_LABORER);
            }
            if (PlayerStatusCatalog.isSeverelyInjuredActive(player)) {
                reasons.add(REASON_SEVERE);
            }
            if (isBoundActive(player)) {
                reasons.add(REASON_BOUND);
            }
        }
        if (Boolean.TRUE.equals(player.getTradeBanned())) {
            reasons.add(REASON_MANUAL);
        }
        return reasons;
    }

    public List<String> reasonsFor(Integer playerId) {
        if (playerId == null) {
            return Collections.emptyList();
        }
        return playerRepository.findById(playerId)
                .map(this::reasonsFor)
                .orElse(Collections.emptyList());
    }

    public boolean isBanned(Player player) {
        return !reasonsFor(player).isEmpty();
    }

    /**
     * @return rejection message, or null if both parties may trade
     */
    public String rejectIfBanned(Integer fromPlayerId, Integer toPlayerId) {
        List<String> parts = new ArrayList<>();
        appendParty(parts, fromPlayerId);
        appendParty(parts, toPlayerId);
        if (parts.isEmpty()) {
            return null;
        }
        return "无法交易：" + String.join("；", parts);
    }

    private void appendParty(List<String> parts, Integer playerId) {
        if (playerId == null) {
            return;
        }
        Player player = playerRepository.findById(playerId).orElse(null);
        if (player == null) {
            return;
        }
        List<String> reasons = reasonsFor(player);
        if (reasons.isEmpty()) {
            return;
        }
        String name = player.getName() != null ? player.getName() : String.valueOf(playerId);
        parts.add(name + "（" + String.join("、", reasons) + "）");
    }

    /** 列标志或名称含「束缚」的标记，任一即视为束缚。 */
    public boolean isBoundActive(Player player) {
        if (player == null) {
            return false;
        }
        return Boolean.TRUE.equals(player.getIsBound()) || hasBindingMarker(player.getId());
    }

    public boolean hasBindingMarker(Integer playerId) {
        if (playerId == null) {
            return false;
        }
        for (PlayerMarker marker : playerMarkerRepository.findByPlayerIdOrderByIdAsc(playerId)) {
            String name = marker.getName();
            if (name != null && name.contains("束缚")) {
                return true;
            }
        }
        return false;
    }
}
