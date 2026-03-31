/// One anonymous story in the in-memory feed.
class Experience {
  const Experience({
    required this.id,
    required this.authorHandle,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String authorHandle;
  final String body;
  final DateTime createdAt;
}
