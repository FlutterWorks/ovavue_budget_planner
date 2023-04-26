import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../state.dart';
import 'active_budget_id_provider.dart';

part 'active_budget_provider.g.dart';

@Riverpod(dependencies: <Object>[activeBudgetId, selectedBudget])
Stream<BaseBudgetState> activeBudget(ActiveBudgetRef ref) async* {
  final String? budgetId = await ref.watch(activeBudgetIdProvider.future);

  if (budgetId == null) {
    yield BaseBudgetState.empty;
  } else {
    yield await ref.watch(selectedBudgetProvider(budgetId).future);
  }
}
