import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ovavue/domain.dart';

import '../../constants.dart';
import '../../models.dart';
import '../../routing.dart';
import '../../state.dart';
import '../../theme.dart';
import '../../utils.dart';
import '../../widgets.dart';
import 'widgets/budget_metadata_entry_form.dart';
import 'widgets/budget_metadata_value_vertical_divider.dart';

class BudgetMetadataPage extends StatefulWidget {
  const BudgetMetadataPage({super.key});

  @override
  State<BudgetMetadataPage> createState() => _BudgetMetadataPageState();
}

class _BudgetMetadataPageState extends State<BudgetMetadataPage> {
  @visibleForTesting
  static const Key dataViewKey = Key('dataViewKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) => ref.watch(budgetMetadataProvider).when(
              data: (List<BudgetMetadataViewModel> data) => _ContentDataView(
                key: dataViewKey,
                data: data,
                metadataNotifier: ref.read(budgetMetadataProvider.notifier),
              ),
              error: ErrorView.new,
              loading: () => child!,
            ),
        child: const LoadingView(),
      ),
    );
  }
}

class _ContentDataView extends StatelessWidget {
  const _ContentDataView({
    super.key,
    required this.data,
    required this.metadataNotifier,
  });

  final List<BudgetMetadataViewModel> data;
  final BudgetMetadata metadataNotifier;

  @override
  Widget build(BuildContext context) {
    final L10n l10n = context.l10n;

    return CustomScrollView(
      slivers: <Widget>[
        CustomAppBar(
          title: Text(l10n.metadataPageTitle),
          asSliver: true,
          centerTitle: true,
        ),
        SliverToBoxAdapter(
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, _) => ActionButtonRow(
              alignment: Alignment.center,
              actions: <ActionButton>[
                ActionButton(
                  icon: AppIcons.plus,
                  onPressed: () => _handleModifyMetadata(context, metadata: null),
                ),
              ],
            ),
          ),
        ),
        if (data.isEmpty)
          const SliverFillRemaining(child: EmptyView())
        else
          for (final BudgetMetadataViewModel metadata in data)
            SliverPadding(
              padding: const EdgeInsets.only(top: 4),
              sliver: SliverExpandableGroup<BudgetMetadataValueViewModel>(
                key: Key(metadata.key.id),
                header: _Header(title: metadata.key.title, description: metadata.key.description),
                values: metadata.values,
                itemBuilder: (BudgetMetadataValueViewModel value) => _MetadataValueTile(
                  key: Key(value.id),
                  item: value,
                  onPressed: () => context.router.goToBudgetMetadataDetail(id: value.id),
                ),
                bottom: Center(
                  child: TextButton(
                    onPressed: () => _handleModifyMetadata(context, metadata: metadata),
                    child: Text(l10n.modifyCaption),
                  ),
                ),
              ),
            ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.paddingOf(context).bottom,
          ),
        ),
      ],
    );
  }

  void _handleModifyMetadata(
    BuildContext context, {
    required BudgetMetadataViewModel? metadata,
  }) async {
    final BudgetMetadataEntryResult? result = await showBudgetMetadataEntryForm(
      context: context,
      type: metadata == null ? BudgetMetadataEntryType.create : BudgetMetadataEntryType.update,
      title: metadata?.key.title,
      description: metadata?.key.description,
      values: metadata?.values,
    );
    if (result == null) {
      return;
    }
    if (context.mounted) {
      final Set<BudgetMetadataValueOperation> operations = <BudgetMetadataValueOperation>{
        for (final BudgetMetadataValueEntryResult item in result.values)
          switch (item) {
            BudgetMetadataValueEntryModifyResult(reference: final ReferenceEntity reference) =>
              BudgetMetadataValueModificationOperation(
                reference: reference,
                title: item.title,
                value: item.value,
              ),
            BudgetMetadataValueEntryModifyResult() => BudgetMetadataValueCreationOperation(
                title: item.title,
                value: item.value,
              ),
            BudgetMetadataValueEntryRemoveResult() => BudgetMetadataValueRemovalOperation(
                reference: item.reference,
              ),
          }
      };
      if (metadata != null) {
        await metadataNotifier.updateMetadata(
          id: metadata.key.id,
          path: metadata.key.path,
          title: result.title,
          description: result.description,
          operations: operations,
        );
      } else {
        await metadataNotifier.createMetadata(
          title: result.title,
          description: result.description,
          operations: operations,
        );
      }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title.sentence(), style: textTheme.titleMedium, maxLines: 1),
        if (description.isNotEmpty) ...<Widget>[
          const SizedBox(height: 2.0),
          Text(description.capitalize(), style: textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _MetadataValueTile extends StatelessWidget {
  const _MetadataValueTile({super.key, required this.item, required this.onPressed});

  final BudgetMetadataValueViewModel item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return InkWell(
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                item.title.sentence(),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: AppFontWeight.medium,
                ),
              ),
            ),
            const BudgetMetadataValueVerticalDivider(),
            Expanded(
              child: Text(
                item.value.capitalize(),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: AppFontWeight.semibold,
                ),
                textAlign: TextAlign.right,
              ),
            )
          ],
        ),
      ),
    );
  }
}
