package com.synaxis.backend.match.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class HealthUpdateResult {

    private final int healthDelta;
    private final int updatedHealth;
    private final boolean reachedZero;
}
