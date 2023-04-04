import 'dart:async';

import '../analytics/analytics.dart';
import '../analytics/analytics_event.dart';

class DeleteBudgetPlanUseCase {
  const DeleteBudgetPlanUseCase({
    required Analytics analytics,
  }) : _analytics = analytics;

  final Analytics _analytics;

  Future<bool> call(String path) {
    unawaited(_analytics.log(AnalyticsEvent.deleteBudgetPlan(path)));
    throw UnimplementedError();
  }
}
