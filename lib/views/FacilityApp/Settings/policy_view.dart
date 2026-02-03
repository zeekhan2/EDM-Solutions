// lib/views/FacilityApp/Settings/policy_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';

class PolicyView extends StatelessWidget {
  final String title;
  final String content;
  const PolicyView({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back()),
        title: Text(title,
            style:
                TextStyle(color: AppColors.textPrimary, fontFamily: semibold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(content,
                  style:
                      TextStyle(color: AppColors.textSecondary, height: 1.45)),
            ),
          ),
        ),
      ),
    );
  }
}
