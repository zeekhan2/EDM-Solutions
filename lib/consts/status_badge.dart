import 'package:flutter/material.dart';

import 'app_text_styles.dart';
import 'colors.dart';

enum StatusType { success, pending, danger, warning, info }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  Color get _bg {
    switch (type) {
      case StatusType.success:
        return AppColors.successBg;
      case StatusType.pending:
        return AppColors.warningBg;
      case StatusType.danger:
        return AppColors.dangerBg;
      case StatusType.warning:
        return AppColors.warningBg;
      case StatusType.info:
        return AppColors.primaryLight;
    }
  }

  Color get _fg {
    switch (type) {
      case StatusType.success:
        return AppColors.accent;
      case StatusType.pending:
        return AppColors.warning;
      case StatusType.danger:
        return AppColors.danger;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.info:
        return AppColors.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: _fg),
      ),
    );
  }
}
