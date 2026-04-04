import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_page_shell.dart';
import '../../features/countdown/presentation/screens/countdown_screen.dart';
import '../../features/game/presentation/screens/game_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/leaderboard/presentation/screens/final_leaderboard_screen.dart';
import '../../features/leaderboard/presentation/screens/round_leaderboard_screen.dart';
import '../../features/learning/presentation/screens/learning_reveal_screen.dart';
import '../../features/room/presentation/screens/create_room_screen.dart';
import '../../features/room/presentation/screens/join_room_screen.dart';
import '../../features/room/presentation/screens/lobby_screen.dart';
import 'route_names.dart';

/// Builds the MVP [GoRouter] (DDS §7.1). Use a fresh instance in tests via this factory.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.createRoom,
        builder: (context, _) => const CreateRoomScreen(),
      ),
      GoRoute(
        path: RouteNames.joinRoom,
        builder: (context, _) =>
            const AppPageShell(title: 'Join room', child: JoinRoomScreen()),
      ),
      GoRoute(
        path: RouteNames.lobby,
        builder: (context, _) =>
            const AppPageShell(title: 'Lobby', child: LobbyScreen()),
      ),
      GoRoute(
        path: RouteNames.countdown,
        builder: (context, _) =>
            const AppPageShell(title: 'Countdown', child: CountdownScreen()),
      ),
      GoRoute(
        path: RouteNames.game,
        builder: (context, _) =>
            const AppPageShell(title: 'Game', child: GameScreen()),
      ),
      GoRoute(
        path: RouteNames.learning,
        builder: (context, _) => const AppPageShell(
          title: 'Learning',
          child: LearningRevealScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.roundLeaderboard,
        builder: (context, _) => const AppPageShell(
          title: 'Round leaderboard',
          child: RoundLeaderboardScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.finalLeaderboard,
        builder: (context, _) => const AppPageShell(
          title: 'Final leaderboard',
          child: FinalLeaderboardScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(RouteNames.home)),
        title: const Text('Not found'),
      ),
      body: Center(child: Text('No route: ${state.uri}')),
    ),
  );
}

/// Root router for the running app (`MaterialApp.router`).
final GoRouter appRouter = createAppRouter();
