package com.synaxis.backend.match.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ScoreBreakdown {

    private final int baseScore;
    private final int speedBonus;
    private final int firstFinisherBonus;
    private final int suddenDeathBonus;
    private final int totalScore;

}
