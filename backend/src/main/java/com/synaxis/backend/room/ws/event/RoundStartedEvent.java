package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RoundStartedEvent extends BaseEvent {

    private String maskedWord;
    private int roundNumber;
}