import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SafeSnackbar {
  static void show(String title, String message) {
    try {
      final context = Get.context;

      if (context == null) {
        // No overlay available → fail silently
        debugPrint('⚠️ Snackbar skipped (no context): $title - $message');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title: $message'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('❌ Snackbar error ignored: $e');
    }
  }
}
