import 'player_session_model.dart';

class RoomSessionModel {
  final String roomCode;
  final PlayerSessionModel player;

  const RoomSessionModel({required this.roomCode, required this.player});
}
