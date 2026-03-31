import 'package:flutter/material.dart';

import 'models/experience.dart';
import 'screens/feed_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anonymous experiences',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anonymous experiences'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FeedScreen(experiences: _experiences),
    );
  }
}
