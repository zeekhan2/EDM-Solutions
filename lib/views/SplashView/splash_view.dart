import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:edm_solutions/consts/images.dart';
import 'package:edm_solutions/consts/colors.dart';
import 'package:edm_solutions/controllers/auth_controller.dart';
import 'package:edm_solutions/views/choose_Mood_Views/ChooseModeViews.dart';

// Dashboards
import '../FacilityApp/Home/dashboard.dart';
import '../UserApp/Home/workerhomeview_new.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final AuthController authController = Get.find<AuthController>();
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(seconds: 2));
    await authController.checkLoginStatus();

    if (_done || !mounted) return;
    _done = true;

    final bool loggedIn = authController.isLoggedIn.value;
    final String? role = authController.role.value;
    final String? normalizedRole = role?.toLowerCase();

    if (!loggedIn || normalizedRole == null) {
      Get.offAll(() => const ChooseModeViews());
      return;
    }

    if (normalizedRole.contains('facility')) {
      Get.offAll(() => const DashboardScreen());
    } else if (normalizedRole.contains('worker')) {
      Get.offAll(() => const WorkerHomeViewNew());
    } else {
      Get.offAll(() => const ChooseModeViews());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appPrimeryColor,
      body: Center(child: Image.asset(applogo)),
    );
  }
}
