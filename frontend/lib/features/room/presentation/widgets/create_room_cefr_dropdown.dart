// DropdownButtonFormField: `value` for controlled state; SDK flags `initialValue`
// migration — revisit when project pins a stable FormField API.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../../app/theme/home_screen_theme.dart';
import '../../../../shared/widgets/synaxis_sci_fi_input_decoration.dart';
import '../create_room_constants.dart';
import '../create_room_validators.dart';

class CreateRoomCefrDropdown extends StatelessWidget {
  const CreateRoomCefrDropdown({
    super.key,
    required this.home,
    required this.value,
    required this.labelTextStyle,
    required this.onChanged,
  });

  final HomeScreenTheme home;
  final String? value;
  final TextStyle? labelTextStyle;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        'Select level',
        style: TextStyle(color: home.accentCyan.withValues(alpha: 0.5)),
      ),
      dropdownColor: home.backgroundDeepNavy,
      iconEnabledColor: home.accentCyan,
      style: labelTextStyle,
      decoration: synaxisSciFiInputDecoration(home),
      items: kCefrLevels
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: validateCreateRoomDropdown,
    );
  }
}
