// lib/views/FacilityApp/Settings/settings_screen.dart
import 'package:edm_solutions/views/FacilityApp/SplashView/splash_view.dart';
import 'package:edm_solutions/views/choose_Mood_Views/ChooseModeViews.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';
import 'package:edm_solutions/Common_Widgets/safe_snackbar_helper.dart';
import 'package:edm_solutions/views/FacilityApp/Settings/feedback_page.dart';
import 'package:edm_solutions/views/FacilityApp/Settings/about_page.dart';
import 'package:edm_solutions/controllers/facility_dashboard_controller.dart';
import 'package:edm_solutions/controllers/auth_controller.dart';
import 'package:edm_solutions/services/api_service.dart';
import 'package:edm_solutions/services/storage_service.dart';
import 'package:edm_solutions/consts/api_constants.dart';

// Local screens used
import 'account_details.dart';
import 'facility_information.dart';
import 'change_password.dart';
import 'payment_methods.dart';
import 'privacy_data.dart';
import 'help_support.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsOn = true;

  final FacilityDashboardController dashboardController =
      Get.find<FacilityDashboardController>();
  final AuthController authController = Get.find<AuthController>();

  Widget _buildTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    bool dense = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding:
              EdgeInsets.symmetric(horizontal: 12, vertical: dense ? 10 : 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: semibold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (trailing != null)
                trailing
              else
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LOGOUT HANDLER =================
  Future<void> _handleLogout() async {
    await Get.dialog(
      Obx(() {
        final isLoading = authController.isLoading.value;

        return PopScope(
          canPop: !isLoading, // ⛔ block back button while loading
          child: AlertDialog(
            title: const Text('Confirm Logout'),
            content: isLoading
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Logging out, please wait...'),
                    ],
                  )
                : const Text('Are you sure you want to log out?'),
            actions: isLoading
                ? [] // ⛔ no buttons while loading
                : [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await authController.logout();
                        // dialog closes automatically due to navigation
                      },
                      child: const Text('Logout'),
                    ),
                  ],
          ),
        );
      }),
      barrierDismissible: false, // ⛔ tap outside blocked
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            /// ✅ FIXED PROFILE IMAGE
            Obx(() {
              final imageUrl = authController.currentUser.value?.image;

              return CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null || imageUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              );
            }),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontFamily: regular,
                  ),
                ),
                Obx(() => Text(
                      dashboardController.facility_name.value.isEmpty
                          ? '—'
                          : dashboardController.facility_name.value,
                      style: TextStyle(
                        fontFamily: semibold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: semibold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTile(
                        icon: Icons.person,
                        title: 'Account Details',
                        onTap: () => Get.to(() => const AccountDetailsPage()),
                      ),
                      const SizedBox(height: 10),
                      _buildTile(
                        icon: Icons.location_city,
                        title: 'Facility Information',
                        onTap: () =>
                            Get.to(() => const FacilityInformationPage()),
                      ),
                      const SizedBox(height: 10),
                      _buildTile(
                        icon: Icons.notifications,
                        title: 'Notification',
                        trailing: Switch(
                          value: _notificationsOn,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) =>
                              setState(() => _notificationsOn = v),
                        ),
                        onTap: () => setState(
                            () => _notificationsOn = !_notificationsOn),
                      ),
                      const SizedBox(height: 10),
                      _buildTile(
                        icon: Icons.lock,
                        title: 'Change Password',
                        onTap: () => Get.to(() => const ChangePasswordPage()),
                      ),
                      const SizedBox(height: 10),
                      _buildTile(
                        icon: Icons.payment,
                        title: 'Payments History',
                        onTap: () => Get.to(() => const PaymentMethodsPage()),
                      ),
                      const SizedBox(height: 10),
                      _buildTile(
                        icon: Icons.shield_outlined,
                        title: 'Privacy & Data',
                        onTap: () => Get.to(() => const PrivacyDataPage()),
                      ),
                      const SizedBox(height: 10),
                      _buildTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () => Get.to(() => const HelpSupportPage()),
                      ),
                      const SizedBox(height: 10),
                      _buildTile(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () => Get.to(() => AboutScreen()),
                      ),
                      const SizedBox(height: 10),
                      _buildTile(
                        icon: Icons.feedback_outlined,
                        title: 'Feedback',
                        onTap: () => Get.to(() => const FeedbackPage()),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Log out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE03A2D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
