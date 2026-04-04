import 'package:flutter_test/flutter_test.dart';

import 'package:synaxis/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('SYNAXIS'), findsOneWidget);
    expect(find.text('CREATE ROOM'), findsOneWidget);
    expect(find.text('JOIN ROOM'), findsOneWidget);
  });
}
