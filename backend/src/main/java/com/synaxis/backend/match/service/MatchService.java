package com.synaxis.backend.match.service;

import com.synaxis.backend.match.model.MatchState;
import com.synaxis.backend.match.model.MatchStatus;
import com.synaxis.backend.match.model.RoundWord;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.word.CefrWordSelector;
import com.synaxis.backend.word.model.Word;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

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

        return MatchState.builder()
                .totalRounds(totalRounds)
                .currentRoundNumber(0)
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
    }
}