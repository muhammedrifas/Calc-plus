import 'calculation.dart';

const powerCostModes = <Calculation>[
  Calculation('Appliance electricity cost', [
    Entry('Appliance power (W)', '100'),
    Entry('Number of appliances', '2'),
    Entry('Hours used per day', '5'),
    Entry('Days in billing period', '30'),
    Entry('Price per kWh', '0.25'),
  ], _applianceElectricityCost),
  Calculation('Battery runtime estimate', [
    Entry('Nominal voltage (V)', '12'),
    Entry('Usable capacity (Ah)', '50'),
    Entry('Constant load (W)', '60'),
    Entry('Conversion efficiency (%)', '90'),
  ], _batteryRuntimeEstimate),
  Calculation('Watt-hours to amp-hours', [
    Entry('Energy (Wh)', '600'),
    Entry('Nominal voltage (V)', '12'),
  ], _wattHoursToAmpHours),
];

Answers _applianceElectricityCost(List<String> values) {
  final w = number(values[0], 'Appliance power (W)', positive: true);
  final qty = number(values[1], 'Number of appliances', positive: true, whole: true);
  final h = number(values[2], 'Hours used per day', minimum: 0, maximum: 24);
  final days = number(values[3], 'Days in billing period', positive: true, whole: true);
  final rate = number(values[4], 'Price per kWh', minimum: 0);
  final energy = w * qty / 1000 * h * days;
  return {
    'Energy over period (kWh)': fmt(energy),
    'Usage cost (excludes fixed fees)': money(energy * rate),
  };
}

Answers _batteryRuntimeEstimate(List<String> values) {
  final v = number(values[0], 'Nominal voltage (V)', positive: true);
  final ah = number(values[1], 'Usable capacity (Ah)', positive: true);
  final w = number(values[2], 'Constant load (W)', positive: true);
  final eff = number(values[3], 'Conversion efficiency (%)', minimum: 0, maximum: 100);
  final energy = v * ah * eff / 100;
  return {
    'Usable energy after losses (Wh)': fmt(energy),
    'Estimated runtime (hours)': fmt(energy / w),
  };
}

Answers _wattHoursToAmpHours(List<String> values) {
  final wh = number(values[0], 'Energy (Wh)', positive: true);
  final v = number(values[1], 'Nominal voltage (V)', positive: true);
  return {
    'Capacity (Ah)': fmt(wh / v),
    'Capacity (mAh)': fmt(1000 * wh / v),
  };
}
