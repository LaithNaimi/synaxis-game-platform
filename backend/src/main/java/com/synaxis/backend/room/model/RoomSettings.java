package com.synaxis.backend.room.model;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RoomSettings {

    private String cefrLevel;
    private int maxPlayers;
    private int totalRounds;
    private int roundDurationSeconds;

}
