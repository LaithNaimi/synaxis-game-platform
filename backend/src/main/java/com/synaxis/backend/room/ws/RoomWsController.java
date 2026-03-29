package com.synaxis.backend.room.ws;

import com.synaxis.backend.messaging.GameEventPublisher;
import com.synaxis.backend.room.ws.command.GuessLetterCommand;
import com.synaxis.backend.room.ws.command.StartGameCommand;
import com.synaxis.backend.room.ws.event.GameStartedEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class RoomWsController {

    private final CommandValidationService commandValidationService;
    private final GameEventPublisher gameEventPublisher;

    @MessageMapping("/game.start")
    public void startGame(StartGameCommand command) {
        AuthorizedPlayerContext context = commandValidationService.validateHostStartGameCommand(command);

        GameStartedEvent event = new GameStartedEvent();
        event.setType("GAME_STARTED");
        event.setRoomCode(context.getRoom().getRoomCode());

        gameEventPublisher.publishRoomEvent(context.getRoom().getRoomCode(), event);
    }

    @MessageMapping("/game.guess-letter")
    public void guessLetter(GuessLetterCommand command) {
        commandValidationService.validatePlayerCommand(command);
    }
}