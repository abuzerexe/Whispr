import '../models/experience.dart';
import '../models/user.dart';
import 'seed_users.dart';

/// Two sample stories per built-in seed account ([User.id] + [User.anonymousHandle]).
/// Home shows everyone’s posts; “My posts” filters by the signed-in user.
List<Experience> buildGlobalDemoExperiencesForSeedUsers() {
  final users = buildSeedUsers();
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);

  final List<Experience> out = [];

  void addPair(
    User u,
    int slot, {
    required String titleA,
    required String bodyA,
    required String titleB,
    required String bodyB,
  }) {
    final tA = now.subtract(Duration(hours: 6 + slot * 4));
    final tB = startOfToday
        .subtract(Duration(days: 1 + slot))
        .add(Duration(hours: 10 + slot, minutes: 20));
    out.add(
      Experience(
        id: 'demo_${u.id}_a',
        ownerUserId: u.id,
        authorHandle: u.anonymousHandle,
        title: titleA,
        body: bodyA,
        createdAt: tA,
      ),
    );
    out.add(
      Experience(
        id: 'demo_${u.id}_b',
        ownerUserId: u.id,
        authorHandle: u.anonymousHandle,
        title: titleB,
        body: bodyB,
        createdAt: tB,
      ),
    );
  }

  addPair(
    users[0],
    0,
    titleA: 'The last doors on the last train',
    bodyA:
        'The car was almost empty. Someone across from me looked up once, '
        'nodded like we’d agreed on a secret, and went back to their phone. '
        'I still think about that nod.',
    titleB: 'The corner shop still had my favorite candy',
    bodyB:
        'I hadn’t been there in years. The owner didn’t recognize me, which was '
        'the point. I bought two bars, ate one on the walk home, and felt '
        'strangely lighter.',
  );
  addPair(
    users[1],
    1,
    titleA: 'Wind tried to steal my sketchbook on the roof',
    bodyA:
        'I had to pin the pages with my knee and elbow. A loose sheet flew off '
        'and a stranger three floors down caught it, waved, and tucked it under '
        'a stone. I laughed harder than I had all week.',
    titleB: 'Rain wrote patterns on the bus window',
    bodyB:
        'I wasn’t going anywhere important. I watched droplets race and merge, '
        'and for twenty minutes the city felt like a quiet song.',
  );
  addPair(
    users[2],
    2,
    titleA: 'Someone traded momos for stories at the night market',
    bodyA:
        'The stall had a tiny chalkboard: “Tell me one true thing—get one free.” '
        'I mumbled something small about my grandmother. They slid a plate my '
        'way like it mattered.',
    titleB: 'The ferry left before I felt ready',
    bodyB:
        'I stood on the pier with coffee going cold. The horn was sharp; the '
        'water looked forgiving. I realized I could miss a boat and still be '
        'exactly where I needed to be.',
  );

  return out;
}
