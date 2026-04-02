class PlayerSessionModel {
  final String playerId;
  final String playerName;
  final String playerToken;
  final bool isHost;

  const PlayerSessionModel({
    required this.playerId,
    required this.playerName,
    required this.playerToken,
    required this.isHost,
  });
}
