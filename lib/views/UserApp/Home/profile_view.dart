import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import 'profile_edit_view.dart';
import 'change_password_view.dart';
import 'credentials_compliance_view.dart';
import 'location_services_view.dart';
import 'payments_view.dart';
import 'bank_details_view.dart';
import 'tax_details_view.dart';
import 'time_sheet_view.dart';
import 'rating_feedback_view.dart';
import 'privacy_data_view.dart';
import 'help_n_support_view.dart';
import 'about_view.dart';

class WorkerProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  Future<void> logout() async {
    await Get.dialog(
      Obx(() {
        final isLoading = authController.isLoading.value;

        return PopScope(
          canPop: !isLoading, // block back button while loading
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
                        // dialog auto-closes due to navigation
                      },
                      child: const Text('Logout'),
                    ),
                  ],
          ),
        );
      }),
      barrierDismissible: false, // block outside tap
    );
  }
}

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final WorkerProfileController controller = Get.put(WorkerProfileController());

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '';
    return name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        final user = controller.authController.currentUser.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// PROFILE HEADER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF1E3A8A),
                      backgroundImage:
                          (user.image != null && user.image!.isNotEmpty)
                              ? NetworkImage(user.image!)
                              : null,
                      child: (user.image == null || user.image!.isEmpty)
                          ? Text(
                              _getInitials(user.fullName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, color: Colors.blue.shade600),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _menu('Profile', Icons.person_outline,
                  () => Get.to(() => const ProfileEditView())),
              _menu('Change Password', Icons.lock_outline,
                  () => Get.to(() => const ChangePasswordView())),
              _menu('Credentials & Compliance', Icons.document_scanner_outlined,
                  () => Get.to(() => const CredentialsComplianceView())),
              _menu('Location Services', Icons.location_on_outlined,
                  () => Get.to(() => const LocationServicesView())),
              _menu('Payments', Icons.payment_outlined,
                  () => Get.to(() => const PaymentsView())),
              _menu('Bank Details', Icons.account_balance_outlined,
                  () => Get.to(() => const BankDetailsView())),
              _menu('Tax Details', Icons.receipt_outlined,
                  () => Get.to(() => const TaxDetailsView())),
              _menu('Time Sheet', Icons.schedule_outlined,
                  () => Get.to(() => const TimeSheetScreen())),
              _menu('Rating Feedback', Icons.star_outline,
                  () => Get.to(() => const RatingFeedbackScreen())),
              _menu('Privacy & Data', Icons.privacy_tip_outlined,
                  () => Get.to(() => const PrivacyDataScreen())),
              _menu('Help & Support', Icons.help_outline,
                  () => Get.to(() => const HelpSupportScreen())),
              _menu('About', Icons.info_outline,
                  () => Get.to(() => const AboutScreen())),

              const SizedBox(height: 32),

              /// LOGOUT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _menu(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        leading: Icon(icon, color: const Color(0xFF1E3A8A)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
