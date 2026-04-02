import '../../../shared/models/player_summary_model.dart';

class LobbyEventHandler {
  static List<PlayerSummaryModel> handlePlayerJoined(
    List<PlayerSummaryModel> currentPlayers,
    Map<String, dynamic> body,
  ) {
    final player = PlayerSummaryModel(
      playerId: body["playerId"],
      playerName: body["playerName"],
      isHost: body["host"] ?? body["isHost"] ?? false,
    );

    final exists = currentPlayers.any((p) => p.playerId == player.playerId);
    if (exists) return currentPlayers;

    return [...currentPlayers, player];
  }

  static List<PlayerSummaryModel> handlePlayerRemoved(
    List<PlayerSummaryModel> currentPlayers,
    Map<String, dynamic> body,
  ) {
    final playerId = body["playerId"];
    return currentPlayers.where((p) => p.playerId != playerId).toList();
  }

  static List<PlayerSummaryModel> handleHostTransferred(
    List<PlayerSummaryModel> currentPlayers,
    Map<String, dynamic> body,
  ) {
    final newHostId = body["newHostPlayerId"];

    return currentPlayers
        .map(
          (p) => PlayerSummaryModel(
            playerId: p.playerId,
            playerName: p.playerName,
            isHost: p.playerId == newHostId,
          ),
        )
        .toList();
  }
}
