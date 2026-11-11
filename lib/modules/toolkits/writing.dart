import 'calculation.dart';

const writingModes = <Calculation>[
  Calculation('Word count', [
    Entry('Text', '', EntryType.paragraph),
  ], _analyze),
];

Answers _analyze(List<String> fields) {
  final raw = fields[0];
  final trimmed = raw.trim();
  final words = trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;

  final sentences = trimmed.split(RegExp(r'[.!?。！？]+')).where((x) => x.trim().isNotEmpty).length;
  final paragraphs = trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\r?\n[ \t]*(?:\r?\n)+')).length;
  return {
    'Words (space-delimited)': '$words', 'Characters (Unicode code points)': '${raw.runes.length}',
    'Characters excluding whitespace': '${raw.replaceAll(RegExp(r'\s'), '').runes.length}',
    'Sentences (estimated)': '$sentences', 'Paragraphs (blank-line separated)': '$paragraphs',    
  };
}
