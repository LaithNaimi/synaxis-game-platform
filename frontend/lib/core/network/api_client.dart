import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../utils/logger.dart';

class _TransientRetryInterceptor extends Interceptor {
  _TransientRetryInterceptor(this._dio);

  final Dio _dio;

  static const String _retryCountKey = 'synaxis_retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final method = req.method.toUpperCase();

    if (method != 'GET') return handler.next(err);

    if (!_isTransient(err)) return handler.next(err);

    final count = (req.extra[_retryCountKey] as int?) ?? 0;
    if (count >= 2) return handler.next(err);

    req.extra[_retryCountKey] = count + 1;
    await Future<void>.delayed(Duration(milliseconds: count == 0 ? 300 : 800));
    try {
      final response = await _dio.fetch<dynamic>(req);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _isTransient(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        return code != null && code >= 500;
      default:
        return false;
    }
  }
}

class ApiClient {
  ApiClient._()
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: const {'Accept': 'application/json'},
        ),
      ) {
    dio.interceptors.add(_TransientRetryInterceptor(dio));
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => AppLogger.debug(o),
        ),
      );
    }
  }

  static final ApiClient instance = ApiClient._();

  final Dio dio;
}
