import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';

/// Entry screen (DDS §15.1). Primary CTAs come in FE-002.1.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Synaxis'),
        actions: [
          if (kDebugMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.route),
              tooltip: 'Jump to route (debug)',
              onSelected: context.go,
              itemBuilder: (context) => [
                const PopupMenuItem(value: RouteNames.createRoom, child: Text('Create room')),
                const PopupMenuItem(value: RouteNames.joinRoom, child: Text('Join room')),
                const PopupMenuItem(value: RouteNames.lobby, child: Text('Lobby')),
                const PopupMenuItem(value: RouteNames.countdown, child: Text('Countdown')),
                const PopupMenuItem(value: RouteNames.game, child: Text('Game')),
                const PopupMenuItem(value: RouteNames.learning, child: Text('Learning')),
                const PopupMenuItem(value: RouteNames.roundLeaderboard, child: Text('Round leaderboard')),
                const PopupMenuItem(value: RouteNames.finalLeaderboard, child: Text('Final leaderboard')),
              ],
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: Text('Home', style: textTheme.titleLarge),
        ),
      ),
    );
  }
}
