import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:synaxis/app/router/app_router.dart';
import 'package:synaxis/app/router/route_names.dart';
import 'package:synaxis/features/countdown/presentation/screens/countdown_screen.dart';
import 'package:synaxis/features/game/presentation/screens/game_screen.dart';
import 'package:synaxis/features/home/presentation/screens/home_screen.dart';
import 'package:synaxis/features/leaderboard/presentation/screens/final_leaderboard_screen.dart';
import 'package:synaxis/features/leaderboard/presentation/screens/round_leaderboard_screen.dart';
import 'package:synaxis/features/learning/presentation/screens/learning_reveal_screen.dart';
import 'package:synaxis/features/room/presentation/screens/lobby_screen.dart';

/// FE-001.3 — every DDS §7.1 path resolves and shows its placeholder body.
void main() {
  testWidgets('all MVP routes show expected screen body', (tester) async {
    final router = createAppRouter();

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final expectedTypes = <String, Type>{
      RouteNames.home: HomeScreen,
      RouteNames.lobby: LobbyScreen,
      RouteNames.countdown: CountdownScreen,
      RouteNames.game: GameScreen,
      RouteNames.learning: LearningRevealScreen,
      RouteNames.roundLeaderboard: RoundLeaderboardScreen,
      RouteNames.finalLeaderboard: FinalLeaderboardScreen,
    };

    for (final entry in expectedTypes.entries) {
      router.go(entry.key);
      await tester.pumpAndSettle();
      expect(find.byType(entry.value), findsOneWidget, reason: entry.key);
    }

    router.go(RouteNames.createRoom);
    await tester.pumpAndSettle();
    expect(find.text('Create room (placeholder)'), findsOneWidget);

    router.go(RouteNames.joinRoom);
    await tester.pumpAndSettle();
    expect(find.text('Join room (placeholder)'), findsOneWidget);
  });

  testWidgets('unknown path uses errorBuilder', (tester) async {
    final router = createAppRouter();

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/no-such-route');
    await tester.pumpAndSettle();

    expect(find.textContaining('No route:'), findsOneWidget);
    expect(find.text('Not found'), findsOneWidget);
  });
}
