import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/shift_models.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../consts/api_constants.dart';
import '../../UserApp/Home/workerhomeview_new.dart';

class ShiftClaimedView extends StatefulWidget {
  final Shift shift;

  const ShiftClaimedView({
    super.key,
    required this.shift,
  });

  @override
  State<ShiftClaimedView> createState() => _ShiftClaimedViewState();
}

class _ShiftClaimedViewState extends State<ShiftClaimedView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  /// ✅ ALWAYS KEEP ORIGINAL SHIFT
  late Shift _shift;

  @override
  void initState() {
    super.initState();

    // ✅ FIX 1: Lock initial shift (never null)
    _shift = widget.shift;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // ❌ DO NOT REFRESH SHIFT HERE
    // _fetchShiftDetails();  <-- REMOVED
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('MM-dd-yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  String _formatTime(String? start, String? end) {
    if (start == null || end == null) return 'N/A';
    return '$start - $end';
  }

  String _calculateDuration(String? start, String? end) {
    if (start == null || end == null) return 'N/A';
    try {
      final s = DateFormat('h:mm a').parse(start);
      final e = DateFormat('h:mm a').parse(end);
      final diff = e.difference(s).inHours;
      return '${diff.abs()} Hours';
    } catch (_) {
      return 'N/A';
    }
  }

  String _payRate(double? rate) =>
      rate == null ? 'N/A' : '\$${rate.toStringAsFixed(0)}/hr';

  @override
  Widget build(BuildContext context) {
    final shift = _shift; // ✅ SINGLE SOURCE

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Text(
            'Shift Claimed',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              /// SUCCESS ICON
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 56),
                ),
              ),

              const SizedBox(height: 32),

              /// MESSAGE
              FadeTransition(
                opacity: _opacityAnimation,
                child: Column(
                  children: [
                    const Text(
                      'Shift Claimed Successfully!',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You successfully claimed shift at ${shift.facilityName ?? shift.location ?? 'Facility'}',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    if (shift.address != null && shift.address!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        shift.address!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// DETAILS
              FadeTransition(
                opacity: _opacityAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _card(
                              'Date',
                              _formatDate(shift.date),
                              Icons.calendar_today_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _card(
                              'Time',
                              _formatTime(
                                  shift.startTime, shift.endTime),
                              Icons.access_time_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _card(
                              'Duration',
                              _calculateDuration(
                                  shift.startTime, shift.endTime),
                              Icons.hourglass_empty_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _card(
                              'Pay Rate',
                              _payRate(shift.payPerHour),
                              Icons.attach_money_outlined,
                            ),
                          ),
                        ],
                      ),
                      if (shift.licenseType != null) ...[
                        const SizedBox(height: 16),
                        _fullCard(
                          'License Type',
                          shift.licenseType!,
                          Icons.badge_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// BACK
              FadeTransition(
                opacity: _opacityAnimation,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Get.offAll(() => WorkerHomeViewNew()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _fullCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
