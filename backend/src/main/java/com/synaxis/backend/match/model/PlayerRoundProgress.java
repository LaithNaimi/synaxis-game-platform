package com.synaxis.backend.match.model;

import lombok.*;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlayerRoundProgress {

    @Builder.Default
    private Set<Character> guessedLetters = new HashSet<>();

    @Builder.Default
    private Set<Character> correctLetters = new HashSet<>();

    @Builder.Default
    private Set<Character> wrongLetters = new HashSet<>();

    private String maskedWord;
    private boolean solved;
    private Instant solvedAt;
}
