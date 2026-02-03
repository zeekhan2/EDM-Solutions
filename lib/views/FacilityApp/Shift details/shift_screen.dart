// lib/views/FacilityApp/Shift details/shift_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/shift_controller.dart';
import '../../../models/shift_models.dart';
import 'open_shift_detail.dart';
import 'pending_shift_detail.dart';
import 'filled_shift_detail.dart';

class ShiftScreen extends StatefulWidget {
  const ShiftScreen({super.key});

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> {
  final ShiftController controller = Get.find<ShiftController>();
  final Color primaryNavy = const Color(0xFF1E3A8A);
  int selectedTabIndex = 0;

  String _safe(String? v) => v ?? '';

  Widget _statusCard(String count, String label, Color bg) {
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _tabPill(String label, int index) {
    final active = selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          color: active ? primaryNavy : const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.black45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _shiftCard(Shift s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title ?? s.licenseType ?? '',
                  style: TextStyle(
                    color: primaryNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.location ?? '',
                  style: const TextStyle(color: Color(0xFF9AA3BD)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${_safe(s.startTime)} - ${_safe(s.endTime)}',
                      style: const TextStyle(color: Color(0xFF9AA3BD)),
                    ),
                    const SizedBox(width: 12),
                    if (s.payPerHour != null)
                      Text(
                        '\$${s.payPerHour!.toStringAsFixed(0)}/hr',
                        style: const TextStyle(color: Color(0xFF9AA3BD)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (selectedTabIndex == 0) {
                Get.to(() => OpenShiftDetailScreen(shift: s));
              } else if (selectedTabIndex == 1) {
                Get.to(() => PendingShiftDetailScreen(shift: s));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: primaryNavy,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Details',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔵 FILLED TAB SPECIAL UI (MATCHES SCREENSHOT)
  Widget _filledOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'See the All Filled Shifts',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => const FilledShiftDetail());
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primaryNavy,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Details',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBody() {
    return Obx(() {
      if (selectedTabIndex == 2) {
        // ✅ ONLY THIS for Filled tab
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _filledOverviewCard(),
        );
      }

      final list = selectedTabIndex == 0
          ? controller.openShifts
          : controller.pendingShifts;

      if (list.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'No shifts available',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return Column(children: list.map(_shiftCard).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shift Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusCard(
                      controller.openShifts.length.toString(),
                      'Opened',
                      const Color(0xFFEFF6FF),
                    ),
                    _statusCard(
                      controller.pendingShifts.length.toString(),
                      'Pending',
                      const Color(0xFFFFF7ED),
                    ),
                    _statusCard(
                      controller.filledShifts.length.toString(),
                      'Filled',
                      const Color(0xFFF0FFF4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _tabPill('Opened', 0),
                  const SizedBox(width: 12),
                  _tabPill('Pending', 1),
                  const SizedBox(width: 12),
                  _tabPill('Filled', 2),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(child: _tabBody()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
