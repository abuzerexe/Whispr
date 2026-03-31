import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proj/main.dart';

void main() {
  testWidgets('feed shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('No stories yet'), findsOneWidget);
  });

  testWidgets('sharing a story shows body text on the feed', (WidgetTester tester) async {
    const sampleBody = 'My secret story';

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), sampleBody);
    await tester.pump();

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(find.text(sampleBody), findsOneWidget);
    expect(find.text('No stories yet'), findsNothing);
  });
}
