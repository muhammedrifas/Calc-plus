import 'calculation.dart';

const businessModes = <Calculation>[
  Calculation('Markup to selling price', [
    Entry('Unit cost', '80'),
    Entry('Markup (%)', '25'),
  ], _markupToSellingPrice),
  Calculation('Target gross margin', [
    Entry('Unit cost', '80'),
    Entry('Target margin (%)', '20'),
  ], _targetGrossMargin),
  Calculation('Break-even quantity', [
    Entry('Fixed costs', '2000'),
    Entry('Selling price per unit', '25'),
    Entry('Variable cost per unit', '15'),
  ], _breakEvenQuantity),
];

Answers _markupToSellingPrice(List<String> values) {
  final cost = number(values[0], 'Unit cost', positive: true);
  final markup = number(values[1], 'Markup (%)', minimum: 0);
  final price = cost * (1 + markup / 100);
  return {
    'Selling price': money(price),
    'Gross profit per unit': money(price - cost),
    'Gross margin (%)': fmt((price - cost) / price * 100),
  };
}

Answers _targetGrossMargin(List<String> values) {
  final cost = number(values[0], 'Unit cost', positive: true);
  final margin = number(values[1], 'Target margin (%)', minimum: 0, maximum: 100);
  if (margin == 100) invalid('Target margin must be below 100%.');
  final price = cost / (1 - margin / 100);
  return {
    'Selling price': money(price),
    'Gross profit per unit': money(price - cost),
    'Markup (%)': fmt((price / cost - 1) * 100),
  };
}

Answers _breakEvenQuantity(List<String> values) {
  final fixed = number(values[0], 'Fixed costs', minimum: 0);
  final price = number(values[1], 'Selling price per unit', positive: true);
  final cost = number(values[2], 'Variable cost per unit', minimum: 0);
  if (price <= cost) invalid('Selling price must exceed variable cost.');
  final units = roundUp(fixed / (price - cost));
  return {
    'Contribution per unit': money(price - cost),
    'Whole units to break even': fmt(units),
    'Revenue at that quantity': money(units * price),
  };
}
