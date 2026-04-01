package com.synaxis.backend.match.service;

import com.synaxis.backend.room.model.PlayerSession;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.room.model.RoomStatus;
import com.synaxis.backend.room.service.RoomService;
import com.synaxis.backend.room.ws.event.PlayerStunnedEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
@RequiredArgsConstructor
public class StunRecoveryScheduler {

    private final RoomService roomService;

    @Scheduled(fixedDelay = 1000)
    public void processRecoveries(){
        for (Room room : roomService.getRooms()){
            if(room.getStatus() != RoomStatus.IN_GAME){
                continue;
            }

            for(PlayerSession player : room.getPlayers()){
                if(player.isStunned()){
                    roomService.recoverPlayer(room.getRoomCode(), player.getPlayerId(), Instant.now());
                }
            }
        }
    }
}
