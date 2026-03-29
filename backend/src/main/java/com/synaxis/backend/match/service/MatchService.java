package com.synaxis.backend.match.service;

import com.synaxis.backend.match.model.MatchState;
import com.synaxis.backend.match.model.MatchStatus;
import com.synaxis.backend.room.model.Room;
import org.springframework.stereotype.Service;

@Service
public class MatchService {

    public MatchState createMatchState(Room room) {
        room.initializePlayersForMatch();

        return MatchState.builder()
                .totalRounds(room.getSettings().getTotalRounds())
                .currentRoundNumber(0)
                .status(MatchStatus.NOT_STARTED)
                .build();
    }
}