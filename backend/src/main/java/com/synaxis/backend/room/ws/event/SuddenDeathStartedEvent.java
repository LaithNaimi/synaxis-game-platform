package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
public class SuddenDeathStartedEvent extends BaseEvent{

    private int roundNumber;
    private String firstSolverPlayerId;
    private Instant suddenDeathAt;
}
