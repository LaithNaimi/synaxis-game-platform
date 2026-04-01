package com.synaxis.backend.room.model;

import lombok.*;

import java.time.Instant;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlayerSession {

    private String playerId;
    private String playerName;
    private String playerToken;
    private boolean host;
    private boolean connected;

    private int score;
    private int health;
    private long totalSolveTimeMs;
    private int roundsWonFirst;

    private boolean stunned;
    private Instant stunnedUntil;

    private PlayerStatus status;
    private Instant reconnectDeadline;
}
