package com.synaxis.backend.room.service;

import com.synaxis.backend.room.dto.CreateRoomRequest;
import com.synaxis.backend.room.dto.CreateRoomResponse;
import com.synaxis.backend.room.dto.PlayerSummaryResponse;
import com.synaxis.backend.room.model.PlayerSession;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.room.model.RoomSettings;
import com.synaxis.backend.room.model.RoomStatus;
import com.synaxis.backend.room.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@RequiredArgsConstructor
@Service
public class RoomService {

    private final RoomRepository roomRepository;
    private static final int ROOM_CODE_LENGTH = 6;
    private static final int PLAYER_ID_LENGTH = 8;

    public CreateRoomResponse createRoom(CreateRoomRequest request) {
        String roomCode = generateRoomCode();
        String playerId = generatePlayerId();
        String playerToken = generatePlayerToken();

        PlayerSession hostPlayer = PlayerSession.builder()
                .playerId(playerId)
                .playerName(request.getPlayerName())
                .playerToken(playerToken)
                .host(true)
                .connected(true)
                .build();

        RoomSettings roomSettings = RoomSettings.builder()
                .cefrLevel(request.getCefrLevel())
                .maxPlayers(request.getMaxPlayers())
                .totalRounds(request.getTotalRounds())
                .roundDurationSeconds(request.getRoundDurationSeconds())
                .build();

        Room room = Room.builder()
                .roomCode(roomCode)
                .settings(roomSettings)
                .status(RoomStatus.WAITING)
                .build();

        room.addPlayer(hostPlayer);
        roomRepository.save(room);

        return new CreateRoomResponse(
                roomCode,
                playerId,
                playerToken,
                true,
                room.getStatus(),
                List.of(
                        new PlayerSummaryResponse(
                                hostPlayer.getPlayerId(),
                                hostPlayer.getPlayerName(),
                                hostPlayer.isHost()
                        )
                )
        );
    }

    private String generateRoomCode() {
        String code;
        do {
            code = UUID.randomUUID()
                    .toString()
                    .replace("-", "")
                    .substring(0, ROOM_CODE_LENGTH)
                    .toUpperCase();
        } while (roomRepository.existsByCode(code));
        return code;
    }

    private String generatePlayerId() {
        return "p_" + UUID.randomUUID()
                    .toString()
                    .replace("-", "")
                    .substring(0, PLAYER_ID_LENGTH)
                    .toUpperCase();
    }

    private String generatePlayerToken() {
        return UUID.randomUUID().toString();
    }
}

