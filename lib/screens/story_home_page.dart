import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../data/demo_seed.dart';
import '../models/experience.dart';
import '../utils/anonymous_name.dart';
import '../utils/feed_query.dart';
import 'compose_screen.dart';
import 'experience_detail_screen.dart';
import 'feed_screen.dart';

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
  final TextEditingController _searchController = TextEditingController();
  late final String _sessionAuthorHandle;
  int _sectionIndex = 0;
  bool _newestFirst = true;

  @override
  void initState() {
    super.initState();
    _sessionAuthorHandle = generateAnonymousName();
    if (widget.seedDemoData) {
      _experiences.addAll(buildDemoExperiences(_sessionAuthorHandle));
    }
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Experience> get _tabExperiences {
    if (_sectionIndex == 0) {
      return List<Experience>.from(_experiences);
    }
    return _experiences
        .where((e) => e.authorHandle == _sessionAuthorHandle)
        .toList();
  }

  List<Experience> get _feedExperiences {
    final filtered = filterExperiencesBySearch(
      _tabExperiences,
      _searchController.text,
    );
    return sortExperiencesByDate(filtered, newestFirst: _newestFirst);
  }

  bool get _showSearchEmpty {
    final q = _searchController.text.trim();
    if (q.isEmpty) return false;
    return _feedExperiences.isEmpty && _tabExperiences.isNotEmpty;
  }

  Future<void> _openCompose() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => ComposeScreen(
          authorHandle: _sessionAuthorHandle,
          onAddExperience: (Experience e) {
            setState(() => _experiences.insert(0, e));
          },
        ),
      ),
    );
    if (!mounted) return;
    if (added == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.snackStoryShared)),
      );
    }
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.snackStoryRemoved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeAppBarTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 22),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: _newestFirst
                ? AppStrings.sortNewestTooltip
                : AppStrings.sortOldestTooltip,
            onPressed: () {
              setState(() => _newestFirst = !_newestFirst);
            },
            icon: Icon(
              _newestFirst ? Icons.south : Icons.north,
            ),
          ),
        ],
      ),
      body: FeedScreen(
        experiences: _feedExperiences,
        sessionAuthorHandle: _sessionAuthorHandle,
        onExperienceTap: _openDetail,
        onDismissOwnExperience: _removeExperience,
        showMyPostsEmptyMessage: _sectionIndex == 1,
        showNoSearchResults: _showSearchEmpty,
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
