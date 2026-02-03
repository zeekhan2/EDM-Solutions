import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../consts/api_constants.dart';

class StaffAttendanceController extends GetxController {
  final attendanceLoading = false.obs;
  final attendanceList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAttendance();
  }

  // ===================== FETCH ATTENDANCE =====================
  Future<void> fetchAttendance() async {
    try {
      attendanceLoading.value = true;

      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        attendanceList.clear();
        return;
      }

      final response = await ApiService.get(
        endpoint: ApiConstants.getStaffAttendanceDetails,
        token: token,
      );

      if (!response.success || response.data == null) {
        attendanceList.clear();
        return;
      }

      final List list = response.data['shift_attendance_details'] ?? [];

      attendanceList.assignAll(
        list.map<Map<String, dynamic>>((e) => {
              'name': e['name'],
              'shift_time': e['shift_time'],
              'date': e['date'],
              'clock_in': e['clocked_in'],
              'clock_out': e['clocked_out'],
              'is_late': false,
            }),
      );
    } finally {
      attendanceLoading.value = false;
    }
  }
}
