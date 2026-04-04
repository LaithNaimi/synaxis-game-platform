import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:synaxis/app/router/app_router.dart';
import 'package:synaxis/features/room/presentation/screens/create_room_screen.dart';
import 'package:synaxis/features/room/presentation/screens/join_room_screen.dart';

void main() {
  testWidgets('Create Room navigates to CreateRoomScreen', (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CREATE ROOM'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateRoomScreen), findsOneWidget);
  });

  testWidgets('Join Room navigates to JoinRoomScreen', (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('JOIN ROOM'));
    await tester.pumpAndSettle();

    expect(find.byType(JoinRoomScreen), findsOneWidget);
  });
}
