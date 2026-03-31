import 'package:flutter/material.dart';

import 'constants/app_strings.dart';
import 'data/demo_seed.dart';
import 'models/experience.dart';
import 'screens/compose_screen.dart';
import 'screens/experience_detail_screen.dart';
import 'screens/feed_screen.dart';
import 'utils/anonymous_name.dart';

void main() {
  runApp(const MyApp(seedDemoData: true));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.seedDemoData = false,
  });

  /// When true, [StoryHomePage] starts with a few demo stories (still in-memory only).
  final bool seedDemoData;

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
      home: StoryHomePage(seedDemoData: seedDemoData),
    );
  }
}

class StoryHomePage extends StatefulWidget {
  const StoryHomePage({
    super.key,
    this.seedDemoData = false,
  });

  final bool seedDemoData;

  @override
  State<StoryHomePage> createState() => _StoryHomePageState();
}

class _StoryHomePageState extends State<StoryHomePage> {
  final List<Experience> _experiences = [];
  late final String _sessionAuthorHandle;
  int _sectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _sessionAuthorHandle = generateAnonymousName();
    if (widget.seedDemoData) {
      _experiences.addAll(buildDemoExperiences(_sessionAuthorHandle));
    }
  }

  List<Experience> get _visibleExperiences {
    if (_sectionIndex == 0) {
      return List<Experience>.from(_experiences);
    }
    return _experiences
        .where((e) => e.authorHandle == _sessionAuthorHandle)
        .toList();
  }

  void _openCompose() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ComposeScreen(
          authorHandle: _sessionAuthorHandle,
          onAddExperience: (Experience e) {
            setState(() => _experiences.insert(0, e));
          },
        ),
      ),
    );
  }

  void _openDetail(Experience experience) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ExperienceDetailScreen(
          experience: experience,
          sessionAuthorHandle: _sessionAuthorHandle,
          onAddComment: (comment) => experience.comments.add(comment),
        ),
      ),
    );
  }

  void _removeExperience(Experience experience) {
    setState(() {
      _experiences.removeWhere((e) => e.id == experience.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeAppBarTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FeedScreen(
        experiences: _visibleExperiences,
        sessionAuthorHandle: _sessionAuthorHandle,
        onExperienceTap: _openDetail,
        onDismissOwnExperience: _removeExperience,
        showMyPostsEmptyMessage: _sectionIndex == 1,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCompose,
        tooltip: AppStrings.shareFabTooltip,
        child: const Icon(Icons.edit_note),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _sectionIndex,
        onDestinationSelected: (int index) {
          setState(() => _sectionIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: AppStrings.navFeedLabel,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.navMyPostsLabel,
          ),
        ],
      ),
    );
  }
}
