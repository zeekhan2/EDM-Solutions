import 'timesheet_summary.dart';
import 'timesheet_entry.dart';

class TimeSheet {
  final String periodLabel;
  final List<TimeSheetSummary> summary;
  final List<TimeSheetEntry> entries;

  TimeSheet({
    required this.periodLabel,
    required this.summary,
    required this.entries,
  });

  factory TimeSheet.fromWeekly(Map<String, dynamic> json) {
    return TimeSheet(
      periodLabel: json['week_display'] ?? '',
      summary: TimeSheetSummary.fromList(json['summary']),
      entries: TimeSheetEntry.fromWeeklyList(json['daily_entries']),
    );
  }

  factory TimeSheet.fromMonthly(Map<String, dynamic> json) {
    return TimeSheet(
      periodLabel: json['month'] ?? '',
      summary: TimeSheetSummary.fromList(json['summary']),
      entries: TimeSheetEntry.fromMonthlyList(json['weeks']),
    );
  }
}
