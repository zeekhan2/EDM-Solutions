import 'package:edm_solutions/config/stripe_config.dart';
import 'package:edm_solutions/controllers/report_stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/auth_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/facility_dashboard_controller.dart';
import 'controllers/shift_controller.dart';
import 'controllers/post_shift_controller.dart';
import 'controllers/staff_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'controllers/chat_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/SplashView/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  StripeConfig.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<StaffController>(StaffController(), permanent: true);
  Get.put<ShiftController>(ShiftController(), permanent: true);
  Get.put<ChatController>(ChatController(), permanent: true);
  Get.put<ReportStatsController>(ReportStatsController());
  Get.put<PostShiftController>(PostShiftController(), permanent: false);
  Get.put<FacilityDashboardController>(
    FacilityDashboardController(),
    permanent: true,
  );
  Get.put<SettingsController>(
    SettingsController(),
    permanent: true,
  );

  runApp(const MyApp());

  _postStartupTasks();
}

Future<void> _postStartupTasks() async {
  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint('Auth init warning: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EDM Solution',
      debugShowCheckedModeBanner: false,
      home: const SplashView(),
    );
  }
}
