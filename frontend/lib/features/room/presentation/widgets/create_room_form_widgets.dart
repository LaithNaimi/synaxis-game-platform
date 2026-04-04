import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/home_screen_theme.dart';
import '../../../../shared/constants/synaxis_assets.dart';
import '../../../../shared/widgets/synaxis_sci_fi_input_decoration.dart';

/// Fixed top row — back only (scrollable content lives below in [Expanded]).
class CreateRoomBackBar extends StatelessWidget {
  const CreateRoomBackBar({
    super.key,
    required this.home,
    required this.onBack,
  });

  final HomeScreenTheme home;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: home.onPrimaryText,
          ),
          onPressed: onBack,
        ),
      ),
    );
  }
}

/// Neon screen title + logo (inside [SingleChildScrollView]).
class CreateRoomTitleLogoBlock extends StatelessWidget {
  const CreateRoomTitleLogoBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CREATE ROOM',
          textAlign: TextAlign.center,
          style: SynaxisNeonTitleStyles.screenTitle(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Semantics(
            label: 'Synaxis logo',
            child: Image.asset(
              SynaxisAssets.logo,
              height: 56,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ],
    );
  }
}

/// Uppercase section label above a field.
class CreateRoomFormSectionLabel extends StatelessWidget {
  const CreateRoomFormSectionLabel({
    super.key,
    required this.text,
    required this.labelTextStyle,
  });

  final String text;
  final TextStyle? labelTextStyle;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: labelTextStyle?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

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

/// Primary CTA row (Orbitron + lock) for create room.
class CreateRoomSubmitBar extends StatelessWidget {
  const CreateRoomSubmitBar({
    super.key,
    required this.home,
    required this.canSubmit,
    required this.onSubmit,
    this.minHeight = 48,
  });

  final HomeScreenTheme home;
  final bool canSubmit;
  final VoidCallback onSubmit;
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
            Text('CREATE ROOM', style: orbitronButton),
          ],
        ),
      ),
    );
  }
}
