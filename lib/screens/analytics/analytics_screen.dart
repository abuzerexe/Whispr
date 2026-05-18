import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../controllers/analytics_controller.dart';
import '../../models/analytics_model.dart';
import 'widgets/bar_chart.dart';
import 'widgets/donut_chart.dart';
import 'widgets/summary_cards.dart';
import 'widgets/topic_legend.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Community Insights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<AnalyticsController>(
        builder: (context, ctrl, _) {
          if (ctrl.status == AnalyticsStatus.loading) {
            return const _LoadingState();
          }
          if (ctrl.status == AnalyticsStatus.error) {
            return _ErrorState(
              message: ctrl.errorMessage,
              onRetry: ctrl.refresh,
            );
          }
          if (ctrl.data == null) {
            return const SizedBox.shrink();
          }
          return _LoadedState(data: ctrl.data!, onRefresh: ctrl.refresh);
        },
      ),
    );
  }
}

class _LoadedState extends StatelessWidget {
  final AnalyticsData data;
  final Future<void> Function() onRefresh;

  const _LoadedState({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF7C6FCD),
      backgroundColor: const Color(0xFF1C1C24),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How the community is talking',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 20),
            SummaryCards(data: data),
            const SizedBox(height: 28),
            const _SectionLabel(label: 'Topic Distribution'),
            const SizedBox(height: 16),
            DonutChartWidget(data: data),
            const SizedBox(height: 28),
            const _SectionLabel(label: 'Posts per Topic'),
            const SizedBox(height: 16),
            BarChartWidget(data: data),
            const SizedBox(height: 28),
            const _SectionLabel(label: 'Legend'),
            const SizedBox(height: 12),
            TopicLegend(data: data),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Last updated ${_fmtTime(data.fetchedAt)}  •  Pull to refresh',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          5,
          (i) => _ShimmerBox(height: i == 1 ? 220 : 72),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  const _ShimmerBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF1C1C24),
        highlightColor: const Color(0xFF2A2A36),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C24),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Color(0xFFE05C5C),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load analytics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C6FCD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}
