package com.synaxis.backend.match.service;

import com.synaxis.backend.match.model.*;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.word.service.CefrWordSelector;
import com.synaxis.backend.word.model.Word;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

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

        matchState.setCurrentRound(createRoundState(matchState, 1));

        return matchState;
    }

    public RoundState createRoundState(MatchState matchState, int roundNumber) {
        if(roundNumber < 1 || roundNumber > matchState.getTotalRounds()) {
            throw new IllegalArgumentException("Invalid round number: " + roundNumber);
        }

        RoundWord roundWord = matchState.getSelectedWords().get(roundNumber - 1);
        return RoundState.builder()
                .roundNumber(roundNumber)
                .roundWord(roundWord)
                .status(RoundStatus.PREPARING)
                .build();
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

    public void advanceToNextRound(MatchState matchState) {
        if (!matchState.hasNextRound()) {
            throw new IllegalStateException("No more rounds available");
        }

        int nextRoundNumber = matchState.getCurrentRoundNumber() + 1;

        matchState.setCurrentRoundNumber(nextRoundNumber);
        matchState.setCurrentRound(
                createRoundState(matchState, nextRoundNumber)
        );
    }

    public void finishMatch(MatchState matchState) {
        matchState.setStatus(MatchStatus.FINISHED);
    }
}