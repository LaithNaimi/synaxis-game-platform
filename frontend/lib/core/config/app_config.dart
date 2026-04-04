/// Single place for REST / WebSocket base URLs (DDS §9.1).
/// Swap per flavor (dev / staging / prod) or `--dart-define` later.
class AppConfig {
  AppConfig._();

  /// Android emulator → host machine. Physical device: use LAN IP of the PC.
  static const String baseUrl = String.fromEnvironment(
    'SYNAXIS_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String wsUrl = String.fromEnvironment(
    'SYNAXIS_WS_URL',
    defaultValue: 'ws://10.0.2.2:8080/ws',
  );
}
