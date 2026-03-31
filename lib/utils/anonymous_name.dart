import 'dart:math';

final List<String> anonymousAdjectives = [
  'Quiet',
  'Curious',
  'Wandering',
  'Thoughtful',
  'Bold',
  'Gentle',
  'Restless',
  'Sleepy',
  'Hopeful',
  'Lost',
];

final List<String> anonymousNouns = [
  'Traveler',
  'Student',
  'Dreamer',
  'Stranger',
  'Local',
  'NightOwl',
  'EarlyBird',
  'Storyteller',
  'Watcher',
  'Wanderer',
];

/// One random label per call; session handle is created once by the home shell.
String generateAnonymousName() {
  final random = Random();
  final a = anonymousAdjectives[random.nextInt(anonymousAdjectives.length)].trim();
  final n = anonymousNouns[random.nextInt(anonymousNouns.length)];
  final suffix = random.nextInt(900) + 100;
  return 'Anonymous $a$n$suffix';
}
