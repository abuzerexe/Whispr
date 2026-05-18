import 'package:flutter/material.dart';

import '../../../models/analytics_model.dart';
import '../../../utils/topic_colors.dart';

class TopicLegend extends StatelessWidget {
  final AnalyticsData data;
  const TopicLegend({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C24),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: data.stats.map((stat) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: TopicColors.of(stat.topicId),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: TopicColors.of(stat.topicId)
                            .withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stat.topicLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: TopicColors.of(stat.topicId).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${stat.postCount} posts',
                    style: TextStyle(
                      color: TopicColors.of(stat.topicId),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${stat.percentage.toStringAsFixed(1)}%',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
