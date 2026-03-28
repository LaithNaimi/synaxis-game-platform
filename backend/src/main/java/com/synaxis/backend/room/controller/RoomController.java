package com.synaxis.backend.room.controller;

import com.synaxis.backend.common.dto.ApiSuccessResponse;
import com.synaxis.backend.room.dto.CreateRoomRequest;
import com.synaxis.backend.room.dto.CreateRoomResponse;
import com.synaxis.backend.room.dto.JoinRoomRequest;
import com.synaxis.backend.room.dto.JoinRoomResponse;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.room.service.RoomService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/room")
public class RoomController {

    private final RoomService roomService;
    @PostMapping
    public ResponseEntity<ApiSuccessResponse<CreateRoomResponse>> createRoom(@Valid @RequestBody CreateRoomRequest request) {
        return ResponseEntity.ok(ApiSuccessResponse.success(roomService.createRoom(request)));
    }

    @PostMapping("/{roomCode}/join")
    public ResponseEntity<ApiSuccessResponse<JoinRoomResponse>> joinRoom(
            @PathVariable String roomCode,
            @Valid @RequestBody JoinRoomRequest request
    ) {
        return ResponseEntity.ok(ApiSuccessResponse.success(roomService.joinRoom(roomCode, request)));
    }
}