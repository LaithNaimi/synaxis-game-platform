import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/create_room_request.dart';
import '../../data/models/join_room_request.dart';
import '../../data/models/room_session_model.dart';
import '../../data/repositories/room_repository.dart';

class RoomSessionController extends Notifier<RoomSessionModel?> {
  late final RoomRepository _repo;

  @override
  RoomSessionModel? build() {
    _repo = RoomRepository();
    return null;
  }

  Future<RoomSessionModel> createRoom(CreateRoomRequest request) async {
    final session = await _repo.createRoom(request);
    state = session;
    return session;
  }

  Future<RoomSessionModel> joinRoom(
    String roomCode,
    JoinRoomRequest request,
  ) async {
    final session = await _repo.joinRoom(roomCode, request);
    state = session;
    return session;
  }

  /// Clears the session (player left or room closed).
  void clear() => state = null;
}
