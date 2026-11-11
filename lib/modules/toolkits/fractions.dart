import 'calculation.dart';

const _inputs = [
  Entry('First fraction or mixed number', '1 1/2', EntryType.text),
  Entry('Second fraction or mixed number', '2/3', EntryType.text),
];

const fractionsModes = <Calculation>[
  Calculation('Add fractions', _inputs, _add),
  Calculation('Subtract fractions', _inputs, _subtract),
  Calculation('Multiply fractions', _inputs, _multiply),
  Calculation('Divide fractions', _inputs, _divide),
];

class _Fraction {
  final BigInt n;
  final BigInt d;
  _Fraction(this.n, this.d);

  factory _Fraction.parse(String raw) {
    final match = RegExp(r'^([+-]?)(?:(\d+)\s+)?(\d+)(?:/(\d+))?$').firstMatch(raw.trim());
    if (raw.length > 200 || match == null || (match[2] != null && match[4] == null)) {
      invalid('Enter a whole number, fraction (2/3), or mixed number (1 1/2).');
    }
    final d = BigInt.parse(match[4] ?? '1');
    if (d == BigInt.zero) invalid('A denominator cannot be zero.');
    final magnitude = BigInt.parse(match[2] ?? '0') * d + BigInt.parse(match[3]!);
    return _Fraction(match[1] == '-' ? -magnitude : magnitude, d);
  }
}

Answers _add(List<String> v) => _compute(v, '+');
Answers _subtract(List<String> v) => _compute(v, '-');
Answers _multiply(List<String> v) => _compute(v, '×');
Answers _divide(List<String> v) => _compute(v, '÷');

Answers _compute(List<String> fields, String op) {
  final a = _Fraction.parse(fields[0]);
  final b = _Fraction.parse(fields[1]);
  var d = a.d * b.d;
  late BigInt n;
  switch (op) {
    case '+': n = a.n * b.d + b.n * a.d; break;
    case '-': n = a.n * b.d - b.n * a.d; break;
    case '×': n = a.n * b.n; break;
    default:
      if (b.n == BigInt.zero) invalid('Cannot divide by zero.');
      n = a.n * b.d;
      d = a.d * b.n;
  }
  final divisor = n.gcd(d) * BigInt.from(d.sign);
  n = n ~/ divisor;
  d = d ~/ divisor;
  final whole = n.abs() ~/ d;
  return {
    'Simplified result': d == BigInt.one ? '$n' : '$n/$d',
    if (whole > BigInt.zero && d != BigInt.one)
      'Mixed number': '${n.isNegative ? '-' : ''}$whole ${n.abs() % d}/$d',
  };
}
