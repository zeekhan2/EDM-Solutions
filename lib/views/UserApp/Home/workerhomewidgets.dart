import 'package:flutter/material.dart';

import '../../../consts/app_radius.dart';
import '../../../consts/app_text_styles.dart';
import '../../../consts/colors.dart';

enum ShiftStatus { pending, approved, completed }

class WorkerStatusBadge extends StatelessWidget {
  final ShiftStatus status;

  const WorkerStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color bg;
    late final Color fg;

    switch (status) {
      case ShiftStatus.pending:
        label = 'Pending';
        bg = const Color(0xFFFFE5E5);
        fg = const Color(0xFFD32F2F);
        break;
      case ShiftStatus.approved:
        label = 'Approved';
        bg = const Color(0xFFE4FADF);
        fg = const Color(0xFF2E7D32);
        break;
      case ShiftStatus.completed:
        label = 'Completed';
        bg = const Color(0xFFE0E7FF);
        fg = AppColors.primaryDark;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: fg),
      ),
    );
  }
}

class WorkerShiftCard extends StatelessWidget {
  final String dayLabel; // e.g. "Today"
  final String timeRange; // "12:00 PM - 8:00 PM"
  final String hospitalName;
  final ShiftStatus status;
  final VoidCallback? onDetailsTap;

  const WorkerShiftCard({
    super.key,
    required this.dayLabel,
    required this.timeRange,
    required this.hospitalName,
    required this.status,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dayLabel, style: AppTextStyles.bodySecondary),
          const SizedBox(height: 4),
          Text(
            timeRange,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            hospitalName,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              WorkerStatusBadge(status: status),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: onDetailsTap,
                child: Text(
                  'Details',
                  style:
                  AppTextStyles.caption.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkerCalendarStrip extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const WorkerCalendarStrip({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final days = [
      {'label': 'Mon', 'day': '01'},
      {'label': 'Tue', 'day': '02'},
      {'label': 'Wed', 'day': '03'},
      {'label': 'Thu', 'day': '04'},
      {'label': 'Fri', 'day': '05'},
      {'label': 'Sat', 'day': '06'},
      {'label': 'Sun', 'day': '07'},
    ];

    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              width: 52,
              decoration: BoxDecoration(
                color:
                isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    days[index]['label']!,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    days[index]['day']!,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class WorkerNotificationCard extends StatelessWidget {
  final String message;

  const WorkerNotificationCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const WorkerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.calendar_today_rounded, 'label': 'Shifts'},
      {'icon': Icons.chat_bubble_outline, 'label': 'Chat'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final isSelected = index == currentIndex;
          final item = items[index];

          if (index == 0) {
            // Home: circular blue background when selected
            return GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['label']! as String,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return GestureDetector(
            onTap: () => onTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  item['label']! as String,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
