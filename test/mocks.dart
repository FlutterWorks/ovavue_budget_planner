import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ovavue/domain.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUsersRepository extends Mock implements UsersRepository {}

class MockCreateBudgetAllocationUseCase extends Mock implements CreateBudgetAllocationUseCase {}

class MockCreateBudgetCategoryUseCase extends Mock implements CreateBudgetCategoryUseCase {}

class MockCreateBudgetItemUseCase extends Mock implements CreateBudgetItemUseCase {}

class MockCreateBudgetUseCase extends Mock implements CreateBudgetUseCase {}

class MockCreateUserUseCase extends Mock implements CreateUserUseCase {}

class MockFetchAccountUseCase extends Mock implements FetchAccountUseCase {}

class MockFetchBudgetAllocationsUseCase extends Mock implements FetchBudgetAllocationsUseCase {}

class MockFetchBudgetItemsUseCase extends Mock implements FetchBudgetItemsUseCase {}

class MockFetchBudgetsUseCase extends Mock implements FetchBudgetsUseCase {}

class MockFetchCurrentBudgetUseCase extends Mock implements FetchCurrentBudgetUseCase {}

class MockFetchUserUseCase extends Mock implements FetchUserUseCase {}

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockUpdateUserUseCase extends Mock implements UpdateUserUseCase {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockValueChangedCallback<T> extends Mock {
  void call(T data);
}

class MockAsyncCallback<T> extends Mock {
  Future<T> call();
}

class FakeRoute extends Fake implements Route<dynamic> {}

class FakeStackTrace extends Fake implements StackTrace {}

class FakeFlutterErrorDetails extends Fake implements FlutterErrorDetails {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return toDiagnosticsNode(style: DiagnosticsTreeStyle.error).toStringDeep(minLevel: minLevel);
  }
}
