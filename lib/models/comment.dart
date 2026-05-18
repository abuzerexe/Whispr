import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Comment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Comment(
      id: doc.id,
      ownerUserId: data['ownerUserId'] as String? ?? '',
      authorHandle: data['authorHandle'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'ownerUserId': ownerUserId,
        'authorHandle': authorHandle,
        'body': body,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
