import 'package:flutter/material.dart';

/// Returns the brand colour for each topic ID.
/// These colours are used in every chart and legend in the analytics screen.
class TopicColors {
  TopicColors._();

  static const Map<String, Color> _map = {
    'domestic_violence': Color(0xFFE05C5C),
    'self': Color(0xFF7C6FCD),
    'workplace_harassment': Color(0xFFE8964D),
    'social_issues': Color(0xFF4EADD4),
    'relationships': Color(0xFFE97FA8),
    'personal_story': Color(0xFF56C596),
  };

  static Color of(String topicId) => _map[topicId] ?? Colors.grey;

  static List<Color> get allColors => _map.values.toList();
}
