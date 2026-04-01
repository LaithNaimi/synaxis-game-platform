package com.synaxis.backend.messaging;

import com.synaxis.backend.match.dto.LearningRevealPayload;
import com.synaxis.backend.messaging.dto.GenericGameEvent;
import com.synaxis.backend.room.ws.event.*;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class GameEventPublisher {

    private final SimpMessagingTemplate messagingTemplate;

    public void publishRoomEvent(String roomCode, Object event) {
        messagingTemplate.convertAndSend(
                TopicNames.roomTopic(roomCode),
                event
        );
    }

    public void publishGameStarted(String roomCode) {
        GameStartedEvent event = new GameStartedEvent();
        event.setType("GAME_STARTED");
        event.setRoomCode(roomCode);

        messagingTemplate.convertAndSend(
                TopicNames.roomTopic(roomCode),
                event
        );
    }

    public void publishRoundEvent(String roomCode, Object event) {
        messagingTemplate.convertAndSend(
                TopicNames.roomRoundTopic(roomCode),
                event
        );
    }

    public void publishLeaderboardEvent(String roomCode, Object event) {
        messagingTemplate.convertAndSend(
                TopicNames.roomLeaderboardTopic(roomCode),
                event
        );
    }

    public void publishPrivatePlayerEvent(String playerId, Object event) {
        messagingTemplate.convertAndSendToUser(
                playerId,
                TopicNames.userGameQueue(),
                event
        );
    }

    public void publishRoundCountdownStarted(String roomCode, int roundNumber) {
        messagingTemplate.convertAndSend(
                TopicNames.roomTopic(roomCode),
                new GenericGameEvent(
                        "ROUND_COUNTDOWN_STARTED",
                        roundNumber
                )
        );
    }

    public void publishRoundStarted(String roomCode, int roundNumber) {
        messagingTemplate.convertAndSend(
                TopicNames.roomTopic(roomCode),
                new GenericGameEvent(
                        "ROUND_STARTED",
                        roundNumber
                )
        );
    }

    public void publishRoundTimeout(String roomCode, int roundNumber) {
        RoundTimeoutEvent event = new RoundTimeoutEvent();
        event.setType("ROUND_TIMEOUT");
        event.setRoomCode(roomCode);
        event.setRoundNumber(roundNumber);

        publishRoundEvent(roomCode, event);
    }

    public void publishMatchFinished(String roomCode) {
        MatchFinishedEvent event = new MatchFinishedEvent();
        event.setType("MATCH_FINISHED");
        event.setRoomCode(roomCode);

        publishRoundEvent(roomCode, event);
    }

    public void publishLetterGuessResult(
            String roomCode,
            String playerId,
            char letter,
            boolean correct,
            int scoreDelta
    ){
        LetterGuessResultEvent event = new LetterGuessResultEvent();
        event.setType("LETTER_GUESS_RESULT");
        event.setRoomCode(roomCode);
        event.setLetter(letter);
        event.setCorrect(correct);
        event.setScoreDelta(scoreDelta);

        publishPrivatePlayerEvent(playerId, event);
    }

    public void publishPlayerRoundState(
            String roomCode,
            String playerId,
            String maskedWord,
            Set<Character> guessedLetters,
            Set<Character> correctLetters,
            Set<Character> wrongLetters,
            boolean solved,
            int currentScore,
            int scoreDelta,
            int currentHealth,
            int healthDelta,
            int penaltyScoreDelta,
            boolean stunned){
        PlayerRoundStateEvent event = new PlayerRoundStateEvent();
        event.setType("PLAYER_ROUND_STATE");
        event.setRoomCode(roomCode);
        event.setMaskedWord(maskedWord);
        event.setGuessedLetters(guessedLetters);
        event.setCorrectedLetters(correctLetters);
        event.setWrongLetters(wrongLetters);
        event.setSolved(solved);
        event.setCurrentScore(currentScore);
        event.setScoreDelta(scoreDelta);
        event.setCurrentHealth(currentHealth);
        event.setHealthDelta(healthDelta);
        event.setPenaltyScoreDelta(penaltyScoreDelta);
        event.setStunned(stunned);

        publishRoundEvent(roomCode, event);
    }

    public void publishPlayerStunned(String roomCode, String playerId, Instant stunnedUntil){
        PlayerStunnedEvent event = new PlayerStunnedEvent();
        event.setType("PLAYER_STUNNED");
        event.setRoomCode(roomCode);
        event.setPlayerId(playerId);
        event.setStunnedUntil(stunnedUntil);

        publishPrivatePlayerEvent(playerId, event);
    }

    public void publishPlayerRecovered(String roomCode, String playerId, int recoveredHealth){
        PlayerRecoveredEvent event = new PlayerRecoveredEvent();
        event.setType("PLAYER_RECOVERED");
        event.setRoomCode(roomCode);
        event.setPlayerId(playerId);
        event.setRestoredHealth(recoveredHealth);

        publishPrivatePlayerEvent(playerId, event);
    }

    public void publishPlayerSolvedWord(String roomCode, String playerId, int roundNumber){
        PlayerSolverWordEvent event = new PlayerSolverWordEvent();
        event.setType("PLAYER_SOLVED_WORD");
        event.setRoomCode(roomCode);
        event.setPlayerId(playerId);
        event.setRoundNumber(roundNumber);

        publishPrivatePlayerEvent(playerId, event);
    }

    public void publishSuddenDeathStarted(String roomCode, String firstSolverPlayerId, int roundNumber, Instant suddenDeathAt){
        SuddenDeathStartedEvent event = new SuddenDeathStartedEvent();
        event.setType("SUDDEN_DEATH_STARTED");
        event.setRoomCode(roomCode);
        event.setRoundNumber(roundNumber);
        event.setFirstSolverPlayerId(firstSolverPlayerId);
        event.setSuddenDeathAt(suddenDeathAt);

        publishPrivatePlayerEvent(firstSolverPlayerId, event);
    }

    public void publishPlayerSolvedDuringSuddenDeath(String roomCode, String playerId, int roundNumber){
        PlayerSolvedDuringSuddenDeathEvent event = new PlayerSolvedDuringSuddenDeathEvent();
        event.setType("PLAYER_SOLVED_DURING_SUDDEN_DEATH");
        event.setRoomCode(roomCode);
        event.setPlayerId(playerId);
        event.setRoundNumber(roundNumber);

        publishPrivatePlayerEvent(playerId, event);
    }

    public void publishSuddenDeathEnded(String roomCode, int roundNumber){
        SuddenDeathEndedEvent event = new SuddenDeathEndedEvent();
        event.setType("SUDDEN_DEATH_ENDED");
        event.setRoomCode(roomCode);
        event.setRoundNumber(roundNumber);

        publishPrivatePlayerEvent(roomCode, event);
    }

    public void publishLearningReveal(String roomCode, LearningRevealPayload payload){
        LearningRevealEvent event = new LearningRevealEvent();
        event.setType("LEARNING_REVEAL");
        event.setRoomCode(roomCode);
        event.setPayload(payload);

        publishPrivatePlayerEvent(roomCode, event);
    }
}