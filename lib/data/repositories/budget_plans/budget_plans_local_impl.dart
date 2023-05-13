import 'package:ovavue/domain.dart';

import '../../local_database.dart';

class BudgetPlansLocalImpl implements BudgetPlansRepository {
  const BudgetPlansLocalImpl(this._db);

  final Database _db;

  @override
  Future<String> create(String userId, CreateBudgetPlanData plan) => _db.budgetPlansDao.createPlan(plan);

  @override
  Future<bool> delete({required String id, required String path}) => _db.budgetPlansDao.deletePlan(id);

  @override
  Stream<BudgetPlanEntityList> fetchAll(String userId) => _db.budgetPlansDao.watchAllBudgetPlans();

  @override
  Stream<BudgetPlanEntityList> fetchByCategory({required String userId, required String categoryId}) =>
      _db.budgetPlansDao.watchAllBudgetPlansByCategory(categoryId);

  @override
  Stream<BudgetPlanEntity> fetchOne({required String userId, required String planId}) =>
      _db.budgetPlansDao.watchSingleBudgetPlan(planId);

  @override
  Future<bool> update(UpdateBudgetPlanData plan) => _db.budgetPlansDao.updatePlan(plan);
}
