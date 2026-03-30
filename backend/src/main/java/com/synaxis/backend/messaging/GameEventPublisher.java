package com.synaxis.backend.messaging;

import com.synaxis.backend.messaging.dto.GenericGameEvent;
import com.synaxis.backend.room.ws.event.GameStartedEvent;
import com.synaxis.backend.room.ws.event.MatchFinishedEvent;
import com.synaxis.backend.room.ws.event.RoundTimeoutEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

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
}