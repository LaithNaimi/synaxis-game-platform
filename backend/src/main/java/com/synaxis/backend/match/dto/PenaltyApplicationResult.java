package com.synaxis.backend.match.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class PenaltyApplicationResult {

    private final int penaltyAmount;
    private final int updatedScore;
}
