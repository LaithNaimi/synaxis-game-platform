import 'player_model.dart';
import 'room_settings_model.dart';

/// The `data` payload returned by both POST /rooms and POST /rooms/{code}/join.
class RoomSessionModel {
  const RoomSessionModel({
    required this.roomCode,
    required this.playerId,
    required this.playerName,
    required this.playerToken,
    required this.roomState,
    required this.roomSettings,
    required this.players,
    required this.host,
  });

  final String roomCode;
  final String playerId;
  final String playerName;
  final String playerToken;
  final String roomState;
  final RoomSettingsModel roomSettings;
  final List<PlayerModel> players;
  final bool host;

  factory RoomSessionModel.fromJson(Map<String, dynamic> json) {
    return RoomSessionModel(
      roomCode: json['roomCode'] as String,
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      playerToken: json['playerToken'] as String,
      roomState: json['roomState'] as String,
      roomSettings: RoomSettingsModel.fromJson(
        json['roomSettings'] as Map<String, dynamic>,
      ),
      players: (json['players'] as List<dynamic>)
          .map((e) => PlayerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      host: json['host'] as bool,
    );
  }
}
