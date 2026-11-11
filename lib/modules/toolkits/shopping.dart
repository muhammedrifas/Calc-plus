import 'calculation.dart';

const shoppingModes = <Calculation>[
  Calculation('Discounts in sequence', [
    Entry('Marked price', '100'),
    Entry('First discount (%)', '20'),
    Entry('Extra discount (%)', '10'),
  ], _discountsInSequence),
  Calculation('Add sales tax', [
    Entry('Pre-tax amount', '100'),
    Entry('Tax rate (%)', '8'),
  ], _addSalesTax),
  Calculation('Remove included tax', [
    Entry('Tax-inclusive amount', '108'),
    Entry('Tax rate (%)', '8'),
  ], _removeIncludedTax),
  Calculation('Tip & split bill', [
    Entry('Bill before tip', '80'),
    Entry('Tip (%)', '15'),
    Entry('People', '4'),
  ], _tipSplitBill),
  Calculation('Compare unit prices', [
    Entry('Pack A price', '6'),
    Entry('Pack A quantity', '750'),
    Entry('Pack B price', '7.5'),
    Entry('Pack B quantity (same unit)', '1000'),
  ], _compareUnitPrices),
];

Answers _discountsInSequence(List<String> values) {
  final price = number(values[0], 'Marked price', minimum: 0);
  final first = number(values[1], 'First discount (%)', minimum: 0, maximum: 100);
  final second = number(values[2], 'Extra discount (%)', minimum: 0, maximum: 100);
  final factor = (1 - first / 100) * (1 - second / 100);
  final finalPrice = price * factor;
  return {
    'Final price': money(finalPrice),
    'Savings': money(price - finalPrice),
    'Effective discount (%)': fmt(100 * (1 - factor)),
  };
}

Answers _addSalesTax(List<String> values) {
  final price = number(values[0], 'Pre-tax amount', minimum: 0);
  final tax = number(values[1], 'Tax rate (%)', minimum: 0);
  return {
    'Tax': money(price * tax / 100),
    'Total including tax': money(price * (1 + tax / 100)),
  };
}

Answers _removeIncludedTax(List<String> values) {
  final price = number(values[0], 'Tax-inclusive amount', minimum: 0);
  final tax = number(values[1], 'Tax rate (%)', minimum: 0);
  final base = price / (1 + tax / 100);
  return {
    'Pre-tax price': money(base),
    'Included tax': money(price - base),
  };
}

Answers _tipSplitBill(List<String> values) {
  final bill = number(values[0], 'Bill before tip', minimum: 0);
  final tip = number(values[1], 'Tip (%)', minimum: 0);
  final people = number(values[2], 'People', positive: true, whole: true);
  final total = bill * (1 + tip / 100);
  return {
    'Tip': money(bill * tip / 100),
    'Total': money(total),
    'Equal share (rounded)': money(total / people),
  };
}

Answers _compareUnitPrices(List<String> values) {
  final pa = number(values[0], 'Pack A price', minimum: 0);
  final qa = number(values[1], 'Pack A quantity', positive: true);
  final pb = number(values[2], 'Pack B price', minimum: 0);
  final qb = number(values[3], 'Pack B quantity (same unit)', positive: true);
  final a = pa / qa;
  final b = pb / qb;
  return {
    'A price per unit': fmt(a),
    'B price per unit': fmt(b),
    'Lower unit price': a == b ? 'Equal' : a < b ? 'Pack A' : 'Pack B',
  };
}
