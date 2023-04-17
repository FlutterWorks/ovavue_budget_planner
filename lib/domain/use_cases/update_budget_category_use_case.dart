import '../analytics/analytics.dart';
import '../analytics/analytics_event.dart';
import '../entities/update_budget_category_data.dart';
import '../repositories/budget_categories.dart';

class UpdateBudgetCategoryUseCase {
  const UpdateBudgetCategoryUseCase({
    required BudgetCategoriesRepository categories,
    required Analytics analytics,
  })  : _categories = categories,
        _analytics = analytics;

  final BudgetCategoriesRepository _categories;
  final Analytics _analytics;

  Future<bool> call(UpdateBudgetCategoryData category) {
    _analytics.log(AnalyticsEvent.updateBudgetCategory(category.path)).ignore();
    return _categories.update(category);
  }
}
