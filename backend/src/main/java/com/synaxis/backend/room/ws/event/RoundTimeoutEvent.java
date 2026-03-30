package com.synaxis.backend.room.ws.event;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
public class RoundTimeoutEvent extends BaseEvent{
    private int roundNumber;
}
