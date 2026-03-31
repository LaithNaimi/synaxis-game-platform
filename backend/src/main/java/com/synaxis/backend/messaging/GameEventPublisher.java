package com.synaxis.backend.messaging;

import com.synaxis.backend.messaging.dto.GenericGameEvent;
import com.synaxis.backend.room.ws.event.*;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

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
            int scoreDelta
            ){
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

        publishRoundEvent(roomCode, event);
    }
}