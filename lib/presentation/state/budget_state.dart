import 'package:equatable/equatable.dart';

import '../models.dart';
import '../utils.dart';

abstract class BaseBudgetState {
  static const BaseBudgetState empty = EmptyBudgetState();
}

class BudgetState with EquatableMixin implements BaseBudgetState {
  const BudgetState({
    required this.budget,
    required this.allocation,
    required this.categories,
  });

  final SelectedBudgetViewModel budget;
  final Money allocation;
  final List<SelectedBudgetCategoryViewModel> categories;

  @override
  List<Object> get props => <Object>[budget, allocation, categories];
}

class EmptyBudgetState implements BaseBudgetState {
  const EmptyBudgetState();
}
