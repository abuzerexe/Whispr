import 'dart:math';

final List<String> _handleAdjectives = [
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
  'Swift',
  'Faded',
  'Silver',
  'Amber',
  'Distant',
  'Calm',
  'Vivid',
  'Soft',
  'Hollow',
  'Misty',
];

final List<String> _handleNouns = [
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
  'River',
  'Echo',
  'Harbor',
  'Maple',
  'Canvas',
  'Pixel',
  'Frost',
  'Ember',
  'Cinder',
];

String generateAnonymousName({int? entropy}) {
  final random = Random(
    (entropy ?? DateTime.now().microsecondsSinceEpoch) ^
        Object.hash(
          DateTime.now().microsecondsSinceEpoch,
          identityHashCode(_handleAdjectives),
        ),
  );
  final a = _handleAdjectives[random.nextInt(_handleAdjectives.length)].trim();
  final n = _handleNouns[random.nextInt(_handleNouns.length)];
  final suffix = random.nextInt(900) + 100;
  return '$a$n$suffix';
}
