import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:ovavue/core.dart';
import 'package:ovavue/domain.dart';
import 'package:registry/registry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/streams.dart';

import '../../../models.dart';
import '../../../state.dart';
import '../../../utils.dart';

part 'models.dart';
part 'selected_budget_category_provider.g.dart';

@Riverpod(dependencies: <Object>[registry, user, budgetCategories])
Stream<BudgetCategoryState> selectedBudgetCategory(
  SelectedBudgetCategoryRef ref, {
  required String id,
  required String budgetId,
}) async* {
  final Registry registry = ref.read(registryProvider);
  final UserEntity user = await ref.watch(userProvider.future);

  final List<BudgetCategoryViewModel> budgetCategories = await ref.watch(budgetCategoriesProvider.future);
  final BudgetCategoryViewModel category = budgetCategories.firstWhere((_) => _.id == id);

  yield* CombineLatestStream.combine3(
    registry.get<FetchBudgetUseCase>().call(userId: user.id, budgetId: budgetId),
    registry.get<FetchBudgetPlansByCategoryUseCase>().call(userId: user.id, categoryId: id),
    registry.get<FetchBudgetAllocationsUseCase>().call(userId: user.id, budgetId: budgetId),
    (
      NormalizedBudgetEntity budget,
      NormalizedBudgetPlanEntityList budgetPlans,
      NormalizedBudgetAllocationEntityList allocations,
    ) {
      final Map<String, NormalizedBudgetAllocationEntity> allocationsByPlan = allocations.foldToMap((_) => _.plan.id);
      final List<BudgetCategoryPlanViewModel> plans = budgetPlans
          .map(
            (NormalizedBudgetPlanEntity element) => BudgetCategoryPlanViewModel(
              id: element.id,
              path: element.path,
              title: element.title,
              allocation: allocationsByPlan[element.id]?.amount.asMoney,
            ),
          )
          .toList(growable: false);

      return BudgetCategoryState(
        category: category,
        allocation: plans.map((_) => _.allocation).whereNotNull().sum(),
        budget: BudgetCategoryBudgetViewModel(
          id: budget.id,
          path: budget.path,
          amount: Money(budget.amount),
        ),
        plans: plans,
      );
    },
  ).distinct();
}

class BudgetCategoryState with EquatableMixin {
  const BudgetCategoryState({
    required this.category,
    required this.allocation,
    required this.budget,
    required this.plans,
  });

  final BudgetCategoryViewModel category;
  final Money allocation;
  final BudgetCategoryBudgetViewModel budget;
  final List<BudgetCategoryPlanViewModel> plans;

  @override
  List<Object?> get props => <Object?>[category, allocation, budget, plans];
}
