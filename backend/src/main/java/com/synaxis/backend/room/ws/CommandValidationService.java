package com.synaxis.backend.room.ws;

import com.synaxis.backend.common.exception.GameAlreadyStartedException;
import com.synaxis.backend.common.exception.PlayerNotAuthorizedException;
import com.synaxis.backend.common.exception.RoomNotFoundException;
import com.synaxis.backend.room.model.PlayerSession;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.room.model.RoomStatus;
import com.synaxis.backend.room.repository.RoomRepository;
import com.synaxis.backend.room.ws.command.BaseCommand;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CommandValidationService {

    private final RoomRepository roomRepository;

    public AuthorizedPlayerContext validatePlayerCommand(BaseCommand command) {
        Room room = roomRepository.findByCode(command.getRoomCode())
                .orElseThrow(RoomNotFoundException::new);

        PlayerSession player = room.findPlayerById(command.getPlayerId());
        if (player == null) {
            throw new PlayerNotAuthorizedException();
        }

        if (!player.getPlayerToken().equals(command.getPlayerToken())) {
            throw new PlayerNotAuthorizedException();
        }

        if (!player.isConnected()) {
            throw new PlayerNotAuthorizedException();
        }

        return new AuthorizedPlayerContext(room, player);
    }

    public AuthorizedPlayerContext validateHostStartGameCommand(BaseCommand command) {
        AuthorizedPlayerContext context = validatePlayerCommand(command);

        if (!context.getPlayer().isHost()) {
            throw new PlayerNotAuthorizedException();
        }

        if (context.getRoom().getStatus() != RoomStatus.WAITING) {
            throw new GameAlreadyStartedException();
        }

        return context;
    }
}