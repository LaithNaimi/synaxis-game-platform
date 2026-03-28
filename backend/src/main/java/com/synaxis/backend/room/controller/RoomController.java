package com.synaxis.backend.room.controller;

import com.synaxis.backend.common.dto.ApiSuccessResponse;
import com.synaxis.backend.room.dto.CreateRoomRequest;
import com.synaxis.backend.room.dto.CreateRoomResponse;
import com.synaxis.backend.room.model.Room;
import com.synaxis.backend.room.service.RoomService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/v1/rooms")
public class RoomController {

    private final RoomService roomService;
    @PostMapping("/create")
    public ResponseEntity<ApiSuccessResponse<CreateRoomResponse>> createRoom(@Valid @RequestBody CreateRoomRequest request) {
        return ResponseEntity.ok(ApiSuccessResponse.success(roomService.createRoom(request)));
    }
}