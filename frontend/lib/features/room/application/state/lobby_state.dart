import '../../data/models/player_model.dart';

class LobbyState {
  const LobbyState({
    this.players = const [],
    this.isConnected = false,
    this.error,
  });

  final List<PlayerModel> players;
  final bool isConnected;
  final String? error;

  LobbyState copyWith({
    List<PlayerModel>? players,
    bool? isConnected,
    String? Function()? error,
  }) {
    return LobbyState(
      players: players ?? this.players,
      isConnected: isConnected ?? this.isConnected,
      error: error != null ? error() : this.error,
    );
  }
}
