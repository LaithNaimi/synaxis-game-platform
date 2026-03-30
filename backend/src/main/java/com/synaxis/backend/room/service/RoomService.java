package com.synaxis.backend.room.service;

import com.synaxis.backend.common.exception.GameAlreadyStartedException;
import com.synaxis.backend.common.exception.PlayerNotAuthorizedException;
import com.synaxis.backend.common.exception.RoomFullException;
import com.synaxis.backend.common.exception.RoomNotFoundException;
import com.synaxis.backend.match.dto.GuessApplicationResult;
import com.synaxis.backend.match.model.MatchState;
import com.synaxis.backend.match.model.RoundState;
import com.synaxis.backend.match.model.RoundStatus;
import com.synaxis.backend.match.service.MatchService;
import com.synaxis.backend.match.service.RoundService;
import com.synaxis.backend.messaging.GameEventPublisher;
import com.synaxis.backend.room.dto.*;
import com.synaxis.backend.room.model.PlayerSession;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.room.model.RoomSettings;
import com.synaxis.backend.room.model.RoomStatus;
import com.synaxis.backend.room.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RequiredArgsConstructor
@Service
public class RoomService {

    private final RoomRepository roomRepository;
    private final RoomLockManager roomLockManager;
    private final MatchService matchService;
    private final GameEventPublisher gameEventPublisher;
    private static final int ROOM_CODE_LENGTH = 6;
    private static final int PLAYER_ID_LENGTH = 8;
    private final RoundService roundService;

    public List<Room> getRooms() {
        return roomRepository.findAll();
    }

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

    public void leaveRoom(String roomCode, LeaveRoomRequest request) {
        roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            PlayerSession player = room.findPlayerById(request.getPlayerId());

            if(player == null || !player.getPlayerToken().equals(request.getPlayerToken())) {
                throw new PlayerNotAuthorizedException();
            }

            boolean wasHost = player.isHost();
            room.removePlayerById(request.getPlayerId());

            if(room.isEmpty()){
                roomRepository.deleteByCode(roomCode);
                roomLockManager.removeLock(roomCode);
                return;
            }
            if(wasHost){
                room.assignHostToFirstPlayerIfNeeded();
            }
            roomRepository.save(room);
        });
    }

    public ReconnectRoomResponse reconnectRoom(String roomCode, ReconnectRoomRequest request) {
        return roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            PlayerSession player = room.findPlayerById(request.getPlayerId());
            if (player == null || !player.getPlayerToken().equals(request.getPlayerToken())) {
                throw new PlayerNotAuthorizedException();
            }

            room.markPlayerConnected(request.getPlayerId());
            roomRepository.save(room);

            List<PlayerSummaryResponse> playerSummaries = room.getPlayers()
                    .stream()
                    .map(existingPlayer -> new PlayerSummaryResponse(
                            existingPlayer.getPlayerId(),
                            existingPlayer.getPlayerName(),
                            existingPlayer.isHost()
                    ))
                    .toList();

            return new ReconnectRoomResponse(
                    room.getRoomCode(),
                    player.getPlayerId(),
                    player.getPlayerName(),
                    player.getPlayerToken(),
                    player.isHost(),
                    room.getStatus(),
                    playerSummaries
            );
        });
    }

    public void startGame(String roomCode) {
        roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            if (room.getStatus() != RoomStatus.WAITING) {
                throw new GameAlreadyStartedException();
            }

            MatchState matchState = matchService.createMatchState(room);

            room.setMatchState(matchState);
            room.setStatus(RoomStatus.IN_GAME);

            roomRepository.save(room);

            gameEventPublisher.publishGameStarted(room.getRoomCode());

            matchService.startRoundCountdown(matchState);
            gameEventPublisher.publishRoundCountdownStarted(room.getRoomCode(), matchState.getCurrentRoundNumber());
        });
    }

    public void startRound(String roomCode) {
        roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            MatchState matchState = room.getMatchState();

            matchService.activateRound(matchState, room.getSettings().getRoundDurationSeconds());

            roomRepository.save(room);
            gameEventPublisher.publishRoundStarted(room.getRoomCode(),  matchState.getCurrentRoundNumber());
        });
    }

    public void timeoutCurrentRound(String roomCode) {
        roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room =  roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            MatchState matchState = room.getMatchState();
            RoundState currentRound = matchState.getCurrentRound();

            if(currentRound.getStatus() != RoundStatus.ACTIVE){
                return;
            }

            if(!currentRound.isTimeout(Instant.now())){
                return;
            };

            currentRound.showLearningReveal();

            roomRepository.save(room);

            gameEventPublisher.publishRoundTimeout(roomCode, currentRound.getRoundNumber());

        });
    }

    public void proceedAfterRound(String roomCode) {
        roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            MatchState matchState = room.getMatchState();
            RoundState currentRound = matchState.getCurrentRound();

            if (currentRound.getStatus() != RoundStatus.COMPLETED) {
                return;
            }

            if (matchState.hasNextRound()) {
                matchService.advanceToNextRound(matchState, room.getPlayers());

                matchService.startRoundCountdown(matchState);

                roomRepository.save(room);

                gameEventPublisher.publishRoundCountdownStarted(
                        roomCode,
                        matchState.getCurrentRoundNumber()
                );

            } else {
                matchService.finishMatch(matchState);

                room.setStatus(RoomStatus.FINISHED);

                roomRepository.save(room);

                gameEventPublisher.publishMatchFinished(roomCode);
            }
        });
    }

    public GuessApplicationResult handleGuess(String roomCode, String playerId, char letter) {
        return roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            GuessApplicationResult result = roundService.applyGuess(room, playerId, letter);
            roomRepository.save(room);
            return result;
        });
    }
}

