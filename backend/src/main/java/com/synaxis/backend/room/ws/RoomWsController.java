package com.synaxis.backend.room.ws;

import com.synaxis.backend.messaging.GameEventPublisher;
import com.synaxis.backend.room.service.RoomService;
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
    private final RoomService roomService;

    @MessageMapping("/game.start")
    public void startGame(StartGameCommand command) {
        commandValidationService.validateHostStartGameCommand(command);
        roomService.startGame(command.getRoomCode());
    }

    @MessageMapping("/game.guess-letter")
    public void guessLetter(GuessLetterCommand command) {
        AuthorizedPlayerContext context = commandValidationService.validatePlayerCommand(command);

        if(command.getLetter() == null || command.getLetter().length() != 1){
            throw new IllegalStateException("Guess must contain exactly one letter");
        }

        char letter = command.getLetter().charAt(0);
        roomService.handleGuess(
                context.getRoom().getRoomCode(),
                context.getPlayer().getPlayerId(),
                letter
        );
    }

}