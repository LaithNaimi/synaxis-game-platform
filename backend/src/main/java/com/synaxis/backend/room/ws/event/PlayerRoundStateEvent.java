package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

import java.util.Set;

@Getter
@Setter
public class PlayerRoundStateEvent extends BaseEvent{
    private String maskedWord;
    private Set<Character> guessedLetters;
    private Set<Character> correctLetters;
    private Set<Character> wrongLetters;
    private boolean solved;

    private int currentScore;
    private int scoreDelta;

    private int currentHealth;
    private int healthDelta;

    private int penaltyScoreDelta;
    private boolean stunned;
}
