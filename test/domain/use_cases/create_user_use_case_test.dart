import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ovavue/data.dart';
import 'package:ovavue/domain.dart';

import '../../utils.dart';

void main() {
  group('CreateUserUseCase', () {
    final UsersRepository usersRepository = mockRepositories.users;
    final CreateUserUseCase useCase = CreateUserUseCase(users: usersRepository, analytics: const NoopAnalytics());

    final AccountEntity dummyAccountModel = AuthMockImpl.generateAccount();

    setUpAll(() {
      registerFallbackValue(dummyAccountModel);
    });

    tearDown(() => reset(usersRepository));

    test('should create a user', () {
      when(() => usersRepository.create(any())).thenAnswer((_) async => dummyAccountModel.id);

      expect(useCase(dummyAccountModel), completion(dummyAccountModel.id));
    });

    test('should bubble create errors', () {
      when(() => usersRepository.create(any())).thenThrow(Exception('an error'));

      expect(() => useCase(dummyAccountModel), throwsException);
    });
  });
}
