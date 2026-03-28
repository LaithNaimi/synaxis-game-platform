package com.synaxis.backend.room.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class JoinRoomRequest {

    @NotBlank(message = "must not be blank")
    @Size(max = 20, message = "must not exceed 20 characters")
    private String playerName;
}