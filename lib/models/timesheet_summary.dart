class TimeSheetSummary {
  final String label;
  final String value;
  final double valueRaw;

  TimeSheetSummary({
    required this.label,
    required this.value,
    required this.valueRaw,
  });

  factory TimeSheetSummary.fromJson(Map<String, dynamic> json) {
    return TimeSheetSummary(
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      valueRaw: (json['value_raw'] ?? 0).toDouble(),
    );
  }

  static List<TimeSheetSummary> fromList(List? list) {
    if (list == null) return [];
    return list.map((e) => TimeSheetSummary.fromJson(e)).toList();
  }
}
