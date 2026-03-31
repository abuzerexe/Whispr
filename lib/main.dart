import 'package:flutter/material.dart';

import 'constants/app_strings.dart';
import 'screens/splash_screen.dart';
import 'screens/story_home_page.dart';

void main() {
  runApp(const MyApp(seedDemoData: true));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.seedDemoData = false,
    this.skipSplash = false,
  });

  /// When true, [StoryHomePage] starts with a few demo stories (still in-memory only).
  final bool seedDemoData;

  /// When true (e.g. in tests), [StoryHomePage] is shown immediately with no splash delay.
  final bool skipSplash;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
        ),
        useMaterial3: true,
      ),
      home: skipSplash
          ? StoryHomePage(seedDemoData: seedDemoData)
          : SplashScreen(seedDemoData: seedDemoData),
    );
  }
}
