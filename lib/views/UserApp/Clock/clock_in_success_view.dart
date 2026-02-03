import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/shift_models.dart';
import '../Home/workerhomeview_new.dart';

class ClockInSuccessView extends StatelessWidget {
  final Shift shift;

  const ClockInSuccessView({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              /// ✅ GREEN CHECK
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              /// ✅ TITLE
              const Text(
                'Successfully Clocked in',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                ),
              ),

              const SizedBox(height: 6),

              /// ✅ SUBTITLE
              Text(
                'at ${DateFormat('h:mm a').format(now)} on ${DateFormat('EEEE dd - MM - yyyy').format(now)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 32),

              /// INFO BOX
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _infoTile(
                      title: 'Date',
                      value: shift.date ??
                          DateFormat('dd - MM - yyyy').format(now),
                    ),
                    const SizedBox(width: 12),
                    _infoTile(
                      title: 'Time',
                      value:
                          '${shift.startTime ?? ''} - ${shift.endTime ?? ''}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _infoTile(
                      title: 'Duration',
                      value: _calculateDuration(
                        shift.startTime,
                        shift.endTime,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _infoTile(
                      title: 'Pay Rate',
                      value: '\$ ${shift.payPerHour ?? '--'}/hr',
                      valueColor: Colors.green,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// BACK TO HOME
              largeButton(
                text: '←  Back to Home',
                onTap: () {
                  Get.until((route) => route.isFirst);


                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // HELPERS
  // =========================

  Widget _infoTile({
    required String title,
    required String value,
    Color valueColor = Colors.black,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget largeButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static String _calculateDuration(String? start, String? end) {
    if (start == null || end == null) return '--';

    try {
      final format = DateFormat('h:mm a');
      final startTime = format.parse(start);
      final endTime = format.parse(end);

      final diff = endTime.difference(startTime);
      return '${diff.inHours} Hours';
    } catch (_) {
      return '--';
    }
  }
}
