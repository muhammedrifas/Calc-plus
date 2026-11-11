import 'dart:math';
import 'calculation.dart';

const volumeMaterialsModes = <Calculation>[
  Calculation('Rectangular slab or garden bed', [
    Entry('Length (m)', '4'),
    Entry('Width (m)', '3'),
    Entry('Depth (cm)', '10'),
    Entry('Extra allowance (%)', '5'),
    Entry('Yield per bag (L)', '25'),
  ], _rectangularSlabOrGardenBed),
  Calculation('Round bed or column', [
    Entry('Diameter (m)', '2'),
    Entry('Depth (cm)', '10'),
    Entry('Extra allowance (%)', '5'),
    Entry('Yield per bag (L)', '25'),
  ], _roundBedOrColumn),
  Calculation('Bulk material weight', [
    Entry('Volume (m³)', '2'),
    Entry('Supplier bulk density (kg/m³)', '1500'),
  ], _bulkMaterialWeight),
];

Answers _rectangularSlabOrGardenBed(List<String> values) {
  final l = number(values[0], 'Length (m)', positive: true);
  final w = number(values[1], 'Width (m)', positive: true);
  final depth = number(values[2], 'Depth (cm)', positive: true);
  final extra = number(values[3], 'Extra allowance (%)', minimum: 0);
  final bag = number(values[4], 'Yield per bag (L)', positive: true);
  final volume = l * w * depth / 100 * (1 + extra / 100);
  return {
    'Volume with allowance (m³)': fmt(volume),
    'Litres': fmt(volume * 1000),
    'Whole bags': fmt(roundUp(volume * 1000 / bag)),
  };
}

Answers _roundBedOrColumn(List<String> values) {
  final d = number(values[0], 'Diameter (m)', positive: true);
  final depth = number(values[1], 'Depth (cm)', positive: true);
  final extra = number(values[2], 'Extra allowance (%)', minimum: 0);
  final bag = number(values[3], 'Yield per bag (L)', positive: true);
  final volume = pi * (d / 2) * (d / 2) * depth / 100 * (1 + extra / 100);
  return {
    'Volume with allowance (m³)': fmt(volume),
    'Litres': fmt(volume * 1000),
    'Whole bags': fmt(roundUp(volume * 1000 / bag)),
  };
}

Answers _bulkMaterialWeight(List<String> values) {
  final vol = number(values[0], 'Volume (m³)', positive: true);
  final density = number(values[1], 'Supplier bulk density (kg/m³)', positive: true);
  return {
    'Mass (kg)': fmt(vol * density),
    'Metric tonnes': fmt(vol * density / 1000),
  };
}
