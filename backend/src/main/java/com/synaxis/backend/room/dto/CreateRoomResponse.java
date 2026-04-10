
package com.synaxis.backend.room.dto;

import com.synaxis.backend.room.model.RoomSettings;
import com.synaxis.backend.room.model.RoomStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CreateRoomResponse {

    private String roomCode;
    private String playerId;
    private String playerName;
    private String playerToken;
    private boolean isHost;
    private RoomStatus roomState;
    private RoomSettings roomSettings;
    private List<PlayerSummaryResponse> players;
}