import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment.dart';
import '../models/experience.dart';
import '../models/user.dart';

const Set<String> _transientFirestoreCodes = {
  'unavailable',
  'deadline-exceeded',
  'aborted',
  'resource-exhausted',
};

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _experiences =>
      _db.collection('experiences');

  Future<T> _withTransientRetry<T>(Future<T> Function() operation) async {
    const attempts = 5;
    FirebaseException? lastTransient;
    for (var attempt = 0; attempt < attempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(
          Duration(milliseconds: 350 * (1 << (attempt - 1))),
        );
      }
      try {
        return await operation();
      } on FirebaseException catch (e) {
        if (!_transientFirestoreCodes.contains(e.code)) {
          rethrow;
        }
        lastTransient = e;
      }
    }
    throw lastTransient!;
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  Future<void> createUser(User user) => _withTransientRetry(
        () => _users.doc(user.id).set(user.toFirestore()),
      );

  Future<User?> getUser(String uid) {
    return _withTransientRetry<User?>(() async {
      final doc = await _users.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return User.fromFirestore(uid, doc.data()!);
    });
  }

  Future<void> updateUsername(String uid, String username) =>
      _withTransientRetry(() => _users.doc(uid).update({'username': username}));

  // ── Experiences ────────────────────────────────────────────────────────────

  Stream<List<Experience>> experiencesStream({String? topicId}) {
    Query<Map<String, dynamic>> query = _experiences;
    if (topicId != null) {
      query = query.where('topicId', isEqualTo: topicId);
    }
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map(Experience.fromFirestore).toList(),
        );
  }

  Future<void> addExperience(Experience exp) =>
      _experiences.add(exp.toFirestore());

  Future<void> deleteExperience(String id) async {
    final expRef = _experiences.doc(id);
    final commentsSnap = await expRef.collection('comments').get();
    final votesSnap = await expRef.collection('votes').get();
    final batch = _db.batch();
    for (final doc in commentsSnap.docs) {
      batch.delete(doc.reference);
    }
    for (final doc in votesSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(expRef);
    await batch.commit();
  }

  Stream<Experience?> experienceStream(String id) {
    return _experiences.doc(id).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return Experience.fromFirestore(snap);
    });
  }

  Stream<int?> userVoteStream(String experienceId, String userId) {
    return _experiences
        .doc(experienceId)
        .collection('votes')
        .doc(userId)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return (snap.data()!['value'] as num?)?.toInt();
    });
  }

  /// Reddit-style vote: [direction] is `1` (up) or `-1` (down).
  /// Tapping the same direction again removes the vote; opposite switches.
  Future<void> voteOnExperience({
    required String experienceId,
    required String userId,
    required int direction,
  }) async {
    assert(direction == 1 || direction == -1);
    final expRef = _experiences.doc(experienceId);
    final voteRef = expRef.collection('votes').doc(userId);

    await _withTransientRetry(() async {
      await _db.runTransaction((tx) async {
        final expSnap = await tx.get(expRef);
        if (!expSnap.exists) {
          throw StateError('Post not found');
        }

        final voteSnap = await tx.get(voteRef);
        final currentVote = voteSnap.exists
            ? (voteSnap.data()!['value'] as num?)?.toInt()
            : null;

        var up = (expSnap.data()!['upvoteCount'] as num?)?.toInt() ?? 0;
        var down = (expSnap.data()!['downvoteCount'] as num?)?.toInt() ?? 0;

        int? nextVote;
        if (currentVote == direction) {
          nextVote = null;
        } else {
          nextVote = direction;
        }

        if (currentVote == 1) up--;
        if (currentVote == -1) down--;
        if (nextVote == 1) up++;
        if (nextVote == -1) down++;

        if (up < 0 || down < 0) {
          throw StateError('Invalid vote counts');
        }

        tx.update(expRef, {
          'upvoteCount': up,
          'downvoteCount': down,
        });

        if (nextVote == null) {
          if (voteSnap.exists) tx.delete(voteRef);
        } else {
          tx.set(voteRef, {'value': nextVote});
        }
      });
    });
  }

  // ── Comments ───────────────────────────────────────────────────────────────

  Stream<List<Comment>> commentsStream(String experienceId) {
    return _experiences
        .doc(experienceId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs.map(Comment.fromFirestore).toList(),
        );
  }

  Future<void> addComment(String experienceId, Comment comment) =>
      _experiences
          .doc(experienceId)
          .collection('comments')
          .add(comment.toFirestore());

  Future<void> deleteComment(String experienceId, String commentId) =>
      _experiences
          .doc(experienceId)
          .collection('comments')
          .doc(commentId)
          .delete();
}
