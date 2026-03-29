package com.synaxis.backend.room.ws;

import com.synaxis.backend.room.model.PlayerSession;
import com.synaxis.backend.room.model.Room;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class AuthorizedPlayerContext {

    private final Room room;
    private final PlayerSession player;
}