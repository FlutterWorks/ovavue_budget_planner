import 'dart:async' as async;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl_standalone.dart' if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:registry/registry.dart';
import 'package:sentry/sentry.dart';
import 'package:universal_io/io.dart' as io;

import 'core.dart';
import 'data.dart';
import 'domain.dart';
import 'presentation.dart';

const String _sentryDns = String.fromEnvironment('env.sentryDns');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await findSystemLocale();

  final _Repository repository = _Repository.mock();
  final ReporterClient reporterClient;
  final NavigatorObserver navigationObserver = NavigatorObserver();
  const Analytics analytics = _PrintAnalytics();
  switch (environment) {
    case Environment.dev:
    case Environment.prod:
      final DeviceInformation deviceInformation = await AppDeviceInformation.initialize();
      reporterClient = _ReporterClient(
        SentryClient(SentryOptions(dsn: _sentryDns)),
        deviceInformation: deviceInformation,
        environment: environment,
      );
      break;
    case Environment.testing:
    case Environment.mock:
      seedMockData();
      reporterClient = const _NoopReporterClient();
      break;
  }

  final ErrorReporter errorReporter = ErrorReporter(client: reporterClient);
  AppLog.init(
    logFilter: () => kDebugMode && !environment.isTesting,
    exceptionFilter: (Object error) {
      const List<Type> ignoreTypes = <Type>[
        io.SocketException,
        io.HandshakeException,
        async.TimeoutException,
      ];
      return !kDebugMode && !ignoreTypes.contains(error.runtimeType);
    },
    onException: errorReporter.report,
    onLog: (Object? message) => debugPrint(message?.toString()),
  );

  final Registry registry = Registry()

    /// Analytics.
    ..set(analytics)

    /// Repositories.
    /// Do not use directly within the app.
    /// Added to Registry only for convenience with the UseCase factories.
    ..set(repository.auth)
    ..set(repository.users)
    ..set(repository.budgets)
    ..set(repository.budgetPlans)
    ..set(repository.budgetCategories)
    ..set(repository.budgetAllocations)

    /// UseCases.
    /// Callable classes that may contain logic or else route directly to repositories.
    ..factory((RegistryFactory di) => CreateBudgetAllocationUseCase(allocations: di(), analytics: di()))
    ..factory((RegistryFactory di) => CreateBudgetCategoryUseCase(categories: di(), analytics: di()))
    ..factory((RegistryFactory di) => CreateBudgetPlanUseCase(plans: di(), analytics: di()))
    ..factory((RegistryFactory di) => CreateBudgetUseCase(budgets: di(), analytics: di()))
    ..factory((RegistryFactory di) => CreateUserUseCase(users: di(), analytics: di()))
    ..factory((RegistryFactory di) => UpdateBudgetAllocationUseCase(allocations: di(), analytics: di()))
    ..factory((RegistryFactory di) => UpdateBudgetCategoryUseCase(categories: di(), analytics: di()))
    ..factory((RegistryFactory di) => UpdateBudgetPlanUseCase(plans: di(), analytics: di()))
    ..factory((RegistryFactory di) => UpdateBudgetUseCase(budgets: di(), analytics: di()))
    ..factory((RegistryFactory di) => DeleteBudgetAllocationUseCase(allocations: di(), analytics: di()))
    ..factory((RegistryFactory di) => DeleteBudgetCategoryUseCase(categories: di(), analytics: di()))
    ..factory((RegistryFactory di) => DeleteBudgetPlanUseCase(plans: di(), analytics: di()))
    ..factory((RegistryFactory di) => DeleteBudgetUseCase(budgets: di(), analytics: di()))
    ..factory((RegistryFactory di) => FetchAccountUseCase(auth: di()))
    ..factory(
      (RegistryFactory di) => FetchBudgetAllocationUseCase(
        allocations: di(),
        budgets: di(),
        plans: di(),
        categories: di(),
      ),
    )
    ..factory(
      (RegistryFactory di) => FetchBudgetAllocationsUseCase(
        allocations: di(),
        budgets: di(),
        plans: di(),
        categories: di(),
      ),
    )
    ..factory(
      (RegistryFactory di) => FetchBudgetAllocationsByPlanUseCase(
        allocations: di(),
        budgets: di(),
        plans: di(),
        categories: di(),
      ),
    )
    ..factory((RegistryFactory di) => FetchBudgetCategoriesUseCase(categories: di()))
    ..factory((RegistryFactory di) => FetchBudgetPlansUseCase(plans: di(), categories: di()))
    ..factory((RegistryFactory di) => FetchBudgetPlansByCategoryUseCase(plans: di(), categories: di()))
    ..factory((RegistryFactory di) => FetchBudgetUseCase(budgets: di(), plans: di(), categories: di()))
    ..factory((RegistryFactory di) => FetchBudgetsUseCase(budgets: di(), plans: di(), categories: di()))
    ..factory((RegistryFactory di) => FetchActiveBudgetUseCase(budgets: di(), plans: di(), categories: di()))
    ..factory((RegistryFactory di) => FetchUserUseCase(users: di()))
    ..factory((RegistryFactory di) => SignInUseCase(auth: di(), analytics: di()))
    ..factory((RegistryFactory di) => SignOutUseCase(auth: di(), analytics: di()))
    ..factory((RegistryFactory di) => UpdateUserUseCase(users: di()))

    /// Environment.
    ..set(environment);

  runApp(
    ProviderScope(
      overrides: <Override>[
        registryProvider.overrideWithValue(registry),
      ],
      child: ErrorBoundary(
        isReleaseMode: !environment.isDebugging,
        errorViewBuilder: (_) => const AppCrashErrorView(),
        onException: AppLog.e,
        onCrash: errorReporter.reportCrash,
        child: App(
          registry: registry,
          navigatorObservers: <NavigatorObserver>[navigationObserver],
        ),
      ),
    ),
  );
}

class _Repository {
  _Repository.mock()
      : auth = AuthMockImpl(),
        users = UsersMockImpl(),
        budgets = BudgetsMockImpl(),
        budgetPlans = BudgetPlansMockImpl(),
        budgetCategories = BudgetCategoriesMockImpl(),
        budgetAllocations = BudgetAllocationsMockImpl();

  final AuthRepository auth;
  final UsersRepository users;
  final BudgetsRepository budgets;
  final BudgetPlansRepository budgetPlans;
  final BudgetCategoriesRepository budgetCategories;
  final BudgetAllocationsRepository budgetAllocations;
}

class _ReporterClient implements ReporterClient {
  const _ReporterClient(
    this.client, {
    required this.deviceInformation,
    required this.environment,
  });

  final SentryClient client;
  final DeviceInformation deviceInformation;
  final Environment environment;

  @override
  async.FutureOr<void> report({required StackTrace stackTrace, required Object error, Object? extra}) async {
    final SentryEvent event = SentryEvent(
      throwable: error,
      environment: environment.name.toUpperCase(),
      release: deviceInformation.appVersion,
      tags: deviceInformation.toMap(),
      user: SentryUser(
        id: deviceInformation.deviceId,
      ),
      extra: extra is Map ? extra as Map<String, dynamic>? : <String, dynamic>{'extra': extra},
    );

    await client.captureEvent(event, stackTrace: stackTrace);
  }

  @override
  async.FutureOr<void> reportCrash(FlutterErrorDetails details) =>
      client.captureException(details.exception, stackTrace: details.stack);

  @override
  void log(Object object) => AppLog.i(object);
}

class _NoopReporterClient implements ReporterClient {
  const _NoopReporterClient();

  @override
  async.FutureOr<void> report({required StackTrace stackTrace, required Object error, Object? extra}) {}

  @override
  async.FutureOr<void> reportCrash(FlutterErrorDetails details) {}

  @override
  void log(Object object) {}
}

class _PrintAnalytics extends NoopAnalytics {
  const _PrintAnalytics();

  @override
  Future<void> log(AnalyticsEvent event) async => AppLog.i(event);

  @override
  Future<void> setCurrentScreen(String name) async => AppLog.i('screen_view: $name');
}
