import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class RoomApi {
  final ApiClient _client;

  RoomApi(this._client);

  Future<Map<String, dynamic>> createRoom({
    required String playerName,
    required String cefrLevel,
    required int maxPlayers,
    required int totalRounds,
    required int roundDurationSeconds,
  }) async {
    final response = await _client.dio.post(
      '/api/room',
      data: {
        "playerName": playerName,
        "cefrLevel": cefrLevel,
        "maxPlayers": maxPlayers,
        "totalRounds": totalRounds,
        "roundDurationSeconds": roundDurationSeconds,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> joinRoom(
    String roomCode,
    String playerName,
  ) async {
    final response = await _client.dio.post(
      '/api/room/$roomCode/join',
      data: {"playerName": playerName},
    );

    return response.data;
  }

  Future<Map<String, dynamic>> reconnect(
    String roomCode,
    String playerId,
    String playerToken,
  ) async {
    final response = await _client.dio.post(
      '/api/room/$roomCode/reconnect',
      data: {"playerId": playerId, "playerToken": playerToken},
    );

    return response.data;
  }
}
