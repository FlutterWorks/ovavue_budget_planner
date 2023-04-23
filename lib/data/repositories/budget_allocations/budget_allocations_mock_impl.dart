import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:faker/faker.dart';
import 'package:ovavue/core.dart';
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
    NormalizedBudgetEntity? budget,
    NormalizedBudgetPlanEntity? plan,
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
    int? amount,
    NormalizedBudgetEntity? budget,
    NormalizedBudgetPlanEntity? plan,
    DateTime? startedAt,
  }) {
    id ??= faker.guid.guid();
    userId ??= AuthMockImpl.id;
    startedAt ??= faker.randomGenerator.dateTime;
    return NormalizedBudgetAllocationEntity(
      id: id,
      path: '/allocations/$userId/$id',
      amount: amount ?? faker.randomGenerator.integer(1000000),
      budget: budget ?? BudgetsMockImpl.generateNormalizedBudget(userId: userId),
      plan: plan ?? BudgetPlansMockImpl.generateNormalizedPlan(userId: userId),
      createdAt: faker.randomGenerator.dateTime,
      updatedAt: clock.now(),
    );
  }

  static final Map<String, BudgetAllocationEntity> _allocations = <String, BudgetAllocationEntity>{};

  final BehaviorSubject<Map<String, BudgetAllocationEntity>> _allocations$ =
      BehaviorSubject<Map<String, BudgetAllocationEntity>>.seeded(_allocations);

  NormalizedBudgetAllocationEntityList seed(int count, NormalizedBudgetAllocationEntity Function(int) builder) {
    final NormalizedBudgetAllocationEntityList items = NormalizedBudgetAllocationEntityList.generate(count, builder);
    _allocations$.add(
      _allocations
        ..addAll(
          items
              .uniqueBy((NormalizedBudgetAllocationEntity element) => Object.hash(element.budget.id, element.plan.id))
              .map((NormalizedBudgetAllocationEntity element) => element.denormalize)
              .foldToMap((BudgetAllocationEntity element) => element.id),
        ),
    );
    return items;
  }

  @override
  Future<String> create(String userId, CreateBudgetAllocationData allocation) async {
    final String id = faker.guid.guid();
    final BudgetAllocationEntity newItem = BudgetAllocationEntity(
      id: id,
      path: '/allocations/$userId/$id',
      amount: allocation.amount,
      budget: allocation.budget,
      plan: allocation.plan,
      createdAt: clock.now(),
      updatedAt: null,
    );
    _allocations$.add(_allocations..putIfAbsent(id, () => newItem));
    return id;
  }

  @override
  Future<bool> update(UpdateBudgetAllocationData allocation) async {
    _allocations$.add(_allocations..update(allocation.id, (BudgetAllocationEntity prev) => prev.update(allocation)));
    return true;
  }

  @override
  Future<bool> delete(String path) async {
    final String id = _allocations.values.firstWhere((BudgetAllocationEntity element) => element.path == path).id;
    _allocations$.add(_allocations..remove(id));
    return true;
  }

  @override
  Future<bool> deleteByPlan({
    required String userId,
    required String planId,
  }) async {
    _allocations$.add(_allocations..removeWhere((__, _) => _.plan.id == planId));
    return true;
  }

  @override
  Stream<BudgetAllocationEntityList> fetchAll(String userId) => _allocations$.stream.map(
        (Map<String, BudgetAllocationEntity> event) => event.values.toList(),
      );

  @override
  Stream<BudgetAllocationEntityList> fetch({
    required String userId,
    required String budgetId,
  }) =>
      _allocations$.stream.map(
        (Map<String, BudgetAllocationEntity> event) =>
            event.values.where((BudgetAllocationEntity element) => element.budget.id == budgetId).toList(),
      );

  @override
  Stream<BudgetAllocationEntity?> fetchOne({
    required String userId,
    required String budgetId,
    required String planId,
  }) =>
      _allocations$.stream.map(
        (Map<String, BudgetAllocationEntity> event) => event.values.singleWhereOrNull(
          (BudgetAllocationEntity element) => element.budget.id == budgetId && element.plan.id == planId,
        ),
      );

  @override
  Stream<BudgetAllocationEntityList> fetchByPlan({
    required String userId,
    required String planId,
  }) =>
      _allocations$.stream.map(
        (Map<String, BudgetAllocationEntity> event) =>
            event.values.where((BudgetAllocationEntity element) => element.plan.id == planId).toList(),
      );
}

extension on BudgetAllocationEntity {
  BudgetAllocationEntity update(UpdateBudgetAllocationData update) => BudgetAllocationEntity(
        id: id,
        path: path,
        amount: update.amount,
        budget: budget,
        plan: plan,
        createdAt: createdAt,
        updatedAt: clock.now(),
      );
}

extension on NormalizedBudgetAllocationEntity {
  BudgetAllocationEntity get denormalize => BudgetAllocationEntity(
        id: id,
        path: path,
        amount: amount,
        budget: budget.reference,
        plan: plan.reference,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
