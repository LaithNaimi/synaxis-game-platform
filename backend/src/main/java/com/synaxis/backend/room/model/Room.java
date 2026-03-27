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
}