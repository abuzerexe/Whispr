import 'package:flutter_test/flutter_test.dart';

import 'package:proj/main.dart';

void main() {
  testWidgets('feed shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('No stories yet'), findsOneWidget);
  });
}
