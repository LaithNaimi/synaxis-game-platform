import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../config/app_config.dart';

class WebSocketClient {
  StompClient? _client;

  void connect({required void Function(StompFrame frame) onConnect}) {
    _client = StompClient(
      config: StompConfig(
        url: AppConfig.wsUrl,
        onConnect: onConnect,
        beforeConnect: () async {
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) {
          print("WebSocket error: $error");
        },
        onStompError: (StompFrame frame) {
          print("STOMP error: ${frame.body}");
        },
      ),
    );

    _client!.activate();
  }

  void subscribe(String destination, void Function(StompFrame frame) callback) {
    _client?.subscribe(destination: destination, callback: callback);
  }

  void send(String destination, String body) {
    _client?.send(destination: destination, body: body);
  }

  void disconnect() {
    _client?.deactivate();
  }
}
