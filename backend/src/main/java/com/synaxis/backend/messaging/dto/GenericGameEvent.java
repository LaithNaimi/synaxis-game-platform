package com.synaxis.backend.messaging.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class GenericGameEvent {

    private String type;
    private String roomCode;
    private int roundNumber;
}
