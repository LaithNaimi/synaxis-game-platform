package com.synaxis.backend.match.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class GuessApplicationResult {

    private final char letter;
    private final boolean correct;
    private final String maskedWord;
    private final boolean solved;
}
