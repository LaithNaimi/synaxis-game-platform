import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_handler.dart' show StompUnsubscribe;

import '../config/app_config.dart';
import '../utils/logger.dart';

class WebSocketClient {
  WebSocketClient({String? wsUrl}) : _url = wsUrl ?? AppConfig.wsUrl;

  final String _url;
  StompClient? _stomp;

  bool get connected => _stomp?.connected ?? false;

  void connect({
    required void Function() onConnected,
    void Function(dynamic error)? onWebSocketError,
  }) {
    disconnect();
    _stomp = StompClient(
      config: StompConfig(
        url: _url,
        reconnectDelay: Duration.zero,
        connectionTimeout: const Duration(seconds: 10),
        onConnect: (_) => onConnected(),
        onWebSocketError: onWebSocketError ?? (_) {},
        onDebugMessage: kDebugMode ? (m) => AppLogger.debug(m) : (_) {},
      ),
    );
    _stomp!.activate();
  }

  StompUnsubscribe subscribe({
    required String destination,
    required StompFrameCallback callback,
    Map<String, String>? headers,
  }) {
    final client = _stomp;
    if (client == null || !client.connected) {
      throw StateError('WebSocketClient.subscribe: not connected');
    }
    return client.subscribe(
      destination: destination,
      callback: callback,
      headers: headers,
    );
  }

  void sendJson({
    required String destination,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) {
    final client = _stomp;
    if (client == null || !client.connected) {
      throw StateError('WebSocketClient.sendJson: not connected');
    }
    final merged = {'content-type': 'application/json', ...?headers};
    client.send(
      destination: destination,
      body: jsonEncode(body),
      headers: merged,
    );
  }

  void disconnect() {
    _stomp?.deactivate();
    _stomp = null;
  }
}
