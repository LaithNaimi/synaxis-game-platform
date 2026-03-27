package com.synaxis.backend.room.service;

import org.springframework.stereotype.Component;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.ReentrantLock;
import java.util.function.Supplier;

@Component
public class RoomLockManager {

    private final ConcurrentHashMap<String, ReentrantLock> roomLocks = new ConcurrentHashMap<>();

    public void executeWithRoomLock(String roomCode, Runnable action) {
        ReentrantLock lock = roomLocks.computeIfAbsent(roomCode, key -> new ReentrantLock());
        lock.lock();
        try {
            action.run();
        } finally {
            lock.unlock();
        }
    }

    public <T> T executeWithRoomLock(String roomCode, Supplier<T> action) {
        ReentrantLock lock = roomLocks.computeIfAbsent(roomCode, key -> new ReentrantLock());
        lock.lock();
        try {
            return action.get();
        } finally {
            lock.unlock();
        }
    }

    public void removeLock(String roomCode) {
        roomLocks.remove(roomCode);
    }
}