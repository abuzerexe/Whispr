import 'package:cloud_firestore/cloud_firestore.dart';

class Experience {
  Experience({
    required this.id,
    required this.ownerUserId,
    required this.authorHandle,
    required this.title,
    required this.body,
    required this.createdAt,
    this.topicId,
    this.topicLabel,
    this.topicEmoji,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
  });

  final String id;
  final String ownerUserId;
  final String authorHandle;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? topicId;
  final String? topicLabel;
  final String? topicEmoji;
  final int upvoteCount;
  final int downvoteCount;

  int get score => upvoteCount - downvoteCount;

  bool get hasTopic =>
      topicId != null && topicId!.isNotEmpty && topicLabel != null;

  factory Experience.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Experience(
      id: doc.id,
      ownerUserId: data['ownerUserId'] as String? ?? '',
      authorHandle: data['authorHandle'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      topicId: data['topicId'] as String?,
      topicLabel: data['topicLabel'] as String?,
      topicEmoji: data['topicEmoji'] as String?,
      upvoteCount: (data['upvoteCount'] as num?)?.toInt() ?? 0,
      downvoteCount: (data['downvoteCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'ownerUserId': ownerUserId,
      'authorHandle': authorHandle,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'upvoteCount': upvoteCount,
      'downvoteCount': downvoteCount,
    };
    if (topicId != null) {
      map['topicId'] = topicId;
      map['topicLabel'] = topicLabel;
      map['topicEmoji'] = topicEmoji;
    }
    return map;
  }
}
