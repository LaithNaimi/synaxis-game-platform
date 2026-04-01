package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
public class PlayerStunnedEvent extends BaseEvent{

    private String playerId;
    private Instant stunnedUntil;
}
