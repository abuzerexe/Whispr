import 'package:flutter/material.dart';

import 'constants/app_strings.dart';
import 'models/experience.dart';
import 'screens/compose_screen.dart';
import 'screens/feed_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
        ),
        useMaterial3: true,
      ),
      home: const StoryHomePage(),
    );
  }
}

class StoryHomePage extends StatefulWidget {
  const StoryHomePage({super.key});

  @override
  State<StoryHomePage> createState() => _StoryHomePageState();
}

class _StoryHomePageState extends State<StoryHomePage> {
  final List<Experience> _experiences = [];

  void _openCompose() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ComposeScreen(
          onAddExperience: (Experience e) {
            setState(() => _experiences.insert(0, e));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeAppBarTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FeedScreen(experiences: _experiences),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCompose,
        tooltip: AppStrings.shareFabTooltip,
        child: const Icon(Icons.edit_note),
      ),
    );
  }
}
