import 'package:edm_solutions/models/timesheet_entry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/controllers/timesheet_controller.dart';

class TimeSheetScreen extends StatelessWidget {
  const TimeSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TimeSheetController controller = Get.put(TimeSheetController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Time Sheet',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// WEEK / MONTH TOGGLE
              Row(
                children: [
                  _toggleButton(
                    label: 'Week',
                    isActive: controller.isWeekly.value,
                    onTap: () => controller.switchToWeekly(),
                  ),
                  const SizedBox(width: 12),
                  _toggleButton(
                    label: 'Month',
                    isActive: !controller.isWeekly.value,
                    onTap: () => controller.switchToMonthly(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.periodLabel.value,
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _badge(controller.totalHours.value),
                ],
              ),

              const SizedBox(height: 16),

              /// SUMMARY
              _summaryCard(controller),

              const SizedBox(height: 28),

              const Text(
                'Daily Entries',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              if (controller.dailyEntries.isEmpty)
                const Text(
                  'No entries found',
                  style: TextStyle(color: Colors.grey),
                ),

              ...controller.dailyEntries.map(_dailyItem),

              const SizedBox(height: 28),
            ],
          ),
        );
      }),
    );
  }

  /// TOGGLE BUTTON
  Widget _toggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1E3A8A) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );

  /// BADGE
  Widget _badge(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber[400],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      );

  /// SUMMARY CARD
  Widget _summaryCard(TimeSheetController c) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            _row('Total Hours', c.totalHours.value, bold: true),
            const Divider(),
            _row('Regular Hours', c.regularHours.value),
            const Divider(),
            _row('Overtime', c.overtimeHours.value),
          ],
        ),
      );

  Widget _row(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      );

  /// DAILY ITEM
  Widget _dailyItem(TimeSheetEntry e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title → Day (weekly) OR Week range (monthly)
                  Text(
                    e.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  /// Subtitle → Date OR "Weekly Total"
                  Text(
                    e.subtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              /// Hours
              Text(
                e.hours,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
}
