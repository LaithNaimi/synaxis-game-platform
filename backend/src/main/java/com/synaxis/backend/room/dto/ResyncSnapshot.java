package com.synaxis.backend.room.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.Instant;
import java.util.List;
import java.util.Set;

@Getter
@AllArgsConstructor
public class ResyncSnapshot {

    private final String roomCode;
    private final String playerId;
    private final String playerName;
    private final boolean host;

    private final String roomStatus;
    private final String playerStatus;

    private final List<String> connectedPlayerIds;

    private final String matchStatus;
    private final Integer currentRoundNumber;
    private final String roundStatus;

    private final String maskedWord;
    private final Set<Character> guessedLetters;
    private final Set<Character> correctLetters;
    private final Set<Character> wrongLetters;

    private final int currentScore;
    private final int currentHealth;
    private final boolean stunned;
    private final Instant stunnedUntil;
}