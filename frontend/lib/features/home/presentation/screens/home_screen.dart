import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/home_screen_theme.dart';
import '../../../../shared/constants/synaxis_assets.dart';
import '../../../../shared/widgets/synaxis_sci_fi_background.dart';

/// Minimum tap height for primary/secondary CTAs (Material / a11y).
const double _kHomeCtaMinHeight = 48;

/// Entry screen — dark sci-fi layout with Orbitron + branded assets.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home =
        Theme.of(context).extension<HomeScreenTheme>() ??
        HomeScreenTheme.synaxis;

    return SynaxisSciFiBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _SynaxisTitle(),
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    label: 'Synaxis logo',
                    child: Image.asset(
                      SynaxisAssets.logo,
                      height: 96,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _CreateRoomButton(home: home),
                  const SizedBox(height: AppSpacing.md),
                  _JoinRoomButton(home: home),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SynaxisTitle extends StatelessWidget {
  const _SynaxisTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'SYNAXIS',
      textAlign: TextAlign.center,
      style: SynaxisNeonTitleStyles.gameName(),
    );
  }
}

class _CreateRoomButton extends StatelessWidget {
  const _CreateRoomButton({required this.home});

  final HomeScreenTheme home;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.orbitron(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: home.onPrimaryText,
    );

    return SizedBox(
      width: double.infinity,
      height: _kHomeCtaMinHeight,
      child: FilledButton(
        onPressed: () => context.go(RouteNames.createRoom),
        style: FilledButton.styleFrom(
          backgroundColor: home.primaryButtonTeal,
          foregroundColor: home.onPrimaryText,
          elevation: 6,
          shadowColor: home.accentCyan.withValues(alpha: 0.45),
          minimumSize: const Size.fromHeight(_kHomeCtaMinHeight),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text('CREATE ROOM', style: labelStyle),
      ),
    );
  }
}

class _JoinRoomButton extends StatelessWidget {
  const _JoinRoomButton({required this.home});

  final HomeScreenTheme home;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.orbitron(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: home.onPrimaryText,
    );

    return SizedBox(
      width: double.infinity,
      height: _kHomeCtaMinHeight,
      child: OutlinedButton(
        onPressed: () => context.go(RouteNames.joinRoom),
        style: OutlinedButton.styleFrom(
          foregroundColor: home.onPrimaryText,
          side: BorderSide(color: home.accentCyan, width: 1.5),
          minimumSize: const Size.fromHeight(_kHomeCtaMinHeight),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text('JOIN ROOM', style: labelStyle),
      ),
    );
  }
}
