import 'package:flutter/material.dart';

import '../../../../app/router/synaxis_pop_or_home.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/home_screen_theme.dart';
import '../../../../shared/widgets/synaxis_room_form_layout.dart';
import '../../../../shared/widgets/synaxis_room_player_name_field.dart';
import '../create_room_constants.dart';
import '../join_room_constants.dart';
import '../join_room_validators.dart';
import '../widgets/create_room_form_widgets.dart';
import '../widgets/join_room_code_field.dart';

/// Join room form — player name + room code (DDS §15.3); submit wired in FE-002.5.
class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  static const double _submitMinHeight = 48;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final name = _nameController.text.trim();
    if (name.isEmpty || name.length > kCreateRoomPlayerNameMaxLength) {
      return false;
    }
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != kJoinRoomCodeLength) return false;
    if (!RegExp('^[A-Z0-9]{${kJoinRoomCodeLength}}\$').hasMatch(code)) {
      return false;
    }
    return true;
  }

  void _onSubmit() {
    if (!_canSubmit) return;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    // FE-002.5 — POST join room.
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
        const SynaxisTitleLogoBlock(title: 'JOIN ROOM'),
        const SizedBox(height: AppSpacing.lg),
        SynaxisRoomPlayerNameField(
          controller: _nameController,
          home: home,
          labelTextStyle: labelTextStyle,
          maxLength: kCreateRoomPlayerNameMaxLength,
          validator: validateJoinRoomPlayerName,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        JoinRoomCodeField(
          controller: _codeController,
          home: home,
          labelTextStyle: labelTextStyle,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.xl),
        CreateRoomSubmitBar(
          home: home,
          canSubmit: _canSubmit,
          onSubmit: _onSubmit,
          buttonLabel: 'JOIN ROOM',
          minHeight: _submitMinHeight,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
