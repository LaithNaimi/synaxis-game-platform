import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:synaxis/app/theme/app_theme.dart';
import 'package:synaxis/features/room/presentation/screens/create_room_screen.dart';

void main() {
  testWidgets('CREATE ROOM submit is disabled until fields complete', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const CreateRoomScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final buttonFinder = find.byType(FilledButton);
    expect(buttonFinder, findsOneWidget);
    final button = tester.widget<FilledButton>(buttonFinder);
    expect(button.onPressed, isNull);
  });
}
