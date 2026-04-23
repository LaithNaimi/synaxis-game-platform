import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/synaxis_app_bar.dart';
import '../../../room/application/providers/lobby_provider.dart';
import '../../../room/application/providers/room_session_provider.dart';
import '../../application/providers/game_provider.dart';
import '../widgets/letter_grid_widget.dart';
import '../widgets/masked_word_widget.dart';
import '../widgets/player_status_panel.dart';
import '../widgets/round_timer_widget.dart';
import '../widgets/score_health_bar.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final lobbyState = ref.watch(lobbyControllerProvider);
    final session = ref.watch(roomSessionControllerProvider);

    if (!_initialized && session != null) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final lobby = ref.read(lobbyControllerProvider.notifier);
        ref
            .read(gameControllerProvider.notifier)
            .initRound(
              ws: lobby.ws!,
              roomCode: session.roomCode,
              playerId: session.playerId,
              playerToken: session.playerToken,
              roundNumber: lobbyState.roundNumber,
              totalRounds: session.roomSettings.totalRounds,
              maskedWord: lobbyState.maskedWord,
              roundDurationSeconds: session.roomSettings.roundDurationSeconds,
            );
      });
    }

    if (gameState.learningReveal != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(RouteNames.learning);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SynaxisAppBar(
        title: 'Synaxis',
        onBack: () => context.go(RouteNames.home),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                'ROUND ${gameState.roundNumber.toString().padLeft(2, '0')}/${gameState.totalRounds.toString().padLeft(2, '0')}',
                style: AppTextStyles.micro.copyWith(
                  color: AppColors.onSurface,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            RoundTimerWidget(
              roundDurationSeconds: gameState.roundDurationSeconds,
              roundStartedAt: gameState.roundStartedAt,
              suddenDeath: gameState.suddenDeath,
              suddenDeathAt: gameState.suddenDeathAt,
              stopped: gameState.roundEnded,
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ── Score + Integrity ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: ScoreHealthBar(
                score: gameState.currentScore,
                scoreDelta: gameState.scoreDelta,
                health: gameState.currentHealth,
                healthDelta: gameState.healthDelta,
                penaltyScoreDelta: gameState.penaltyScoreDelta,
              ),
            ),

            const Spacer(flex: 1),

            // ── Status banners ──
            if (gameState.solved)
              _buildStatusBanner('WORD SOLVED!', AppColors.success),
            if (gameState.roundTimedOut && !gameState.solved)
              _buildStatusBanner("TIME'S UP!", AppColors.warning),
            if (gameState.suddenDeath &&
                !gameState.suddenDeathEnded &&
                !gameState.solved)
              _buildStatusBanner('SUDDEN DEATH', AppColors.error),
            if (gameState.suddenDeathEnded &&
                !gameState.solved &&
                !gameState.roundTimedOut)
              _buildStatusBanner('SUDDEN DEATH ENDED', AppColors.error),

            // ── Masked Word ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: MaskedWordWidget(maskedWord: gameState.maskedWord),
            ),

            const Spacer(flex: 1),

            // ── Letter Grid ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Stack(
                children: [
                  LetterGridWidget(
                    correctLetters: gameState.correctLetters,
                    wrongLetters: gameState.wrongLetters,
                    guessedLetters: gameState.guessedLetters,
                    disabled: gameState.inputBlocked,
                    onLetterTap: (letter) {
                      ref
                          .read(gameControllerProvider.notifier)
                          .guessLetter(letter);
                    },
                  ),
                  if (gameState.stunned)
                    _buildStunOverlay(gameState.stunnedUntil),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Live Lobby ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: PlayerStatusPanel(
                players: lobbyState.players,
                currentPlayerId: session?.playerId ?? '',
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          text,
          style: AppTextStyles.labelUppercase.copyWith(
            color: color,
            letterSpacing: 3,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStunOverlay(DateTime? stunnedUntil) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.flash_on_rounded,
              color: AppColors.warning,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'STUNNED',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (stunnedUntil != null)
              _StunCountdown(stunnedUntil: stunnedUntil),
          ],
        ),
      ),
    );
  }
}

class _StunCountdown extends StatefulWidget {
  const _StunCountdown({required this.stunnedUntil});
  final DateTime stunnedUntil;

  @override
  State<_StunCountdown> createState() => _StunCountdownState();
}

class _StunCountdownState extends State<_StunCountdown> {
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _computeLeft();
  }

  @override
  void didUpdateWidget(covariant _StunCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _computeLeft();
  }

  void _computeLeft() {
    final diff = widget.stunnedUntil.difference(DateTime.now()).inSeconds;
    _secondsLeft = diff.clamp(0, 99);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: Stream<void>.periodic(const Duration(seconds: 1)),
      builder: (_, __) {
        _computeLeft();
        return Text(
          '${_secondsLeft}s',
          style: AppTextStyles.body.copyWith(color: AppColors.warning),
        );
      },
    );
  }
}
