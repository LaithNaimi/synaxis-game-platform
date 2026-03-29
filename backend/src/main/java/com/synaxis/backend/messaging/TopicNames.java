package com.synaxis.backend.messaging;

public final class TopicNames {

    private TopicNames() {
    }

    public static String roomTopic(String roomCode) {
        return "/topic/rooms/" + roomCode;
    }

    public static String roomRoundTopic(String roomCode) {
        return "/topic/rooms/" + roomCode + "/round";
    }

    public static String roomLeaderboardTopic(String roomCode) {
        return "/topic/rooms/" + roomCode + "/leaderboard";
    }

    public static String userGameQueue() {
        return "/queue/game";
    }
}
