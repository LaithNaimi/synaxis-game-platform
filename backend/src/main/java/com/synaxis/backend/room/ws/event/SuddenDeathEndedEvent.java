package com.synaxis.backend.room.ws.event;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SuddenDeathEndedEvent extends BaseEvent{
    private int roundNumber;
}
