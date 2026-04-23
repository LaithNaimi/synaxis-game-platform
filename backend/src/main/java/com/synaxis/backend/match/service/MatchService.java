package com.synaxis.backend.match.service;

import com.synaxis.backend.match.model.*;
import com.synaxis.backend.room.model.PlayerSession;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.word.service.CefrWordSelector;
import com.synaxis.backend.word.model.Word;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MatchService {

    private final CefrWordSelector cefrWordSelector;

    public MatchState createMatchState(Room room) {
        room.initializePlayersForMatch();

        int totalRounds = room.getSettings().getTotalRounds();

        List<Word> words = cefrWordSelector.selectWordsForMatch(
                room.getSettings().getCefrLevel(),
                totalRounds
        );

        MatchState matchState = MatchState.builder()
                .totalRounds(totalRounds)
                .currentRoundNumber(1)
                .status(MatchStatus.COUNTDOWN)
                .selectedWords(
                        words.stream()
                                .map(word -> RoundWord.builder()
                                        .word(word.getWord())
                                        .arabicMeaning(word.getArabicMeaning())
                                        .englishDefinition(word.getEnglishDefinition())
                                        .build()
                                ).toList()
                )
                .build();

        matchState.setCurrentRound(
                createRoundState(
                        1,
                        matchState.getSelectedWords().get(0),
                        room.getPlayers()
                ));

        for(Word word : words) {
            System.out.println(word.getWord());
        }
        return matchState;
    }

    private RoundState createRoundState(int roundNumber, RoundWord roundWord, List<PlayerSession> players) {
        Map<String, PlayerRoundProgress> playerProgressMap = new HashMap<>();

        for (PlayerSession player : players) {
            playerProgressMap.put(
                    player.getPlayerId(),
                    PlayerRoundProgress.builder()
                            .maskedWord(buildInitialMaskedWord(roundWord.getWord().length()))
                            .build()
            );

        }
        return RoundState.builder()
                .roundNumber(roundNumber)
                .roundWord(roundWord)
                .status(RoundStatus.PREPARING)
                .playerProgress(playerProgressMap)
                .build();
    }

    private String buildInitialMaskedWord(int length) {
        return "_ ".repeat(length).trim();
    }

    public void startRoundCountdown(MatchState matchState) {
        matchState.getCurrentRound().startCountdown();
    }

    public void activateRound(MatchState matchState, int roundDurationSeconds) {
        RoundState roundState = matchState.getCurrentRound();

        Instant startedAt = Instant.now();
        Instant timeoutAt = startedAt.plusSeconds(roundDurationSeconds);

        roundState.activate(startedAt, timeoutAt);
    }

    public void advanceToNextRound(MatchState matchState, List<PlayerSession> players) {
        if (!matchState.hasNextRound()) {
            throw new IllegalStateException("No more rounds available");
        }

        int nextRoundNumber = matchState.getCurrentRoundNumber() + 1;
        RoundWord nextWord = matchState.getSelectedWords().get(nextRoundNumber - 1);

        matchState.setCurrentRoundNumber(nextRoundNumber);
        matchState.setCurrentRound(
                createRoundState(nextRoundNumber,nextWord,players)
        );
    }

    public void finishMatch(MatchState matchState) {
        matchState.setStatus(MatchStatus.FINISHED);
    }
}