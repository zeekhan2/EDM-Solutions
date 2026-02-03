import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'app_text_styles.dart';
import 'colors.dart';
import 'status_badge.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String? avatarUrl;

  const ProfileCard({
    super.key,
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.h3),
                const SizedBox(height: 2),
                Text(role, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final StatusType status;

  const ServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          StatusBadge(label: _statusLabel(status), type: status),
        ],
      ),
    );
  }

  String _statusLabel(StatusType type) {
    switch (type) {
      case StatusType.success:
        return 'Completed';
      case StatusType.pending:
        return 'Pending';
      case StatusType.danger:
        return 'Rejected';
      case StatusType.warning:
        return 'Warning';
      case StatusType.info:
        return 'Active';
    }
  }
}

class RequestItemTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateTime;
  final StatusType status;
  final VoidCallback? onTap;

  const RequestItemTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dateTime,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      title: Text(title, style: AppTextStyles.body),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(dateTime, style: AppTextStyles.caption),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StatusBadge(label: _statusLabel(status), type: status),
          const SizedBox(height: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  String _statusLabel(StatusType type) {
    switch (type) {
      case StatusType.success:
        return 'Completed';
      case StatusType.pending:
        return 'Pending';
      case StatusType.danger:
        return 'Rejected';
      case StatusType.warning:
        return 'Warning';
      case StatusType.info:
        return 'In Progress';
    }
  }
}
