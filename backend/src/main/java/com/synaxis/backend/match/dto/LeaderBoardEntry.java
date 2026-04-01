package com.synaxis.backend.match.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LeaderBoardEntry {

    private final String playerId;
    private final String playerName;
    private final int score;
    private final int health;
    private final long totalSolveTimeMs;
    private final int rank;
}
