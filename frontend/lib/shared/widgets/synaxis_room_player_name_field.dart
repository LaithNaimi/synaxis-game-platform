import 'package:flutter/material.dart';

import '../../app/theme/home_screen_theme.dart';
import 'synaxis_room_form_layout.dart';
import 'synaxis_sci_fi_input_decoration.dart';

/// PLAYER NAME + nickname field (create/join room).
class SynaxisRoomPlayerNameField extends StatelessWidget {
  const SynaxisRoomPlayerNameField({
    super.key,
    required this.controller,
    required this.home,
    required this.labelTextStyle,
    required this.maxLength,
    required this.validator,
    required this.onChanged,
  });

  final TextEditingController controller;
  final HomeScreenTheme home;
  final TextStyle? labelTextStyle;
  final int maxLength;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SynaxisLabeledSciFiField(
      label: 'PLAYER NAME',
      labelTextStyle: labelTextStyle,
      field: TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: 1,
        style: labelTextStyle,
        cursorColor: home.accentCyan,
        decoration: synaxisSciFiInputDecoration(
          home,
          hint: 'Enter your nickname',
        ).copyWith(counterText: ''),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}
