import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

/// Entry screen (DDS §15.1). CTAs wired in FE-002.1.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Synaxis')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: Text('Home', style: textTheme.titleLarge),
        ),
      ),
    );
  }
}
