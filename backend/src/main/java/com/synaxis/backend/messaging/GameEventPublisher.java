package com.synaxis.backend.messaging;

import com.synaxis.backend.room.ws.event.GameStartedEvent;
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
}