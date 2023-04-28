import 'package:collection/collection.dart';
import 'package:ovavue/domain.dart';
import 'package:registry/registry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import '../models.dart';
import '../state.dart';

part 'budgets_provider.g.dart';

@Riverpod(dependencies: <Object>[registry, user])
Stream<List<BudgetViewModel>> budgets(BudgetsRef ref) async* {
  final Registry registry = ref.read(registryProvider);
  final UserEntity user = await ref.watch(userProvider.future);

  yield* CombineLatestStream.combine2(
    registry.get<FetchBudgetsUseCase>().call(user.id),
    registry.get<FetchBudgetPlansByBudgetUseCase>().call(user.id),
    (BudgetEntityList budgets, BudgetIdToPlansMap budgetIdToPlans) => budgets
        .map(
          (BudgetEntity budget) => BudgetViewModel.fromEntity(
            budget,
            budgetIdToPlans[budget.id]?.toList(growable: false) ?? const <BudgetPlanEntity>[],
          ),
        )
        .sorted((BudgetViewModel a, BudgetViewModel b) => b.startedAt.compareTo(a.startedAt))
        .toList(growable: false),
  );
}
