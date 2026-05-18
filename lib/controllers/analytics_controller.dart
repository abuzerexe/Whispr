import 'package:flutter/foundation.dart';

import '../models/analytics_model.dart';
import '../services/analytics_service.dart';

enum AnalyticsStatus { idle, loading, loaded, error }

class AnalyticsController extends ChangeNotifier {
  final AnalyticsService _service;

  AnalyticsController({AnalyticsService? service})
      : _service = service ?? AnalyticsService();

  AnalyticsStatus status = AnalyticsStatus.idle;
  AnalyticsData? data;
  String errorMessage = '';

  Future<void> load() async {
    if (status == AnalyticsStatus.loading) return;
    status = AnalyticsStatus.loading;
    notifyListeners();

    try {
      data = await _service.fetchAnalytics();
      status = AnalyticsStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = AnalyticsStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => load();
}
