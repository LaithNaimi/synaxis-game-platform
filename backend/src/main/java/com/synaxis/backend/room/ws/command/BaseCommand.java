package com.synaxis.backend.room.ws.command;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public abstract class BaseCommand {

    private String roomCode;
    private String playerId;
    private String playerToken;
}