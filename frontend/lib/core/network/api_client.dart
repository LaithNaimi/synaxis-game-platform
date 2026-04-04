import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../utils/logger.dart';

/// Wraps a single [Dio] instance (DDS §9.2): 10s connect + receive timeouts.
class ApiClient {
  ApiClient._()
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
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

  /// Shared instance for the app (one [Dio] as per DDS).
  static final ApiClient instance = ApiClient._();

  final Dio dio;
}
