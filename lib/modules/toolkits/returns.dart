import 'dart:math';
import 'calculation.dart';

const returnsModes = <Calculation>[
  Calculation('Simple interest', [
    Entry('Starting principal', '1000'),
    Entry('Annual rate (%)', '5'),
    Entry('Term (years)', '3'),
  ], _simpleInterest),
  Calculation('Compound interest & APY', [
    Entry('Starting principal', '1000'),
    Entry('Nominal annual rate (%)', '6'),
    Entry('Compounding periods per year', '12'),
    Entry('Term (years)', '5'),
  ], _compoundInterestApy),
  Calculation('ROI & annualized return', [
    Entry('Starting value', '1000'),
    Entry('Ending value including payouts', '1210'),
    Entry('Holding period (years)', '2'),
  ], _roiAnnualizedReturn),
  Calculation('Inflation-adjusted return', [
    Entry('Nominal return (%)', '8'),
    Entry('Inflation over same period (%)', '3'),
  ], _inflationAdjustedReturn),
];

Answers _simpleInterest(List<String> values) {
  final p = number(values[0], 'Starting principal', minimum: 0);
  final r = number(values[1], 'Annual rate (%)', minimum: 0);
  final t = number(values[2], 'Term (years)', minimum: 0);
  return {
    'Interest': money(p * r / 100 * t),
    'Final balance': money(p * (1 + r / 100 * t)),
  };
}

Answers _compoundInterestApy(List<String> values) {
  final p = number(values[0], 'Starting principal', minimum: 0);
  final r = number(values[1], 'Nominal annual rate (%)', minimum: 0);
  final n = number(values[2], 'Compounding periods per year', positive: true, whole: true);
  final t = number(values[3], 'Term (years)', minimum: 0);
  final periodic = r / 100 / n;
  final balance = p * pow(1 + periodic, n * t);
  return {
    'Balance (no deposits)': money(balance),
    'Interest earned': money(balance - p),
    'Effective annual yield (%)': fmt((pow(1 + periodic, n) - 1) * 100),
  };
}

Answers _roiAnnualizedReturn(List<String> values) {
  final p = number(values[0], 'Starting value', positive: true);
  final end = number(values[1], 'Ending value including payouts', minimum: 0);
  final t = number(values[2], 'Holding period (years)', positive: true);
  return {
    'Gain or loss': money(end - p),
    'Simple ROI (%)': fmt((end / p - 1) * 100),
    'Annualized return (CAGR, %)': fmt((pow(end / p, 1 / t) - 1) * 100),
  };
}

Answers _inflationAdjustedReturn(List<String> values) {
  final r = number(values[0], 'Nominal return (%)');
  final i = number(values[1], 'Inflation over same period (%)');
  if (i <= -100 || r < -100) invalid('Inflation must exceed −100% and return must be at least −100%.');
  return {
    'Real return (%)': fmt(((1 + r / 100) / (1 + i / 100) - 1) * 100),
  };
}
