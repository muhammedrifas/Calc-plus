import 'calculation.dart';

final _today = DateTime.now().toIso8601String().split('T').first;
final _date = Entry('Date', _today, EntryType.date);
final calendarModes = <Calculation>[
  Calculation('Week number & day of year', [_date], _calendar),
  const Calculation('Unix timestamp to UTC', [
    Entry('Seconds since Unix epoch', '1704067200', EntryType.text),
  ], _unix),
  Calculation('UTC midnight to Unix timestamp', [_date], _epoch),
];

// UTC civil dates keep day counts independent of daylight-saving transitions.
DateTime _utc(String raw) => DateTime.parse('${raw}T00:00:00Z');

Answers _calendar(List<String> fields) {
  const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final d = _utc(fields.first);
  final thursday = d.add(Duration(days: 4 - d.weekday));
  final week = thursday.difference(DateTime.utc(thursday.year)).inDays ~/ 7 + 1;
  return {'Weekday': names[d.weekday - 1], 'ISO week': '${thursday.year}-W${week.toString().padLeft(2, '0')}',
    'Day of year': '${d.difference(DateTime.utc(d.year)).inDays + 1}',
    'Days remaining after this date': '${DateTime.utc(d.year, 12, 31).difference(d).inDays}',
    'Leap year': DateTime.utc(d.year, 3, 0).day == 29 ? 'Yes' : 'No'};
}

Answers _unix(List<String> fields) {
  final s = number(fields.first, 'Unix seconds', minimum: -62135596800, maximum: 253402300799, whole: true).toInt();
  return {'UTC date and time': DateTime.fromMillisecondsSinceEpoch(s * 1000, isUtc: true).toIso8601String()};
}

Answers _epoch(List<String> fields) {
  final ms = _utc(fields.first).millisecondsSinceEpoch;
  return {'Unix seconds': '${ms ~/ 1000}', 'Unix milliseconds': '$ms'};
}
