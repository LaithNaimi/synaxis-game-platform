import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synaxis/features/room/data/models/player_model.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glow_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/synaxis_app_bar.dart';
import '../../application/providers/lobby_provider.dart';
import '../../application/providers/room_session_provider.dart';
import '../widgets/live_feed_card.dart';
import '../widgets/player_tile.dart';
import '../widgets/room_code_card.dart';
import '../widgets/room_settings_card.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(roomSessionControllerProvider);
    final lobbyState = ref.watch(lobbyControllerProvider);

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(RouteNames.home);
      });
      return const SizedBox.shrink();
    }

    final settings = session.roomSettings;
    final players = lobbyState.players;
    final isHost = players.any((p) => p.playerId == session.playerId && p.host);
    final isConnected = lobbyState.isConnected;

    // All players navigate when the server confirms game start.
    if (lobbyState.gameStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(RouteNames.countdown);
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: SynaxisAppBar(
        title: 'Lobby',
        onBack: () => _onLeave(context, ref),
        trailing: StatusBadge(
          label: isConnected ? 'Connected' : 'Disconnected',
          showDot: true,
          variant: isConnected
              ? StatusBadgeVariant.success
              : StatusBadgeVariant.error,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    RoomCodeCard(roomCode: session.roomCode),
                    const SizedBox(height: AppSpacing.md),
                    _buildStartButton(context, ref, isHost),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPlayerSection(
                      players,
                      settings.maxPlayers,
                      isConnected,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    RoomSettingsCard(
                      cefrLevel: settings.cefrLevel,
                      totalRounds: settings.totalRounds,
                      roundDuration: settings.roundDurationSeconds,
                      maxPlayers: settings.maxPlayers,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    LiveFeedCard(messages: lobbyState.feedMessages),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DEPLOYMENT PROTOCOL',
          style: AppTextStyles.labelUppercase.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'The Lobby',
          style: AppTextStyles.title.copyWith(color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref, bool isHost) {
    final lobbyState = ref.watch(lobbyControllerProvider);

    if (isHost) {
      return GlowButton(
        label: 'Start Game',
        icon: Icons.play_arrow,
        isLoading: lobbyState.isStarting,
        onPressed: lobbyState.isStarting
            ? null
            : () => ref.read(lobbyControllerProvider.notifier).startGame(),
      );
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(
        'Waiting for host to start...',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildPlayerSection(
    List<PlayerModel> players,
    int maxPlayers,
    bool isConnected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Players in the Room',
              style: AppTextStyles.labelUppercase.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              '${players.length}/$maxPlayers',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        ...List.generate(players.length, (i) {
          final p = players[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: PlayerTile(
              name: p.playerName,
              avatarIndex: i + 1,
              isHost: p.host,
              status: p.host ? 'Ready to lead' : 'Be ready',
              isOnline: isConnected,
            ),
          );
        }),
      ],
    );
  }

  void _onLeave(BuildContext context, WidgetRef ref) {
    ref.read(lobbyControllerProvider.notifier).disconnect();
    ref.read(roomSessionControllerProvider.notifier).leaveRoom();
    context.go(RouteNames.home);
  }
}
