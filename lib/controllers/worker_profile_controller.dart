import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class WorkerProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  /// 🔹 Convenience getters (SAFE)
  String get fullName => authController.currentUser.value?.fullName ?? 'User';

  String get email => authController.currentUser.value?.email ?? '';

  String get role => authController.role.value;

  String get initials {
    final name = fullName.trim();
    if (name.isEmpty) return 'U';
    return name[0].toUpperCase();
  }

  /// 🔹 Logout (worker)
  void logout() {
    Get.defaultDialog(
      title: 'Logout',
      content: const Text('Are you sure you want to logout?'),
      textCancel: 'Cancel',
      textConfirm: 'Logout',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await authController.logout();
      },
    );
  }
}
