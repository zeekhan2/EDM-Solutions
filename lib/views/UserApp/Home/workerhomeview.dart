import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../consts/app_text_styles.dart';
import '../../../consts/colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/worker_home_controller.dart';

import 'Shift_Details/workershiftdetailsview.dart';
import 'chat_view.dart';
import 'profile_view.dart';
import 'workerhomewidgets.dart';

class WorkerHomeView extends StatefulWidget {
  const WorkerHomeView({super.key});

  @override
  State<WorkerHomeView> createState() => _WorkerHomeViewState();
}

class _WorkerHomeViewState extends State<WorkerHomeView> {
  int bottomIndex = 0;

  final AuthController authController = Get.find<AuthController>();
  final WorkerHomeController workerController =
      Get.find<WorkerHomeController>(); // ✅ FIXED (no duplicate init)

  @override
  void initState() {
    super.initState();

    /// Ensure auth state is ready
    if (authController.currentUser.value == null) {
      authController.checkLoginStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          /// ---------------- TAB SWITCH ----------------
          if (bottomIndex == 1) {
            return const ChatView();
          }
          if (bottomIndex == 2) {
            return ProfileView();
          }

          /// ---------------- HOME ----------------
          if (workerController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (workerController.error.isNotEmpty) {
            return Center(
              child: Text(
                workerController.error.value,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await workerController.fetchShifts(); // ✅ ONLY worker API
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// ---------------- HEADER ----------------
                Text(
                  'Available Shifts',
                  style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                /// ---------------- SHIFTS LIST ----------------
                if (workerController.shifts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No shifts available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...workerController.shifts.map(
                    (shift) => Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          shift.licenseType ?? 'Shift',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${shift.createdAt ?? ''} • ${shift.startTime ?? ''} - ${shift.endTime ?? ''}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                        /// ✅ ONLY NAVIGATION — NO API CALL HERE
                        onTap: () {
                          if (shift.id == null) return;

                          Get.to(
                            () => WorkerShiftDetailsView(
                                claimedShiftId: shift.realShiftId!),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),

      /// ---------------- BOTTOM NAV ----------------
      bottomNavigationBar: WorkerBottomNavBar(
        currentIndex: bottomIndex,
        onTap: (index) {
          if (index == bottomIndex) return;
          setState(() => bottomIndex = index);
        },
      ),
    );
  }
}
