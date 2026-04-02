import '../../../shared/models/player_summary_model.dart';

class RoomLiveStateModel {
  final List<PlayerSummaryModel> players;
  final bool gameStarted;

  const RoomLiveStateModel({required this.players, required this.gameStarted});

  RoomLiveStateModel copyWith({
    List<PlayerSummaryModel>? players,
    bool? gameStarted,
  }) {
    return RoomLiveStateModel(
      players: players ?? this.players,
      gameStarted: gameStarted ?? this.gameStarted,
    );
  }
}
