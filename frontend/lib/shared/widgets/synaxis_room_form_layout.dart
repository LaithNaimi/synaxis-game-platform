import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/home_screen_theme.dart';
import '../constants/synaxis_assets.dart';
import 'synaxis_sci_fi_background.dart';

/// Max content width for room forms (matches prior [ConstrainedBox]).
const double kSynaxisRoomFormMaxWidth = 560;

/// Fixed top row — back only; scrollable body lives in [SynaxisRoomFormShell].
class SynaxisRoomBackBar extends StatelessWidget {
  const SynaxisRoomBackBar({
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

/// Neon screen title + logo (inside scroll area).
class SynaxisTitleLogoBlock extends StatelessWidget {
  const SynaxisTitleLogoBlock({super.key, this.title = 'CREATE ROOM'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
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
class SynaxisFormSectionLabel extends StatelessWidget {
  const SynaxisFormSectionLabel({
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

/// Section label + small gap + field (no trailing section spacing).
class SynaxisLabeledSciFiField extends StatelessWidget {
  const SynaxisLabeledSciFiField({
    super.key,
    required this.label,
    required this.labelTextStyle,
    required this.field,
  });

  final String label;
  final TextStyle? labelTextStyle;
  final Widget field;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SynaxisFormSectionLabel(text: label, labelTextStyle: labelTextStyle),
        const SizedBox(height: AppSpacing.xs),
        field,
      ],
    );
  }
}

/// Sci-fi background + keyboard padding + back bar + scrollable [Form].
class SynaxisRoomFormShell extends StatelessWidget {
  const SynaxisRoomFormShell({
    super.key,
    required this.formKey,
    required this.home,
    required this.onBack,
    required this.children,
  });

  final GlobalKey<FormState> formKey;
  final HomeScreenTheme home;
  final VoidCallback onBack;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SynaxisSciFiBackground(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SynaxisRoomBackBar(home: home, onBack: onBack),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: kSynaxisRoomFormMaxWidth,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
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
