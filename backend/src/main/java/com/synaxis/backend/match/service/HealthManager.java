package com.synaxis.backend.match.service;

import com.synaxis.backend.match.dto.HealthUpdateResult;
import com.synaxis.backend.match.model.HealthPenaltyCategory;
import org.springframework.stereotype.Service;

import java.util.Set;

@Service
public class HealthManager {
    private static final int MAX_HEALTH = 100;
    private static final int MIN_HEALTH = 0;

    private static Set<Character> HIGH_FREQUENCY_LETTERS = Set.of(
            'a', 'e', 'i', 'o', 'u', 'n', 'r', 's', 't', 'l'
    );
    private static Set<Character> MEDIUM_FREQUENCY_LETTERS = Set.of(
            'b', 'c', 'd', 'f', 'g', 'h', 'm', 'p', 'w', 'y'
    );

    public HealthUpdateResult applyWrongGuessDamage(int currentHealth, char rowLetter){
        char letter = Character.toLowerCase(rowLetter);

        HealthPenaltyCategory category = classify(letter);
        int damage = damageFor(category);

        int updatedHealth = Math.max(MIN_HEALTH, currentHealth - damage);
        int healthDelta = updatedHealth - currentHealth;

        return new HealthUpdateResult(
                healthDelta,
                updatedHealth,
                updatedHealth == 0
        );
    }

    public int capHealth(int health){
        return Math.min(MAX_HEALTH, Math.min(health, MAX_HEALTH));
    }

    private HealthPenaltyCategory classify(char letter){
        if(HIGH_FREQUENCY_LETTERS.contains(letter)){
            return HealthPenaltyCategory.HIGH_FREQUENCY;
        }
        if(MEDIUM_FREQUENCY_LETTERS.contains(letter)){
            return HealthPenaltyCategory.MEDIUM_FREQUENCY;
        }
        return HealthPenaltyCategory.LOW_FREQUENCY;
    }

    private int damageFor(HealthPenaltyCategory category){
        return switch (category){
            case HIGH_FREQUENCY -> 5;
            case MEDIUM_FREQUENCY -> 12;
            case LOW_FREQUENCY -> 25;
        };
    }
}
