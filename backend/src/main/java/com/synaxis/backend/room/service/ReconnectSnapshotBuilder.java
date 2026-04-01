package com.synaxis.backend.room.service;

import com.synaxis.backend.match.model.PlayerRoundProgress;
import com.synaxis.backend.match.model.RoundState;
import com.synaxis.backend.room.dto.ResyncSnapshot;
import com.synaxis.backend.room.model.PlayerSession;
import com.synaxis.backend.room.model.Room;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Set;

@Service
public class ReconnectSnapshotBuilder {

    public ResyncSnapshot build(Room room, PlayerSession player) {
        String matchStatus = null;
        Integer currentRoundNumber = null;
        String roundStatus = null;

        String maskedWord = null;
        Set<Character> guessedLetters = Collections.emptySet();
        Set<Character> correctLetters = Collections.emptySet();
        Set<Character> wrongLetters = Collections.emptySet();

        if (room.getMatchState() != null) {
            matchStatus = room.getMatchState().getStatus().name();
            currentRoundNumber = room.getMatchState().getCurrentRoundNumber();

            RoundState currentRound = room.getMatchState().getCurrentRound();
            if (currentRound != null) {
                roundStatus = currentRound.getStatus().name();

                PlayerRoundProgress progress = currentRound.getPlayerProgress(player.getPlayerId());
                if (progress != null) {
                    maskedWord = progress.getMaskedWord();
                    guessedLetters = progress.getGuessedLetters();
                    correctLetters = progress.getCorrectLetters();
                    wrongLetters = progress.getWrongLetters();
                }
            }
        }

        List<String> connectedPlayerIds = room.getPlayers().stream()
                .filter(PlayerSession::isConnected)
                .map(PlayerSession::getPlayerId)
                .toList();

        return new ResyncSnapshot(
                room.getRoomCode(),
                player.getPlayerId(),
                player.getPlayerName(),
                player.isHost(),
                room.getStatus().name(),
                player.getStatus().name(),
                connectedPlayerIds,
                matchStatus,
                currentRoundNumber,
                roundStatus,
                maskedWord,
                guessedLetters,
                correctLetters,
                wrongLetters,
                player.getScore(),
                player.getHealth(),
                player.isStunned(),
                player.getStunnedUntil()
        );
    }
}