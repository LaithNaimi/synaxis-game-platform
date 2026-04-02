class PlayerSummaryModel {
  final String playerId;
  final String playerName;
  final bool isHost;

  const PlayerSummaryModel({
    required this.playerId,
    required this.playerName,
    required this.isHost,
  });
}
