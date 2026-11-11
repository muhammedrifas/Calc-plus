import 'calculation.dart';

const paceModes = <Calculation>[
  Calculation('Pace from elapsed time', [
    Entry('Distance (km)', '5'),
    Entry('Elapsed whole minutes', '27'),
    Entry('Additional seconds', '30'),
  ], _paceFromElapsedTime),
  Calculation('Finish time from pace', [
    Entry('Distance (km)', '21.0975'),
    Entry('Pace whole minutes per km', '5'),
    Entry('Additional seconds per km', '30'),
  ], _finishTimeFromPace),
  Calculation('Distance from speed', [
    Entry('Average speed (km/h)', '18'),
    Entry('Duration (minutes)', '45'),
  ], _distanceFromSpeed),
];

Answers _paceFromElapsedTime(List<String> values) {
  final d = number(values[0], 'Distance (km)', positive: true);
  final m = number(values[1], 'Elapsed whole minutes', minimum: 0, whole: true);
  final s = number(values[2], 'Additional seconds', minimum: 0, maximum: 59, whole: true);
  final total = m * 60 + s;
  if (total == 0) invalid('Elapsed time must be positive.');
  return {
    'Pace per km': clock(total / d),
    'Pace per mile': clock(total / d * 1.609344),
    'Speed (km/h)': fmt(d * 3600 / total),
  };
}

Answers _finishTimeFromPace(List<String> values) {
  final d = number(values[0], 'Distance (km)', positive: true);
  final m = number(values[1], 'Pace whole minutes per km', minimum: 0, whole: true);
  final s = number(values[2], 'Additional seconds per km', minimum: 0, maximum: 59, whole: true);
  final pace = m * 60 + s;
  if (pace == 0) invalid('Pace must be positive.');
  return {
    'Estimated finish time (h:mm:ss)': clock(d * pace, hours: true),
    'Speed (km/h)': fmt(3600 / pace),
  };
}

Answers _distanceFromSpeed(List<String> values) {
  final v = number(values[0], 'Average speed (km/h)', positive: true);
  final t = number(values[1], 'Duration (minutes)', positive: true);
  return {
    'Distance (km)': fmt(v * t / 60),
    'Distance (mi)': fmt(v * t / 60 / 1.609344),
  };
}
