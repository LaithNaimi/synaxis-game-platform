package com.synaxis.backend.room.ws.event;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PlayerLeaveEvent extends BaseEvent{
    String leavingPlayerId;
    String hostPlayerId;
}
