package com.synaxis.backend.match.service;

import com.synaxis.backend.match.dto.FirstSolverResult;
import com.synaxis.backend.match.dto.LearningRevealPayload;
import com.synaxis.backend.match.model.PlayerRoundProgress;
import com.synaxis.backend.match.model.RoundState;
import com.synaxis.backend.match.model.RoundWord;
import com.synaxis.backend.room.model.PlayerSession;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.match.dto.GuessApplicationResult;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Set;

@Service
public class RoundService {

    private static final int SECONDS_AFTER_SOLVED = 10;
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
        if(player.isStunned()){
            throw new IllegalArgumentException("Player is stunned");
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

    public GuessApplicationResult applyGuess(Room room, String playerId, char rowLetter){
        char letter = Character.toLowerCase(rowLetter);

        PlayerRoundProgress playerProgress = validateGuess(room, playerId, letter);
        RoundState round = room.getMatchState().getCurrentRound();
        String word = round.getRoundWord().getWord().toLowerCase();

        playerProgress.getGuessedLetters().add(letter);

        boolean correct = word.indexOf(letter) >= 0;
        if(correct) {
            playerProgress.getCorrectLetters().add(letter);
        }
        else {
            playerProgress.getWrongLetters().add(letter);
        }

        String maskedWord =  buildMaskedWord(word, playerProgress.getCorrectLetters());
        playerProgress.setMaskedWord(maskedWord);

        boolean solved = isSolved(word, playerProgress.getCorrectLetters());
        if(solved && !playerProgress.isSolved()){
            playerProgress.setSolved(true);
            playerProgress.setSolvedAt(Instant.now());
        }

        return new GuessApplicationResult(
                letter,
                correct,
                maskedWord,
                playerProgress.isSolved()
        );
    }

    public FirstSolverResult registerFirstSolver(Room room, String playerId){
        RoundState round = room.getMatchState().getCurrentRound();
        PlayerRoundProgress playerProgress = round.getPlayerProgress(playerId);

        if(playerProgress == null || !playerProgress.isSolved()){
            return new FirstSolverResult(false,false,null);
        }

        if(round.hasFirstSolver()){
            return new FirstSolverResult(false,false,null);
        }

        Instant now = Instant.now();
        Instant suddenDeathAt = now.plusSeconds(SECONDS_AFTER_SOLVED);

        round.enterSuddenDeath(playerId, now, suddenDeathAt);

        return new FirstSolverResult(true,true,suddenDeathAt);
    }

    public LearningRevealPayload buildLearningRevealPayload(Room room){
        if(room.getMatchState() == null || room.getMatchState().getCurrentRound() == null){
            throw new IllegalArgumentException("No current round available for learning reveal");
        }

        RoundState round = room.getMatchState().getCurrentRound();
        RoundWord word = round.getRoundWord();

        return new LearningRevealPayload(
                round.getRoundNumber(),
                word.getWord(),
                word.getArabicMeaning(),
                word.getEnglishDefinition()
        );
    }

    private boolean isEnglishLetter(char letter){
        return letter >= 'a' && letter <= 'b';
    }

    private String buildMaskedWord(String word, Set<Character> correctLetters){
        StringBuilder masked = new StringBuilder(word);

        for(char currentLetter : word.toCharArray()){
            if(correctLetters.contains(currentLetter)){
                masked.append(currentLetter);
            }
            else {
                masked.append(' ');
            }
            masked.append(' ');
        }
        return masked.toString().trim();
    }

    private boolean isSolved(String word, Set<Character> correctLetters){
        for(char currentLetter : word.toCharArray()){
            if(!correctLetters.contains(currentLetter)){
                return false;
            }
        }
        return true;
    }
}
