import 'player_model.dart';

sealed class RoomEvent {
  const RoomEvent({required this.type, this.roomCode = ''});

  final String type;
  final String roomCode;

  factory RoomEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'PLAYER_JOINED' => PlayerJoinedEvent.fromJson(json),
      'PLAYER_LEAVE' => PlayerLeaveEvent.fromJson(json),
      'GAME_STARTED' => GameStartedEvent.fromJson(json),
      'ROUND_COUNTDOWN_STARTED' => RoundCountdownStartedEvent.fromJson(json),
      'ROUND_STARTED' => RoundStartedEvent.fromJson(json),
      'PLAYER_ROUND_STATE' ||
      'LETTER_GUESS_RESULT' ||
      'PLAYER_STUNNED' ||
      'PLAYER_RECOVERED' ||
      'PLAYER_SOLVED_WORD' ||
      'SUDDEN_DEATH_STARTED' ||
      'SUDDEN_DEATH_ENDED' ||
      'ROUND_TIMEOUT' ||
      'LEARNING_REVEAL' ||
      'ROUND_LEADERBOARD' ||
      'MATCH_FINISHED' ||
      'FINAL_LEADERBOARD' =>
        GameEvent(type: type, roomCode: json['roomCode'] as String? ?? '', raw: json),
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

class GameStartedEvent extends RoomEvent {
  const GameStartedEvent({required super.type, required super.roomCode});

  factory GameStartedEvent.fromJson(Map<String, dynamic> json) {
    return GameStartedEvent(
      type: json['type'] as String,
      roomCode: json['roomCode'] as String,
    );
  }
}

class RoundCountdownStartedEvent extends RoomEvent {
  const RoundCountdownStartedEvent({
    required super.type,
    required super.roomCode,
    required this.roundNumber,
  });

  final int roundNumber;

  factory RoundCountdownStartedEvent.fromJson(Map<String, dynamic> json) {
    return RoundCountdownStartedEvent(
      type: json['type'] as String,
      roomCode: json['roomCode'] as String? ?? '',
      roundNumber: json['roundNumber'] as int,
    );
  }
}

class RoundStartedEvent extends RoomEvent {
  const RoundStartedEvent({
    required super.type,
    super.roomCode,
    required this.roundNumber,
    required this.maskedWord,
  });

  final int roundNumber;
  final String maskedWord;

  factory RoundStartedEvent.fromJson(Map<String, dynamic> json) {
    return RoundStartedEvent(
      type: json['type'] as String,
      roomCode: json['roomCode'] as String? ?? '',
      roundNumber: json['roundNumber'] as int,
      maskedWord: json['maskedWord'] as String? ?? '',
    );
  }
}

/// Wraps all in-game events (round topic + private queue) with raw JSON
/// so the GameController can handle them without duplicating parsing here.
class GameEvent extends RoomEvent {
  const GameEvent({
    required super.type,
    super.roomCode,
    required this.raw,
  });

  final Map<String, dynamic> raw;
}

class UnknownRoomEvent extends RoomEvent {
  const UnknownRoomEvent({required super.type, super.roomCode});

  factory UnknownRoomEvent.fromJson(Map<String, dynamic> json) {
    return UnknownRoomEvent(
      type: json['type'] as String,
      roomCode: json['roomCode'] as String? ?? '',
    );
  }
}
