package com.synaxis.backend.match.service;

import com.synaxis.backend.match.dto.PenaltyApplicationResult;
import org.springframework.stereotype.Service;

@Service
public class PenaltyManager {

    private static final int MIN_PENALTY = 100;

    public PenaltyApplicationResult applyStunPenalty(int currentScore) {
        int percentagePenalty = (int) (Math.ceil(currentScore * 0.10));
        int penaltyAmount = Math.max(MIN_PENALTY, percentagePenalty);

        int updatedScore = Math.max(0, currentScore - penaltyAmount);

        return new PenaltyApplicationResult(penaltyAmount, updatedScore);
    }
}
