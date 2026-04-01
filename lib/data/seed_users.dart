import '../models/user.dart';

List<User> buildSeedUsers() {
  return <User>[
    User(
      id: 'seed-u1',
      username: 'alex',
      email: 'alex@example.com',
      password: '1234',
      anonymousHandle: 'Anonymous QuietTraveler104',
    ),
    User(
      id: 'seed-u2',
      username: 'sara',
      email: 'sara@example.com',
      password: '1234',
      anonymousHandle: 'Anonymous BoldDreamer583',
    ),
    User(
      id: 'seed-u3',
      username: 'zayd',
      email: 'zayd@example.com',
      password: '1234',
      anonymousHandle: 'Anonymous GentleWatcher721',
    ),
  ];
}
