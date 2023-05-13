import 'package:equatable/equatable.dart';

class BudgetCategoryEntity with EquatableMixin {
  const BudgetCategoryEntity({
    required this.id,
    required this.path,
    required this.title,
    required this.description,
    required this.iconIndex,
    required this.colorSchemeIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String path;
  final String title;
  final String description;
  final int iconIndex;
  final int colorSchemeIndex;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[id, path, title, description, iconIndex, colorSchemeIndex, createdAt, updatedAt];
}

typedef BudgetCategoryEntityList = List<BudgetCategoryEntity>;
