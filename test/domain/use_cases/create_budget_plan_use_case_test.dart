import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ovavue/data.dart';
import 'package:ovavue/domain.dart';

import '../../utils.dart';

void main() {
  group('CreateBudgetPlanUseCase', () {
    final LogAnalytics analytics = LogAnalytics();
    final CreateBudgetPlanUseCase useCase = CreateBudgetPlanUseCase(
      plans: mockRepositories.budgetPlans,
      analytics: analytics,
    );

    final BudgetPlanEntity dummyEntity = BudgetPlansMockImpl.generatePlan(userId: '1');
    const CreateBudgetPlanData dummyData = CreateBudgetPlanData(
      title: 'title',
      description: 'description',
      category: ReferenceEntity(id: '1', path: 'path'),
    );

    setUpAll(() {
      registerFallbackValue(dummyData);
    });

    tearDown(() {
      analytics.reset();
      mockRepositories.reset();
    });

    test('should create a budget plan', () async {
      when(() => mockRepositories.budgetPlans.create(any(), any())).thenAnswer((_) async => dummyEntity.id);

      await expectLater(useCase(userId: '1', plan: dummyData), completion(dummyEntity.id));
      expect(analytics.events, containsOnce(AnalyticsEvent.createBudgetPlan('1')));
    });

    test('should bubble create errors', () {
      when(() => mockRepositories.budgetPlans.create(any(), any())).thenThrow(Exception('an error'));

      expect(() => useCase(userId: '1', plan: dummyData), throwsException);
    });
  });
}
