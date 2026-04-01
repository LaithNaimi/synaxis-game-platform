package com.synaxis.backend.room.ws.event;

import com.synaxis.backend.room.dto.ResyncSnapshot;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ResyncSnapshotEvent extends BaseEvent{

    private ResyncSnapshot payload;
}
