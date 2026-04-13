import 'package:flutter_test/flutter_test.dart';

import 'package:synaxis/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SynaxisApp());

    expect(find.text('Synaxis'), findsOneWidget);
  });
}
