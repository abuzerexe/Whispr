import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/topics_constants.dart';
import '../models/analytics_model.dart';

class AnalyticsService {
  final FirebaseFirestore _db;

  AnalyticsService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Fetches experience counts per topic from Firestore.
  ///
  /// Uses parallel [AggregateQuery.count] queries on the `experiences`
  /// collection — no document reads.
  Future<AnalyticsData> fetchAnalytics() async {
    final futures = kTopics.map((topic) async {
      final id = topic['id'] as String;
      final snap = await _db
          .collection('experiences')
          .where('topicId', isEqualTo: id)
          .count()
          .get();
      return MapEntry(id, snap.count ?? 0);
    });

    final results = await Future.wait(futures);
    final countMap = Map<String, int>.fromEntries(results);
    final total = countMap.values.fold<int>(0, (acc, c) => acc + c);

    final stats = kTopics.map((topic) {
      final id = topic['id'] as String;
      final label = topic['label'] as String;
      final count = countMap[id] ?? 0;
      final pct = total == 0 ? 0.0 : (count / total) * 100;
      return TopicStat(
        topicId: id,
        topicLabel: label,
        postCount: count,
        percentage: pct,
      );
    }).toList();

    return AnalyticsData(
      stats: stats,
      totalPosts: total,
      fetchedAt: DateTime.now(),
    );
  }
}
