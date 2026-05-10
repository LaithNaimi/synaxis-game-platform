import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: SynaxisApp()));
}

class SynaxisApp extends StatelessWidget {
  const SynaxisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Synaxis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: appRouter,
    );
  }
}

// you are a senior code alasyze who can analyze the flow of data and explain it in simple way and at a low level, i want u to help me to understand this files and how they work together i have low knowledge about the consepts that these files contain so i want first to explain to me all the concepts that  these files use it, then explain files based on data flow  with simple way to understand it.

// do it in Arabic
