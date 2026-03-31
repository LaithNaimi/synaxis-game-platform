package com.synaxis.backend.match.service;

import com.synaxis.backend.match.dto.ScoreBreakdown;
import com.synaxis.backend.match.model.LetterFrequencyCategory;
import org.springframework.stereotype.Service;

import static com.synaxis.backend.match.model.LetterFrequencyCategory.COMMON;

@Service
public class ScoreCalculator {
    private static final int COMMON_LETTER_SCORE = 10;
    private static final int MODERN_LETTER_SCORE = 20;
    private static final int RARE_LETTER_SCORE = 30;

    private static final int SPEED_BONUS = 5;
    private static final int FIRST_FINISHER_BONUS = 150;
    private static final int SUDDEN_DEATH_COMPLETION_BONUS = 25;

    public ScoreBreakdown calculateCorrectGuessScore(
            LetterFrequencyCategory category,
            boolean withinSpeedWindow,
            boolean firstFinisher,
            boolean suddenDeathCompletion
    ){
        int baseScore = baseScoreFor(category);
        int speedBonus = withinSpeedWindow ? SPEED_BONUS : 0;
        int firstFinisherBonus = firstFinisher ? FIRST_FINISHER_BONUS : 0;
        int suddenDeathBonus = suddenDeathCompletion ? SUDDEN_DEATH_COMPLETION_BONUS : 0;

        int totalScore = baseScore + speedBonus + firstFinisherBonus + suddenDeathBonus;

        return new ScoreBreakdown(
                baseScore,
                speedBonus,
                firstFinisherBonus,
                suddenDeathBonus,
                totalScore
        );
    }

    private int baseScoreFor(LetterFrequencyCategory category){
        return switch (category) {
            case COMMON -> COMMON_LETTER_SCORE;
            case MODERATE ->  MODERN_LETTER_SCORE;
            case RARE ->  RARE_LETTER_SCORE;
        };
    }
}
