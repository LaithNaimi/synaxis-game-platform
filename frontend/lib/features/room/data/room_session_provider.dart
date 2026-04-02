import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/room_session_model.dart';

class RoomSessionNotifier extends StateNotifier<RoomSessionModel?> {
  RoomSessionNotifier() : super(null);

  void setSession(RoomSessionModel session) {
    state = session;
  }

  void clearSession() {
    state = null;
  }
}

final roomSessionProvider =
    StateNotifierProvider<RoomSessionNotifier, RoomSessionModel?>(
      (ref) => RoomSessionNotifier(),
    );
