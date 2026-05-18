import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/experience.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';
import '../state/auth_state.dart';
import '../utils/feed_query.dart';
import '../widgets/topic_filter_bar.dart';
import 'analytics/analytics_screen.dart';
import 'compose_screen.dart';
import 'experience_detail_screen.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';

enum _ShellOverlay { none, compose, detail }

class StoryHomePage extends StatefulWidget {
  const StoryHomePage({
    super.key,
    required this.authState,
    required this.currentUser,
    required this.onLogout,
  });

  final AuthState authState;
  final User currentUser;
  final VoidCallback onLogout;

  @override
  State<StoryHomePage> createState() => _StoryHomePageState();
}

class _StoryHomePageState extends State<StoryHomePage> {
  final TextEditingController _searchController = TextEditingController();
  int _sectionIndex = 0;
  bool _newestFirst = true;
  _ShellOverlay _overlay = _ShellOverlay.none;
  Experience? _detailExperience;
  String? _selectedTopicId;

  List<Experience> _experiences = [];
  StreamSubscription<List<Experience>>? _expSub;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _subscribeExperiences();
  }

  void _subscribeExperiences() {
    _expSub?.cancel();
    final topicId = _sectionIndex == 0 ? _selectedTopicId : null;
    _expSub = FirestoreService.instance
        .experiencesStream(topicId: topicId)
        .listen((list) {
      if (mounted) setState(() => _experiences = list);
    });
  }

  void _onTopicFilterChanged(String? topicId) {
    setState(() => _selectedTopicId = topicId);
    _subscribeExperiences();
  }

  @override
  void didUpdateWidget(covariant StoryHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUser.id != widget.currentUser.id) {
      _sectionIndex = 0;
      _searchController.clear();
      _overlay = _ShellOverlay.none;
      _detailExperience = null;
      _selectedTopicId = null;
      _subscribeExperiences();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _expSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<Experience> get _tabExperiences {
    if (_sectionIndex == 0) return List<Experience>.from(_experiences);
    return _experiences
        .where((e) => e.ownerUserId == widget.currentUser.id)
        .toList();
  }

  List<Experience> get _feedExperiences {
    final filtered =
        filterExperiencesBySearch(_tabExperiences, _searchController.text);
    return sortExperiencesByDate(filtered, newestFirst: _newestFirst);
  }

  bool get _showSearchEmpty {
    final q = _searchController.text.trim();
    if (q.isEmpty) return false;
    return _feedExperiences.isEmpty && _tabExperiences.isNotEmpty;
  }

  bool get _onProfileTab => _sectionIndex == 2;

  void _logoutFromShell() {
    widget.onLogout();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.authLoggedOut)),
    );
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) return false;
    final wasCompose = _overlay == _ShellOverlay.compose;
    final shared = result == true;
    setState(() {
      if (_overlay == _ShellOverlay.detail) _detailExperience = null;
      _overlay = _ShellOverlay.none;
    });
    if (wasCompose && shared && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.snackStoryShared)),
        );
      });
    }
    return true;
  }

  void _openCompose() => setState(() => _overlay = _ShellOverlay.compose);

  void _openAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()),
    );
  }

  void _openDetail(Experience experience) {
    setState(() {
      _detailExperience = experience;
      _overlay = _ShellOverlay.detail;
    });
  }

  void _removeExperience(Experience experience) {
    FirestoreService.instance.deleteExperience(experience.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.snackStoryRemoved)),
    );
  }

  void _onPostDeletedFromDetail() {
    setState(() {
      _detailExperience = null;
      _overlay = _ShellOverlay.none;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.snackStoryRemoved)),
    );
  }

  PreferredSizeWidget get _searchBarBottom {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
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
    );
  }

  PreferredSizeWidget get _profileAppBar {
    return AppBar(
      title: const Text(AppStrings.profileTitle),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        IconButton(
          tooltip: AppStrings.authLogoutTooltip,
          onPressed: _logoutFromShell,
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  PreferredSizeWidget get _homeAppBar {
    return AppBar(
      title: const Text(AppStrings.homeAppBarTitle),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      bottom: _searchBarBottom,
      actions: [
        IconButton(
          tooltip: AppStrings.analyticsTooltip,
          onPressed: _openAnalytics,
          icon: const Icon(Icons.bar_chart_rounded),
        ),
        IconButton(
          tooltip: _newestFirst
              ? AppStrings.sortNewestTooltip
              : AppStrings.sortOldestTooltip,
          onPressed: () => setState(() => _newestFirst = !_newestFirst),
          icon: Icon(_newestFirst ? Icons.south : Icons.north),
        ),
        IconButton(
          tooltip: AppStrings.authLogoutTooltip,
          onPressed: _logoutFromShell,
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  Widget _buildFeedWithTopicBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_sectionIndex == 0) ...[
          const SizedBox(height: 8),
          TopicFilterBar(
            selectedTopicId: _selectedTopicId,
            onTopicSelected: _onTopicFilterChanged,
          ),
          const SizedBox(height: 4),
        ],
        Expanded(
          child: FeedScreen(
            experiences: _feedExperiences,
            sessionUserId: widget.currentUser.id,
            onExperienceTap: _openDetail,
            onDismissOwnExperience: _removeExperience,
            showMyPostsEmptyMessage: _sectionIndex == 1,
            showNoSearchResults: _showSearchEmpty,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _overlay != _ShellOverlay.none
          ? null
          : (_onProfileTab ? _profileAppBar : _homeAppBar),
      body: _onProfileTab
          ? ProfileScreen(
              user: widget.currentUser,
              authState: widget.authState,
              onProfileChanged: () => setState(() {}),
              onLogout: _logoutFromShell,
            )
          : Navigator(
              pages: [
                MaterialPage<void>(
                  key: const ValueKey<String>('shell_feed'),
                  child: _buildFeedWithTopicBar(),
                ),
                if (_overlay == _ShellOverlay.compose)
                  MaterialPage<void>(
                    key: const ValueKey<String>('shell_compose'),
                    child: ComposeScreen(
                      ownerUserId: widget.currentUser.id,
                      authorHandle: widget.currentUser.anonymousHandle,
                      onLogout: _logoutFromShell,
                    ),
                  ),
                if (_overlay == _ShellOverlay.detail &&
                    _detailExperience != null)
                  MaterialPage<void>(
                    key: ValueKey<String>(
                        'shell_detail_${_detailExperience!.id}'),
                    child: ExperienceDetailScreen(
                      experience: _detailExperience!,
                      sessionUserId: widget.currentUser.id,
                      sessionAuthorHandle: widget.currentUser.anonymousHandle,
                      onLogout: _logoutFromShell,
                      onPostDeleted: _onPostDeletedFromDetail,
                    ),
                  ),
              ],
              // ignore: deprecated_member_use
              onPopPage: _onPopPage,
            ),
      floatingActionButton:
          _overlay == _ShellOverlay.none && !_onProfileTab
              ? FloatingActionButton(
                  onPressed: _openCompose,
                  tooltip: AppStrings.shareFabTooltip,
                  child: const Icon(Icons.edit_note),
                )
              : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _sectionIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _sectionIndex = index;
            _overlay = _ShellOverlay.none;
            _detailExperience = null;
          });
          _subscribeExperiences();
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
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts),
            label: AppStrings.navProfileLabel,
          ),
        ],
      ),
    );
  }
}
