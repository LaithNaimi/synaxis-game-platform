package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PlayerRemovedAfterDisconnectEvent extends BaseEvent{

    private String playerId;
}
