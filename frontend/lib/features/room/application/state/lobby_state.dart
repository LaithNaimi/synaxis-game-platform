import '../../data/models/player_model.dart';
import '../../presentation/widgets/live_feed_card.dart';

class LobbyState {
  const LobbyState({
    this.players = const [],
    this.feedMessages = const [],
    this.isConnected = false,
    this.isStarting = false,
    this.gameStarted = false,
    this.roundNumber = 0,
    this.roundStarted = false,
    this.error,
  });

  final List<PlayerModel> players;
  final List<LiveFeedEntry> feedMessages;
  final bool isConnected;

  /// True while waiting for the server to confirm start.
  final bool isStarting;

  /// True once GAME_STARTED event is received — triggers navigation to countdown.
  final bool gameStarted;

  /// Current round number (set by ROUND_COUNTDOWN_STARTED).
  final int roundNumber;

  /// True once ROUND_STARTED is received — triggers navigation to game.
  final bool roundStarted;

  final String? error;

  LobbyState copyWith({
    List<PlayerModel>? players,
    List<LiveFeedEntry>? feedMessages,
    bool? isConnected,
    bool? isStarting,
    bool? gameStarted,
    int? roundNumber,
    bool? roundStarted,
    String? Function()? error,
  }) {
    return LobbyState(
      players: players ?? this.players,
      feedMessages: feedMessages ?? this.feedMessages,
      isConnected: isConnected ?? this.isConnected,
      isStarting: isStarting ?? this.isStarting,
      gameStarted: gameStarted ?? this.gameStarted,
      roundNumber: roundNumber ?? this.roundNumber,
      roundStarted: roundStarted ?? this.roundStarted,
      error: error != null ? error() : this.error,
    );
  }
}
