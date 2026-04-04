import 'package:flutter_test/flutter_test.dart';

import 'package:synaxis/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Synaxis'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
