package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
public class RoundStartedEvent extends BaseEvent {

    private String maskedWord;
    private int roundNumber;
    /** Server time when the round became ACTIVE (authoritative for client timers). */
    private Instant startedAt;
}