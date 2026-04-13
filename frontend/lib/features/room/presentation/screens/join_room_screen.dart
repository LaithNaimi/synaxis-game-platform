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
import '../../../../shared/widgets/synaxis_text_field.dart';
import '../../application/providers/lobby_provider.dart';
import '../../application/providers/room_session_provider.dart';
import '../../data/models/join_room_request.dart';
import '../../../../shared/widgets/footer.dart';

class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join the Hearth',
          style: AppTextStyles.title.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Enter your credentials to enter the cosmic game.',
          style: AppTextStyles.body,
        ),
      ],
    );
  }

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
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Visible to other travelers in the room.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildRoomCodeField(),
          const SizedBox(height: AppSpacing.xl),
          GlowButton(
            label: 'Join Room',
            icon: Icons.rocket_launch,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _onJoinRoom,
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ROOM CODE',
          style: AppTextStyles.labelUppercase.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _codeController,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
            color: AppColors.primary,
            letterSpacing: 12,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'X7R2KL',
            counterText: '',
            hintStyle: AppTextStyles.display.copyWith(
              color: AppColors.outline.withValues(alpha: 0.4),
              letterSpacing: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onJoinRoom() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim().toUpperCase();
    if (name.isEmpty || code.length != 6) return;

    setState(() => _isLoading = true);
    try {
      final request = JoinRoomRequest(playerName: name);
      final session = await ref
          .read(roomSessionControllerProvider.notifier)
          .joinRoom(code, request);

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
