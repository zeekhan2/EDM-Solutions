import 'package:get/get.dart';

import '../models/shift_models.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../consts/api_constants.dart';
import '../services/storage_service.dart';

class ShiftController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Shift> openShifts = <Shift>[].obs;
  final RxList<Shift> pendingShifts = <Shift>[].obs;
  final RxList<Shift> filledShifts = <Shift>[].obs;

  String? _token;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _token = await StorageService.getToken();
    if (_token == null || _token!.isEmpty) return;
    await fetchAll();
  }

  // ================= FETCH =================
  Future<void> fetchAll() async {
    if (_token == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final ApiResponse resp = await ApiService.get(
        endpoint: ApiConstants.facilityGetShifts,
        token: _token,
      );

      _clearAll();

      if (resp.success != true || resp.data == null) return;

      final List raw = _extractList(resp.data);

      final shifts =
          raw.map((e) => Shift.fromJson(Map<String, dynamic>.from(e))).toList();

      for (final s in shifts) {
        final status = s.status ?? -1;

        if (status == 1) {
          openShifts.add(s);
        } else if (status == 2) {
          pendingShifts.add(s);
        } else if (status >= 3) {
          filledShifts.add(s);
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      _clearAll();
    } finally {
      isLoading.value = false;
    }
  }

  // ================= DELETE SHIFT =================
  Future<bool> deleteShift(int shiftId) async {
    if (_token == null) return false;

    isLoading.value = true;

    try {
      final ApiResponse resp = await ApiService.get(
        endpoint: '/api/delete/shift/$shiftId',
        token: _token,
      );

      if (resp.success == true) {
        await fetchAll(); // refresh list
        return true;
      } else {
        errorMessage.value = resp.message ?? 'Delete failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= UPDATE SHIFT =================
  Future<void> updateShift(int id, Map<String, dynamic> body) async {
    // ✅ ALWAYS FETCH LATEST TOKEN
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      Get.snackbar('Error', 'Authentication token missing');
      return;
    }

    isLoading.value = true;

    try {
      final ApiResponse resp = await ApiService.post(
        endpoint: '${ApiConstants.updateShift}/$id',
        token: token, // ✅ USE FRESH TOKEN
        body: body,
      );

      if (resp.success == true) {
        await fetchAll();
        Get.back();
        Get.snackbar('Success', 'Shift updated successfully');
      } else {
        Get.snackbar('Error', resp.message ?? 'Update failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= APPROVE SHIFT =================
  Future<void> approveShift(int shiftId) async {
    if (_token == null) return;

    isLoading.value = true;

    try {
      final ApiResponse resp = await ApiService.get(
        endpoint: '/api/accept-pending-shift/$shiftId',
        token: _token,
      );

      if (resp.success == true) {
        await fetchAll();
        Get.snackbar('Success', 'Shift approved');
      } else {
        Get.snackbar('Error', resp.message ?? 'Approval failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

//==================== GET OPEN SHIFTS =================
  Future<List<Map<String, dynamic>>> getOpenShifts() async {
    final token = await StorageService.getToken();
    if (token == null) return [];

    final res = await ApiService.get(
      endpoint: ApiConstants.facilityGetShifts,
      token: token,
    );

    if (res.success == true && res.data != null) {
      return List<Map<String, dynamic>>.from(res.data['data'] ?? []);
    }

    return [];
  }

  // ================= REJECT SHIFT =================
  Future<void> rejectShift(int shiftId) async {
    if (_token == null) return;

    isLoading.value = true;

    try {
      final ApiResponse resp = await ApiService.post(
        endpoint: '/api/reject/shift/$shiftId',
        token: _token,
      );

      if (resp.success == true) {
        await fetchAll();
        Get.snackbar('Success', 'Shift rejected');
      } else {
        Get.snackbar('Error', resp.message ?? 'Rejection failed');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ================= HELPERS =================
  void _clearAll() {
    openShifts.clear();
    pendingShifts.clear();
    filledShifts.clear();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      if (data['data'] is List) return data['data'];
      if (data['shifts'] is List) return data['shifts'];
    }
    return [];
  }
}
