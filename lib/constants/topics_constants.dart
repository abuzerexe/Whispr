import '../models/topic.dart';

/// Whispr support topics (fixed set — keep in sync with [ModerationPrompts]).
const List<Map<String, dynamic>> kTopics = [
  {
    'id': 'domestic_violence',
    'label': 'Domestic Violence',
    'emoji': '🏠',
  },
  {
    'id': 'social_issues',
    'label': 'Social Issues',
    'emoji': '🌍',
  },
  {
    'id': 'self',
    'label': 'Self',
    'emoji': '🪞',
  },
  {
    'id': 'workplace_harassment',
    'label': 'Workplace Harassment',
    'emoji': '💼',
  },
  {
    'id': 'relationships',
    'label': 'Relationships',
    'emoji': '❤️',
  },
  {
    'id': 'personal_story',
    'label': 'Personal Story',
    'emoji': '📖',
  },
];

List<Topic> get kTopicList =>
    kTopics.map((m) => Topic.fromMap(m)).toList(growable: false);

Topic? topicById(String id) {
  for (final map in kTopics) {
    if (map['id'] == id) return Topic.fromMap(map);
  }
  return null;
}
