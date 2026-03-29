package com.synaxis.backend.match.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MatchState {

    private int totalRounds;
    private int currentRoundNumber;
    private MatchStatus status;

    @Builder.Default
    private List<RoundWord> selectedWords = new ArrayList<>();
}