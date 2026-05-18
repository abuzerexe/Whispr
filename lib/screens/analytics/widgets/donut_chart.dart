import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../models/analytics_model.dart';
import '../../../utils/topic_colors.dart';

class DonutChartWidget extends StatefulWidget {
  final AnalyticsData data;
  const DonutChartWidget({super.key, required this.data});

  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final stats = widget.data.stats;
    final total = widget.data.totalPosts;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C24),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touched = -1;
                            return;
                          }
                          _touched = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 3,
                    centerSpaceRadius: 60,
                    sections: stats.asMap().entries.map((e) {
                      final i = e.key;
                      final stat = e.value;
                      final isTouched = i == _touched;
                      final sliceValue = total == 0
                          ? 1.0
                          : stat.postCount.toDouble();
                      return PieChartSectionData(
                        color: TopicColors.of(stat.topicId),
                        value: sliceValue,
                        title: isTouched
                            ? '${stat.percentage.toStringAsFixed(1)}%'
                            : '',
                        radius: isTouched ? 68 : 56,
                        titleStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _touched == -1
                          ? '${widget.data.totalPosts}'
                          : '${stats[_touched].postCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _touched == -1
                          ? 'total posts'
                          : stats[_touched].topicLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
