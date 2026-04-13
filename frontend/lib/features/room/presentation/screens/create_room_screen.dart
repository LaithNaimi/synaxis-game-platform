import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/glassmorphic_panel.dart';
import '../../../../shared/widgets/glow_button.dart';
import '../../../../shared/widgets/synaxis_app_bar.dart';
import '../../../../shared/widgets/synaxis_dropdown.dart';
import '../../../../shared/widgets/synaxis_text_field.dart';
import '../../../../shared/widgets/footer.dart';
import '../../application/providers/lobby_provider.dart';
import '../../application/providers/room_session_provider.dart';
import '../../data/models/create_room_request.dart';

/// Create room form — API call on submit (DDS §27.2).
class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _nameController = TextEditingController();

  String _cefrLevel = 'B1';
  int _maxPlayers = 4;
  int _totalRounds = 5;
  int _roundDuration = 60;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                alignment: Alignment.center,
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildForm(),
                    const SizedBox(height: AppSpacing.lg),
                    const Footer(),
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

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set the Hearth',
          style: AppTextStyles.title.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Configure your shared learning space. '
          'Every detail is crafted for an ethereal experience.',
          style: AppTextStyles.body.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  // ── Form inside glassmorphic panel ──────────────────────────────
  Widget _buildForm() {
    return GlassmorphicPanel(
      child: Column(
        children: [
          SynaxisTextField(
            label: 'Player Name',
            hint: 'LAITH  3MK',
            controller: _nameController,
            icon: Icons.person,
          ),

          const SizedBox(height: AppSpacing.lg),

          // CEFR Level
          SynaxisDropdown<String>(
            label: 'CEFR Level',
            value: _cefrLevel,
            icon: Icons.language,
            items: const [
              DropdownMenuItem(value: 'A1', child: Text('A1 - Discovery')),
              DropdownMenuItem(value: 'A2', child: Text('A2 - Voyager')),
              DropdownMenuItem(value: 'B1', child: Text('B1 - Explorer')),
              DropdownMenuItem(value: 'B2', child: Text('B2 - Trailblazer')),
              DropdownMenuItem(value: 'C1', child: Text('C1 - Master')),
            ],
            onChanged: (v) => setState(() => _cefrLevel = v ?? _cefrLevel),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Max Players
          SynaxisDropdown<int>(
            label: 'Max Players',
            value: _maxPlayers,
            icon: Icons.group,
            items: const [
              DropdownMenuItem(value: 2, child: Text('2 Souls')),
              DropdownMenuItem(value: 4, child: Text('4 Souls')),
              DropdownMenuItem(value: 6, child: Text('6 Souls')),
              DropdownMenuItem(value: 8, child: Text('8 Souls')),
              DropdownMenuItem(value: 10, child: Text('10 Souls')),
            ],
            onChanged: (v) => setState(() => _maxPlayers = v ?? _maxPlayers),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Total Rounds
          SynaxisDropdown<int>(
            label: 'Total Rounds',
            value: _totalRounds,
            icon: Icons.refresh,
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 Round')),
              DropdownMenuItem(value: 3, child: Text('3 Rounds')),
              DropdownMenuItem(value: 5, child: Text('5 Rounds')),
              DropdownMenuItem(value: 7, child: Text('7 Rounds')),
              DropdownMenuItem(value: 10, child: Text('10 Rounds')),
            ],
            onChanged: (v) => setState(() => _totalRounds = v ?? _totalRounds),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Round Duration
          SynaxisDropdown<int>(
            label: 'Round Duration',
            value: _roundDuration,
            icon: Icons.schedule,
            items: const [
              DropdownMenuItem(value: 30, child: Text('30 Seconds')),
              DropdownMenuItem(value: 60, child: Text('60 Seconds')),
              DropdownMenuItem(value: 90, child: Text('90 Seconds')),
              DropdownMenuItem(value: 120, child: Text('2 Minutes')),
              DropdownMenuItem(value: 180, child: Text('3 Minutes')),
              DropdownMenuItem(value: 240, child: Text('4 Minutes')),
              DropdownMenuItem(value: 300, child: Text('5 Minutes')),
            ],
            onChanged: (v) =>
                setState(() => _roundDuration = v ?? _roundDuration),
          ),

          const SizedBox(height: AppSpacing.xl),

          GlowButton(
            label: 'Create Room',
            icon: Icons.rocket_launch,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _onCreateRoom,
          ),
        ],
      ),
    );
  }

  Future<void> _onCreateRoom() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final request = CreateRoomRequest(
        playerName: name,
        cefrLevel: _cefrLevel,
        maxPlayers: _maxPlayers,
        totalRounds: _totalRounds,
        roundDurationSeconds: _roundDuration,
      );
      final session = await ref
          .read(roomSessionControllerProvider.notifier)
          .createRoom(request);

      if (!mounted) return;
      ref.read(lobbyControllerProvider.notifier).init(session);
      context.go(RouteNames.lobby);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
