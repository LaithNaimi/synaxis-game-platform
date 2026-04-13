import 'package:dio/dio.dart';

import 'app_exception.dart';

class ErrorMapper {
  const ErrorMapper._();

  static const _backendMessages = {
    'ROOM_NOT_FOUND': 'Room not found — check the code',
    'ROOM_FULL': 'Room is full',
    'GAME_ALREADY_STARTED': 'Game already started',
    'INVALID_REQUEST': 'Invalid request — check your input',
  };

  static AppException fromBackendJson(Map<String, dynamic> json) {
    final code = json['errorCode'] as String?;
    final fallback = json['message'] as String? ?? 'Something went wrong';
    return AppException(_backendMessages[code] ?? fallback);
  }

  static AppException fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException('Connection timed out — try again');
      case DioExceptionType.connectionError:
        return const AppException('Connection failed — check your network');
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data['success'] == false) {
          return fromBackendJson(data);
        }
        return AppException(
          'Server error (${e.response?.statusCode ?? 'unknown'})',
        );
      default:
        return const AppException('Something went wrong');
    }
  }
}
