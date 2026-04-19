class LeaveRoomRequest {
  const LeaveRoomRequest({
    required this.playerId,
    required this.playerToken,
  });

  final String playerId;
  final String playerToken;

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'playerToken': playerToken,
      };
}
