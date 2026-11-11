import 'calculation.dart';

const digitalModes = <Calculation>[
  Calculation('Download duration', [
    Entry('File size (GB, decimal)', '4'),
    Entry('Actual throughput (Mbps)', '50'),
  ], _downloadDuration),
  Calculation('Measured transfer speed', [
    Entry('Data transferred (MB, decimal)', '500'),
    Entry('Elapsed seconds', '80'),
  ], _measuredTransferSpeed),
  Calculation('Storage capacity', [
    Entry('Drive capacity (GB, decimal)', '256'),
    Entry('Average file size (MiB)', '10'),
  ], _storageCapacity),
];

Answers _downloadDuration(List<String> values) {
  final size = number(values[0], 'File size (GB, decimal)', positive: true);
  final speed = number(values[1], 'Actual throughput (Mbps)', positive: true);
  return {
    'Duration (h:mm:ss)': clock(size * 8000 / speed, hours: true),
    'Seconds': fmt(size * 8000 / speed),
  };
}

Answers _measuredTransferSpeed(List<String> values) {
  final size = number(values[0], 'Data transferred (MB, decimal)', positive: true);
  final time = number(values[1], 'Elapsed seconds', positive: true);
  return {
    'Throughput (Mbps)': fmt(size * 8 / time),
    'Megabytes per second': fmt(size / time),
  };
}

Answers _storageCapacity(List<String> values) {
  final gb = number(values[0], 'Drive capacity (GB, decimal)', positive: true);
  final size = number(values[1], 'Average file size (MiB)', positive: true);
  final count = gb * 1e9 / 1048576 / size;
  if (!count.isFinite || count > 9007199254740991) invalid('File count exceeds the supported range.');
  return {
    'Binary capacity (GiB)': fmt(gb * 1e9 / 1073741824),
    'Whole files (before overhead)': fmt(count.floor()),
  };
}
