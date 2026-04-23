import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../room/application/providers/lobby_provider.dart';
import '../../../room/application/providers/room_session_provider.dart';
import '../../application/providers/countdown_provider.dart';
import '../widgets/countdown_circle.dart';
import '../../../../shared/widgets/synaxis_app_bar.dart';

class CountdownScreen extends ConsumerStatefulWidget {
  const CountdownScreen({super.key});

  @override
  ConsumerState<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends ConsumerState<CountdownScreen> {
  bool _timerStarted = false;

  @override
  Widget build(BuildContext context) {
    final lobbyState = ref.watch(lobbyControllerProvider);
    final countdownState = ref.watch(countdownControllerProvider);
    final session = ref.watch(roomSessionControllerProvider);

    final totalRounds = session?.roomSettings.totalRounds ?? 0;
    final roundNumber = lobbyState.roundNumber;

    if (roundNumber > 0 && !_timerStarted) {
      _timerStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(countdownControllerProvider.notifier).start();
      });
    }

    if (lobbyState.roundStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(RouteNames.game);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SynaxisAppBar(
        title: 'Lobby',
        onBack: () => context.go(RouteNames.home),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Round label
            if (roundNumber > 0)
              Text(
                'Round $roundNumber of $totalRounds',
                style: AppTextStyles.labelUppercase.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 3,
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),

            CountdownCircle(value: countdownState.value),

            const SizedBox(height: AppSpacing.xxl),

            Text(
              'Get ready...',
              style: AppTextStyles.body.copyWith(
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
