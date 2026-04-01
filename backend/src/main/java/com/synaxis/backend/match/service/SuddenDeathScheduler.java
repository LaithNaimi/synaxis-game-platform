package com.synaxis.backend.match.service;

import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.room.model.RoomStatus;
import com.synaxis.backend.room.service.RoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

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

            roomService.endSuddenDeathIfNeed(room.getRoomCode(), Instant.now());
        }
    }
}
