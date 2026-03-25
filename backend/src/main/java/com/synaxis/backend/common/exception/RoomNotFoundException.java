package com.synaxis.backend.common.exception;

import org.springframework.http.HttpStatus;

public class RoomNotFoundException extends BaseBusinessException {

    public RoomNotFoundException() {
        super("ROOM_NOT_FOUND", "Room not found", HttpStatus.NOT_FOUND);
    }
}