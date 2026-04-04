import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/home_screen_theme.dart';
import '../constants/synaxis_assets.dart';

/// Deep navy + wireframe pattern + status bar styling (shared by Home / Create Room).
class SynaxisSciFiBackground extends StatelessWidget {
  const SynaxisSciFiBackground({super.key, required this.child});

  final Widget child;

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
                SynaxisAssets.backgroundPattern,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.medium,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
