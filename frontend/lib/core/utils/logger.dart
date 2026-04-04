import 'package:flutter/foundation.dart';

/// Debug / structured logging (DDS §9 — used by network layer).
abstract final class AppLogger {
  static void debug(Object message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[Synaxis] $message');
      if (error != null) {
        debugPrint('$error');
      }
      if (stackTrace != null) {
        debugPrint('$stackTrace');
      }
    }
  }
}
