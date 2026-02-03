class DailyEntry {
  final String day;
  final String date;
  final String hours;

  DailyEntry({
    required this.day,
    required this.date,
    required this.hours,
  });

  /// WEEKLY → daily_entries
  factory DailyEntry.fromWeekly(Map<String, dynamic> json) {
    return DailyEntry(
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      hours: '${json['hours']} hrs',
    );
  }

  /// MONTHLY → weeks[]
  factory DailyEntry.fromMonthly(Map<String, dynamic> json) {
    return DailyEntry(
      day: json['week'] ?? '',
      date: 'Weekly Total',
      hours: '${json['hours']} hrs',
    );
  }
}
