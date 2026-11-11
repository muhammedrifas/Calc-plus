import 'calculation.dart';

const circuitsModes = <Calculation>[
  Calculation('DC voltage from current', [
    Entry('Current (A)', '0.02'),
    Entry('Resistance (Ω)', '220'),
  ], _dcVoltageFromCurrent),
  Calculation('DC current from voltage', [
    Entry('Voltage (V)', '12'),
    Entry('Resistance (Ω)', '100'),
  ], _dcCurrentFromVoltage),
  Calculation('DC resistance from current', [
    Entry('Voltage (V)', '5'),
    Entry('Current (A)', '0.02'),
  ], _dcResistanceFromCurrent),
  Calculation('Two resistors', [
    Entry('First resistance (Ω)', '100'),
    Entry('Second resistance (Ω)', '200'),
  ], _twoResistors),
  Calculation('Unloaded voltage divider', [
    Entry('Supply voltage (V)', '12'),
    Entry('Upper resistance (Ω)', '1000'),
    Entry('Lower resistance (Ω)', '2000'),
  ], _unloadedVoltageDivider),
];

Answers _dcVoltageFromCurrent(List<String> values) {
  final i = number(values[0], 'Current (A)', minimum: 0);
  final r = number(values[1], 'Resistance (Ω)', positive: true);
  return {
    'Voltage drop (V)': fmt(i * r),
    'Power (W)': fmt(i * i * r),
  };
}

Answers _dcCurrentFromVoltage(List<String> values) {
  final v = number(values[0], 'Voltage (V)', minimum: 0);
  final r = number(values[1], 'Resistance (Ω)', positive: true);
  return {
    'Current (A)': fmt(v / r),
    'Current (mA)': fmt(1000 * v / r),
    'Power (W)': fmt(v * v / r),
  };
}

Answers _dcResistanceFromCurrent(List<String> values) {
  final v = number(values[0], 'Voltage (V)', positive: true);
  final i = number(values[1], 'Current (A)', positive: true);
  return {
    'Resistance (Ω)': fmt(v / i),
    'Power (W)': fmt(v * i),
  };
}

Answers _twoResistors(List<String> values) {
  final a = number(values[0], 'First resistance (Ω)', positive: true);
  final b = number(values[1], 'Second resistance (Ω)', positive: true);
  return {
    'Series resistance (Ω)': fmt(a + b),
    'Parallel resistance (Ω)': fmt(1 / (1 / a + 1 / b)),
  };
}

Answers _unloadedVoltageDivider(List<String> values) {
  final v = number(values[0], 'Supply voltage (V)', minimum: 0);
  final a = number(values[1], 'Upper resistance (Ω)', positive: true);
  final b = number(values[2], 'Lower resistance (Ω)', positive: true);
  return {
    'Output across lower resistor (V)': fmt(v * (b / (a + b))),
    'Divider current (mA)': fmt(1000 * v / (a + b)),
  };
}
