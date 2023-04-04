import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ovavue/domain.dart';

import '../../utils.dart';

void main() {
  group('CreateBudgetAllocationUseCase', () {
    final LogAnalytics analytics = LogAnalytics();
    final BudgetAllocationsRepository budgetAllocationsRepository = mockRepositories.budgetAllocations;
    final CreateBudgetAllocationUseCase useCase = CreateBudgetAllocationUseCase(
      allocations: budgetAllocationsRepository,
      analytics: analytics,
    );
    final CreateBudgetAllocationData dummyData = CreateBudgetAllocationData(
      amount: 1,
      budget: const ReferenceEntity(id: '1', path: 'path'),
      plan: const ReferenceEntity(id: '1', path: 'path'),
      startedAt: DateTime(0),
      endedAt: null,
    );

    tearDown(() {
      analytics.reset();
      reset(budgetAllocationsRepository);
    });

    test('should create a budget allocation', () {
      expect(() => useCase(userId: '1', allocation: dummyData), throwsUnimplementedError);
      // TODO(Jogboms): test analytics event
    });

    test('should bubble create errors', () {
      expect(() => useCase(userId: '1', allocation: dummyData), throwsUnimplementedError);
    });
  });
}
