import 'calculation.dart';

const percentagesModes = <Calculation>[
  Calculation('Percentage of a value', [
    Entry('Value', '250'),
    Entry('Percentage (%)', '15'),
  ], _percentageOfAValue),
  Calculation('What percent is it?', [
    Entry('Part', '30'),
    Entry('Total', '120'),
  ], _whatPercentIsIt),
  Calculation('Percentage change', [
    Entry('Starting value', '80'),
    Entry('Ending value', '100'),
  ], _percentageChange),
  Calculation('Percentage difference', [
    Entry('First value', '80'),
    Entry('Second value', '100'),
  ], _percentageDifference),
  Calculation('Reverse a percentage change', [
    Entry('Final value', '120'),
    Entry('Signed change (%)', '20'),
  ], _reverseAPercentageChange),
];

Answers _percentageOfAValue(List<String> values) {
  final base = number(values[0], 'Value');
  final rate = number(values[1], 'Percentage (%)');
  return {
    'Share': fmt(base * rate / 100),
  };
}

Answers _whatPercentIsIt(List<String> values) {
  final part = number(values[0], 'Part');
  final total = number(values[1], 'Total');
  if (total == 0) invalid('Total must be nonzero.');
  return {
    'Percentage (%)': fmt(part / total * 100),
  };
}

Answers _percentageChange(List<String> values) {
  final old = number(values[0], 'Starting value');
  final current = number(values[1], 'Ending value');
  if (old == 0) invalid('Change from zero is undefined.');
  return {
    'Change': fmt(current - old),
    'Change (%)': fmt((current - old) / old.abs() * 100),
  };
}

Answers _percentageDifference(List<String> values) {
  final a = number(values[0], 'First value', minimum: 0);
  final b = number(values[1], 'Second value', minimum: 0);
  if (a == 0 && b == 0) invalid('At least one value must be positive.');
  return {
    'Absolute difference': fmt((a - b).abs()),
    'Difference relative to mean (%)': fmt((a - b).abs() / (a / 2 + b / 2) * 100),
  };
}

Answers _reverseAPercentageChange(List<String> values) {
  final end = number(values[0], 'Final value');
  final rate = number(values[1], 'Signed change (%)');
  if (rate == -100) invalid('A 100% decrease has no unique original value.');
  return {
    'Original value': fmt(end / (1 + rate / 100)),
  };
}
