import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glassmorphic_panel.dart';
import '../../../../shared/widgets/glow_button.dart';
import '../../../../shared/widgets/nebula_background.dart';
import '../../../../shared/widgets/synaxis_app_bar.dart';
import '../../../../shared/widgets/synaxis_text_field.dart';

/// Join room form — player name + room code (DDS §27.2).
class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
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
      backgroundColor: Colors.transparent,
      appBar: SynaxisAppBar(onBack: () => context.go(RouteNames.home)),
      body: NebulaBackground(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Center(
                  child: ConstrainedBox(
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
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
          'Enter your credentials to enter the cosmic session.',
          style: AppTextStyles.body.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return GlassmorphicPanel(
      child: Column(
        children: [
          // Player Name
          SynaxisTextField(
            label: 'Player Name',
            hint: 'e.g. Starchild_01',
            controller: _nameController,
            suffixIcon: Icons.person,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.secondary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Visible to other travelers in the room.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Room Code
          _buildRoomCodeField(),

          const SizedBox(height: AppSpacing.xl),

          // Submit
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
          textCapitalization: TextCapitalization.characters,
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
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_user,
                size: 14,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'ENCRYPTED PORTAL',
                style: AppTextStyles.micro.copyWith(
                  color: AppColors.secondary,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onJoinRoom() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}
