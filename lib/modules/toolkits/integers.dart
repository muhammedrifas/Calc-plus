import 'calculation.dart';

const _pair = [
  Entry('First integer', '48', EntryType.text),
  Entry('Second integer', '18', EntryType.text),
];
const integersModes = <Calculation>[
  Calculation('GCD, LCM & reduced ratio', _pair, _divisors),
  Calculation('Number base converter', [
    Entry('Integer digits', 'FF', EntryType.text),
    Entry('Input base (2–36)', '16'),
  ], _convert),
  Calculation('Permutations & combinations', [
    Entry('Total items (0–1000)', '10'), Entry('Items selected', '3'),
  ], _selections),
  Calculation('Factorial', [Entry('Nonnegative integer (up to 1000)', '10')], _factorial),
];

BigInt integer(String raw, {int radix = 10}) {
  final s = raw.trim();
  if (s.length > 500) invalid('Use up to 500 characters per integer.');
  return BigInt.tryParse(s, radix: radix) ?? invalid('Enter a valid base-$radix integer.');
}

Answers _divisors(List<String> fields) {
  final a = integer(fields[0]);
  final b = integer(fields[1]);
  final gcd = a.gcd(b);
  if (gcd == BigInt.zero) invalid('At least one integer must be nonzero.');
  return {'Greatest common divisor': '$gcd', 'Least common multiple': '${(a ~/ gcd * b).abs()}',
    'Reduced ratio': '${a ~/ gcd} : ${b ~/ gcd}'};
}

Answers _convert(List<String> fields) {
  final radix = number(fields[1], 'Input base', minimum: 2, maximum: 36, whole: true).toInt();
  final v = integer(fields[0], radix: radix);
  return {'Binary': v.toRadixString(2), 'Octal': v.toRadixString(8),
    'Decimal': '$v', 'Hexadecimal': v.toRadixString(16).toUpperCase()};
}

int _count(String text) => number(text, 'Item count', minimum: 0, maximum: 1000, whole: true).toInt();

Answers _selections(List<String> fields) {
  final n = _count(fields[0]);
  final k = _count(fields[1]);
  if (k > n) invalid('Selected items cannot exceed total items.');
  var ordered = BigInt.one;
  var factorial = BigInt.one;
  for (var i = 1; i <= k; i++) {
    ordered *= BigInt.from(n - i + 1);
    factorial *= BigInt.from(i);
  }
  return {'Permutations (ordered)': '$ordered', 'Combinations (unordered)': '${ordered ~/ factorial}'};
}

Answers _factorial(List<String> fields) {
  final n = _count(fields.first);
  var product = BigInt.one;
  for (var i = 2; i <= n; i++) {
    product *= BigInt.from(i);
  }
  return {'$n!': '$product'};
}
