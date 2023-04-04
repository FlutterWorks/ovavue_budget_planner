import 'package:equatable/equatable.dart';

import 'budget_entity.dart';
import 'budget_plan_entity.dart';
import 'reference_entity.dart';

class BaseBudgetAllocationEntity<U, V> with EquatableMixin {
  const BaseBudgetAllocationEntity({
    required this.id,
    required this.path,
    required this.amount,
    required this.budget,
    required this.plan,
    required this.startedAt,
    required this.endedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String path;
  final int amount;
  final U budget;
  final V plan;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[id, path, amount, budget, plan, startedAt, createdAt, updatedAt];

  @override
  bool? get stringify => true;
}

typedef BudgetAllocationEntity = BaseBudgetAllocationEntity<ReferenceEntity, ReferenceEntity>;
typedef NormalizedBudgetAllocationEntity = BaseBudgetAllocationEntity<BudgetEntity, BudgetPlanEntity>;

typedef BudgetAllocationEntityList = List<BudgetAllocationEntity>;
typedef NormalizedBudgetAllocationEntityList = List<NormalizedBudgetAllocationEntity>;
