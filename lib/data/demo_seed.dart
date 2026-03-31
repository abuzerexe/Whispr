import '../models/experience.dart';

/// Builds three in-memory demo stories: two “other” authors and one using [sessionHandle].
/// Uses times near [DateTime.now] so feed labels look like “today”, “yesterday”, etc.
List<Experience> buildDemoExperiences(String sessionHandle) {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);

  final tMine = now.subtract(const Duration(hours: 2, minutes: 12));
  final tB = startOfToday
      .subtract(const Duration(days: 1))
      .add(const Duration(hours: 15, minutes: 40));
  final tA = startOfToday
      .subtract(const Duration(days: 3))
      .add(const Duration(hours: 11, minutes: 5));

  return [
    Experience(
      id: 'demo-seed-mine',
      authorHandle: sessionHandle,
      title: 'Seed: My session story',
      body: 'This one uses your session label so it appears under My posts.',
      createdAt: tMine,
    ),
    Experience(
      id: 'demo-seed-b',
      authorHandle: 'Anonymous DemoReader204',
      title: 'Seed: Stranger on the train',
      body: 'A short demo story from another anonymous voice.',
      createdAt: tB,
    ),
    Experience(
      id: 'demo-seed-a',
      authorHandle: 'Anonymous DemoWatcher718',
      title: 'Seed: Late night café',
      body: 'Another demo card for the shared feed.',
      createdAt: tA,
    ),
  ];
}
