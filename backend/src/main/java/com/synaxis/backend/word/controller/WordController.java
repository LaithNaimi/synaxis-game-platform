package com.synaxis.backend.word.controller;

import com.synaxis.backend.word.model.Word;
import com.synaxis.backend.word.service.WordService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("api/words")
public class WordController {

    private final WordService wordService;

    @GetMapping("/random")
    public Word getRandomWord(@RequestParam String level) {
        return wordService.getRandomWord(level);
    }
}
