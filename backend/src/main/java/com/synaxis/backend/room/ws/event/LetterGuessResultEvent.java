package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LetterGuessResultEvent extends BaseEvent{
    private char letter;
    private boolean correct;
    private int scoreDelta;
}
