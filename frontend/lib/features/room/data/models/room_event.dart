import 'player_model.dart';

/// Base for all room-scoped STOMP events on `/topic/room/{code}`.
sealed class RoomEvent {
  const RoomEvent({required this.type, required this.roomCode});

  final String type;
  final String roomCode;

  /// Dispatches to the correct subclass based on the `type` field.
  factory RoomEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'PLAYER_JOINED' => PlayerJoinedEvent.fromJson(json),
      'PLAYER_LEAVE' => PlayerLeaveEvent.fromJson(json),
      _ => UnknownRoomEvent.fromJson(json),
    };
  }
}

class PlayerJoinedEvent extends RoomEvent {
  const PlayerJoinedEvent({
    required super.type,
    required super.roomCode,
    required this.player,
  });

  final PlayerModel player;

  factory PlayerJoinedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerJoinedEvent(
      type: json['type'] as String,
      roomCode: json['roomCode'] as String,
      player: PlayerModel(
        playerId: json['playerId'] as String,
        playerName: json['playerName'] as String,
        host: json['host'] as bool,
      ),
    );
  }
}

class PlayerLeaveEvent extends RoomEvent {
  const PlayerLeaveEvent({
    required super.type,
    required super.roomCode,
    required this.leavingPlayerId,
    required this.hostPlayerId,
  });

  final String leavingPlayerId;

  /// The current host after the leave — may differ from before if the leaver was host.
  final String hostPlayerId;

  factory PlayerLeaveEvent.fromJson(Map<String, dynamic> json) {
    return PlayerLeaveEvent(
      type: json['type'] as String,
      roomCode: json['roomCode'] as String,
      leavingPlayerId: json['leavingPlayerId'] as String,
      hostPlayerId: json['hostPlayerId'] as String,
    );
  }
}

class UnknownRoomEvent extends RoomEvent {
  const UnknownRoomEvent({required super.type, required super.roomCode});

  factory UnknownRoomEvent.fromJson(Map<String, dynamic> json) {
    return UnknownRoomEvent(
      type: json['type'] as String,
      roomCode: json['roomCode'] as String,
    );
  }
}
