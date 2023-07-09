import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:intl/intl.dart';
import 'package:money/money.dart';

import '../models.dart';

export 'package:flutter_gen/gen_l10n/l10n.dart';

extension L10nExtensions on BuildContext {
  L10n get l10n => L10n.of(this);
}

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    if (length == 1) {
      return toUpperCase();
    }
    return this[0].toUpperCase() + substring(1);
  }

  String sentence() => split(' ').map((_) => _.capitalize()).join(' ');
}

extension SortedByMoneyIterableExtension on Iterable<BudgetPlanViewModel> {
  List<BudgetPlanViewModel> sortedByMoney() => sorted(
        (BudgetPlanViewModel a, BudgetPlanViewModel b) {
          final Money moneyA = a.allocation?.amount ?? Money.zero;
          final Money moneyB = b.allocation?.amount ?? Money.zero;

          return moneyB.compareTo(moneyA);
        },
      );
}

extension KeyboardPaddingEdgeInsets on EdgeInsets {
  EdgeInsets withKeyboardPadding(BuildContext context) =>
      copyWith(bottom: MediaQuery.viewInsetsOf(context).bottom + bottom);
}

extension DateTimeFormatExtension on DateTime {
  String format(DateTimeFormat type) => DateFormat(type._pattern).format(this);
}

enum DateTimeFormat {
  dottedInt('dd.MM.yy'),
  yearMonthDate('yMMMMd');

  const DateTimeFormat(this._pattern);

  final String _pattern;
}
