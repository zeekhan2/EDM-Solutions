import 'package:edm_solutions/models/daily_entry.dart';
import 'package:edm_solutions/models/timesheet_entry.dart';
import 'package:get/get.dart';

import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../consts/api_constants.dart';

class TimeSheetController extends GetxController {
  final isLoading = true.obs;

  /// TOGGLE
  final isWeekly = true.obs;

  /// HEADER
  final periodLabel = ''.obs;

  /// SUMMARY
  final totalHours = '0 hrs'.obs;
  final regularHours = '0 hrs'.obs;
  final overtimeHours = '0 hrs'.obs;

  /// LIST (Daily for Week, Weekly for Month)
  final dailyEntries = <TimeSheetEntry>[].obs;

  String? _token;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    _token = await StorageService.getToken();
    if (_token == null || _token!.isEmpty) return;

    fetchWeekly();
  }

  // ================= TOGGLE =================

  void switchToWeekly() {
    if (!isWeekly.value) {
      isWeekly.value = true;
      fetchWeekly();
    }
  }

  void switchToMonthly() {
    if (isWeekly.value) {
      isWeekly.value = false;
      fetchMonthly();
    }
  }

  // ================= WEEKLY =================

  Future<void> fetchWeekly() async {
    await _fetchWeekly(ApiConstants.timesheetWeek);
  }

  // ================= MONTHLY =================

  Future<void> fetchMonthly() async {
    await _fetchMonthly(ApiConstants.timesheetMonthly);
  }

  // ================= WEEKLY HANDLER =================

  Future<void> _fetchWeekly(String endpoint) async {
    try {
      isLoading.value = true;
      dailyEntries.clear();

      final response = await ApiService.get(
        endpoint: endpoint,
        token: _token,
      );

      if (!response.success || response.data == null) {
        _reset();
        return;
      }

      /// 🔴 FIX: unwrap inner data
      final Map<String, dynamic> data =
          response.data is Map && response.data['data'] != null
              ? response.data['data']
              : response.data;

      /// HEADER
      periodLabel.value = data['week_display'] ?? '';

      _parseSummary(data['summary']);

      /// DAILY ENTRIES
      final List entries = data['daily_entries'] ?? [];
      dailyEntries.assignAll(
        entries.map((e) => TimeSheetEntry.fromWeekly(e)).toList(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ================= MONTHLY HANDLER =================

  Future<void> _fetchMonthly(String endpoint) async {
    try {
      isLoading.value = true;
      dailyEntries.clear();

      final response = await ApiService.get(
        endpoint: endpoint,
        token: _token,
      );

      if (!response.success || response.data == null) {
        _reset();
        return;
      }

      /// 🔴 FIX: unwrap inner data
      final Map<String, dynamic> data =
          response.data is Map && response.data['data'] != null
              ? response.data['data']
              : response.data;

      /// HEADER
      periodLabel.value = data['month'] ?? '';

      _parseSummary(data['summary']);

      /// WEEKS
      final List weeks = data['weeks'] ?? [];
      dailyEntries.assignAll(
        weeks.map((e) => TimeSheetEntry.fromMonthly(e)).toList(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ================= SUMMARY PARSER =================

  void _parseSummary(List? summary) {
    totalHours.value = '0 hrs';
    regularHours.value = '0 hrs';
    overtimeHours.value = '0 hrs';

    if (summary == null) return;

    for (final item in summary) {
      switch (item['label']) {
        case 'Total Hours':
          totalHours.value = item['value'];
          break;
        case 'Regular Hours':
          regularHours.value = item['value'];
          break;
        case 'Overtime':
          overtimeHours.value = item['value'];
          break;
      }
    }
  }

  void _reset() {
    periodLabel.value = '';
    totalHours.value = '0 hrs';
    regularHours.value = '0 hrs';
    overtimeHours.value = '0 hrs';
    dailyEntries.clear();
  }
}
