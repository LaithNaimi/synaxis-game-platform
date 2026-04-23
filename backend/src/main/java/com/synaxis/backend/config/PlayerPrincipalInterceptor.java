package com.synaxis.backend.config;

import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;

import java.security.Principal;

/**
 * Reads the "playerId" header from the STOMP CONNECT frame and assigns it
 * as the session principal so that convertAndSendToUser(playerId, …) works.
 */
public class PlayerPrincipalInterceptor implements ChannelInterceptor {

    private static final String PLAYER_ID_HEADER = "playerId";

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor =
                MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String playerId = accessor.getFirstNativeHeader(PLAYER_ID_HEADER);
            if (playerId != null && !playerId.isBlank()) {
                accessor.setUser(new StompPrincipal(playerId));
            }
        }
        return message;
    }

    private record StompPrincipal(String name) implements Principal {
        @Override
        public String getName() {
            return name;
        }
    }
}
