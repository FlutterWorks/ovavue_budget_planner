import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../models.dart';
import '../../routing.dart';
import '../../theme.dart';
import '../../utils.dart';
import '../../widgets.dart';
import 'providers/selected_budget_plan_provider.dart';

class BudgetPlanDetailPage extends StatefulWidget {
  const BudgetPlanDetailPage({super.key, required this.id, this.budgetId});

  final String id;
  final String? budgetId;

  @override
  State<BudgetPlanDetailPage> createState() => BudgetPlanDetailPageState();
}

@visibleForTesting
class BudgetPlanDetailPageState extends State<BudgetPlanDetailPage> {
  @visibleForTesting
  static const Key dataViewKey = Key('dataViewKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) =>
            ref.watch(selectedBudgetPlanProvider(id: widget.id, budgetId: widget.budgetId)).when(
                  data: (BudgetPlanState data) => _ContentDataView(
                    key: dataViewKey,
                    state: data,
                    budgetId: widget.budgetId,
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
  const _ContentDataView({super.key, required this.state, required this.budgetId});

  final BudgetPlanState state;
  final String? budgetId;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    final BudgetPlanAllocationViewModel? allocation = state.allocation;

    return CustomScrollView(
      slivers: <Widget>[
        CustomAppBar(
          title: const Text(''),
          asSliver: true,
          centerTitle: true,
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            <Widget>[
              const SizedBox(height: 18.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            state.plan.title.sentence(),
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: AppFontWeight.semibold,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            state.plan.description.capitalize(),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                          _CategoryChip(
                            key: Key(state.plan.category.id),
                            category: state.plan.category,
                            onPressed: () {
                              final String? budgetId = this.budgetId;
                              if (budgetId != null) {
                                context.router.goToBudgetCategoryDetailForBudget(
                                  id: state.plan.category.id,
                                  budgetId: budgetId,
                                );
                              } else {
                                context.router.goToBudgetCategoryDetail(
                                  id: state.plan.category.id,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (allocation != null)
                      AmountRatioItem.large(
                        allocationAmount: allocation.amount,
                        baseAmount: allocation.budget.amount,
                      )
                  ],
                ),
              ),
              const SizedBox(height: 2.0),
              ActionButtonRow(
                actions: <ActionButton>[
                  ActionButton(
                    icon: Icons.edit,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
        SliverPinnedHeader(
          child: Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              context.l10n.previousAllocationsTitle,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.only(
            top: 8.0,
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final BudgetPlanAllocationViewModel allocation = state.previousAllocations[index];

                return ListTile(
                  key: Key(allocation.id),
                  title: Text(
                    allocation.budget.title.sentence(),
                    style: textTheme.titleMedium,
                  ),
                  subtitle: BudgetDurationText(
                    startedAt: allocation.budget.startedAt,
                    endedAt: allocation.budget.endedAt,
                  ),
                  trailing: AmountRatioItem(
                    allocationAmount: allocation.amount,
                    baseAmount: allocation.budget.amount,
                  ),
                );
              },
              childCount: state.previousAllocations.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({super.key, required this.category, required this.onPressed});

  final BudgetCategoryViewModel category;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ActionChip(
      label: Text(category.title.sentence()),
      avatar: Icon(category.icon, color: category.foregroundColor, size: 16.0),
      backgroundColor: category.backgroundColor,
      side: BorderSide.none,
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: category.foregroundColor,
      ),
      onPressed: onPressed,
    );
  }
}
