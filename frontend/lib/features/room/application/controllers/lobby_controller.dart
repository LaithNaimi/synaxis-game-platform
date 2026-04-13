import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_handler.dart' show StompUnsubscribe;

import '../../../../core/network/websocket_client.dart';
import '../../../../core/network/ws_destinations.dart';
import '../../data/models/player_model.dart';
import '../../data/models/room_event.dart';
import '../../data/models/room_session_model.dart';
import '../state/lobby_state.dart';

class LobbyController extends Notifier<LobbyState> {
  WebSocketClient? _ws;
  StompUnsubscribe? _unsubscribe;
  RoomSessionModel? _session;

  @override
  LobbyState build() => const LobbyState();

  void init(RoomSessionModel session) {
    _session = session;
    state = LobbyState(players: List.of(session.players));
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
      case UnknownRoomEvent():
        break;
    }
  }

  void _handlePlayerJoined(PlayerModel player) {
    final exists = state.players.any((p) => p.playerId == player.playerId);
    if (exists) return;
    state = state.copyWith(players: [...state.players, player]);
  }

  void _handlePlayerLeave(String leavingPlayerId, String hostPlayerId) {
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
    state = state.copyWith(players: updated);
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
