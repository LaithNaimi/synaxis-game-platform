package com.synaxis.backend.word.service;

import com.synaxis.backend.word.model.Word;
import com.synaxis.backend.word.repository.WordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CefrWordSelector {

    private final WordRepository wordRepository;

    public List<Word> selectWordsForMatch(String cefrLevel, int requiredCount) {
        List<Word> words = new ArrayList<>(wordRepository.findByCefrLevelAndIsActiveTrue(cefrLevel));

        if (words.size() < requiredCount) {
            throw new IllegalStateException("Not enough words available for level: " + cefrLevel);
        }

        Collections.shuffle(words);

        return words.subList(0, requiredCount);
    }


}

