/// Anonymous reply on an experience (stored only in memory).
class Comment {
  const Comment({
    required this.id,
    required this.ownerUserId,
    required this.authorHandle,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String ownerUserId;
  final String authorHandle;
  final String body;
  final DateTime createdAt;
}
