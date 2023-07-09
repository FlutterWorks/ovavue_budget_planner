import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ovavue/data.dart';
import 'package:ovavue/domain.dart';
import 'package:ovavue/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../utils.dart';

Future<void> main() async {
  tearDown(mockUseCases.reset);

  group('PreferencesProvider', () {
    test('should get current state', () {
      final AccountEntity dummyAccount = AuthMockImpl.generateAccount();
      final PreferencesState expectedState = PreferencesState(
        accountKey: dummyAccount.id,
        themeMode: ThemeMode.system,
      );
      when(mockUseCases.fetchThemeModeUseCase.call).thenAnswer((_) async => 0);

      final ProviderContainer container = createProviderContainer(
        overrides: <Override>[
          accountProvider.overrideWith((_) async => dummyAccount),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(preferencesProvider.future),
        completion(expectedState),
      );
    });

    test('should update theme mode', () {
      when(() => mockUseCases.updateThemeModeUseCase.call(1)).thenAnswer((_) async => true);

      final ProviderContainer container = createProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(preferencesProvider.notifier).updateThemeMode(ThemeMode.light),
        completion(true),
      );
    });
  });
}
