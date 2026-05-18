class Topic {
  final String id;
  final String label;
  final String emoji;

  const Topic({required this.id, required this.label, required this.emoji});

  factory Topic.fromMap(Map<String, dynamic> map) => Topic(
        id: map['id'] as String,
        label: map['label'] as String,
        emoji: map['emoji'] as String,
      );

  Map<String, dynamic> toMap() => {'id': id, 'label': label, 'emoji': emoji};
}
