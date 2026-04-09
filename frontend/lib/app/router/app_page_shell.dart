import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/nebula_background.dart';
import '../../shared/widgets/synaxis_app_bar.dart';
import 'route_names.dart';

/// Scaffold wrapper with [SynaxisAppBar] and [NebulaBackground] for non-home routes.
///
/// Provides consistent dark-space aesthetic across all screens.
class AppPageShell extends StatelessWidget {
  const AppPageShell({
    super.key,
    required this.title,
    required this.child,
    this.showBackButton = true,
    this.appBarTrailing,
    this.appBarCenterContent,
  });

  final String title;
  final Widget child;
  final bool showBackButton;
  final Widget? appBarTrailing;
  final Widget? appBarCenterContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: NebulaBackground(
        child: Column(
          children: [
            SynaxisAppBar(
              title: title,
              showBackButton: showBackButton,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RouteNames.home);
                }
              },
              trailing: appBarTrailing,
              centerContent: appBarCenterContent,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
