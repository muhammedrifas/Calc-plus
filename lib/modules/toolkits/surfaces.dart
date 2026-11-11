import 'calculation.dart';

const surfacesModes = <Calculation>[
  Calculation('Paint for four walls', [
    Entry('Room length (m)', '5'),
    Entry('Room width (m)', '4'),
    Entry('Wall height (m)', '2.5'),
    Entry('Excluded doors and windows (m²)', '5'),
    Entry('Number of coats', '2'),
    Entry('Coverage per litre (m²)', '10'),
  ], _paintForFourWalls),
  Calculation('Flooring or carpet packs', [
    Entry('Area length (m)', '5'),
    Entry('Area width (m)', '4'),
    Entry('Extra for cuts (%)', '10'),
    Entry('Coverage per pack (m²)', '2.2'),
  ], _flooringOrCarpetPacks),
  Calculation('Tiles or pavers', [
    Entry('Area length (m)', '5'),
    Entry('Area width (m)', '4'),
    Entry('Extra for cuts (%)', '10'),
    Entry('Coverage per tile (m²)', '0.09'),
  ], _tilesOrPavers),
];

Answers _paintForFourWalls(List<String> values) {
  final length = number(values[0], 'Room length (m)', positive: true);
  final width = number(values[1], 'Room width (m)', positive: true);
  final height = number(values[2], 'Wall height (m)', positive: true);
  final openings = number(values[3], 'Excluded doors and windows (m²)', minimum: 0);
  final coats = number(values[4], 'Number of coats', positive: true, whole: true);
  final coverage = number(values[5], 'Coverage per litre (m²)', positive: true);
  final area = 2 * (length + width) * height - openings;
  if (area < 0) invalid('Openings exceed the total wall area.');
  return {
    'Paintable area per coat (m²)': fmt(area),
    'Paint required (L)': fmt(area * coats / coverage),
  };
}

Answers _flooringOrCarpetPacks(List<String> values) {
  final l = number(values[0], 'Area length (m)', positive: true);
  final w = number(values[1], 'Area width (m)', positive: true);
  final waste = number(values[2], 'Extra for cuts (%)', minimum: 0);
  final coverage = number(values[3], 'Coverage per pack (m²)', positive: true);
  final area = l * w * (1 + waste / 100);
  return {
    'Floor area (m²)': fmt(l * w),
    'Area with allowance (m²)': fmt(area),
    'Whole packs to order': fmt(roundUp(area / coverage)),
  };
}

Answers _tilesOrPavers(List<String> values) {
  final l = number(values[0], 'Area length (m)', positive: true);
  final w = number(values[1], 'Area width (m)', positive: true);
  final waste = number(values[2], 'Extra for cuts (%)', minimum: 0);
  final coverage = number(values[3], 'Coverage per tile (m²)', positive: true);
  final area = l * w * (1 + waste / 100);
  return {
    'Floor area (m²)': fmt(l * w),
    'Area with allowance (m²)': fmt(area),
    'Whole tiles to order': fmt(roundUp(area / coverage)),
  };
}
