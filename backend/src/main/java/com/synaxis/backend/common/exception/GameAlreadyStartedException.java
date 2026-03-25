package com.synaxis.backend.common.exception;

import org.springframework.http.HttpStatus;

public class GameAlreadyStartedException extends BaseBusinessException {

    public GameAlreadyStartedException() {
        super("GAME_ALREADY_STARTED", "Game already started", HttpStatus.BAD_REQUEST);
    }
}