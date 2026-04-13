import 'package:flutter/material.dart';
import '../../shared/widgets/synaxis_app_bar.dart';

class AppPageShell extends StatelessWidget {
  const AppPageShell({
    super.key,
    required this.title,
    required this.child,
    this.showBackButton = true,
  });

  final String title;
  final Widget child;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SynaxisAppBar(title: title, showBackButton: showBackButton),
          Expanded(child: child),
        ],
      ),
    );
  }
}
