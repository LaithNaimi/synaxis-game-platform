package com.synaxis.backend.match.service;

import com.synaxis.backend.match.dto.StunTriggerResult;
import com.synaxis.backend.room.model.PlayerSession;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
public class StunManager {

    private static final int STUN_DURATION_SECONDS = 5;
    private static final int RECOVERY_HEALTH = 40;

    public StunTriggerResult triggerStun(PlayerSession player){
        if(player.getHealth() > 0){
            return new StunTriggerResult(false,null);
        }
        if(player.isStunned()){
            return new StunTriggerResult(true,player.getStunnedUntil());
        }

        Instant stunnedUntil = Instant.now().plusSeconds(STUN_DURATION_SECONDS);

        player.setStunned(true);
        player.setStunnedUntil(stunnedUntil);

        return new StunTriggerResult(true,stunnedUntil);
    }

    public boolean canRecover(PlayerSession player, Instant now){
        return player.isStunned()
                && player.getStunnedUntil() != null
                && !now.isBefore(player.getStunnedUntil());
    }

    public void recover(PlayerSession player){
        player.setStunned(false);
        player.setStunnedUntil(null);
        player.setHealth(RECOVERY_HEALTH);
    }
}
