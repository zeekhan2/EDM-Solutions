import 'package:edm_solutions/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/api_constants.dart';
import 'package:edm_solutions/services/api_service.dart';

class ReportStatsController extends GetxController {
  // -----------------------
  // STATE
  // -----------------------
  final RxBool isLoading = false.obs;

  // -----------------------
  // TOP SUMMARY CARDS
  // -----------------------
  final RxDouble totalCost = 0.0.obs;
  final RxInt totalCostChange = 0.obs;

  final RxInt totalShifts = 0.obs;
  final RxInt totalShiftsChange = 0.obs;

  final RxDouble avgRate = 0.0.obs;

  final RxDouble pendingAmount = 0.0.obs;
  final RxString nextPaymentDate = ''.obs;

  // -----------------------
  // CHART DATA
  // -----------------------
  final RxList<int> monthlyShifts = <int>[].obs;
  final RxList<String> monthlyLabels = <String>[].obs;

  final RxMap<String, int> costByDepartment = <String, int>{}.obs;
  final RxMap<String, int> roleDistribution = <String, int>{}.obs;

  // -----------------------
  // API CALL
  // -----------------------
  /// API: GET /api/get/report/stats
  Future<void> fetchReportStats({String? range}) async {
    try {
      isLoading.value = true;

      final token = await StorageService.getToken();

      final response = await ApiService.get(
        endpoint: ApiConstants.getReportStats,
        token: token,
        queryParams: {
          if (range != null) 'range': range,
        },
      );

      if (!response.success || response.data == null) {
        throw response.message ?? 'Failed to load report stats';
      }

      final body = response.data as Map<String, dynamic>;

      // =======================
      // TOP STATS
      // =======================
      final stats = body['stats'] ?? {};

      // Total Cost
      totalCost.value = double.tryParse(
            stats['total_cost_paid']?['amount']?.toString() ?? '0',
          ) ??
          0;

      totalCostChange.value =
          stats['total_cost_paid']?['change_percentage'] ?? 0;

      // Total Shifts (✅ FIXED)
      totalShifts.value = stats['total_shifts_completed']?['count'] ?? 0;

      totalShiftsChange.value =
          stats['total_shifts_completed']?['change_percentage'] ?? 0;

      // Avg Rate
      avgRate.value = (stats['average_cost_per_shift'] ?? 0).toDouble();

      // Pending Payments
      pendingAmount.value =
          (stats['pending_payments']?['amount'] ?? 0).toDouble();

      nextPaymentDate.value =
          stats['pending_payments']?['next_payment_date']?.toString() ?? '';

      // =======================
      // MONTHLY SHIFTS (LINE)
      // =======================
      final monthly = body['monthly_filled_shifts'] as List? ?? [];

      monthlyShifts.assignAll(
        monthly.map<int>((e) => e['shifts'] ?? 0).toList(),
      );

      monthlyLabels.assignAll(
        monthly.map<String>((e) => e['month'].toString()).toList(),
      );

      // =======================
      // COST BY DEPARTMENT (BAR)
      // =======================
      final deptList = body['cost_by_department'] as List? ?? [];

      costByDepartment.assignAll({
        for (final d in deptList)
          d['department'].toString(): (d['cost'] as num).round(),
      });

      // =======================
      // ROLE DISTRIBUTION (PIE)
      // =======================
      final roles =
          body['shift_title_distribution']?['shifts_by_title'] as List? ?? [];

      roleDistribution.assignAll({
        for (final r in roles) r['initials'].toString(): r['count'] ?? 0,
      });

      // DEBUG (safe to remove later)
      debugPrint('✅ Report stats loaded');
      debugPrint('Total Shifts: ${totalShifts.value}');
    } catch (e, st) {
      debugPrint('❌ ReportStats error: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      isLoading.value = false;
    }
  }
}
