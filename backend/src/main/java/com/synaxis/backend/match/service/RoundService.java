package com.synaxis.backend.match.service;

import com.synaxis.backend.match.model.PlayerRoundProgress;
import com.synaxis.backend.match.model.RoundState;
import com.synaxis.backend.room.model.PlayerSession;
import com.synaxis.backend.room.model.Room;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
public class RoundService {

    public PlayerRoundProgress validateGuess(Room room, String playerId, char letter){
        if(room.getMatchState() == null || room.getMatchState().getCurrentRound() == null){
            throw new IllegalArgumentException("No action round available");
        }

        RoundState round = room.getMatchState().getCurrentRound();
        if(!round.isAcceptingGuesses()){
            throw new IllegalArgumentException("Round is not accepting guesses");
        }

        PlayerSession player = room.findPlayerById(playerId);
        if(player == null){
            throw new IllegalArgumentException("Player not found in room");
        }
        if(!player.isConnected()){
            throw new IllegalArgumentException("Player is offline");
        }
        if(!isEnglishLetter(letter)){
            throw new IllegalArgumentException("Guess must be english letter");
        }


        PlayerRoundProgress playerProgress = round.getPlayerProgress(playerId);
        if(playerProgress == null){
            throw new IllegalArgumentException("Player progress not found");
        }
        if(playerProgress.getGuessedLetters().contains(letter)){
            throw new IllegalArgumentException("Letter already guessed");
        }

        return playerProgress;
    }

    private boolean isEnglishLetter(char letter){
        return letter >= 'A' && letter <= 'Z';
    }
}
