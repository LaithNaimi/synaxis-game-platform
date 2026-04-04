import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/home_screen_theme.dart';
import '../../../../shared/widgets/synaxis_sci_fi_background.dart';
import '../../../../shared/widgets/synaxis_sci_fi_input_decoration.dart';
import '../create_room_constants.dart';
import '../create_room_validators.dart';
import '../widgets/create_room_cefr_dropdown.dart';
import '../widgets/create_room_form_widgets.dart';

/// Create room form — sci-fi styling; submit wired in FE-002.4.
class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maxPlayersController = TextEditingController();
  final _roundsController = TextEditingController();
  final _durationSecController = TextEditingController();

  String? _cefr;

  static const double _submitMinHeight = 48;

  @override
  void dispose() {
    _nameController.dispose();
    _maxPlayersController.dispose();
    _roundsController.dispose();
    _durationSecController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final name = _nameController.text.trim();
    if (name.isEmpty || name.length > kCreateRoomPlayerNameMaxLength) {
      return false;
    }
    if (_cefr == null) return false;
    final p = int.tryParse(_maxPlayersController.text.trim());
    if (p == null || p < 2 || p > 8) return false;
    final r = int.tryParse(_roundsController.text.trim());
    if (r == null || r < 1 || r > kCreateRoomMaxTotalRounds) return false;
    final d = int.tryParse(_durationSecController.text.trim());
    if (d == null || d < 15 || d > 180) return false;
    return true;
  }

  void _onSubmit() {
    if (!_canSubmit) return;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    // FE-002.4 — POST create room.
  }

  @override
  Widget build(BuildContext context) {
    final home =
        Theme.of(context).extension<HomeScreenTheme>() ??
        HomeScreenTheme.synaxis;
    final labelTextStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: home.onPrimaryText.withValues(alpha: 0.95),
    );

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SynaxisSciFiBackground(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CreateRoomBackBar(
                home: home,
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RouteNames.home);
                  }
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const CreateRoomTitleLogoBlock(),
                            const SizedBox(height: AppSpacing.lg),
                            CreateRoomFormSectionLabel(
                              text: 'PLAYER NAME',
                              labelTextStyle: labelTextStyle,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            TextFormField(
                              controller: _nameController,
                              maxLength: kCreateRoomPlayerNameMaxLength,
                              maxLines: 1,
                              style: labelTextStyle,
                              cursorColor: home.accentCyan,
                              decoration: synaxisSciFiInputDecoration(
                                home,
                                hint: 'Enter your nickname',
                              ).copyWith(counterText: ''),
                              validator: validateCreateRoomPlayerName,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            CreateRoomFormSectionLabel(
                              text: 'CEFR LEVEL',
                              labelTextStyle: labelTextStyle,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            CreateRoomCefrDropdown(
                              home: home,
                              value: _cefr,
                              labelTextStyle: labelTextStyle,
                              onChanged: (v) => setState(() => _cefr = v),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            CreateRoomFormSectionLabel(
                              text: 'MAXIMUM PLAYERS',
                              labelTextStyle: labelTextStyle,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            CreateRoomDigitsTextField(
                              controller: _maxPlayersController,
                              home: home,
                              labelTextStyle: labelTextStyle,
                              hint: '2–8',
                              validator: validateCreateRoomMaxPlayers,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            CreateRoomFormSectionLabel(
                              text: 'NUMBER OF ROUNDS',
                              labelTextStyle: labelTextStyle,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            CreateRoomDigitsTextField(
                              controller: _roundsController,
                              home: home,
                              labelTextStyle: labelTextStyle,
                              hint: '1–$kCreateRoomMaxTotalRounds',
                              validator: validateCreateRoomTotalRounds,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            CreateRoomFormSectionLabel(
                              text: 'ROUND TIME (SECONDS)',
                              labelTextStyle: labelTextStyle,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            CreateRoomDigitsTextField(
                              controller: _durationSecController,
                              home: home,
                              labelTextStyle: labelTextStyle,
                              hint: '15–180',
                              validator: validateCreateRoomRoundDurationSec,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            CreateRoomSubmitBar(
                              home: home,
                              canSubmit: _canSubmit,
                              onSubmit: _onSubmit,
                              minHeight: _submitMinHeight,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
