package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PlayerJoinedEvent extends BaseEvent {

    private String playerId;
    private String playerName;
    private boolean host;
}
