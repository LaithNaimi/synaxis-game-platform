import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';

/// Entry screen (DDS §15.1). CTAs wired in FE-002.1.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Synaxis')),
      body: Center(
        child: Text('Home', style: AppTextStyles.title),
      ),
    );
  }
}
