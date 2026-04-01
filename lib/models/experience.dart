import 'comment.dart';

/// One anonymous story in the in-memory feed.
class Experience {
  Experience({
    required this.id,
    required this.ownerUserId,
    required this.authorHandle,
    required this.title,
    required this.body,
    required this.createdAt,
    List<Comment>? comments,
  }) : comments = comments ?? <Comment>[];

  final String id;
  final String ownerUserId;
  final String authorHandle;
  final String title;
  final String body;
  final DateTime createdAt;
  final List<Comment> comments;
}
