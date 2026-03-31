package com.synaxis.backend.match.service;

import com.synaxis.backend.match.model.LetterFrequencyCategory;
import org.springframework.stereotype.Service;

import java.util.Set;

@Service
public class LetterFrequencyClassifier {

    private static Set<Character> COMMON_LETTERS = Set.of(
            'a', 'e', 'i', 'o', 'u', 'n', 'r', 's', 't', 'l'
    );
    private static Set<Character> MODERATE_LETTERS = Set.of(
            'b', 'c', 'd', 'f', 'g', 'h', 'm', 'p', 'w', 'y'
    );

    public LetterFrequencyCategory classify(char rowLetter) {
        char letter = Character.toLowerCase(rowLetter);
        if (COMMON_LETTERS.contains(letter)) {
            return LetterFrequencyCategory.COMMON;
        }
        if (MODERATE_LETTERS.contains(letter)) {
            return LetterFrequencyCategory.MODERATE;
        }
        return LetterFrequencyCategory.RARE;
    }
}
