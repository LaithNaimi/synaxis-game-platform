package com.synaxis.backend.room.service;

import com.synaxis.backend.room.model.PlayerSession;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.room.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
@RequiredArgsConstructor
public class ReconnectExpiryScheduler {

    private final RoomRepository roomRepository;
    private final RoomService roomService;

    @Scheduled(fixedDelay = 1000)
    public void removeExpiredDisconnectedPlayers() {
        Instant now = Instant.now();

        for (Room room : roomRepository.findAll()) {
            for (PlayerSession player : room.getPlayers()) {
                roomService.removeExpiredDisconnectedPlayer(
                        room.getRoomCode(),
                        player.getPlayerId(),
                        now
                );
            }
        }
    }
}