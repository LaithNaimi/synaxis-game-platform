package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PlayerSolvedDuringSuddenDeathEvent extends BaseEvent {

    private String playerId;
    private int roundNumber;
}
