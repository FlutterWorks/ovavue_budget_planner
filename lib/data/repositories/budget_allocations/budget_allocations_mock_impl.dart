import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:ovavue/domain.dart';
import 'package:rxdart/subjects.dart';

import '../auth/auth_mock_impl.dart';
import '../budget_plans/budget_plans_mock_impl.dart';
import '../budgets/budgets_mock_impl.dart';
import '../extensions.dart';

class BudgetAllocationsMockImpl implements BudgetAllocationsRepository {
  static BudgetAllocationEntity generateAllocation({
    String? id,
    String? userId,
    BudgetEntity? budget,
    BudgetPlanEntity? plan,
    DateTime? startedAt,
  }) =>
      generateNormalizedAllocation(
        id: id,
        userId: userId,
        budget: budget,
        plan: plan,
        startedAt: startedAt,
      ).denormalize;

  static NormalizedBudgetAllocationEntity generateNormalizedAllocation({
    String? id,
    String? userId,
    BudgetEntity? budget,
    BudgetPlanEntity? plan,
    DateTime? startedAt,
  }) {
    id ??= faker.guid.guid();
    startedAt ??= faker.randomGenerator.dateTime;
    return NormalizedBudgetAllocationEntity(
      id: id,
      path: '/allocations/${userId ?? AuthMockImpl.id}/$id',
      amount: faker.randomGenerator.integer(1000000),
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(minutes: 10000)),
      budget: budget ?? BudgetsMockImpl.budgets.values.first,
      plan: plan ?? BudgetPlansMockImpl.plans.values.random(),
      createdAt: faker.randomGenerator.dateTime,
      updatedAt: clock.now(),
    );
  }

  static final Map<String, BudgetAllocationEntity> allocations = faker.randomGenerator
      .amount((_) => generateAllocation(), 10, min: 5)
      .foldToMap((BudgetAllocationEntity element) => element.id);

  final BehaviorSubject<Map<String, BudgetAllocationEntity>> _allocations$ =
      BehaviorSubject<Map<String, BudgetAllocationEntity>>.seeded(allocations);

  @override
  Future<String> create(String userId, CreateBudgetAllocationData allocation) async {
    final String id = faker.guid.guid();
    final BudgetAllocationEntity newItem = BudgetAllocationEntity(
      id: id,
      path: '/allocations/$userId/$id',
      amount: allocation.amount,
      startedAt: allocation.startedAt,
      endedAt: allocation.endedAt,
      budget: allocation.budget,
      plan: allocation.plan,
      createdAt: clock.now(),
      updatedAt: null,
    );
    _allocations$.add(allocations..putIfAbsent(id, () => newItem));
    return id;
  }

  @override
  Future<bool> delete(String path) async {
    final String id = allocations.values.firstWhere((BudgetAllocationEntity element) => element.path == path).id;
    _allocations$.add(allocations..remove(id));
    return true;
  }

  @override
  Stream<BudgetAllocationEntityList> fetch({
    required String userId,
    required String budgetId,
  }) =>
      _allocations$.stream.map((Map<String, BudgetAllocationEntity> event) => event.values.toList());
}

extension on NormalizedBudgetAllocationEntity {
  BudgetAllocationEntity get denormalize => BudgetAllocationEntity(
        id: id,
        path: path,
        amount: amount,
        startedAt: startedAt,
        endedAt: endedAt,
        budget: budget.reference,
        plan: plan.reference,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
