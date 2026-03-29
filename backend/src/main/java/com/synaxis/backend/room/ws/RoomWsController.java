package com.synaxis.backend.room.ws;

import com.synaxis.backend.room.ws.command.GuessLetterCommand;
import com.synaxis.backend.room.ws.command.StartGameCommand;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class RoomWsController {

    private final CommandValidationService commandValidationService;

    @MessageMapping("/game.start")
    public void startGame(StartGameCommand command) {
        commandValidationService.validateHostStartGameCommand(command);
    }

    @MessageMapping("/game.guess-letter")
    public void guessLetter(GuessLetterCommand command) {
        commandValidationService.validatePlayerCommand(command);
    }
}