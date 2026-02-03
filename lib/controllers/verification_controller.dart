import 'dart:typed_data';
import 'package:get/get.dart';

import '../models/shift_models.dart';
import '../services/worker_service.dart';
import '../services/storage_service.dart';
import 'package:edm_solutions/views/UserApp/Clock/shift_completed_screen.dart';

class VerificationController extends GetxController {
  final Shift shift;

  VerificationController(this.shift);

  final RxBool isSubmitting = false.obs;

  /// ✅ SINGLE METHOD — accepts signature
  Future<void> confirmVerification({Uint8List? signature}) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        Get.snackbar('Session expired', 'Please login again');
        return;
      }

      if (shift.id == null) {
        Get.snackbar('Error', 'Invalid shift');
        return;
      }

      // 🔹 Signature captured (kept for future backend use)

      final res = await WorkerService.confirmSupervisorVerification(
        token,
        shift.id!,
      );

      if (res.success) {
        // ✅ SUCCESS → GO TO SHIFT COMPLETED SCREEN
        Get.offAll(
          () => ShiftCompletedScreen(shift: shift),
        );
      } else {
        Get.snackbar(
          'Error',
          res.message ?? 'Verification failed',
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }
}
