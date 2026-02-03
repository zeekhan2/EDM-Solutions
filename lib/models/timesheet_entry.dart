class TimeSheetEntry {
  final String title; // Day or Week
  final String subtitle; // Date or label
  final String hours;

  TimeSheetEntry({
    required this.title,
    required this.subtitle,
    required this.hours,
  });

  /// Weekly → daily_entries
  factory TimeSheetEntry.fromWeekly(Map<String, dynamic> json) {
    return TimeSheetEntry(
      title: json['day'] ?? '',
      subtitle: json['date'] ?? '',
      hours: '${json['hours']} hrs',
    );
  }

  /// Monthly → weeks[]
  factory TimeSheetEntry.fromMonthly(Map<String, dynamic> json) {
    return TimeSheetEntry(
      title: json['week'] ?? '',
      subtitle: 'Weekly Total',
      hours: '${json['hours']} hrs',
    );
  }

  static List<TimeSheetEntry> fromWeeklyList(List? list) {
    if (list == null) return [];
    return list.map((e) => TimeSheetEntry.fromWeekly(e)).toList();
  }

  static List<TimeSheetEntry> fromMonthlyList(List? list) {
    if (list == null) return [];
    return list.map((e) => TimeSheetEntry.fromMonthly(e)).toList();
  }
}
