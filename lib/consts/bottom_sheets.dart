import 'package:flutter/material.dart';
import 'app_text_styles.dart';
import 'colors.dart';

class ActionBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const ActionBottomSheet({
    super.key,
    required this.title,
    required this.child,
  });

  static Future<T?> show<T>(
      BuildContext context, {
        required String title,
        required Widget child,
      }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ActionBottomSheet(title: title, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
