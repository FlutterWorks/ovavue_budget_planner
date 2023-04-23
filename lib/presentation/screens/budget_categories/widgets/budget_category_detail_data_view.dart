import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models.dart';
import '../../../routing.dart';
import '../../../state.dart';
import '../../../utils.dart';
import '../../../widgets.dart';
import '../providers/budget_category_provider.dart';
import '../providers/budget_category_state.dart';
import '../providers/models.dart';
import 'budget_category_header.dart';
import 'budget_category_plan_tile.dart';
import 'budget_plan_selection_picker.dart';

class BudgetCategoryDetailDataView extends StatelessWidget {
  const BudgetCategoryDetailDataView({super.key, required this.state});

  final BudgetCategoryState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: <Widget>[
        CustomAppBar(
          title: const Text(''),
          asSliver: true,
          centerTitle: true,
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            BudgetCategoryHeader(
              category: state.category,
              allocationAmount: state.allocation,
              budgetAmount: state.budget?.amount,
            ),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) => ActionButtonRow(
                actions: <ActionButton>[
                  ActionButton(
                    icon: Icons.add_moderator_outlined, // TODO(Jogboms): fix icon
                    onPressed: () => _handlePlanAdditionAction(
                      context,
                      ref: ref,
                      category: state.category,
                    ),
                  ),
                  ActionButton(
                    icon: Icons.edit,
                    onPressed: () {},
                  ),
                  if (state.plans.isEmpty)
                    ActionButton(
                      icon: Icons.delete,
                      backgroundColor: colorScheme.errorContainer,
                      onPressed: () => _handleCategoryDeletionAction(
                        context,
                        ref: ref,
                        category: state.category,
                        dismissOnComplete: true,
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(height: 8.0),
          ]),
        ),
        SliverPinnedTitleCountHeader(
          title: context.l10n.associatedPlansTitle,
          count: state.plans.length,
        ),
        SliverPadding(
          padding: EdgeInsets.only(
            top: 8.0,
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          sliver: SliverList(
            delegate: SliverSeparatorBuilderDelegate(
              builder: (BuildContext context, int index) {
                final BudgetCategoryPlanViewModel plan = state.plans[index];

                return BudgetCategoryPlanTile(
                  key: Key(plan.id),
                  plan: plan,
                  categoryAllocationAmount: state.allocation,
                  onPressed: () => context.router.goToBudgetPlanDetail(
                    id: plan.id,
                    budgetId: state.budget?.id,
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              childCount: state.plans.length,
            ),
          ),
        ),
      ],
    );
  }

  void _handlePlanAdditionAction(
    BuildContext context, {
    required WidgetRef ref,
    required BudgetCategoryViewModel category,
  }) async {
    final BudgetPlanViewModel? plan = await showModalBottomSheet(
      context: context,
      builder: (_) => const BudgetPlanSelectionPicker(),
    );
    if (plan == null) {
      return;
    }

    await ref.read(budgetPlanProvider).updateCategory(plan: plan, category: category);
  }

  void _handleCategoryDeletionAction(
    BuildContext context, {
    required WidgetRef ref,
    required BudgetCategoryViewModel category,
    required bool dismissOnComplete,
  }) async {
    final L10n l10n = context.l10n;
    final AppSnackBar snackBar = context.snackBar;
    final NavigatorState navigator = Navigator.of(context);
    final bool choice = await showErrorChoiceBanner(
      context,
      message: context.l10n.deleteCategoryAreYouSureAboutThisMessage,
    );
    if (!choice) {
      return;
    }

    final bool successful = await ref.read(budgetCategoryProvider).delete(category.path);
    if (successful) {
      snackBar.success(l10n.successfulMessage);
      if (dismissOnComplete) {
        navigator.pop();
      }
    } else {
      snackBar.error(l10n.genericErrorMessage);
    }
  }
}
