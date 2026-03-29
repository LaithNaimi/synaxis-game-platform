package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public abstract class BaseEvent {

    private String type;
    private String roomCode;
}