package com.synaxis.backend.room.controller;

import com.synaxis.backend.common.dto.ApiSuccessResponse;
import com.synaxis.backend.room.dto.*;
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

    @PostMapping("/{roomCode}/leave")
    public ResponseEntity<?> leaveRoom(
            @PathVariable String roomCode,
            @Valid @RequestBody LeaveRoomRequest request
    ){
        roomService.leaveRoom(roomCode, request);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{roomCode}/reconnect")
    public ResponseEntity<ApiSuccessResponse<ReconnectRoomResponse>> reconnectRoom(
            @PathVariable String roomCode,
            @Valid @RequestBody ReconnectRoomRequest request
    ) {
        ReconnectRoomResponse response = roomService.reconnectRoom(roomCode, request);
        return ResponseEntity.ok(ApiSuccessResponse.success(response));
    }
}