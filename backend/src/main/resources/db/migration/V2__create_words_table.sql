CREATE TABLE words (
                       id BIGSERIAL PRIMARY KEY,
                       word VARCHAR(100) NOT NULL,
                       cefr_level VARCHAR(10) NOT NULL,
                       arabic_meaning TEXT NOT NULL,
                       english_definition TEXT NOT NULL,
                       is_active BOOLEAN NOT NULL DEFAULT TRUE,
                       created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uq_words_word ON words (word);

CREATE INDEX idx_words_cefr_level ON words (cefr_level);

CREATE INDEX idx_words_is_active ON words (is_active);