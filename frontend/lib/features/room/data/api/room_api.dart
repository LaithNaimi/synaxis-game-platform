import 'package:dio/dio.dart';

// import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/network/api_client.dart';
import '../models/create_room_request.dart';
import '../models/join_room_request.dart';
import '../models/leave_room_request.dart';
import '../models/room_session_model.dart';

class RoomApi {
  RoomApi({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<RoomSessionModel> createRoom(CreateRoomRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/room/create',
        data: request.toJson(),
      );
      return _unwrap(response.data!);
    } on DioException catch (e) {
      print(e.response?.data);
      throw ErrorMapper.fromDioException(e);
    }
  }

  Future<RoomSessionModel> joinRoom(
    String roomCode,
    JoinRoomRequest request,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/room/$roomCode/join',
        data: request.toJson(),
      );
      return _unwrap(response.data!);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }

  Future<void> leaveRoom(String roomCode, LeaveRoomRequest request) async {
    try {
      await _dio.post<void>(
        '/api/room/$roomCode/leave',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioException(e);
    }
  }

  RoomSessionModel _unwrap(Map<String, dynamic> json) {
    if (json['success'] == true) {
      return RoomSessionModel.fromJson(json['data'] as Map<String, dynamic>);
    }
    throw ErrorMapper.fromBackendJson(json);
  }
}
