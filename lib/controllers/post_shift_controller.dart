import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../consts/api_constants.dart';
import '../services/storage_service.dart';

class PostShiftController extends GetxController {
  // --------------------
  // STATE
  // --------------------
  final isLoading = false.obs;
  final RxnString error = RxnString();

  // --------------------
  // FORM CONTROLLERS
  // --------------------
  final TextEditingController payRateController = TextEditingController();
  final TextEditingController roleController =
      TextEditingController(); // used as title
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // --------------------
  // DATE / TIME
  // --------------------
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?> endTime = Rx<TimeOfDay?>(null);

  // --------------------
  // HELPERS
  // --------------------
  String formatTime(TimeOfDay? t) {
    if (t == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  /// ✅ USED BY BULK + SINGLE
  String formatTimeForApi(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  // --------------------
  // VALIDATION (REUSABLE)
  // --------------------
  bool validateForBulk() {
    error.value = null;

    if (selectedDate.value == null) {
      error.value = 'Please select shift date';
      return false;
    }

    final today = DateTime.now();
    final pickedDate = DateTime(
      selectedDate.value!.year,
      selectedDate.value!.month,
      selectedDate.value!.day,
    );

    if (pickedDate.isBefore(DateTime(today.year, today.month, today.day))) {
      error.value = 'Date cannot be in the past';
      return false;
    }

    if (startTime.value == null || endTime.value == null) {
      error.value = 'Please select start and end time';
      return false;
    }

    final start = startTime.value!;
    final end = endTime.value!;

    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;

    if (endMin <= startMin) {
      error.value = 'End time must be after start time';
      return false;
    }

    if (payRateController.text.trim().isEmpty) {
      error.value = 'Enter pay rate';
      return false;
    }

    final pay = double.tryParse(payRateController.text.trim());
    if (pay == null || pay <= 0) {
      error.value = 'Invalid pay rate';
      return false;
    }

    if (roleController.text.trim().isEmpty) {
      error.value = 'Enter title';
      return false;
    }

    if (locationController.text.trim().isEmpty) {
      error.value = 'Enter location';
      return false;
    }

    return true;
  }

  // --------------------
  // SUBMIT SINGLE SHIFT
  // --------------------
  Future<bool> submitShift() async {
    error.value = null;

    if (!validateForBulk()) return false;

    try {
      isLoading.value = true;

      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        error.value = 'Session expired. Please login again';
        return false;
      }

      final body = {
        'title': roleController.text.trim(),
        'date': DateFormat('yyyy-MM-dd').format(selectedDate.value!),
        'pay_per_hour': double.parse(payRateController.text.trim()),
        'start_time': formatTimeForApi(startTime.value!),
        'end_time': formatTimeForApi(endTime.value!),
        'license_type': roleController.text.trim(),
        'location': locationController.text.trim(),
        'status': 'open',
        if (instructionsController.text.trim().isNotEmpty)
          'special_instruction': instructionsController.text.trim(),
      };

      final response = await ApiService.post(
        endpoint: ApiConstants.createShift,
        token: token,
        body: body,
      );

      if (response.success == true) {
        return true;
      } else {
        _parseError(response.message);
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // --------------------
  // UPDATE SHIFT
  // --------------------
  Future<bool> updateShift(int shiftId) async {
    error.value = null;

    // Validation (same rules as create)
    if (!validateForBulk()) return false;

    try {
      isLoading.value = true;

      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        error.value = 'Session expired. Please login again';
        return false;
      }

      final body = {
        'date': DateFormat('yyyy-MM-dd').format(selectedDate.value!),
        'start_time': formatTimeForApi(startTime.value!),
        'end_time': formatTimeForApi(endTime.value!),
        'pay_per_hour': double.parse(payRateController.text.trim()),
        'title': roleController.text.trim(),
        'location': locationController.text.trim(),
        if (instructionsController.text.trim().isNotEmpty)
          'special_instruction': instructionsController.text.trim(),
      };

      final response = await ApiService.post(
        endpoint: '${ApiConstants.updateShift}/$shiftId',
        token: token,
        body: body,
      );

      if (response.success == true) {
        return true;
      } else {
        error.value = response.message ?? 'Failed to update shift';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // --------------------
  // ERROR PARSER
  // --------------------
  void _parseError(dynamic msg) {
    if (msg is List && msg.isNotEmpty) {
      error.value = msg.first.toString();
    } else if (msg is String && msg.isNotEmpty) {
      error.value = msg;
    } else {
      error.value = 'Failed to post shift';
    }
  }

  // --------------------
  // CLEANUP
  // --------------------
  @override
  void onClose() {
    payRateController.dispose();
    roleController.dispose();
    instructionsController.dispose();
    locationController.dispose();
    super.onClose();
  }
}
