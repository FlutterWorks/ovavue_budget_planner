import 'package:equatable/equatable.dart';
import 'package:ovavue/domain.dart';

import 'budget_category_view_model.dart';

class BudgetPlanViewModel with EquatableMixin {
  const BudgetPlanViewModel({
    required this.id,
    required this.title,
    required this.path,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  static BudgetPlanViewModel fromEntity(BudgetPlanEntity entity) {
    return BudgetPlanViewModel(
      id: entity.id,
      title: entity.title,
      path: entity.path,
      description: entity.description,
      category: BudgetCategoryViewModel.fromEntity(entity.category),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String path;
  final String title;
  final String description;
  final BudgetCategoryViewModel category;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[id, path, title, description, category, createdAt, updatedAt];
}
