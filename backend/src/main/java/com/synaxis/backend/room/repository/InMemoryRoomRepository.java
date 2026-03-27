package com.synaxis.backend.room.repository;

import com.synaxis.backend.room.model.Room;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class InMemoryRoomRepository implements RoomRepository{

    private final ConcurrentHashMap<String, Room> rooms = new ConcurrentHashMap<>();

    @Override
    public Room save(Room room) {
        rooms.put(room.getRoomCode(), room);
        return room;
    }

    @Override
    public Optional<Room> findByCode(String roomCode) {

        return Optional.ofNullable(rooms.get(roomCode));
    }

    @Override
    public boolean existsByCode(String roomCode) {
        return rooms.containsKey(roomCode);
    }

    @Override
    public List<Room> findAll() {
        return new ArrayList<>(rooms.values());
    }

    @Override
    public void deleteByCode(String roomCode) {
        rooms.remove(roomCode);
    }

}
