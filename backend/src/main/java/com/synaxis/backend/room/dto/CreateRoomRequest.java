package com.synaxis.backend.room.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CreateRoomRequest {

    @NotBlank(message = "must not be blank")
    @Size(max = 20, message = "must not exceed 20 characters")
    private String playerName;

    @NotBlank(message = "must not be blank")
    private String cefrLevel;

    @Min(value = 2, message = "must be at least 2")
    @Max(value = 8, message = "must not exceed 8")
    private int maxPlayers;

    @Min(value = 1, message = "must be at least 1")
    @Max(value = 10, message = "must not exceed 10")
    private int totalRounds;

    @Min(value = 15, message = "must be at least 15 seconds")
    @Max(value = 180, message = "must not exceed 180 seconds")
    private int roundDurationSeconds;
}