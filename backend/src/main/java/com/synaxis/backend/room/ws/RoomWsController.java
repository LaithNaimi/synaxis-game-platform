package com.synaxis.backend.room.ws;

import com.synaxis.backend.room.service.RoomService;
import com.synaxis.backend.room.ws.command.GuessLetterCommand;
import com.synaxis.backend.room.ws.command.StartGameCommand;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageExceptionHandler;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.annotation.SendToUser;
import org.springframework.stereotype.Controller;

import java.util.Map;

@Controller
@RequiredArgsConstructor
public class RoomWsController {

    private final CommandValidationService commandValidationService;
    private final RoomService roomService;

    @MessageExceptionHandler
    @SendToUser("/queue/errors")
    public Map<String, String> handleException(Exception ex) {
        String message = ex.getMessage() != null ? ex.getMessage() : "Unknown error";
        return Map.of("type", "ERROR", "message", message);
    }

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