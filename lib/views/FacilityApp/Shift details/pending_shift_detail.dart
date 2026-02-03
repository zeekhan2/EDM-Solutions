// lib/views/FacilityApp/Shift details/pending_shift_detail.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/shift_models.dart';
import '../../../controllers/shift_controller.dart';

class PendingShiftDetailScreen extends StatelessWidget {
  final Shift shift;
  const PendingShiftDetailScreen({super.key, required this.shift});

  Widget _infoBox(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9AA3BD)),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShiftController>();
    const primary = Color(0xFF1E3A8A);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pending Shift Details',
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ]),
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F9FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  shift.worker?['name']?.toString() ?? 'Worker',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: _infoBox('Date', shift.createdAt ?? '-')),
              const SizedBox(width: 12),
              Expanded(
                child: _infoBox(
                  'Time',
                  '${shift.startTime ?? ''} - ${shift.endTime ?? ''}',
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _infoBox(
                  'Pay Rate',
                  shift.payPerHour != null
                      ? '\$${shift.payPerHour!.toStringAsFixed(0)}/hr'
                      : '-',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoBox(
                  'Status',
                  shift.statusLabel, // ✅ FIXED
                ),
              ),
            ]),

            const Spacer(),

            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.pendingShifts
                        .removeWhere((s) => s.id == shift.id);
                    controller.filledShifts.insert(0, shift);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B57),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.pendingShifts
                        .removeWhere((s) => s.id == shift.id);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4D4D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Deny',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
