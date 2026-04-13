class CreateRoomRequest {
  const CreateRoomRequest({
    required this.playerName,
    required this.cefrLevel,
    required this.maxPlayers,
    required this.totalRounds,
    required this.roundDurationSeconds,
  });

  final String playerName;
  final String cefrLevel;
  final int maxPlayers;
  final int totalRounds;
  final int roundDurationSeconds;

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'cefrLevel': cefrLevel,
        'maxPlayers': maxPlayers,
        'totalRounds': totalRounds,
        'roundDurationSeconds': roundDurationSeconds,
      };
}
