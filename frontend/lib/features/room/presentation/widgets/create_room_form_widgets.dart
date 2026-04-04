import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/home_screen_theme.dart';
import '../../../../shared/widgets/synaxis_sci_fi_input_decoration.dart';

/// Numeric-only field with shared sci-fi decoration.
class CreateRoomDigitsTextField extends StatelessWidget {
  const CreateRoomDigitsTextField({
    super.key,
    required this.controller,
    required this.home,
    required this.labelTextStyle,
    required this.hint,
    required this.validator,
    required this.onChanged,
  });

  final TextEditingController controller;
  final HomeScreenTheme home;
  final TextStyle? labelTextStyle;
  final String hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: labelTextStyle,
      cursorColor: home.accentCyan,
      decoration: synaxisSciFiInputDecoration(home, hint: hint),
      validator: validator,
      onChanged: onChanged,
    );
  }
}

/// Primary CTA row (Orbitron + lock) for create/join room flows.
class CreateRoomSubmitBar extends StatelessWidget {
  const CreateRoomSubmitBar({
    super.key,
    required this.home,
    required this.canSubmit,
    required this.onSubmit,
    this.buttonLabel = 'CREATE ROOM',
    this.minHeight = 48,
  });

  final HomeScreenTheme home;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final String buttonLabel;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final orbitronButton = GoogleFonts.orbitron(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
      color: home.onPrimaryText,
    );

    return SizedBox(
      width: double.infinity,
      height: minHeight,
      child: FilledButton(
        onPressed: canSubmit ? onSubmit : null,
        style: FilledButton.styleFrom(
          backgroundColor: home.primaryButtonTeal,
          foregroundColor: home.onPrimaryText,
          disabledBackgroundColor: home.primaryButtonTeal.withValues(
            alpha: 0.35,
          ),
          disabledForegroundColor: home.onPrimaryText.withValues(alpha: 0.45),
          elevation: canSubmit ? 6 : 0,
          shadowColor: home.accentCyan.withValues(alpha: 0.45),
          minimumSize: Size(double.infinity, minHeight),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: home.onPrimaryText.withValues(alpha: canSubmit ? 1 : 0.45),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(buttonLabel, style: orbitronButton),
          ],
        ),
      ),
    );
  }
}
