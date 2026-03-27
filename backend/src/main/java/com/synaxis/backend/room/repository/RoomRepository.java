package com.synaxis.backend.room.repository;

import com.synaxis.backend.room.model.Room;

import java.util.List;
import java.util.Optional;

public interface RoomRepository {

    Room save(Room room);

    Optional<Room> findByCode(String roomCode);

    boolean existsByCode(String roomCode);

    void deleteByCode(String roomCode);

    List<Room> findAll();
}