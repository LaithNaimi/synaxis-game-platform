import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../room/data/room_session_provider.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(roomSessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Game")),
      body: Center(
        child: Text(
          "Game Started!\nPlayer: ${session?.player.playerName}",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
