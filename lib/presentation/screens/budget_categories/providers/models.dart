import 'package:equatable/equatable.dart';

import '../../../utils.dart';

class BudgetCategoryPlanViewModel with EquatableMixin {
  const BudgetCategoryPlanViewModel({
    required this.id,
    required this.path,
    required this.title,
    required this.description,
    required this.allocation,
  });

  final String id;
  final String path;
  final String title;
  final String description;
  final Money? allocation;

  @override
  List<Object?> get props => <Object?>[id, path, title, description, allocation];
}

class BudgetCategoryBudgetViewModel with EquatableMixin {
  const BudgetCategoryBudgetViewModel({
    required this.id,
    required this.path,
    required this.amount,
  });

  final String id;
  final String path;
  final Money amount;

  @override
  List<Object?> get props => <Object?>[id, path, amount];
}
