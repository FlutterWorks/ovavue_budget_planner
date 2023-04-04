import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:ovavue/domain.dart';
import 'package:rxdart/subjects.dart';

import '../auth/auth_mock_impl.dart';
import '../budget_plans/budget_plans_mock_impl.dart';
import '../extensions.dart';

class BudgetsMockImpl implements BudgetsRepository {
  static BudgetEntity generateBudget({String? id, List<BudgetPlanEntity>? plans, DateTime? startedAt}) =>
      generateNormalizedBudget(id: id, plans: plans, startedAt: startedAt).denormalize;

  static NormalizedBudgetEntity generateNormalizedBudget({
    String? id,
    List<BudgetPlanEntity>? plans,
    DateTime? startedAt,
  }) {
    id ??= faker.guid.guid();
    startedAt ??= faker.randomGenerator.dateTime;
    return NormalizedBudgetEntity(
      id: id,
      path: '/budgets/${AuthMockImpl.id}/$id',
      title: faker.lorem.words(2).join(' '),
      description: faker.lorem.sentence(),
      amount: faker.randomGenerator.integer(1000000),
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(minutes: 10000)),
      plans: plans ?? BudgetPlansMockImpl.plans.values.toList(growable: false),
      createdAt: faker.randomGenerator.dateTime,
      updatedAt: clock.now(),
    );
  }

  static final Map<String, BudgetEntity> budgets = (faker.randomGenerator.amount((_) => generateBudget(), 250, min: 50)
        ..sort(_sortFn))
      .foldToMap((BudgetEntity element) => element.id);

  final BehaviorSubject<Map<String, BudgetEntity>> _budgets$ =
      BehaviorSubject<Map<String, BudgetEntity>>.seeded(budgets);

  @override
  Future<String> create(String userId, CreateBudgetData budget) async {
    final String id = faker.guid.guid();
    final BudgetEntity newItem = BudgetEntity(
      id: id,
      path: '/budgets/$userId/$id',
      title: budget.title,
      description: budget.description,
      amount: budget.amount,
      startedAt: budget.startedAt,
      endedAt: budget.endedAt,
      plans: budget.plans,
      createdAt: clock.now(),
      updatedAt: null,
    );
    _budgets$.add(budgets..putIfAbsent(id, () => newItem));
    return id;
  }

  @override
  Future<bool> delete(String path) async {
    final String id = budgets.values.firstWhere((BudgetEntity element) => element.path == path).id;
    _budgets$.add(budgets..remove(id));
    return true;
  }

  @override
  Stream<BudgetEntityList> fetch(String userId) =>
      _budgets$.stream.map((Map<String, BudgetEntity> event) => event.values.toList());

  @override
  Stream<BudgetEntity> fetchActiveBudget(String userId) => _budgets$.stream.map(
        (Map<String, BudgetEntity> event) => (event.values.toList(growable: false)..sort(_sortFn)).first,
      );
}

int _sortFn(BudgetEntity a, BudgetEntity b) => b.startedAt.compareTo(a.startedAt);

extension on NormalizedBudgetEntity {
  BudgetEntity get denormalize => BudgetEntity(
        id: id,
        path: path,
        title: title,
        description: description,
        amount: amount,
        startedAt: startedAt,
        endedAt: endedAt,
        plans: plans.map((BudgetPlanEntity element) => element.reference).toList(growable: false),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
