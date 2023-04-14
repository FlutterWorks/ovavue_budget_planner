import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class Money with EquatableMixin implements Comparable<Money> {
  const Money(this.rawValue);

  static const Money zero = Money(0);

  final int rawValue;

  String get formatted => NumberFormat.simpleCurrency(decimalDigits: 2).format(rawValue / 100);

  @override
  List<Object> get props => <Object>[rawValue];

  Money operator +(Money other) => Money(rawValue + other.rawValue);

  Money operator -(Money other) => Money(rawValue - other.rawValue);

  double operator /(Object other) {
    if (other is Money) {
      return rawValue / other.rawValue;
    } else if (other is num) {
      return rawValue / other;
    }

    throw ArgumentError('invalid divisor type');
  }

  @override
  int compareTo(Money other) => rawValue.compareTo(other.rawValue);

  double ratio(Money of) => this / of;

  String percentage(Money of) => NumberFormat.decimalPercentPattern(decimalDigits: 1).format(ratio(of));

  @override
  String toString() => formatted;
}

extension MoneyIntExtension on int {
  Money get asMoney => Money(this);
}

extension MoneyIterableSumExtension on Iterable<Money> {
  Money sum() {
    if (isEmpty) {
      return Money.zero;
    }
    return reduce((Money value, Money current) => value + current);
  }
}
