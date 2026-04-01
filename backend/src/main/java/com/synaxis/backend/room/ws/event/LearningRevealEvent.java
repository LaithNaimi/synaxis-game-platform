package com.synaxis.backend.room.ws.event;

import com.synaxis.backend.match.dto.LearningRevealPayload;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class LearningRevealEvent extends BaseEvent{

    private LearningRevealPayload payload;
}
