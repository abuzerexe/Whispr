import 'package:flutter/material.dart';

import '../../../models/analytics_model.dart';
import '../../../utils/topic_colors.dart';

class BarChartWidget extends StatelessWidget {
  final AnalyticsData data;
  const BarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final sorted = data.sortedByCount;
    final max = sorted.isEmpty ? 1 : sorted.first.postCount;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C24),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: sorted.map((stat) {
          final frac = max == 0 ? 0.0 : stat.postCount / max;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        stat.topicLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${stat.postCount}',
                      style: TextStyle(
                        color: TopicColors.of(stat.topicId),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 8,
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: frac),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) => Container(
                            height: 8,
                            width: constraints.maxWidth * value,
                            decoration: BoxDecoration(
                              color: TopicColors.of(stat.topicId),
                              borderRadius: BorderRadius.circular(99),
                              boxShadow: [
                                BoxShadow(
                                  color: TopicColors.of(stat.topicId)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
