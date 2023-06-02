import 'package:collection/collection.dart';
import 'package:ovavue/domain.dart';
import 'package:registry/registry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models.dart';
import 'registry_provider.dart';
import 'user_provider.dart';

part 'budget_metadata_provider.g.dart';

@Riverpod(dependencies: <Object>[registry, user])
class BudgetMetadata extends _$BudgetMetadata {
  @override
  Stream<List<BudgetMetadataViewModel>> build() async* {
    final Registry registry = ref.read(registryProvider);
    final UserEntity user = await ref.watch(userProvider.future);

    yield* registry
        .get<FetchBudgetMetadataUseCase>()
        .call(user.id)
        .map((_) => _.groupListsBy((_) => _.key).entries.map((_) => _.toEntity()).toList(growable: false));
  }

  Future<String> createMetadata({
    required String title,
    required String description,
    required Set<BudgetMetadataValueOperation> operations,
  }) async {
    final Registry registry = ref.read(registryProvider);
    final UserEntity user = await ref.watch(userProvider.future);

    return registry.get<CreateBudgetMetadataUseCase>().call(
          userId: user.id,
          metadata: CreateBudgetMetadataData(
            title: title,
            description: description,
            operations: operations,
          ),
        );
  }

  Future<bool> updateMetadata({
    required String id,
    required String path,
    required String title,
    required String description,
    required Set<BudgetMetadataValueOperation> operations,
  }) async {
    final Registry registry = ref.read(registryProvider);
    final UserEntity user = await ref.watch(userProvider.future);

    return registry.get<UpdateBudgetMetadataUseCase>().call(
          userId: user.id,
          metadata: UpdateBudgetMetadataData(
            id: id,
            path: path,
            title: title,
            description: description,
            operations: operations,
          ),
        );
  }

  Future<bool> addMetadataToPlan({
    required ReferenceEntity plan,
    required ReferenceEntity metadata,
  }) async {
    final Registry registry = ref.read(registryProvider);
    final UserEntity user = await ref.watch(userProvider.future);

    return registry.get<AddMetadataToPlanUseCase>().call(
          userId: user.id,
          plan: plan,
          metadata: metadata,
        );
  }

  Future<bool> removeMetadataFromPlan({
    required ReferenceEntity plan,
    required ReferenceEntity metadata,
  }) async {
    final Registry registry = ref.read(registryProvider);
    final UserEntity user = await ref.watch(userProvider.future);

    return registry.get<RemoveMetadataFromPlanUseCase>().call(
          userId: user.id,
          plan: plan,
          metadata: metadata,
        );
  }
}

extension BudgetMetadataViewModelExtension on MapEntry<BudgetMetadataKeyEntity, List<BudgetMetadataValueEntity>> {
  BudgetMetadataViewModel toEntity() => BudgetMetadataViewModel(
        key: BudgetMetadataKeyViewModel.fromEntity(key),
        values: value.map(BudgetMetadataValueViewModel.fromEntity).toList(growable: false),
      );
}
