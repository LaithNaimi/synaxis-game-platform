package com.synaxis.backend.match.service;

import com.synaxis.backend.common.exception.RoomNotFoundException;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.room.model.RoomStatus;
import com.synaxis.backend.room.service.RoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
@RequiredArgsConstructor
public class SuddenDeathScheduler {

    private final RoomService roomService;

    @Scheduled(fixedDelay = 1000)
    public void checkSuddenDeathTimeouts() {
        for (Room room : roomService.getRooms()){
            if (room.getStatus() != RoomStatus.IN_GAME){
                continue;
            }
            if(room.getMatchState() == null || room.getMatchState().getCurrentRound() == null){
                continue;
            }

            try {
                roomService.endSuddenDeathIfNeed(room.getRoomCode(), Instant.now());
            } catch (RoomNotFoundException ignored) {
                // Room removed between snapshot and lock
            }
        }
    }
}
