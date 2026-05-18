class MonitorResult {
  final String name;
  final double value;
  final double min;
  final double max;
  final String unit;
  final bool passed;

  MonitorResult({
    required this.name,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.passed,
  });
}
