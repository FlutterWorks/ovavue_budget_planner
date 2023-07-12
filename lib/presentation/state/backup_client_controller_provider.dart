import 'package:ovavue/presentation/backup_client/backup_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backup_client/backup_client_provider.dart';

part 'backup_client_controller_provider.g.dart';

/// Container for the backup client controller
/// Should be overridden per [ProviderScope]
@Riverpod(dependencies: <Object>[])
BackupClientController backupClientController(BackupClientControllerRef ref) => throw UnimplementedError();

abstract class BackupClientController {
  Set<BackupClient> get clients;

  BackupClient get client;

  String displayName(covariant BackupClient client);

  Future<BackupClientResult> setup(covariant BackupClient client, String accountKey);

  Future<BackupClientResult> import();

  Future<BackupClientResult> export();
}
