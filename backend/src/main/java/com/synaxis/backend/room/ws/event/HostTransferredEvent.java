package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class HostTransferredEvent extends BaseEvent{

    private String previousHostPlayerId;
    private String newHostPlayerId;
}
