import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../config/app_config.dart';

class WebSocketClient {
  StompClient? _client;

  void connect({required void Function(StompFrame frame) onConnect}) {
    _client = StompClient(
      config: StompConfig.SockJS(
        url: AppConfig.wsUrl,
        onConnect: onConnect,
        onWebSocketError: (error) {
          print("WebSocket error: $error");
        },
      ),
    );

    _client!.activate();
  }

  void subscribe(String destination, Function(StompFrame) callback) {
    _client?.subscribe(destination: destination, callback: callback);
  }

  void send(String destination, String body) {
    _client?.send(destination: destination, body: body);
  }

  void disconnect() {
    _client?.deactivate();
  }
}
