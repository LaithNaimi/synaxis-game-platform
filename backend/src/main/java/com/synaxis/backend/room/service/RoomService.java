package com.synaxis.backend.room.service;

import com.synaxis.backend.common.exception.GameAlreadyStartedException;
import com.synaxis.backend.common.exception.PlayerNotAuthorizedException;
import com.synaxis.backend.common.exception.RoomFullException;
import com.synaxis.backend.common.exception.RoomNotFoundException;
import com.synaxis.backend.match.dto.*;
import com.synaxis.backend.match.model.*;
import com.synaxis.backend.match.service.*;
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

    private static final int ROOM_CODE_LENGTH = 6;
    private static final int PLAYER_ID_LENGTH = 8;
    private static final int FULL_HEALTH = 100;
    private static final int FIRST_SOLVER_BONUS = 150;
    private static final int SOLVED_DURING_SUDDEN_DEATH_BONUS = 20;

    private final RoomRepository roomRepository;
    private final RoomLockManager roomLockManager;
    private final MatchService matchService;
    private final GameEventPublisher gameEventPublisher;
    private final RoundService roundService;
    private final LetterFrequencyClassifier  letterFrequencyClassifier;
    private final ScoreCalculator scoreCalculator;
    private final HealthManager  healthManager;
    private final StunManager stunManager;
    private final PenaltyManager penaltyManager;
    private final LeaderboardService leaderboardService;
    private final DisconnectManager disconnectManager;
    private final ReconnectSnapshotBuilder reconnectSnapshotBuilder;

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
                roomSettings,
                List.of(
                        new PlayerSummaryResponse(
                                hostPlayer.getPlayerId(),
                                hostPlayer.getPlayerName(),
                                hostPlayer.isHost()
                        )
                )
        );
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

            gameEventPublisher.publishPlayerJoined(
                    roomCode,
                    playerId,
                    request.getPlayerName(),
                    playerSession.isHost()
            );

            List<PlayerSummaryResponse> players =  room.getPlayers()
                    .stream()
                    .map(player -> new PlayerSummaryResponse(
                            player.getPlayerId(),
                            player.getPlayerName(),
                            player.isHost()
                    ))
                    .toList();
         //   gameEventPublisher.publishRoomRosterUpdated(roomCode, players);
            return new JoinRoomResponse(
                    roomCode,
                    playerId,
                    request.getPlayerName(),
                    playerToken,
                    false,
                    room.getStatus(),
                    room.getSettings(),
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
            if (!room.isEmpty()) {
                gameEventPublisher.publishRoomRosterUpdated(
                        roomCode,
                        request.getPlayerId(),
                        room.getHostPlayer().getPlayerId()
                        );
            }
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

    public void startGame(String roomCode, String playerId) {
        roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            if (room.getStatus() != RoomStatus.WAITING) {
                throw new GameAlreadyStartedException();
            }

            PlayerSession player = room.findPlayerById(playerId);
            if(player == null || !player.isHost()) {
                throw new PlayerNotAuthorizedException();
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


    public GuessHandlingResult handleGuess(String roomCode, String playerId, char letter) {
        return roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            GuessApplicationResult applyResult = roundService.applyGuess(room, playerId, letter);

            PlayerSession player = room.findPlayerById(playerId);
            if(player == null){
                throw new IllegalStateException("Player not found after guess");
            }

            int scoreDelta = 0;
            int healthDelta = 0;
            int penaltyScoreDelta = 0;
            boolean stunned = false;

            if(applyResult.isCorrect()){
                LetterFrequencyCategory category = letterFrequencyClassifier.classify(applyResult.getLetter());

                // speed bound, first finisher, sudden death will be integrated later
                ScoreBreakdown scoreBreakdown = scoreCalculator.calculateCorrectGuessScore(
                        category,
                        false,
                        false,
                        false
                );

                scoreDelta = scoreBreakdown.getTotalScore();
                player.setScore(player.getScore() + scoreDelta);
            }
            else {
                HealthUpdateResult healthUpdateResult = healthManager.applyWrongGuessDamage(
                        player.getHealth(), applyResult.getLetter()
                );
                healthDelta =  healthUpdateResult.getHealthDelta();
                player.setHealth(healthUpdateResult.getUpdatedHealth());

                StunTriggerResult stunTriggerResult = stunManager.triggerStun(player);

                if(stunTriggerResult.isStunned() && player.isStunned()){
                    PenaltyApplicationResult penaltyResult = penaltyManager.applyStunPenalty(player.getScore());

                    penaltyScoreDelta = -1 * penaltyResult.getPenaltyAmount();
                    player.setScore(penaltyResult.getUpdatedScore());
                    stunned = true;
                }
            }

            GuessHandlingResult guessResult = new GuessHandlingResult(
                    applyResult.getLetter(),
                    applyResult.isCorrect(),
                    applyResult.getMaskedWord(),
                    applyResult.isSolved(),
                    scoreDelta,
                    player.getScore(),
                    healthDelta,
                    player.getHealth(),
                    penaltyScoreDelta,
                    stunned
            );

            FirstSolverResult firstSolverResult = new FirstSolverResult(false, false, null);
            if(applyResult.isSolved()){
                firstSolverResult = roundService.registerFirstSolver(room, playerId);

                if (firstSolverResult.isFirstSolver()){
                    player.setScore(player.getScore() + FIRST_SOLVER_BONUS);
                    player.setHealth(FULL_HEALTH);
                }
            }

            boolean solvedDuringSuddenDeath = false;
            RoundState currentRound = room.getMatchState().getCurrentRound();

            if(applyResult.isSolved() && currentRound.isInSuddenDeath() && !currentRound.isFirstSolver(playerId)){
                int updatedHealth = Math.min(FULL_HEALTH, player.getHealth() + SOLVED_DURING_SUDDEN_DEATH_BONUS);
                healthDelta += (updatedHealth - player.getHealth());
                player.setHealth(updatedHealth);

                solvedDuringSuddenDeath = true;
            }

            roomRepository.save(room);


            PlayerRoundProgress playerProgress = currentRound.getPlayerProgress(playerId);

            gameEventPublisher.publishLetterGuessResult(
                    roomCode,
                    playerId,
                    guessResult.getLetter(),
                    guessResult.isCorrect(),
                    guessResult.getScoreDelta()
            );

            gameEventPublisher.publishPlayerRoundState(
                    roomCode,
                    playerId,
                    playerProgress.getMaskedWord(),
                    playerProgress.getGuessedLetters(),
                    playerProgress.getCorrectLetters(),
                    playerProgress.getWrongLetters(),
                    playerProgress.isSolved(),
                    player.getScore(),
                    guessResult.getScoreDelta(),
                    player.getHealth(),
                    guessResult.getHealthDelta(),
                    guessResult.getPenaltyScoreDelta(),
                    guessResult.isStunned()
            );

            if(!applyResult.isCorrect() && guessResult.isStunned()){
                gameEventPublisher.publishPlayerStunned(
                        roomCode,
                        playerId,
                        player.getStunnedUntil()
                );
            }

            if(applyResult.isSolved()){
                gameEventPublisher.publishPlayerSolvedWord(
                        roomCode,
                        playerId,
                        room.getMatchState().getCurrentRoundNumber()
                );
            }

            if(firstSolverResult.isSuddenDeathStarted()){
                gameEventPublisher.publishSuddenDeathStarted(
                        roomCode,
                        playerId,
                        room.getMatchState().getCurrentRoundNumber(),
                        firstSolverResult.getSuddenDeathAt()
                );
            }

            if(solvedDuringSuddenDeath){
                gameEventPublisher.publishPlayerSolvedDuringSuddenDeath(
                        roomCode,
                        playerId,
                        room.getMatchState().getCurrentRoundNumber()
                );
            }
            return guessResult;
        });
    }

    public void recoverPlayer(String roomCode, String playerId, Instant now) {
        roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            PlayerSession player = room.findPlayerById(playerId);
            if(player == null){
                throw new PlayerNotAuthorizedException();
            }

            if(!stunManager.canRecover(player, now)){
                return;
            }

            stunManager.recover(player);
            roomRepository.save(room);

            gameEventPublisher.publishPlayerRecovered(
                    roomCode,
                    playerId,
                    player.getHealth()
            );
        });
    }

    public void timeoutCurrentRoundIfNeed(String roomCode) {
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
            LearningRevealPayload payload = roundService.buildLearningRevealPayload(room);

            RoundLeaderboardPayload roundLeaderboard = leaderboardService.buildRoundLeaderboard(
                    currentRound.getRoundNumber(),
                    room.getPlayers()
            );

            roomRepository.save(room);

            gameEventPublisher.publishRoundTimeout(roomCode, currentRound.getRoundNumber());

            gameEventPublisher.publishLearningReveal(roomCode, payload);

            gameEventPublisher.publishRoundLeaderboard(roomCode, roundLeaderboard);

            proceedAfterRound(roomCode);
        });
    }

    public void endSuddenDeathIfNeed(String roomCode, Instant now) {
        roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            if(room.getMatchState() == null || room.getMatchState().getCurrentRound() == null){
                return;
            }

            RoundState round = room.getMatchState().getCurrentRound();

            if(!round.isSuddenDeathExpired(now)){
                return;
            }

            round.showLearningReveal();
            LearningRevealPayload payload = roundService.buildLearningRevealPayload(room);

            RoundLeaderboardPayload roundLeaderboard = leaderboardService.buildRoundLeaderboard(
                    round.getRoundNumber(),
                    room.getPlayers()
            );
            roomRepository.save(room);

            gameEventPublisher.publishSuddenDeathEnded(roomCode,round.getRoundNumber());

            gameEventPublisher.publishLearningReveal(roomCode,payload);

            gameEventPublisher.publishRoundLeaderboard(roomCode,roundLeaderboard);

            proceedAfterRound(roomCode);
        });
    }

    public void handleDisconnect(String roomCode, String playerId){
        roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            PlayerSession player = room.findPlayerById(playerId);
            if(player == null){
                return;
            }

            DisconnectResult disconnectResult = disconnectManager.markDisconnected(player);
            if(!disconnectResult.isDisconnected()){
                return;
            }

            roomRepository.save(room);

            gameEventPublisher.publishPlayerDisconnected(
                    roomCode,
                    playerId,
                    disconnectResult.getReconnectDeadline()
            );
        });
    }

    private void proceedAfterRound(String roomCode) {
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
                FinalLeaderboardPayload finalLeaderboard = leaderboardService.buildFinalLeaderboard(room.getPlayers());

                roomRepository.save(room);

                gameEventPublisher.publishMatchFinished(roomCode);
                gameEventPublisher.publishFinalLeaderboard(roomCode, finalLeaderboard);

            }
        });
    }

    public void removeExpiredDisconnectedPlayer(String roomCode, String playerId, java.time.Instant now) {
        roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            PlayerSession player = room.findPlayerById(playerId);
            if (player == null) {
                return;
            }

            ReconnectExpiryResult expiryResult = disconnectManager.isReconnectExpired(player, now);
            if (!expiryResult.isExpired()) {
                return;
            }

            boolean wasHost = player.isHost();
            String previousHostId = player.getPlayerId();

            room.removePlayerById(playerId);

            if (room.isEmpty()) {
                roomRepository.deleteByCode(roomCode);
                roomLockManager.removeLock(roomCode);
                return;
            }

            String newHostPlayerId = null;

            if (wasHost) {
                room.assignHostToFirstPlayerIfNeeded();

                PlayerSession newHost = room.getPlayers().stream()
                        .filter(PlayerSession::isHost)
                        .findFirst()
                        .orElse(null);

                if (newHost != null) {
                    newHostPlayerId = newHost.getPlayerId();
                }
            }

            roomRepository.save(room);

            gameEventPublisher.publishPlayerRemovedAfterDisconnect(roomCode, playerId);

            if (wasHost && newHostPlayerId != null) {
                gameEventPublisher.publishHostTransferred(
                        roomCode,
                        previousHostId,
                        newHostPlayerId
                );
            }
        });
    }

    public ResyncSnapshot reconnectPlayer(String roomCode, String playerId, String playerToken) {
        return roomLockManager.executeWithRoomLock(roomCode, () -> {
            Room room = roomRepository.findByCode(roomCode)
                    .orElseThrow(RoomNotFoundException::new);

            PlayerSession player = room.findPlayerById(playerId);
            if (player == null) {
                throw new IllegalStateException("Player not found");
            }

            if (!player.getPlayerToken().equals(playerToken)) {
                throw new IllegalStateException("Player token is invalid");
            }

            if (player.getStatus() != com.synaxis.backend.room.model.PlayerStatus.OFFLINE_TEMP) {
                throw new IllegalStateException("Player is not eligible for reconnect");
            }

            if (player.getReconnectDeadline() == null || java.time.Instant.now().isAfter(player.getReconnectDeadline())) {
                throw new IllegalStateException("Reconnect window expired");
            }

            player.setConnected(true);
            player.setStatus(com.synaxis.backend.room.model.PlayerStatus.ACTIVE);
            player.setReconnectDeadline(null);

            ResyncSnapshot snapshot = reconnectSnapshotBuilder.build(room, player);

            roomRepository.save(room);

            gameEventPublisher.publishPlayerReconnected(roomCode, playerId);
            gameEventPublisher.publishResyncSnapshot(roomCode, playerId, snapshot);

            return snapshot;
        });
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

