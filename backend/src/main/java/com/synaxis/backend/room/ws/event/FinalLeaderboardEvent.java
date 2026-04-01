package com.synaxis.backend.room.ws.event;

import com.synaxis.backend.match.dto.FinalLeaderboardPayload;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FinalLeaderboardEvent extends BaseEvent{

    private FinalLeaderboardPayload payload;
}
