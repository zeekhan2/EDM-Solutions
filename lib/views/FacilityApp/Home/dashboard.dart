import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:edm_solutions/views/FacilityApp/Home/Shift/post_shift_screen.dart';
import 'package:edm_solutions/views/FacilityApp/Home/emergency_pool_screen.dart';
import 'package:edm_solutions/views/FacilityApp/Home/view_all_screen.dart';
import 'package:edm_solutions/views/FacilityApp/Shift details/shift_screen.dart';
import 'package:edm_solutions/views/FacilityApp/Staff/staff_home.dart';
import 'package:edm_solutions/views/FacilityApp/Report/report_screen.dart';
import 'package:edm_solutions/views/FacilityApp/Settings/settings_screen.dart';
import 'package:edm_solutions/views/FacilityApp/Home/bulk_post.dart';
import '../../../controllers/facility_dashboard_controller.dart';
import '../../../controllers/post_shift_controller.dart';
import '../../../controllers/shift_controller.dart';
import '../../../controllers/auth_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  final FacilityDashboardController dashboardController =
      Get.find<FacilityDashboardController>();

  @override
  void initState() {
    super.initState();
    dashboardController.fetchFacilityName();
    dashboardController.fetchDashboard();

    _pages = const [
      DashboardContent(),
      ShiftScreen(),
      StaffHomePage(),
      ReportScreen(),
      SettingsScreen(),
    ];
  }

  void _onTap(int index) async {
    if (_selectedIndex == index) {
      // 👇 already on Home tab → force refresh
      if (index == 0) {
        await dashboardController.fetchDashboard();
        await Get.find<ShiftController>().fetchAll();
      }
      return;
    }

    setState(() => _selectedIndex = index);

    if (index == 0) {
      await dashboardController.fetchDashboard();
      await Get.find<ShiftController>().fetchAll();
    }
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTap(index),
      child: active
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade200,
              child: Icon(icon, color: Colors.black54, size: 20),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.home, 'Home', 0),
            _navItem(Icons.calendar_today, 'Shift', 1),
            _navItem(Icons.group, 'Staff', 2),
            _navItem(Icons.bar_chart, 'Report', 3),
            _navItem(Icons.settings, 'Settings', 4),
          ],
        ),
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final FacilityDashboardController controller =
        Get.find<FacilityDashboardController>();
    final ShiftController shiftController = Get.find<ShiftController>();

    const navy = Color(0xFF1E3A8A);

    Widget statusCard(String value, String label, Color bg) {
      return Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
        child: RefreshIndicator(
          color: navy,
          onRefresh: () async {
            await controller.fetchFacilityName();
            await controller.fetchDashboard();
            await shiftController.fetchAll();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Obx(() {
                  final authController = Get.find<AuthController>();
                  final user = authController.currentUser.value;

                  final avatarImage =
                      (user?.image != null && user!.image!.isNotEmpty)
                          ? NetworkImage(user.image!)
                          : null;

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: navy,
                        backgroundImage: avatarImage,
                        child: avatarImage == null
                            ? Text(
                                user?.fullName != null &&
                                        user!.fullName!.isNotEmpty
                                    ? user.fullName![0].toUpperCase()
                                    : 'F',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            controller.facility_name.value.isEmpty
                                ? '—'
                                : controller.facility_name.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 22),

                /// DASHBOARD TITLE
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),

                const SizedBox(height: 18),

                /// SHIFT OVERVIEW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Shift Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const ViewAllScreen()),
                      style: TextButton.styleFrom(
                        backgroundColor: navy,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      statusCard(
                        shiftController.openShifts.length.toString(),
                        'Open',
                        const Color(0xFFEFF6FF),
                      ),
                      statusCard(
                        shiftController.pendingShifts.length.toString(),
                        'Pending',
                        const Color(0xFFFFF7ED),
                      ),
                      statusCard(
                        shiftController.filledShifts.length.toString(),
                        'Filed',
                        const Color(0xFFF0FFF4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                /// POST SHIFT BUTTON
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (!Get.isRegistered<PostShiftController>()) {
                        Get.put(PostShiftController());
                      }

                      final result =
                          await Get.to(() => const PostNewShiftScreen());

                      if (result == true) {
                        controller.fetchDashboard();
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Post New Shift',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 34, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                /// QUICK ACTION
                const Text(
                  'Quick Action',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () =>
                              Get.to(() => const EmergencyPoolScreen()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEC4D4D),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Trigger\nEmergency Pool',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => const BulkPostScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3BC86A),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Bulk Posting',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
