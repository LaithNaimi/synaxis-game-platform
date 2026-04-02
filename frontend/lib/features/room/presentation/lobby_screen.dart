import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/websocket_client.dart';
import '../../../shared/models/player_summary_model.dart';
import '../data/lobby_event_handler.dart';
import '../data/room_live_state_model.dart';
import '../data/room_live_state_provider.dart';
import '../data/room_session_provider.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  final WebSocketClient _ws = WebSocketClient();
  bool _connected = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(roomSessionProvider);
      if (session == null) return;

      ref
          .read(roomLiveStateProvider.notifier)
          .setInitial(
            RoomLiveStateModel(players: session.players, gameStarted: false),
          );

      _connectWebSocket(session.roomCode);
    });
  }

  void _connectWebSocket(String roomCode) {
    if (_connected) return;

    _ws.connect(
      onConnect: (_) {
        _connected = true;

        _ws.subscribe("/topic/room/$roomCode", (frame) {
          if (frame.body == null) return;

          final body = jsonDecode(frame.body!);
          final type = body["type"];

          final liveState = ref.read(roomLiveStateProvider);
          if (liveState == null) return;

          if (type == "PLAYER_JOINED") {
            final updated = LobbyEventHandler.handlePlayerJoined(
              liveState.players,
              body,
            );
            ref.read(roomLiveStateProvider.notifier).setPlayers(updated);
          }

          if (type == "PLAYER_REMOVED_AFTER_DISCONNECT") {
            final updated = LobbyEventHandler.handlePlayerRemoved(
              liveState.players,
              body,
            );
            ref.read(roomLiveStateProvider.notifier).setPlayers(updated);
          }

          if (type == "HOST_TRANSFERRED") {
            final updated = LobbyEventHandler.handleHostTransferred(
              liveState.players,
              body,
            );
            ref.read(roomLiveStateProvider.notifier).setPlayers(updated);
          }

          if (type == "GAME_STARTED") {
            ref.read(roomLiveStateProvider.notifier).markGameStarted();
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _ws.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(roomSessionProvider);
    final liveState = ref.watch(roomLiveStateProvider);

    if (session == null) {
      return const Scaffold(body: Center(child: Text("No room session found")));
    }

    final players = liveState?.players ?? session.players;
    final gameStarted = liveState?.gameStarted ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text("Lobby")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Room Code: ${session.roomCode}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              "You: ${session.player.playerName}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text("Host: ${session.player.isHost ? "Yes" : "No"}"),
            const SizedBox(height: 12),
            Text("Game Started: ${gameStarted ? "Yes" : "No"}"),
            const SizedBox(height: 24),
            const Text(
              "Players",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return ListTile(
                    title: Text(player.playerName),
                    subtitle: Text(player.playerId),
                    trailing: player.isHost
                        ? const Text("Host")
                        : const SizedBox.shrink(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
