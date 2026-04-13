import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/lobby_controller.dart';
import '../state/lobby_state.dart';

/// Live lobby state — player list, WS connection status.
final lobbyControllerProvider =
    NotifierProvider<LobbyController, LobbyState>(
  LobbyController.new,
);
