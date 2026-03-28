package com.synaxis.backend.room.service;

import com.synaxis.backend.common.exception.GameAlreadyStartedException;
import com.synaxis.backend.common.exception.RoomFullException;
import com.synaxis.backend.common.exception.RoomNotFoundException;
import com.synaxis.backend.room.dto.*;
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
    private final RoomLockManager roomLockManager;
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
                request.getPlayerName(),
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

    public JoinRoomResponse joinRoom(String roomCode, JoinRoomRequest request) {

        return roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);
            if(room.getStatus() != RoomStatus.WAITING) {
                throw new GameAlreadyStartedException();
            }
            if(room.isFull()){
                throw new RoomFullException();
            }

            String playerId = generatePlayerId();
            String playerToken = generatePlayerToken();

            PlayerSession playerSession = PlayerSession.builder()
                    .playerId(playerId)
                    .playerName(request.getPlayerName())
                    .playerToken(playerToken)
                    .host(false)
                    .connected(true)
                    .build();

            room.addPlayer(playerSession);
            roomRepository.save(room);

            List<PlayerSummaryResponse> players =  room.getPlayers()
                    .stream()
                    .map(player -> new PlayerSummaryResponse(
                            player.getPlayerId(),
                            player.getPlayerName(),
                            player.isHost()
                    ))
                    .toList();
            return new JoinRoomResponse(
                    roomCode,
                    playerId,
                    request.getPlayerName(),
                    playerToken,
                    false,
                    room.getStatus(),
                    players
            );
        });
    }
}

