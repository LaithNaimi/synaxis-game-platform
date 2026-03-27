package com.synaxis.backend.word.repository;

import com.synaxis.backend.word.model.Word;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface WordRepository extends JpaRepository<Word, String> {
    List<Word> findByCefrLevelAndIsActiveTrue(String cefrLevel);

    Optional<Word> findByWord(String word);

    @Query(value = "SELECT * FROM words WHERE cefr_level = :level AND is_active = true ORDER BY RANDOM() LIMIT 1", nativeQuery = true)
    Optional<Word> findRandomByLevel(String level);
}
