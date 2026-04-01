package com.synaxis.backend.match.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class FinalLeaderboardPayload {

    private final List<LeaderBoardEntry> entries;
}
