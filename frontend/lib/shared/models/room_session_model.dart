import 'package:synaxis/shared/models/player_summary_model.dart';

import 'player_session_model.dart';

class RoomSessionModel {
  final String roomCode;
  final PlayerSessionModel player;
  final List<PlayerSummaryModel> players;

  const RoomSessionModel({
    required this.roomCode,
    required this.player,
    required this.players,
  });
}
