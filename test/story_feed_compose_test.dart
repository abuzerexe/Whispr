import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proj/constants/app_strings.dart';
import 'package:proj/main.dart';

void main() {
  testWidgets('empty feed opens compose with correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text(AppStrings.feedEmptyTitle), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.composeAppBarTitle), findsOneWidget);
  });

  testWidgets('sharing a story shows body text on the feed', (WidgetTester tester) async {
    const sampleBody = 'My secret story';

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), sampleBody);
    await tester.pump();

    await tester.tap(find.text(AppStrings.composeShare));
    await tester.pumpAndSettle();

    expect(find.text(sampleBody), findsOneWidget);
    expect(find.text(AppStrings.feedEmptyTitle), findsNothing);
  });
}
