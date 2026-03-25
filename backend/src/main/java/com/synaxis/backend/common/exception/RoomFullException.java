package com.synaxis.backend.common.exception;

import org.springframework.http.HttpStatus;

public class RoomFullException extends BaseBusinessException{
    public RoomFullException(){
        super("ROOM_FULL", "Room is full", HttpStatus.BAD_REQUEST);
    }
}
