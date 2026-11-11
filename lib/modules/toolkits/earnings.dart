import 'calculation.dart';

const earningsModes = <Calculation>[
  Calculation('Annual salary to hourly pay', [
    Entry('Annual gross pay', '52000'),
    Entry('Paid weeks per year', '52'),
    Entry('Hours per paid week', '40'),
  ], _annualSalaryToHourlyPay),
  Calculation('Hourly wage to salary', [
    Entry('Hourly wage', '25'),
    Entry('Hours per paid week', '40'),
    Entry('Paid weeks per year', '52'),
  ], _hourlyWageToSalary),
  Calculation('Overtime pay', [
    Entry('Hourly wage', '20'),
    Entry('Regular hours', '40'),
    Entry('Overtime hours', '5'),
    Entry('Overtime multiplier', '1.5'),
  ], _overtimePay),
  Calculation('Raise or bonus', [
    Entry('Current pay', '50000'),
    Entry('Increase (%)', '5'),
  ], _raiseOrBonus),
  Calculation('Commission', [
    Entry('Eligible sales', '12000'),
    Entry('Commission (%)', '8'),
    Entry('Base pay for period', '1000'),
  ], _commission),
];

Answers _annualSalaryToHourlyPay(List<String> values) {
  final annual = number(values[0], 'Annual gross pay', minimum: 0);
  final weeks = number(values[1], 'Paid weeks per year', positive: true);
  final hours = number(values[2], 'Hours per paid week', positive: true);
  return {
    'Monthly average': money(annual / 12),
    'Per paid week': money(annual / weeks),
    'Hourly equivalent': money(annual / weeks / hours),
  };
}

Answers _hourlyWageToSalary(List<String> values) {
  final wage = number(values[0], 'Hourly wage', minimum: 0);
  final hours = number(values[1], 'Hours per paid week', positive: true);
  final weeks = number(values[2], 'Paid weeks per year', positive: true);
  return {
    'Weekly gross': money(wage * hours),
    'Average monthly gross': money(wage * hours * weeks / 12),
    'Annual gross': money(wage * hours * weeks),
  };
}

Answers _overtimePay(List<String> values) {
  final rate = number(values[0], 'Hourly wage', minimum: 0);
  final regular = number(values[1], 'Regular hours', minimum: 0);
  final extra = number(values[2], 'Overtime hours', minimum: 0);
  final multiplier = number(values[3], 'Overtime multiplier', positive: true);
  return {
    'Regular pay': money(rate * regular),
    'Overtime pay': money(rate * extra * multiplier),
    'Total gross pay': money(rate * (regular + extra * multiplier)),
  };
}

Answers _raiseOrBonus(List<String> values) {
  final base = number(values[0], 'Current pay', minimum: 0);
  final rate = number(values[1], 'Increase (%)', minimum: 0);
  return {
    'Increase': money(base * rate / 100),
    'Pay with increase': money(base * (1 + rate / 100)),
  };
}

Answers _commission(List<String> values) {
  final sales = number(values[0], 'Eligible sales', minimum: 0);
  final rate = number(values[1], 'Commission (%)', minimum: 0);
  final base = number(values[2], 'Base pay for period', minimum: 0);
  return {
    'Commission': money(sales * rate / 100),
    'Total pay': money(base + sales * rate / 100),
  };
}
