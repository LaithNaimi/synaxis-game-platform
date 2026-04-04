import 'package:flutter/material.dart';

import '../../../../app/router/synaxis_pop_or_home.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/home_screen_theme.dart';
import '../../../../shared/widgets/synaxis_room_form_layout.dart';
import '../../../../shared/widgets/synaxis_room_player_name_field.dart';
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

    return SynaxisRoomFormShell(
      formKey: _formKey,
      home: home,
      onBack: () => synaxisPopOrGoHome(context),
      children: [
        const SynaxisTitleLogoBlock(),
        const SizedBox(height: AppSpacing.lg),
        SynaxisRoomPlayerNameField(
          controller: _nameController,
          home: home,
          labelTextStyle: labelTextStyle,
          maxLength: kCreateRoomPlayerNameMaxLength,
          validator: validateCreateRoomPlayerName,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        SynaxisLabeledSciFiField(
          label: 'CEFR LEVEL',
          labelTextStyle: labelTextStyle,
          field: CreateRoomCefrDropdown(
            home: home,
            value: _cefr,
            labelTextStyle: labelTextStyle,
            onChanged: (v) => setState(() => _cefr = v),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SynaxisLabeledSciFiField(
          label: 'MAXIMUM PLAYERS',
          labelTextStyle: labelTextStyle,
          field: CreateRoomDigitsTextField(
            controller: _maxPlayersController,
            home: home,
            labelTextStyle: labelTextStyle,
            hint: '2–8',
            validator: validateCreateRoomMaxPlayers,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SynaxisLabeledSciFiField(
          label: 'NUMBER OF ROUNDS',
          labelTextStyle: labelTextStyle,
          field: CreateRoomDigitsTextField(
            controller: _roundsController,
            home: home,
            labelTextStyle: labelTextStyle,
            hint: '1–$kCreateRoomMaxTotalRounds',
            validator: validateCreateRoomTotalRounds,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SynaxisLabeledSciFiField(
          label: 'ROUND TIME (SECONDS)',
          labelTextStyle: labelTextStyle,
          field: CreateRoomDigitsTextField(
            controller: _durationSecController,
            home: home,
            labelTextStyle: labelTextStyle,
            hint: '15–180',
            validator: validateCreateRoomRoundDurationSec,
            onChanged: (_) => setState(() {}),
          ),
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
    );
  }
}
