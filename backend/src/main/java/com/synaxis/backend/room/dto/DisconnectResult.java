package com.synaxis.backend.room.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.Instant;

@Getter
@AllArgsConstructor
public class DisconnectResult {

    private final boolean disconnected;
    private final Instant reconnectDeadline;
}
