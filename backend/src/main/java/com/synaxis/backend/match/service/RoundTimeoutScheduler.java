package com.synaxis.backend.match.service;

import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.room.model.RoomStatus;
import com.synaxis.backend.room.service.RoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class RoundTimeoutScheduler {

    private final RoomService roomService;

    @Scheduled(fixedRate = 1000)
    public void scheduledRoundTimeout() {
        for(Room room : roomService.getRooms()) {
            if(room.getStatus() != RoomStatus.IN_GAME){
                continue;
            }
            if(room.getMatchState() == null && room.getMatchState().getCurrentRound() == null){
                continue;
            }

            roomService.timeoutCurrentRound(room.getRoomCode());
        }
    }
}
