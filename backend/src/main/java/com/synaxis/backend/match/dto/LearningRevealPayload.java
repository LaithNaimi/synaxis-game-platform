package com.synaxis.backend.match.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LearningRevealPayload {

    private final int roundNumber;
    private final String word;
    private final String arabicMeaning;
    private final String englishDefinition;
}
