package com.synaxis.backend.room.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PlayerSummaryResponse {

    private String playerId;
    private String playerName;
    private boolean isHost;
}