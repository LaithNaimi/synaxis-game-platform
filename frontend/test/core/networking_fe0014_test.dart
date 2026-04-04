import 'package:flutter_test/flutter_test.dart';

import 'package:synaxis/core/config/app_config.dart';
import 'package:synaxis/core/network/api_client.dart';
import 'package:synaxis/core/network/ws_destinations.dart';

/// FE-001.4 — core networking contracts (DDS §9, §9.4).
void main() {
  group('ApiClient', () {
    test('uses AppConfig base URL and 10s timeouts', () {
      final o = ApiClient.instance.dio.options;
      expect(o.baseUrl, AppConfig.baseUrl);
      expect(o.connectTimeout, const Duration(seconds: 10));
      expect(o.sendTimeout, const Duration(seconds: 10));
      expect(o.receiveTimeout, const Duration(seconds: 10));
      expect(o.headers['Accept'], 'application/json');
    });

    test('registers transient retry interceptor', () {
      final names = ApiClient.instance.dio.interceptors
          .map((i) => i.runtimeType.toString())
          .join(' ');
      expect(names, contains('TransientRetry'));
    });
  });

  group('WsDestinations', () {
    test('matches DDS STOMP paths', () {
      expect(WsDestinations.roomTopic('ABC123'), '/topic/room/ABC123');
      expect(WsDestinations.privateGameQueue(), '/user/queue/game');
      expect(WsDestinations.startGameCommand(), '/app/game.start');
      expect(WsDestinations.guessLetterCommand(), '/app/game.guess-letter');
      expect(WsDestinations.nextRoundCommand(), '/app/round.next');
    });
  });
}
