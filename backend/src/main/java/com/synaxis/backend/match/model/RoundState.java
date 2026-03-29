package com.synaxis.backend.match.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RoundState {

    private int roundNumber;
    private RoundWord roundWord;
    private RoundStatus status;
    private String firstSolverPlayerId;

    public void startCountdown() {
        requireStatus(RoundStatus.PREPARING);
        this.status = RoundStatus.COUNTDOWN;
    }

    public void activate() {
        requireStatus(RoundStatus.COUNTDOWN);
        this.status = RoundStatus.ACTIVE;
    }

    public void enterSuddenDeath(String firstSolverPlayerId) {
        requireStatus(RoundStatus.ACTIVE);
        this.firstSolverPlayerId = firstSolverPlayerId;
        this.status = RoundStatus.SUDDEN_DEATH;
    }

    public void showLearningReveal() {
        if (this.status != RoundStatus.ACTIVE && this.status != RoundStatus.SUDDEN_DEATH) {
            throw new IllegalStateException("Round can enter learning reveal only from ACTIVE or SUDDEN_DEATH");
        }
        this.status = RoundStatus.LEARNING_REVEAL;
    }

    public void showRoundResults() {
        requireStatus(RoundStatus.LEARNING_REVEAL);
        this.status = RoundStatus.ROUND_RESULTS;
    }

    public void complete() {
        requireStatus(RoundStatus.ROUND_RESULTS);
        this.status = RoundStatus.COMPLETED;
    }

    private void requireStatus(RoundStatus expected) {
        if (this.status != expected) {
            throw new IllegalStateException(
                    "Invalid round state transition. Expected: " + expected + ", but was: " + this.status
            );
        }
    }
}