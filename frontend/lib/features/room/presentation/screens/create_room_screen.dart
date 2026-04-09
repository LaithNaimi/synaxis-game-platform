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
import '../../../../shared/widgets/synaxis_dropdown.dart';
import '../../../../shared/widgets/synaxis_text_field.dart';

/// Create room form — local state only, API call on submit (DDS §27.2).
class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
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
                        const SizedBox(height: AppSpacing.lg),
                        _buildFooter(),
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
          // Player Name
          SynaxisTextField(
            label: 'Player Name',
            hint: 'Enter your celestial handle...',
            controller: _nameController,
            suffixIcon: Icons.person,
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: AppSpacing.lg),

          // CEFR Level
          SynaxisDropdown<String>(
            label: 'CEFR Level',
            value: _cefrLevel,
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
            suffixIcon: Icons.group,
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
            suffixIcon: Icons.refresh,
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
            suffixIcon: Icons.schedule,
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

          // Submit
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

  // ── Footer ──────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Center(
      child: Opacity(
        opacity: 0.4,
        child: Column(
          children: [
            Container(
              height: 1,
              width: 96,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primaryDim,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'INITIALIZING VIRTUAL HEARTH',
              style: AppTextStyles.micro.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCreateRoom() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}
