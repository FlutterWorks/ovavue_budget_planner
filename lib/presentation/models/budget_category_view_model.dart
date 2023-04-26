import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ovavue/domain.dart';

import '../utils.dart';

class BudgetCategoryViewModel with EquatableMixin {
  const BudgetCategoryViewModel({
    required this.id,
    required this.path,
    required this.title,
    required this.description,
    required this.icon,
    required this.brightness,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.createdAt,
    required this.updatedAt,
  });

  static BudgetCategoryViewModel fromEntity(BudgetCategoryEntity entity) {
    final BudgetCategoryColorScheme colorScheme = BudgetCategoryColorScheme.values[entity.colorSchemeIndex];

    return BudgetCategoryViewModel(
      id: entity.id,
      path: entity.path,
      title: entity.title,
      description: entity.description,
      icon: BudgetCategoryIcon.values[entity.iconIndex].data,
      brightness: colorScheme.brightness,
      foregroundColor: colorScheme.foreground,
      backgroundColor: colorScheme.background,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  final String id;
  final String path;
  final String title;
  final String description;
  final IconData icon;
  final Brightness brightness;
  final Color foregroundColor;
  final Color backgroundColor;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props =>
      <Object?>[id, path, title, description, icon, brightness, foregroundColor, backgroundColor, createdAt, updatedAt];
}
