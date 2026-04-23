package com.synaxis.backend.match.model;

import lombok.*;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RoundWord {

    private String word;
    private String arabicMeaning;
    private String englishDefinition;

    public String getMaskedWord() {
        return "_ ".repeat(word.length()).trim();
    }
}
