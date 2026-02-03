// lib/views/FacilityApp/Settings/help_support.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';
import 'help_center.dart';
import 'package:edm_solutions/Common_Widgets/safe_snackbar_helper.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  void _openEmailDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dctx) {
        return AlertDialog(
          title: const Text('Email Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('support@example.com'),
              SizedBox(height: 8),
              Text('We typically reply within 24 hours.')
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(dctx);
                },
                child: const Text('Close')),
            TextButton(
                onPressed: () {
                  Clipboard.setData(
                      const ClipboardData(text: 'support@example.com'));
                  SafeSnackbarHelper.showSafeSnackbar(
                      title: 'Copied',
                      message: 'support@example.com copied to clipboard');
                  Navigator.pop(dctx);
                },
                child: const Text('Copy')),
          ],
        );
      },
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontFamily: semibold,
                            color: AppColors.textPrimary,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            fontFamily: regular,
                            color: AppColors.textSecondary,
                            fontSize: 13))
                  ]),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(question,
            style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontFamily: semibold)),
        children: [
          Text(
            'This is an example answer for "$question". Replace with live FAQ content or fetch from your Help Center API.',
            style:
                TextStyle(color: AppColors.textSecondary, fontFamily: regular),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const faqs = [
      'How do I clock in for my shift?',
      'When will I receive my payment?',
      'How do I update my credentials?',
      'What if I forget my password?',
      'How do I contact my supervisor?',
    ];

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
        title: Text('Help & Support',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: semibold,
                fontSize: 19)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Us',
                style: TextStyle(
                    fontFamily: semibold,
                    color: AppColors.textPrimary,
                    fontSize: 16)),
            const SizedBox(height: 12),
            _contactTile(
                icon: Icons.email_outlined,
                title: 'Email Support',
                subtitle: 'support@example.com',
                onTap: () => _openEmailDialog(context)),
            _contactTile(
                icon: Icons.menu_book_outlined,
                title: 'Help Center',
                subtitle: 'Browse articles and guides',
                onTap: () => Get.to(() => const HelpCenterPage())),
            const SizedBox(height: 18),
            Text('Frequently Asked Questions',
                style: TextStyle(
                    fontFamily: semibold,
                    color: AppColors.textPrimary,
                    fontSize: 16)),
            const SizedBox(height: 12),
            ...faqs.map((q) => _faqTile(q)),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
