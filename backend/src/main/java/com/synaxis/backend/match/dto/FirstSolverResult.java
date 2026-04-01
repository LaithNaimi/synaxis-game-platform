package com.synaxis.backend.match.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.Instant;

@Getter
@AllArgsConstructor
public class FirstSolverResult {
    private final boolean firstSolver;
    private final boolean suddenDeathStarted;
    private final Instant suddenDeathAt;
}

