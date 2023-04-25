import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ovavue/domain.dart';

import '../../utils.dart';

void main() {
  group('UpdateBudgetPlanUseCase', () {
    final LogAnalytics analytics = LogAnalytics();
    final UpdateBudgetPlanUseCase useCase = UpdateBudgetPlanUseCase(
      plans: mockRepositories.budgetPlans,
      analytics: analytics,
    );

    const UpdateBudgetPlanData dummyData = UpdateBudgetPlanData(
      id: 'id',
      path: 'path',
      title: 'title',
      description: 'description',
      categoryId: 'id',
      categoryPath: 'path',
    );

    setUpAll(() {
      registerFallbackValue(dummyData);
    });

    tearDown(() {
      analytics.reset();
      mockRepositories.reset();
    });

    test('should create a budget plan', () async {
      when(() => mockRepositories.budgetPlans.update(any())).thenAnswer((_) async => true);

      await expectLater(useCase(dummyData), completion(true));
      expect(analytics.events, containsOnce(AnalyticsEvent.updateBudgetPlan('path')));
    });

    test('should bubble update errors', () {
      when(() => mockRepositories.budgetPlans.update(any())).thenThrow(Exception('an error'));

      expect(() => useCase(dummyData), throwsException);
    });
  });
}
