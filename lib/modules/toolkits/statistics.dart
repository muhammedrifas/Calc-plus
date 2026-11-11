import 'dart:math';
import 'calculation.dart';

const statisticsModes = <Calculation>[
  Calculation('Descriptive statistics', [
    Entry('Values (spaces or commas)', '2, 4, 4, 6, 9', EntryType.paragraph),
  ], _summary),
  Calculation('Weighted average', [
    Entry('Values', '70, 85, 90', EntryType.text),
    Entry('Weights in matching order', '2, 3, 5', EntryType.text),
  ], _weighted),
];

List<double> _list(String raw) {
  final tokens = raw.trim().split(RegExp(r'[,\s]+'));
  if (tokens.length > 10000) invalid('Use up to 10,000 values.');
  return [for (final token in tokens) parseNumber(token, 'each list entry')];
}

Answers _summary(List<String> fields) {
  final values = _list(fields.first)..sort();
  final n = values.length;
  final middle = n ~/ 2;
  var mean = 0.0;
  var sumSquares = 0.0;
  final frequencies = <double, int>{};
  for (var i = 0; i < n; i++) {
    final value = values[i];
    final delta = value - mean;
    mean += delta / (i + 1);
    sumSquares += delta * (value - mean);
    frequencies.update(value, (count) => count + 1, ifAbsent: () => 1);
  }
  final peak = frequencies.values.reduce((a, b) => a > b ? a : b);
  return {
    'Count': '$n',
    'Mean (average)': fmt(mean),
    'Median': fmt(n.isOdd ? values[middle] : values[middle - 1] / 2 + values[middle] / 2),
    'Mode': peak == 1 ? 'No repeated values' : frequencies.keys.where((x) => frequencies[x] == peak).map(fmt).join(', '),
    'Minimum': fmt(values.first),
    'Maximum': fmt(values.last),
    'Range': fmt(values.last - values.first),
    'Mean absolute deviation': fmt(values.fold<double>(0, (s, x) => s + (x - mean).abs() / n)),
    'Population variance': fmt(sumSquares / n),
    'Population standard deviation': fmt(sqrt(sumSquares / n)),
    if (n > 1) ...{
      'Sample variance': fmt(sumSquares / (n - 1)),
      'Sample standard deviation': fmt(sqrt(sumSquares / (n - 1))),
    },
  };
}

Answers _weighted(List<String> fields) {
  final values = _list(fields[0]);
  final weights = _list(fields[1]);
  if (values.length != weights.length) invalid('Each value needs one weight.');
  if (weights.any((w) => w < 0)) invalid('Weights must be nonnegative.');
  final total = weights.fold<double>(0, (s, w) => s + w);
  if (total == 0 || !total.isFinite) invalid('Enter weights with a finite, positive sum.');
  var mean = 0.0;
  for (var i = 0; i < values.length; i++) {
    mean += values[i] * (weights[i] / total);
  }
  return {'Weighted average': fmt(mean), 'Sum of weights': fmt(total)};
}
