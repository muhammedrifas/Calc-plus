import 'dart:math';
import 'calculation.dart';

const geometryModes = <Calculation>[
  Calculation('Rectangle', [
    Entry('Length (m)', '4'),
    Entry('Width (m)', '3'),
  ], _rectangle),
  Calculation('Right triangle', [
    Entry('First leg (m)', '3'),
    Entry('Second leg (m)', '4'),
  ], _rightTriangle),
  Calculation('Circle', [
    Entry('Radius (m)', '2'),
  ], _circle),
  Calculation('Rectangular box', [
    Entry('Length (m)', '4'),
    Entry('Width (m)', '3'),
    Entry('Height (m)', '2'),
  ], _rectangularBox),
  Calculation('Cylinder', [
    Entry('Radius (m)', '2'),
    Entry('Height (m)', '3'),
  ], _cylinder),
  Calculation('Sphere', [
    Entry('Radius (m)', '2'),
  ], _sphere),
];

Answers _rectangle(List<String> values) {
  final l = number(values[0], 'Length (m)', positive: true);
  final w = number(values[1], 'Width (m)', positive: true);
  return {
    'Area (m²)': fmt(l * w),
    'Perimeter (m)': fmt(2 * (l + w)),
    'Diagonal (m)': fmt(sqrt(l * l + w * w)),
  };
}

Answers _rightTriangle(List<String> values) {
  final a = number(values[0], 'First leg (m)', positive: true);
  final b = number(values[1], 'Second leg (m)', positive: true);
  final c = sqrt(a * a + b * b);
  return {
    'Hypotenuse (m)': fmt(c),
    'Area (m²)': fmt(a * b / 2),
    'Perimeter (m)': fmt(a + b + c),
  };
}

Answers _circle(List<String> values) {
  final r = number(values[0], 'Radius (m)', positive: true);
  return {
    'Area (m²)': fmt(pi * r * r),
    'Circumference (m)': fmt(2 * pi * r),
    'Diameter (m)': fmt(2 * r),
  };
}

Answers _rectangularBox(List<String> values) {
  final l = number(values[0], 'Length (m)', positive: true);
  final w = number(values[1], 'Width (m)', positive: true);
  final h = number(values[2], 'Height (m)', positive: true);
  return {
    'Volume (m³)': fmt(l * w * h),
    'Closed surface area (m²)': fmt(2 * (l * w + w * h + l * h)),
    'Capacity (L)': fmt(1000 * l * w * h),
  };
}

Answers _cylinder(List<String> values) {
  final r = number(values[0], 'Radius (m)', positive: true);
  final h = number(values[1], 'Height (m)', positive: true);
  return {
    'Volume (m³)': fmt(pi * r * r * h),
    'Closed surface area (m²)': fmt(2 * pi * r * (r + h)),
    'Capacity (L)': fmt(1000 * pi * r * r * h),
  };
}

Answers _sphere(List<String> values) {
  final r = number(values[0], 'Radius (m)', positive: true);
  return {
    'Volume (m³)': fmt(4 / 3 * pi * r * r * r),
    'Surface area (m²)': fmt(4 * pi * r * r),
  };
}
