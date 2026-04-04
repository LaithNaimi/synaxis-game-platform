import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/home_screen_theme.dart';
import '../home_assets.dart';

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: home.backgroundDeepNavy,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: home.backgroundDeepNavy,
        body: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: home.backgroundDeepNavy),
            Positioned.fill(
              child: Image.asset(
                HomeScreenAssets.backgroundPattern,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.medium,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SynaxisTitle(home: home),
                        const SizedBox(height: AppSpacing.md),
                        Semantics(
                          label: 'Synaxis logo',
                          child: Image.asset(
                            HomeScreenAssets.logo,
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
          ],
        ),
      ),
    );
  }
}

class _SynaxisTitle extends StatelessWidget {
  const _SynaxisTitle({required this.home});

  final HomeScreenTheme home;

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.orbitron(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: 4,
      color: home.onPrimaryText,
    );

    return Text(
      'SYNAXIS',
      textAlign: TextAlign.center,
      style: baseStyle.copyWith(
        shadows: [
          Shadow(
            color: home.titleGlowColor.withValues(alpha: 0.95),
            blurRadius: 24,
          ),
          Shadow(
            color: home.titleGlowColor.withValues(alpha: 0.55),
            blurRadius: 48,
          ),
        ],
      ),
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
