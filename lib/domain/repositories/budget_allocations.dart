import '../entities/budget_allocation_entity.dart';
import '../entities/create_budget_allocation_data.dart';
import '../entities/update_budget_allocation_data.dart';

abstract class BudgetAllocationsRepository {
  Future<String> create(String userId, CreateBudgetAllocationData allocation);

  Future<bool> update(UpdateBudgetAllocationData allocation);

  Future<bool> delete(String path);

  Stream<BudgetAllocationEntityList> fetch({
    required String userId,
    required String budgetId,
  });

  Stream<BudgetAllocationEntityList> fetchByPlan({
    required String userId,
    required String planId,
  });

  Stream<BudgetAllocationEntity?> fetchOne({
    required String userId,
    required String budgetId,
    required String planId,
  });
}
