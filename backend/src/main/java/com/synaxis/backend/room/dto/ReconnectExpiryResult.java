package com.synaxis.backend.room.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ReconnectExpiryResult {

    private final boolean expired;
}
