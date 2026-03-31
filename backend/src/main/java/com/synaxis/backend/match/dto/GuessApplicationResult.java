package com.synaxis.backend.match.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class GuessApplicationResult {

    private char letter;
    private boolean correct;
    private String maskedWord;
    private boolean solved;
    private int scoreDelta;
    private int updatedTotalScore;
}
