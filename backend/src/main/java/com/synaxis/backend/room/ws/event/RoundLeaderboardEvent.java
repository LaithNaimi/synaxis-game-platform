package com.synaxis.backend.room.ws.event;

import com.synaxis.backend.match.dto.RoundLeaderboardPayload;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RoundLeaderboardEvent extends BaseEvent{

    private RoundLeaderboardPayload payload;
}
