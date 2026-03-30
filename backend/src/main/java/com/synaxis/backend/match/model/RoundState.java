package com.synaxis.backend.match.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

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
    private Instant startedAt;
    private Instant timeoutAt;

    public void startCountdown() {
        requireStatus(RoundStatus.PREPARING);
        this.status = RoundStatus.COUNTDOWN;
    }

    public void activate(Instant startedAt, Instant timeoutAt) {
        requireStatus(RoundStatus.COUNTDOWN);
        this.startedAt = startedAt;
        this.timeoutAt = timeoutAt;
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

    public boolean isTimeout(Instant now) {
        return this.timeoutAt != null && now.isAfter(this.timeoutAt);

    }

    public boolean isAcceptingGuesses(){
         return this.status == RoundStatus.ACTIVE;
    }
    private void requireStatus(RoundStatus expected) {
        if (this.status != expected) {
            throw new IllegalStateException(
                    "Invalid round state transition. Expected: " + expected + ", but was: " + this.status
            );
        }
    }
}