import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/home_screen_theme.dart';
import '../../../../shared/widgets/synaxis_room_form_layout.dart';
import '../../../../shared/widgets/synaxis_sci_fi_input_decoration.dart';
import '../join_room_constants.dart';
import '../join_room_validators.dart';

/// ROOM CODE input (6 alphanumeric) for join flow.
class JoinRoomCodeField extends StatelessWidget {
  const JoinRoomCodeField({
    super.key,
    required this.controller,
    required this.home,
    required this.labelTextStyle,
    required this.onChanged,
  });

  final TextEditingController controller;
  final HomeScreenTheme home;
  final TextStyle? labelTextStyle;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SynaxisLabeledSciFiField(
      label: 'ROOM CODE',
      labelTextStyle: labelTextStyle,
      field: TextFormField(
        controller: controller,
        maxLength: kJoinRoomCodeLength,
        maxLines: 1,
        style: labelTextStyle,
        cursorColor: home.accentCyan,
        textCapitalization: TextCapitalization.characters,
        autocorrect: false,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(kJoinRoomCodeLength),
        ],
        decoration: synaxisSciFiInputDecoration(home, hint: '6-character code'),
        validator: validateJoinRoomCode,
        onChanged: onChanged,
      ),
    );
  }
}
