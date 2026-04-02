import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synaxis/shared/models/player_summary_model.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/player_session_model.dart';
import '../../../shared/models/room_session_model.dart';
import '../data/room_api.dart';
import '../data/room_session_provider.dart';
import 'lobby_screen.dart';

class JoinCreateScreen extends ConsumerStatefulWidget {
  const JoinCreateScreen({super.key});

  @override
  ConsumerState<JoinCreateScreen> createState() => _JoinCreateScreenState();
}

class _JoinCreateScreenState extends ConsumerState<JoinCreateScreen> {
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();

  final _api = RoomApi(ApiClient());

  bool _loading = false;

  Future<void> _createRoom() async {
    setState(() => _loading = true);

    try {
      final result = await _api.createRoom(
        playerName: _nameController.text,
        cefrLevel: "A1",
        maxPlayers: 2,
        totalRounds: 3,
        roundDurationSeconds: 30,
      );

      final data = result["data"];

      final playersJson = (data["players"] as List<dynamic>? ?? []);

      final players = playersJson
          .map(
            (p) => PlayerSummaryModel(
              playerId: p["playerId"],
              playerName: p["playerName"],
              isHost: p["host"] ?? p["isHost"] ?? false,
            ),
          )
          .toList();

      final session = RoomSessionModel(
        roomCode: data["roomCode"],
        player: PlayerSessionModel(
          playerId: data["playerId"],
          playerName: data["playerName"],
          playerToken: data["playerToken"],
          isHost: data["host"] ?? data["isHost"] ?? true,
        ),
        players: players,
      );

      ref.read(roomSessionProvider.notifier).setSession(session);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LobbyScreen()),
      );
    } catch (e) {
      print("ERROR: $e");
      _showMessage("Error creating room");
    }

    setState(() => _loading = false);
  }

  Future<void> _joinRoom() async {
    setState(() => _loading = true);

    try {
      final result = await _api.joinRoom(
        _roomController.text,
        _nameController.text,
      );

      final data = result["data"];
      final playersJson = (data["players"] as List<dynamic>? ?? []);

      final players = playersJson
          .map(
            (p) => PlayerSummaryModel(
              playerId: p["playerId"],
              playerName: p["playerName"],
              isHost: p["host"] ?? p["isHost"] ?? false,
            ),
          )
          .toList();

      final session = RoomSessionModel(
        roomCode: data["roomCode"],
        player: PlayerSessionModel(
          playerId: data["playerId"],
          playerName: data["playerName"],
          playerToken: data["playerToken"],
          isHost: data["host"] ?? data["isHost"] ?? false,
        ),
        players: players,
      );

      ref.read(roomSessionProvider.notifier).setSession(session);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LobbyScreen()),
      );
    } catch (e) {
      print("ERROR: $e");
      _showMessage("Error joining room");
    }

    setState(() => _loading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Synaxis")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Player Name"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _createRoom,
              child: const Text("Create Room"),
            ),
            const Divider(height: 32),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: "Room Code"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _joinRoom,
              child: const Text("Join Room"),
            ),
          ],
        ),
      ),
    );
  }
}
