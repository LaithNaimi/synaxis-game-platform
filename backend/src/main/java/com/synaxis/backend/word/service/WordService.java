package com.synaxis.backend.word.service;

import com.synaxis.backend.word.model.Word;
import com.synaxis.backend.word.repository.WordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WordService {

    private final WordRepository wordRepository;

    public List<Word> getWordsByLevel(String level) {
        return wordRepository.findByCefrLevelAndIsActiveTrue(level);
    }

    public Word getRandomWord(String level) {
        return wordRepository.findRandomByLevel(level)
                .orElseThrow(() -> new RuntimeException("No word found for level: " + level));
    }
}
