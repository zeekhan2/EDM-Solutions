import 'package:get/get.dart';

import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../consts/api_constants.dart';

class FacilityDashboardController extends GetxController {
  final openCount = 0.obs;
  final pendingCount = 0.obs;
  final filledCount = 0.obs;
  final facilityImage = ''.obs;

  /// Facility name (USED IN HEADER)
  final facility_name = ''.obs;

  final isLoading = true.obs;

  String? _token;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
  try {
    isLoading.value = true;

    _token = await StorageService.getToken();
    if (_token == null || _token!.isEmpty) return;

    await fetchFacilityName();
    await fetchDashboard();
  } finally {
    isLoading.value = false;
  }
}


  // =========================
  // FACILITY NAME (HEADER)
  // =========================
  Future<void> fetchFacilityName() async {
  try {
    final response = await ApiService.get(
      endpoint: '/api/facility/profile', // ✅ facility-only API
      token: _token,
    );

    if (response.success == true && response.data != null) {
      final data = response.data['data'];

      facility_name.value = data['facility_name'] ?? '';
      facilityImage.value = data['image'] ?? '';
    }
  } catch (_) {
    facility_name.value = '';
    facilityImage.value = '';
  }
}


  // =========================
  // DASHBOARD COUNTS
  // =========================
 Future<void> fetchDashboard() async {
  if (_token == null) return;

  final response = await ApiService.get(
    endpoint: ApiConstants.facilityGetShifts,
    token: _token,
  );

  if (!response.success || response.data == null) {
    openCount.value = 0;
    pendingCount.value = 0;
    filledCount.value = 0;
    return;
  }

  final List list = response.data['data'] ?? [];

  openCount.value = list.length;
  pendingCount.value = 0;
  filledCount.value = 0;
}

}
