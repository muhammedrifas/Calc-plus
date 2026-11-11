import 'calculation.dart';

const ratiosModes = <Calculation>[
  Calculation('Split a total in a ratio', [
    Entry('Total to distribute', '240'),
    Entry('First ratio weight', '2'),
    Entry('Second ratio weight', '3'),
  ], _splitATotalInARatio),
  Calculation('Solve a proportion', [
    Entry('A in A/B = C/D', '3'),
    Entry('B', '4'),
    Entry('C', '12'),
  ], _solveAProportion),
  Calculation('Scale a recipe', [
    Entry('Ingredient quantity', '250'),
    Entry('Original servings', '4'),
    Entry('Desired servings', '6'),
  ], _scaleARecipe),
];

Answers _splitATotalInARatio(List<String> values) {
  final total = number(values[0], 'Total to distribute', minimum: 0);
  final a = number(values[1], 'First ratio weight', positive: true);
  final b = number(values[2], 'Second ratio weight', positive: true);
  return {
    'First share': fmt(total * (a / (a + b))),
    'Second share': fmt(total * (b / (a + b))),
  };
}

Answers _solveAProportion(List<String> values) {
  final a = number(values[0], 'A in A/B = C/D', positive: true);
  final b = number(values[1], 'B', positive: true);
  final c = number(values[2], 'C', positive: true);
  return {
    'Missing D': fmt(b * (c / a)),
  };
}

Answers _scaleARecipe(List<String> values) {
  final amount = number(values[0], 'Ingredient quantity', minimum: 0);
  final old = number(values[1], 'Original servings', positive: true);
  final target = number(values[2], 'Desired servings', positive: true);
  return {
    'Scaled ingredient (same unit)': fmt(amount * target / old),
    'Recipe multiplier': fmt(target / old),
  };
}
