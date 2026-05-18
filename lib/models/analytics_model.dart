/// Holds the count and display info for a single topic.
class TopicStat {
  final String topicId;
  final String topicLabel;
  final int postCount;
  final double percentage; // 0–100

  const TopicStat({
    required this.topicId,
    required this.topicLabel,
    required this.postCount,
    required this.percentage,
  });
}

/// Aggregated analytics data for all six topics.
class AnalyticsData {
  final List<TopicStat> stats;
  final int totalPosts;
  final DateTime fetchedAt;

  const AnalyticsData({
    required this.stats,
    required this.totalPosts,
    required this.fetchedAt,
  });

  /// Topic with the highest post count.
  TopicStat get mostActive {
    assert(stats.isNotEmpty);
    return stats.reduce((a, b) => a.postCount >= b.postCount ? a : b);
  }

  /// Topic with the lowest post count.
  TopicStat get leastActive {
    assert(stats.isNotEmpty);
    return stats.reduce((a, b) => a.postCount <= b.postCount ? a : b);
  }

  /// Returns stats sorted by count descending — used for bar chart.
  List<TopicStat> get sortedByCount =>
      [...stats]..sort((a, b) => b.postCount.compareTo(a.postCount));
}
