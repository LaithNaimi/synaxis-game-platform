package com.synaxis.backend.match.service;

import com.synaxis.backend.match.dto.FinalLeaderboardPayload;
import com.synaxis.backend.match.dto.LeaderBoardEntry;
import com.synaxis.backend.match.dto.RoundLeaderboardPayload;
import com.synaxis.backend.room.model.PlayerSession;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@Service
public class LeaderboardService {

    public RoundLeaderboardPayload buildRoundLeaderboard(int roundNumber , List<PlayerSession> players){
        return new RoundLeaderboardPayload(
                roundNumber,
                rankPlayers(players)
        );
    }

    public FinalLeaderboardPayload buildFinalLeaderboard(List<PlayerSession> players){
        return new FinalLeaderboardPayload(
                rankPlayers(players)
        );
    }

    private List<LeaderBoardEntry> rankPlayers(List<PlayerSession> players){
        List<PlayerSession> sortedPlayers = new ArrayList<>(players);

        sortedPlayers.sort(
                Comparator.comparingInt(PlayerSession::getScore).reversed()
                        .thenComparing(Comparator.comparingInt(PlayerSession::getHealth).reversed())
                        .thenComparingLong(PlayerSession::getTotalSolveTimeMs)
        );

        List<LeaderBoardEntry> leaderboardEntries = new ArrayList<>();

        for(int i = 0; i < sortedPlayers.size(); i++){
            PlayerSession player = sortedPlayers.get(i);

            leaderboardEntries.add(new LeaderBoardEntry(
                    player.getPlayerId(),
                    player.getPlayerName(),
                    player.getScore(),
                    player.getHealth(),
                    player.getTotalSolveTimeMs(),
                    i + 1
            ));
        }

        return leaderboardEntries;
    }
}
