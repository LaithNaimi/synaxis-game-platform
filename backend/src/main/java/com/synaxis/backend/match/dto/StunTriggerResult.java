package com.synaxis.backend.match.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.Instant;

@Getter
@AllArgsConstructor
public class StunTriggerResult {

    private final boolean stunned;
    private final Instant stunnedUntil;
}
