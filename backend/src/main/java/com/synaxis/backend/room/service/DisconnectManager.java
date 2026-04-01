package com.synaxis.backend.room.service;

import com.synaxis.backend.room.dto.DisconnectResult;
import com.synaxis.backend.room.dto.ReconnectExpiryResult;
import com.synaxis.backend.room.model.PlayerSession;
import com.synaxis.backend.room.model.PlayerStatus;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;

@Service
public class DisconnectManager {

    private static final int RECONNECT_GRACE_SECONDS = 60;

    public DisconnectResult markDisconnected(PlayerSession player) {
        if(!player.isConnected() && player.getStatus() == PlayerStatus.OFFLINE_TEMP) {
            return new DisconnectResult(false, player.getReconnectDeadline());
        }

        Instant reconnectDeadline = Instant.now().plus(Duration.ofSeconds(RECONNECT_GRACE_SECONDS));

        player.setConnected(false);
        player.setStatus(PlayerStatus.OFFLINE_TEMP);
        player.setReconnectDeadline(reconnectDeadline);

        return new DisconnectResult(true, reconnectDeadline);
    }

    public ReconnectExpiryResult isReconnectExpired(PlayerSession player, Instant now) {
        if(player.getStatus() != PlayerStatus.OFFLINE_TEMP) {
            return new ReconnectExpiryResult(false);
        }
        if(player.getReconnectDeadline() == null) {
            return new ReconnectExpiryResult(true);
        }

        return new ReconnectExpiryResult(!now.isBefore(player.getReconnectDeadline()));
    }
}


