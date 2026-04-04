import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

/// Root [GoRouter] for MVP routes (DDS §7.1).
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.home,
  routes: [
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: RouteNames.createRoom,
      builder: (context, _) => _PageShell(
        title: 'Create room',
        child: const CreateRoomScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.joinRoom,
      builder: (context, _) => _PageShell(
        title: 'Join room',
        child: const JoinRoomScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.lobby,
      builder: (context, _) => _PageShell(
        title: 'Lobby',
        child: const LobbyScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.countdown,
      builder: (context, _) => _PageShell(
        title: 'Countdown',
        child: const CountdownScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.game,
      builder: (context, _) => _PageShell(
        title: 'Game',
        child: const GameScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.learning,
      builder: (context, _) => _PageShell(
        title: 'Learning',
        child: const LearningRevealScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.roundLeaderboard,
      builder: (context, _) => _PageShell(
        title: 'Round leaderboard',
        child: const RoundLeaderboardScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.finalLeaderboard,
      builder: (context, _) => _PageShell(
        title: 'Final leaderboard',
        child: const FinalLeaderboardScreen(),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      leading: BackButton(
        onPressed: () => context.go(RouteNames.home),
      ),
      title: const Text('Not found'),
    ),
    body: Center(child: Text('No route: ${state.uri}')),
  ),
);

class _PageShell extends StatelessWidget {
  const _PageShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.home);
            }
          },
        ),
        title: Text(title),
      ),
      body: child,
    );
  }
}
