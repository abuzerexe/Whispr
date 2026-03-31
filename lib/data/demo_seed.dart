import '../models/experience.dart';

/// Builds three in-memory demo stories: two “other” authors and one using [sessionHandle].
List<Experience> buildDemoExperiences(String sessionHandle) {
  final t0 = DateTime(2024, 1, 10, 9, 0);
  final t1 = DateTime(2024, 1, 10, 10, 0);
  final t2 = DateTime(2024, 1, 10, 11, 0);

  return [
    Experience(
      id: 'demo-seed-mine',
      authorHandle: sessionHandle,
      title: 'Seed: My session story',
      body: 'This one uses your session label so it appears under My posts.',
      createdAt: t2,
    ),
    Experience(
      id: 'demo-seed-b',
      authorHandle: 'Anonymous DemoReader204',
      title: 'Seed: Stranger on the train',
      body: 'A short demo story from another anonymous voice.',
      createdAt: t1,
    ),
    Experience(
      id: 'demo-seed-a',
      authorHandle: 'Anonymous DemoWatcher718',
      title: 'Seed: Late night café',
      body: 'Another demo card for the shared feed.',
      createdAt: t0,
    ),
  ];
}
