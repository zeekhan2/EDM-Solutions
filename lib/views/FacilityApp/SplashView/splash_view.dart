import 'package:edm_solutions/consts/images.dart';
import 'package:edm_solutions/views/choose_Mood_Views/ChooseModeViews.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../consts/colors.dart';
import '../../../consts/strings.dart';
import '../../../controllers/auth_controller.dart';
import 'package:edm_solutions/views/FacilityApp/Home/dashboard.dart';
import 'package:edm_solutions/views/UserApp/Home/workerhomeview_new.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    // Small delay for splash visuals
    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      // Sync local auth state
      await _authController.checkLoginStatus();

      final bool loggedIn = _authController.isLoggedIn.value;
      final String? role = _authController.role.value;
      final String? normalizedRole = role?.toLowerCase();

      if (loggedIn && normalizedRole != null) {
        if (normalizedRole.contains('facility')) {
          Get.offAll(() => const DashboardScreen());
          return;
        }

        if (normalizedRole.contains('worker')) {
          Get.offAll(() => const WorkerHomeViewNew());
          return;
        }
      }

      // Default fallback
      Get.offAll(() => const ChooseModeViews());
    } catch (e) {
      // Absolute safety fallback
      Get.offAll(() => const ChooseModeViews());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appPrimeryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image(image: AssetImage(applogo))),
          15.heightBox,
          Center(
            child: Text(appname).text.center
                .size(30)
                .fontWeight(FontWeight.w500)
                .color(appSeconderyColor)
                .make(),
          ),
          20.heightBox,
          Center(
            child: Text(appsologan).text
                .color(appSeconderyColor)
                .size(14)
                .fontWeight(FontWeight.w400)
                .make(),
          ),
        ],
      ),
    );
  }
}
