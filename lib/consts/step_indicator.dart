import 'package:flutter/material.dart';
import 'app_text_styles.dart';
import 'colors.dart';

class StepIndicatorRow extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StepIndicatorRow({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index + 1 <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 4),
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class StepIndicatorHeader extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final String title;

  const StepIndicatorHeader({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step $currentStep of $totalSteps', style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(title, style: AppTextStyles.h2),
        const SizedBox(height: 12),
        StepIndicatorRow(totalSteps: totalSteps, currentStep: currentStep),
      ],
    );
  }
}
