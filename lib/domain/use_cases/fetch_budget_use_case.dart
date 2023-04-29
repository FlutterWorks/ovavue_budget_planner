import '../entities/budget_entity.dart';
import '../repositories/budgets.dart';

class FetchBudgetUseCase {
  const FetchBudgetUseCase({
    required BudgetsRepository budgets,
  }) : _budgets = budgets;

  final BudgetsRepository _budgets;

  Stream<BudgetEntity> call({
    required String userId,
    required String budgetId,
  }) =>
      _budgets.fetchOne(userId: userId, budgetId: budgetId);
}
