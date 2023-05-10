import 'dart:io';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meta/meta.dart';
import 'package:ovavue/core.dart';
import 'package:ovavue/domain.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/transformers.dart';
import 'package:uuid/uuid.dart';

part 'daos.dart';
part 'database.g.dart';
part 'mappings.dart';
part 'tables.dart';

@DriftDatabase(
  tables: <Type>[
    Accounts,
    Users,
    Budgets,
    BudgetPlans,
    BudgetCategories,
    BudgetAllocations,
  ],
  daos: <Type>[
    AccountsDao,
    UsersDao,
    BudgetsDao,
    BudgetPlansDao,
    BudgetCategoriesDao,
    BudgetAllocationsDao,
  ],
)
class Database extends _$Database {
  Database(String dbName)
      : super(
          LazyDatabase(() async {
            final Directory dbFolder = await getApplicationDocumentsDirectory();

            return NativeDatabase.createInBackground(File(p.join(dbFolder.path, dbName)));
          }),
        );

  Database.memory() : super(NativeDatabase.memory(logStatements: true));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (OpeningDetails details) async => customStatement('PRAGMA foreign_keys = ON'),
      );
}
