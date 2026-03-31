import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:proj/constants/app_strings.dart';
import 'package:proj/main.dart';

void main() {
  testWidgets('empty feed opens compose with correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(seedDemoData: false));

    expect(find.text(AppStrings.feedEmptyTitle), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.composeAppBarTitle), findsOneWidget);
  });

  testWidgets('sharing a story shows title and body on the feed', (WidgetTester tester) async {
    const sampleTitle = 'The night bus';
    const sampleBody = 'Something unforgettable happened on the way home.';

    await tester.pumpWidget(const MyApp(seedDemoData: false));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('compose_title_field')), sampleTitle);
    await tester.enterText(find.byKey(const Key('compose_body_field')), sampleBody);
    await tester.pump();

    await tester.tap(find.text(AppStrings.composeShare));
    await tester.pumpAndSettle();

    expect(find.text(sampleTitle), findsOneWidget);
    expect(find.text(sampleBody), findsOneWidget);
    expect(find.text(AppStrings.feedEmptyTitle), findsNothing);
  });

  testWidgets('My posts tab shows only session stories with demo seed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(seedDemoData: true));
    await tester.pumpAndSettle();

    expect(find.text('Seed: My session story'), findsOneWidget);
    expect(find.text('Seed: Stranger on the train'), findsOneWidget);
    expect(find.text('Seed: Late night café'), findsOneWidget);

    await tester.tap(find.text(AppStrings.navMyPostsLabel));
    await tester.pumpAndSettle();

    expect(find.text('Seed: My session story'), findsOneWidget);
    expect(find.text('Seed: Stranger on the train'), findsNothing);
    expect(find.text('Seed: Late night café'), findsNothing);
  });

  testWidgets('tap story opens detail and can post a comment', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(seedDemoData: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Seed: My session story'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(AppStrings.detailCommentsHeading),
      findsOneWidget,
    );

    const commentText = 'Nice demo story.';
    await tester.enterText(find.byType(TextField), commentText);
    await tester.pump();

    await tester.tap(find.text(AppStrings.detailCommentPost));
    await tester.pumpAndSettle();

    expect(find.text(commentText), findsOneWidget);
  });

  testWidgets('swipe-dismiss removes only own story from feed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(seedDemoData: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('dismiss_demo-seed-mine')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('dismiss_demo-seed-a')), findsNothing);
    expect(find.byKey(const ValueKey<String>('dismiss_demo-seed-b')), findsNothing);

    await tester.drag(
      find.byKey(const ValueKey<String>('dismiss_demo-seed-mine')),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seed: My session story'), findsNothing);

    expect(find.text('Seed: Stranger on the train'), findsOneWidget);
    expect(find.text('Seed: Late night café'), findsOneWidget);
  });
}
