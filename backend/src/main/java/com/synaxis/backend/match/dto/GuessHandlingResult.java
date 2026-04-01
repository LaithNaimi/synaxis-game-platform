package com.synaxis.backend.match.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class GuessHandlingResult {

    private final char letter;
    private final boolean correct;
    private final String maskedWord;
    private final boolean solved;
    private final int scoreDelta;
    private final int updatedTotalScore;
    private final int healthDelta;
    private final int updatedHealth;
}
