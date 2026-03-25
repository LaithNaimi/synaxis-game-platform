package com.synaxis.backend.common.exception;

import org.springframework.http.HttpStatus;

public class PlayerNotAuthorizedException extends BaseBusinessException {

    public PlayerNotAuthorizedException() {
        super("PLAYER_NOT_AUTHORIZED", "Player is not authorized", HttpStatus.UNAUTHORIZED);
    }
}