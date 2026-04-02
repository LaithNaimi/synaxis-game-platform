import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/room_session_provider.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(roomSessionProvider);

    if (session == null) {
      return const Scaffold(body: Center(child: Text("No room session found")));
    }

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
              "Player: ${session.player.playerName}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text("Player ID: ${session.player.playerId}"),
            const SizedBox(height: 12),
            Text("Host: ${session.player.isHost ? "Yes" : "No"}"),
          ],
        ),
      ),
    );
  }
}
