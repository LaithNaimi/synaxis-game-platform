package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
public class PlayerDisconnectedEvent extends BaseEvent{

    private String playerId;
    private Instant reconnectDeadline;
}
