package com.synaxis.backend.room.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ReconnectRoomRequest {

    @NotBlank(message = "must not be blank")
    private String playerId;

    @NotBlank(message = "must not be blank")
    private String playerToken;
}