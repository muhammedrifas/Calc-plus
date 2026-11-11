import 'dart:math';
import 'calculation.dart';

const budgetModes = <Calculation>[
  Calculation('Emergency fund', [
    Entry('Monthly essential expenses', '2000'),
    Entry('Months of coverage', '6'),
    Entry('Current reserve', '5000'),
  ], _emergencyFund),
  Calculation('Savings timeline', [
    Entry('Savings goal', '10000'),
    Entry('Already saved', '2000'),
    Entry('Monthly contribution', '500'),
  ], _savingsTimeline),
  Calculation('Debt-to-income ratio', [
    Entry('Total monthly debt payments', '800'),
    Entry('Gross monthly income', '4000'),
  ], _debtToIncomeRatio),
  Calculation('Credit utilization', [
    Entry('Outstanding balances', '1000'),
    Entry('Total credit limits', '5000'),
  ], _creditUtilization),
];

Answers _emergencyFund(List<String> values) {
  final spend = number(values[0], 'Monthly essential expenses', positive: true);
  final months = number(values[1], 'Months of coverage', positive: true);
  final saved = number(values[2], 'Current reserve', minimum: 0);
  return {
    'Target reserve': money(spend * months),
    'Still needed': money(max(0, spend * months - saved)),
    'Months currently covered': fmt(saved / spend),
  };
}

Answers _savingsTimeline(List<String> values) {
  final goal = number(values[0], 'Savings goal', minimum: 0);
  final balance = number(values[1], 'Already saved', minimum: 0);
  final monthly = number(values[2], 'Monthly contribution', positive: true);
  final remaining = max(0.0, goal - balance);
  return {
    'Remaining amount': money(remaining),
    'Months at zero interest': fmt(roundUp(remaining / monthly)),
  };
}

Answers _debtToIncomeRatio(List<String> values) {
  final debt = number(values[0], 'Total monthly debt payments', minimum: 0);
  final income = number(values[1], 'Gross monthly income', positive: true);
  return {
    'Debt-to-income (%)': fmt(debt / income * 100),
  };
}

Answers _creditUtilization(List<String> values) {
  final used = number(values[0], 'Outstanding balances', minimum: 0);
  final limit = number(values[1], 'Total credit limits', positive: true);
  return {
    'Credit utilization (%)': fmt(used / limit * 100),
    'Unused credit': money(limit - used),
  };
}
