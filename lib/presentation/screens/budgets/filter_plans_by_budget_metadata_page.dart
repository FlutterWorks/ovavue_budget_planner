import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants.dart';
import '../../models.dart';
import '../../routing.dart';
import '../../state.dart';
import '../../theme.dart';
import '../../utils.dart';
import '../../widgets.dart';
import 'providers/filter_plans_by_budget_metadata.dart';

class FilterPlansByBudgetMetadataPage extends StatefulWidget {
  const FilterPlansByBudgetMetadataPage({super.key, required this.budgetId});

  final String budgetId;

  @override
  State<FilterPlansByBudgetMetadataPage> createState() => FilterPlansByBudgetMetadataPageState();
}

@visibleForTesting
class FilterPlansByBudgetMetadataPageState extends State<FilterPlansByBudgetMetadataPage> {
  @visibleForTesting
  static const Key dataViewKey = Key('dataViewKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) => ref.watch(budgetMetadataProvider).when(
              skipLoadingOnRefresh: true,
              skipLoadingOnReload: true,
              data: (List<BudgetMetadataViewModel> data) =>
                  ref.watch(filterPlansByBudgetMetadataProvider(budgetId: widget.budgetId)).when(
                        skipLoadingOnRefresh: true,
                        skipLoadingOnReload: true,
                        data: (BaseBudgetPlansByMetadataState state) => _ContentDataView(
                          key: dataViewKey,
                          data: data,
                          state: state,
                          budgetId: widget.budgetId,
                        ),
                        error: ErrorView.new,
                        loading: () => child!,
                      ),
              error: ErrorView.new,
              loading: () => child!,
            ),
        child: const LoadingView(),
      ),
    );
  }
}

class _ContentDataView extends StatefulWidget {
  const _ContentDataView({super.key, required this.data, required this.state, required this.budgetId});

  final Iterable<BudgetMetadataViewModel> data;
  final BaseBudgetPlansByMetadataState state;
  final String budgetId;

  @override
  State<_ContentDataView> createState() => _ContentDataViewState();
}

class _ContentDataViewState extends State<_ContentDataView> {
  static final GlobalKey<FormFieldState<String>> _metadataFieldKey = GlobalKey(debugLabel: 'metadataFieldKey');

  final ValueNotifier<BudgetMetadataViewModel?> _selectedMetadata = ValueNotifier<BudgetMetadataViewModel?>(null);
  final ValueNotifier<BudgetMetadataValueViewModel?> _selectedMetadataValue =
      ValueNotifier<BudgetMetadataValueViewModel?>(null);
  late final Listenable _formChanges = Listenable.merge(<Listenable>[
    _selectedMetadata,
    _selectedMetadataValue,
  ]);

  @override
  void dispose() {
    _selectedMetadata.dispose();
    _selectedMetadataValue.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final L10n l10n = context.l10n;

    late final Money aggregateAmount;
    if (widget.state case final BudgetPlansByMetadataState state) {
      aggregateAmount = state.plans.map((_) => _.allocation?.amount ?? Money.zero).sum();
    } else {
      aggregateAmount = Money.zero;
    }

    return CustomScrollView(
      slivers: <Widget>[
        CustomAppBar(
          title: Column(
            children: <Widget>[
              Text(l10n.aggregateAllocationCaption.toUpperCase(), style: textTheme.labelMedium),
              Text('$aggregateAmount', style: textTheme.titleLarge?.copyWith(fontWeight: AppFontWeight.semibold)),
            ],
          ),
          asSliver: true,
          centerTitle: true,
        ),
        if (widget.data.isEmpty)
          const SliverFillRemaining(child: EmptyView())
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) => Row(
                  children: <Widget>[
                    Expanded(
                      child: ValueListenableBuilder<BudgetMetadataViewModel?>(
                        valueListenable: _selectedMetadata,
                        builder: (BuildContext context, BudgetMetadataViewModel? value, _) {
                          return DropdownButtonFormField<BudgetMetadataViewModel>(
                            key: _metadataFieldKey,
                            value: value,
                            isExpanded: true,
                            decoration: const InputDecoration(prefixIcon: Icon(AppIcons.metadata)),
                            hint: Text(l10n.selectMetadataCaption, overflow: TextOverflow.ellipsis),
                            items: <DropdownMenuItem<BudgetMetadataViewModel>>[
                              for (final BudgetMetadataViewModel item in widget.data)
                                DropdownMenuItem<BudgetMetadataViewModel>(
                                  key: Key(item.key.id),
                                  value: item,
                                  child: Text(item.key.title),
                                ),
                            ],
                            onChanged: (BudgetMetadataViewModel? value) {
                              _selectedMetadata.value = value;
                              _handleMetadataValueChanged(null, ref);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: _formChanges,
                        builder: (BuildContext context, _) => DropdownButtonFormField<BudgetMetadataValueViewModel>(
                          value: _selectedMetadataValue.value,
                          isExpanded: true,
                          hint: Text(l10n.selectMetadataValueCaption, overflow: TextOverflow.ellipsis),
                          items: <DropdownMenuItem<BudgetMetadataValueViewModel>>[
                            if (_selectedMetadata.value case final BudgetMetadataViewModel metadata)
                              for (final BudgetMetadataValueViewModel item in metadata.values)
                                DropdownMenuItem<BudgetMetadataValueViewModel>(
                                  key: Key(item.id),
                                  value: item,
                                  child: Text(item.title),
                                ),
                          ],
                          onChanged: (_) => _handleMetadataValueChanged(_, ref),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (widget.state case final BudgetPlansByMetadataState state)
          if (state.plans.isEmpty)
            const SliverFillRemaining(child: EmptyView())
          else ...<Widget>[
            SliverPinnedTitleCountHeader.count(
              title: context.l10n.associatedPlansTitle,
              count: state.plans.length,
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                top: 8.0,
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
              sliver: SliverList.separated(
                itemBuilder: (BuildContext context, int index) {
                  final BudgetPlanViewModel plan = state.plans.elementAt(index);
                  final Money? allocationAmount = plan.allocation?.amount;
                  final Money? budgetAmount = state.budget?.amount;

                  return BudgetPlanListTile(
                    key: Key(plan.id),
                    plan: plan,
                    trailing: allocationAmount != null && budgetAmount != null
                        ? AmountRatioItem(
                            allocationAmount: allocationAmount,
                            baseAmount: budgetAmount,
                          )
                        : null,
                    onTap: () => context.router.goToBudgetPlanDetail(
                      id: plan.id,
                      budgetId: state.budget?.id,
                      entrypoint: BudgetPlanDetailPageEntrypoint.budget,
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemCount: state.plans.length,
              ),
            ),
          ],
      ],
    );
  }

  void _handleMetadataValueChanged(BudgetMetadataValueViewModel? value, WidgetRef ref) {
    _selectedMetadataValue.value = value;
    ref.read(filterMetadataIdProvider.notifier).setState(value?.id);
  }
}
