import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'room_live_state_model.dart';

class RoomLiveStateNotifier extends StateNotifier<RoomLiveStateModel?> {
  RoomLiveStateNotifier() : super(null);

  void setInitial(RoomLiveStateModel stateValue) {
    state = stateValue;
  }

  void setPlayers(List players) {
    if (state == null) return;
    state = state!.copyWith(players: players.cast());
  }

  void markGameStarted() {
    if (state == null) return;
    state = state!.copyWith(gameStarted: true);
  }

  void clear() {
    state = null;
  }
}

final roomLiveStateProvider =
    StateNotifierProvider<RoomLiveStateNotifier, RoomLiveStateModel?>(
      (ref) => RoomLiveStateNotifier(),
    );
