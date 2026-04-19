import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_handler.dart' show StompUnsubscribe;

import '../../../../core/network/websocket_client.dart';
import '../../../../core/network/ws_destinations.dart';
import '../../data/models/player_model.dart';
import '../../data/models/room_event.dart';
import '../../data/models/room_session_model.dart';
import '../../presentation/widgets/live_feed_card.dart';
import '../state/lobby_state.dart';

class LobbyController extends Notifier<LobbyState> {
  WebSocketClient? _ws;
  StompUnsubscribe? _unsubscribe;
  RoomSessionModel? _session;

  @override
  LobbyState build() => const LobbyState();

  void init(RoomSessionModel session) {
    _session = session;
    final seedFeed = session.players
        .map((p) => LiveFeedEntry(
              text: '${p.playerName} is in the room.',
              isSystem: true,
            ))
        .toList();
    state = LobbyState(
      players: List.of(session.players),
      feedMessages: seedFeed,
    );
    _connectWebSocket();
  }

  void _connectWebSocket() {
    final session = _session;
    if (session == null) return;

    _ws = WebSocketClient();
    _ws!.connect(
      onConnected: () {
        state = state.copyWith(isConnected: true, error: () => null);
        _unsubscribe = _ws!.subscribe(
          destination: WsDestinations.roomTopic(session.roomCode),
          callback: _onFrame,
        );
      },
      onWebSocketError: (error) {
        state = state.copyWith(
          isConnected: false,
          error: () => 'Connection lost',
        );
      },
    );
  }

  void _onFrame(dynamic frame) {
    // StompFrame has a `body` field (String?).
    final body = (frame as dynamic).body as String?;
    if (body == null) return;

    final json = jsonDecode(body) as Map<String, dynamic>;
    final event = RoomEvent.fromJson(json);

    switch (event) {
      case PlayerJoinedEvent(:final player):
        _handlePlayerJoined(player);
      case PlayerLeaveEvent(:final leavingPlayerId, :final hostPlayerId):
        _handlePlayerLeave(leavingPlayerId, hostPlayerId);
      case GameStartedEvent():
        state = state.copyWith(gameStarted: true, isStarting: false);
      case RoundCountdownStartedEvent(:final roundNumber):
        state = state.copyWith(roundNumber: roundNumber, roundStarted: false);
      case RoundStartedEvent():
        state = state.copyWith(roundStarted: true);
      case UnknownRoomEvent():
        break;
    }
  }

  void _handlePlayerJoined(PlayerModel player) {
    final exists = state.players.any((p) => p.playerId == player.playerId);
    if (exists) return;
    state = state.copyWith(
      players: [...state.players, player],
      feedMessages: [
        ...state.feedMessages,
        LiveFeedEntry(
          text: '${player.playerName} has joined the room.',
          isSystem: true,
        ),
      ],
    );
  }

  void _handlePlayerLeave(String leavingPlayerId, String hostPlayerId) {
    final leaver = state.players.where((p) => p.playerId == leavingPlayerId).firstOrNull;
    final updated = state.players
        .where((p) => p.playerId != leavingPlayerId)
        .map(
          (p) => PlayerModel(
            playerId: p.playerId,
            playerName: p.playerName,
            host: p.playerId == hostPlayerId,
          ),
        )
        .toList();
    state = state.copyWith(
      players: updated,
      feedMessages: [
        ...state.feedMessages,
        LiveFeedEntry(
          text: '${leaver?.playerName ?? 'A player'} has left the room.',
          isSystem: true,
        ),
      ],
    );
  }

  /// Host sends the start-game command via STOMP.
  /// Sets `isStarting` while waiting; `GAME_STARTED` event sets `gameStarted`.
  void startGame() {
    final session = _session;
    if (session == null || _ws == null || !_ws!.connected) return;

    state = state.copyWith(isStarting: true, error: () => null);
    _ws!.sendJson(
      destination: WsDestinations.startGameCommand(),
      body: {
        'roomCode': session.roomCode,
        'playerId': session.playerId,
        'playerToken': session.playerToken,
      },
    );
  }

  /// Tear down WS — call before navigating away from the lobby.
  void disconnect() {
    _unsubscribe?.call(unsubscribeHeaders: {});
    _unsubscribe = null;
    _ws?.disconnect();
    _ws = null;
    state = const LobbyState();
  }
}
