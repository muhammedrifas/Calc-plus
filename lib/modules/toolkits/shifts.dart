import 'calculation.dart';

const shiftsModes = <Calculation>[
  Calculation('Paid shift hours', [
    Entry('Clock in (24-hour HH:MM)', '09:00', EntryType.text),
    Entry('Clock out (earlier means next day)', '17:30', EntryType.text),
    Entry('Unpaid break (minutes)', '30'),
  ], _shift),
  Calculation('Decimal hours to duration', [Entry('Decimal hours', '7.75')], _duration),
  Calculation('Duration to decimal hours', [
    Entry('Whole hours', '7'), Entry('Additional minutes (0–59)', '45'),
  ], _decimal),
];

int _minutes(String raw) {
  final m = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch(raw.trim());
  if (m == null) invalid('Enter a 24-hour time, for example 17:30.');
  return int.parse(m[1]!) * 60 + int.parse(m[2]!);
}

Answers _shift(List<String> fields) {
  final start = _minutes(fields[0]);
  final end = _minutes(fields[1]);
  final elapsed = (end - start) % 1440;
  final pause = number(fields[2], 'Unpaid break', minimum: 0, whole: true);
  if (pause > elapsed) invalid('Break cannot exceed the shift duration.');
  final paid = elapsed - pause;
  return {'Elapsed (hours:minutes)': '${elapsed ~/ 60}:${(elapsed % 60).toString().padLeft(2, '0')}',
    'Paid time (decimal hours)': fmt(paid / 60), 'Paid minutes': fmt(paid)};
}

Answers _duration(List<String> fields) {
  final h = number(fields.first, 'Hours', minimum: 0);
  return {'Duration (h:mm:ss)': clock(h * 3600, hours: true), 'Total minutes': fmt(h * 60)};
}

Answers _decimal(List<String> fields) {
  final h = number(fields[0], 'Hours', minimum: 0, whole: true);
  final m = number(fields[1], 'Minutes', minimum: 0, maximum: 59, whole: true);
  return {'Decimal hours': fmt(h + m / 60), 'Total minutes': fmt(h * 60 + m)};
}
