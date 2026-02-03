import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';
import 'package:edm_solutions/Common_Widgets/safe_snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import 'policy_view.dart';

class PrivacyDataPage extends StatelessWidget {
  const PrivacyDataPage({super.key});

  // ================= DELETE CONFIRM + API =================
  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete My Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to permanently delete your account?\n\n"
          "This action cannot be undone.",
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _deleteAccount(context);
    }
  }

  // ================= DELETE ACCOUNT =================
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      SafeSnackbarHelper.showSafeSnackbar(
        title: "Processing",
        message: "Deleting your account...",
      );

      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token missing");
      }

      final res = await ApiService.post(
        endpoint: '/api/delete/account',
        token: token,
        body: {},
      );

      if (res.success == true) {
        // ✅ CLEAR LOCAL DATA ONLY AFTER SERVER CONFIRMATION
        final sp = await SharedPreferences.getInstance();
        await sp.clear();
        await StorageService.clearAll();

        SafeSnackbarHelper.showSafeSnackbar(
          title: "Account Deleted",
          message: "Your account has been permanently deleted.",
        );

        // 🚀 REDIRECT TO LOGIN / SPLASH
        Get.offAllNamed('/login');
      } else {
        throw Exception(res.message ?? "Delete failed");
      }
    } catch (e) {
      SafeSnackbarHelper.showSafeSnackbar(
        title: "Delete Failed",
        message: e.toString(),
      );
    }
  }

  // ================= TILE =================
  Widget _legalTile(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.5,
                  color: AppColors.textPrimary,
                  fontFamily: semibold,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const privacyText = '''
Privacy Policy

Replace this text with your real Privacy Policy document.
''';

    const termsText = '''
Terms of Service

Replace this text with the actual Terms of Service.
''';

    const dpaText = '''
Data Processing Agreement

Replace with your DPA content.
''';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          "Privacy & Data",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: semibold,
            fontSize: 19,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- ACCOUNT SECTION ----
            Text(
              "Account",
              style: TextStyle(
                fontSize: 15.5,
                fontFamily: semibold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // DELETE ACCOUNT
            InkWell(
              onTap: () => _confirmDelete(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEFEF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Delete My Account",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ---- LEGAL SECTION ----
            Text(
              "Legal",
              style: TextStyle(
                fontSize: 15.5,
                fontFamily: semibold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            _legalTile("Privacy Policy", () {
              Get.to(() => const PolicyView(
                    title: "Privacy Policy",
                    content: privacyText,
                  ));
            }),

            _legalTile("Terms of Service", () {
              Get.to(() => const PolicyView(
                    title: "Terms of Service",
                    content: termsText,
                  ));
            }),

            _legalTile("Data Processing Agreement", () {
              Get.to(() => const PolicyView(
                    title: "Data Processing Agreement",
                    content: dpaText,
                  ));
            }),
          ],
        ),
      ),
    );
  }
}
