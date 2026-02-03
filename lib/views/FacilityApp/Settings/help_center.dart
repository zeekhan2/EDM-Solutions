// lib/views/FacilityApp/Settings/help_center.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';
import 'package:edm_solutions/Common_Widgets/safe_snackbar_helper.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  Widget _articleTile(
      BuildContext ctx, String title, String snippet, String full) {
    return InkWell(
      onTap: () {
        Get.to(() => ArticleDetailPage(title: title, content: full));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontFamily: semibold,
                        color: AppColors.textPrimary,
                        fontSize: 15)),
                const SizedBox(height: 6),
                Text(snippet,
                    style: TextStyle(
                        fontFamily: regular,
                        color: AppColors.textSecondary,
                        fontSize: 13)),
              ],
            )),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> articles = [
      {
        'title': 'How to clock in for a shift',
        'snippet': 'Learn how to start and stop your shift using the app.',
        'full':
            'Full article: Step-by-step instructions to clock in and clock out...'
      },
      {
        'title': 'Managing your payments',
        'snippet': 'Everything about invoices and payouts.',
        'full': 'Full article: Payments details, schedules and FAQs...'
      },
      {
        'title': 'Updating credentials',
        'snippet': 'Add & remove certificates and licenses.',
        'full': 'Full article: How to add credentials and upload documents...'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text('Help Center',
            style:
                TextStyle(color: AppColors.textPrimary, fontFamily: semibold)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: SingleChildScrollView(
          child: Column(
            children: articles
                .map((a) => _articleTile(
                    context, a['title']!, a['snippet']!, a['full']!))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  final String title;
  final String content;
  const ArticleDetailPage(
      {super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(title,
            style:
                TextStyle(color: AppColors.textPrimary, fontFamily: semibold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: semibold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Text(content,
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: regular,
                    fontSize: 14)),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  SafeSnackbarHelper.showSafeSnackbar(
                      title: 'Helpful?',
                      message: 'Thanks for checking this article.');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text(
                  'Thanks — that helped',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
