import '../api/room_api.dart';
import '../models/create_room_request.dart';
import '../models/join_room_request.dart';
import '../models/leave_room_request.dart';
import '../models/room_session_model.dart';

class RoomRepository {
  RoomRepository({RoomApi? api}) : _api = api ?? RoomApi();

  final RoomApi _api;

  Future<RoomSessionModel> createRoom(CreateRoomRequest request) =>
      _api.createRoom(request);

  Future<RoomSessionModel> joinRoom(String roomCode, JoinRoomRequest request) =>
      _api.joinRoom(roomCode, request);

  Future<void> leaveRoom(String roomCode, LeaveRoomRequest request) =>
      _api.leaveRoom(roomCode, request);
}
