import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// Consistent scaffold + AppBar for non-home MVP routes (FE-001.3).
/// Session guards / redirects attach later at [GoRouter] level (DDS §7).
class AppPageShell extends StatelessWidget {
  const AppPageShell({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.home);
            }
          },
        ),
        title: Text(title),
      ),
      body: child,
    );
  }
}
