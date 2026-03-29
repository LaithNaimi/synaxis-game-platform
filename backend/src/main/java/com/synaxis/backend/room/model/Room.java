package com.synaxis.backend.room.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Room {

    private String roomCode;
    private RoomStatus status;
    private RoomSettings settings;

    @Builder.Default
    private List<PlayerSession> players = new ArrayList<>();

    public void addPlayer(PlayerSession player) {
        this.players.add(player);
    }

    public boolean isFull(){
        return players.size() >= this.settings.getMaxPlayers();
    }

    public int playerCount(){
        return players.size();
    }

    public PlayerSession findPlayerById(String playerId) {
        return players.stream()
                .filter(player -> player.getPlayerId().equals(playerId))
                .findFirst()
                .orElse(null);
    }

    public void removePlayerById(String playerId) {
        players.removeIf(player -> player.getPlayerId().equals(playerId));
    }

    public boolean isEmpty() {
        return players.isEmpty();
    }

    public PlayerSession getHostPlayer() {
        return players.stream()
                .filter(PlayerSession::isHost)
                .findFirst()
                .orElse(null);
    }

    public void assignHostToFirstPlayerIfNeeded() {
        if (players.isEmpty()) {
            return;
        }
        boolean hasHost = players.stream().anyMatch(PlayerSession::isHost);
        if (!hasHost) {
            players.getFirst().setHost(true);
        }
    }

    public void markPlayerConnected(String playerId) {
        PlayerSession player = findPlayerById(playerId);
        if (player != null) {
            player.setConnected(true);
        }
    }
}