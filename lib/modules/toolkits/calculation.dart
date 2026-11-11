typedef Answers = Map<String, String>;

enum EntryType { number, text, paragraph, date }

class Entry {
  final String label;
  final String initial;
  final EntryType type;
  const Entry(this.label, this.initial, [this.type = EntryType.number]);
}

class Calculation {
  final String title;
  final List<Entry> fields;
  final Answers Function(List<String>) evaluate;
  const Calculation(this.title, this.fields, this.evaluate);
}

Never invalid(String message) => throw FormatException(message);

double parseNumber(String value, String label) {
  final n = double.tryParse(value.trim());
  if (n == null || !n.isFinite) invalid('Enter a finite number for $label.');
  return n;
}

double number(String value, String label, {double? minimum, bool positive = false, double? maximum, bool whole = false}) {
  final n = parseNumber(value, label);
  if (positive && n <= 0) invalid('$label must be greater than zero.');
  if (minimum != null && n < minimum) invalid('$label must be at least ${fmt(minimum)}.');
  if (maximum != null && n > maximum) invalid('$label must be at most ${fmt(maximum)}.');
  if (whole && (n != n.truncateToDouble() || n.abs() > 9007199254740991)) {
    invalid('Enter a whole number within the supported range for $label.');
  }
  return n;
}

String fmt(num value) {
  if (!value.isFinite) invalid('The result exceeds the supported range.');
  if (value == 0) return '0';
  if (value is int) return value.toString();
  if (value.abs() <= 9007199254740991 && value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  final parts = value.toStringAsPrecision(12).split('e');
  final mantissa = parts.first.contains('.')
      ? parts.first.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
      : parts.first;
  return [mantissa, ...parts.skip(1)].join('e');
}

String money(num value) {
  if (!value.isFinite) invalid('The amount exceeds the supported range.');
  return value.toStringAsFixed(2);
}

int roundUp(double value) {
  if (!value.isFinite || value.abs() > 9007199254740991) invalid('Quantity exceeds the supported range.');
  // Ignore sub-ULP noise when a decimal quantity should be integral.
  final nearest = value.round();
  if ((nearest - value).abs() <= 2.22e-16 * value.abs()) return nearest;
  return value.ceil();
}

String clock(double seconds, {bool hours = false}) {
  if (!seconds.isFinite || seconds < 0 || seconds > 9007199254740991) {
    invalid('Duration exceeds the supported range.');
  }
  final total = seconds.round();
  final s = (total % 60).toString().padLeft(2, '0');
  if (!hours) return '${total ~/ 60}:$s';
  final m = (total ~/ 60 % 60).toString().padLeft(2, '0');
  return '${total ~/ 3600}:$m:$s';
}
