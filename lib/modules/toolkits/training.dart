import 'calculation.dart';

const trainingModes = <Calculation>[
  Calculation('Workout volume', [
    Entry('Weight per repetition (kg)', '60'),
    Entry('Repetitions per set', '8'),
    Entry('Sets', '3'),
  ], _workoutVolume),
  Calculation('Barbell loading', [
    Entry('Target total (kg)', '80'),
    Entry('Bar weight (kg)', '20'),
  ], _barbellLoading),
];

Answers _workoutVolume(List<String> values) {
  final load = number(values[0], 'Weight per repetition (kg)', minimum: 0);
  final reps = number(values[1], 'Repetitions per set', positive: true, whole: true);
  final sets = number(values[2], 'Sets', positive: true, whole: true);
  return {
    'Total repetitions': fmt(reps * sets),
    'Volume load (kg)': fmt(load * reps * sets),
  };
}

Answers _barbellLoading(List<String> values) {
  final target = number(values[0], 'Target total (kg)', positive: true);
  final bar = number(values[1], 'Bar weight (kg)', positive: true);
  if (target < bar) invalid('Target weight must be at least the bar weight.');
  return {
    'Plates required per side (kg)': fmt((target - bar) / 2),
  };
}
