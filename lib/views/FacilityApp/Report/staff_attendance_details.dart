import 'package:edm_solutions/controllers/staff_attendance_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';

class StaffAttendanceDetails extends StatelessWidget {
  const StaffAttendanceDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final StaffAttendanceController controller =
        Get.put(StaffAttendanceController(), permanent: true);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                )
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
          ),
        ),
        title: const Text(
          "Staff Attendance Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.attendanceLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.attendanceList.isEmpty) {
          return const Center(child: Text('No attendance records found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: controller.attendanceList.map((a) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _attendanceCard(
                  name: a['name'] ?? '—',
                  shiftTime: a['shift_time'] ?? '—',
                  date: a['date'] ?? '—',
                  clockIn: a['clock_in'] ?? '—',
                  clockOut: a['clock_out'] ?? '—',
                  isLate: false, // API does not send this
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  /// 🔒 UI BELOW IS 100% UNCHANGED

  Widget _attendanceCard({
    required String name,
    required String shiftTime,
    required String date,
    required String clockIn,
    required String clockOut,
    required bool isLate,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FFF1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month,
                    color: Colors.green, size: 26),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  Text(
                    "Shift Time ( $shiftTime )",
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _clockBox(
                  "Clocked In",
                  clockIn,
                  isLate ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _clockBox("Clocked out", clockOut, Colors.green),
              ),
            ],
          ),
          if (isLate) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE6FFE8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "Note late clock approved by supervisor",
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.green,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _clockBox(String title, String time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
