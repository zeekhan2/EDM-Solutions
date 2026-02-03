import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/worker_home_controller.dart';
import '../../../models/shift_models.dart';
import 'shift_claimed_view.dart';
import '../Home/chat_detail_view.dart';
import '../../../controllers/auth_controller.dart';

class ShiftDetailsView extends StatefulWidget {
  final int shiftId;

  const ShiftDetailsView({super.key, required this.shiftId});

  @override
  State<ShiftDetailsView> createState() => _ShiftDetailsViewState();
}

class _ShiftDetailsViewState extends State<ShiftDetailsView> {
  final WorkerHomeController workerController =
      Get.find<WorkerHomeController>();

  final Rxn<Shift> shift = Rxn<Shift>();
  final RxBool isLoading = true.obs;

  bool hasTimeConflict = false;
  bool isPastShift = false;
  String? disableReason;

  @override
  void initState() {
    super.initState();
    _loadShiftDetail();
  }

  Future<void> _loadShiftDetail() async {
    isLoading.value = true;

    final result = await workerController.getShiftDetail(widget.shiftId);

    if (result != null) {
      shift.value = result;
      _checkPastShift(result);
      _checkTimeConflict(result);
    }

    isLoading.value = false;
  }

  // ==========================================================
  // PAST SHIFT CHECK
  // ==========================================================
  void _checkPastShift(Shift s) {
    if (s.date == null || s.startTime == null) return;

    final date = DateTime.parse(s.date!);
    final time = DateFormat('h:mm a').parse(s.startTime!);

    final shiftDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (shiftDateTime.isBefore(DateTime.now())) {
      isPastShift = true;
      disableReason = 'You cannot claim a past shift.';
    }
  }

  // ==========================================================
  // TIME CONFLICT CHECK
  // ==========================================================
  void _checkTimeConflict(Shift s) {
    final format = DateFormat('h:mm a');

    final existingShifts = workerController.todayShifts.where(
      (e) => e.status == 2 || e.status == 3 || e.status == 4,
    );

    for (final e in existingShifts) {
      if (e.id == s.id) continue;
      if (e.date == null || s.date == null || e.date != s.date) continue;

      final newStart = format.parse(s.startTime!);
      final newEnd = format.parse(s.endTime!);
      final oldStart = format.parse(e.startTime!);
      final oldEnd = format.parse(e.endTime!);

      if (newStart.isBefore(oldEnd) && newEnd.isAfter(oldStart)) {
        hasTimeConflict = true;
        disableReason = 'This shift overlaps with another claimed shift.';
        return;
      }
    }
  }

  // ==========================================================
  // CHAT (WORKER → FACILITY WHO POSTED SHIFT)
  // ==========================================================
  void _openChat() {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;
    final s = shift.value;

    if (user == null || s == null) return;

    if (s.facilityFirebaseUid == null ||
        s.facilityFirebaseUid!.isEmpty ||
        s.facilityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Facility chat is not enabled yet'),
        ),
      );
      return;
    }

    final chatId = 'facility_${s.facilityId}_worker_${user.id}';

    Get.to(
      () => ChatDetailView(
        chatId: chatId,
        contactName: s.facilityName ?? 'Facility',
        workerId: user.id!,
        facilityId: s.facilityId!,
        workerName: user.fullName ?? 'Worker',
        facilityName: s.facilityName ?? 'Facility',
        otherUserFirebaseUid: s.facilityFirebaseUid!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Shift Details',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1E3A8A),
            ),
          );
        }

        final s = shift.value;
        if (s == null) {
          return const Center(child: Text('Unable to load shift'));
        }

        final canClaim = s.status == 1 && !hasTimeConflict && !isPastShift;

        final facilityName =
            (s.facilityName != null && s.facilityName!.isNotEmpty)
                ? s.facilityName!
                : '—';

        final facilityAddress = (s.address != null && s.address!.isNotEmpty)
            ? s.address!
            : (s.location ?? '');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ==================================================
              // HEADER (FACILITY NAME + ADDRESS)
              // ==================================================
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F4EA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF22C55E),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facilityName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          facilityAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble,
                      color: Color(0xFF1E3A8A),
                    ),
                    onPressed: _openChat,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // INFO CARDS
              // ==================================================
              Row(
                children: [
                  _infoCard(
                    'Date',
                    DateFormat('MM-dd-yyyy').format(DateTime.parse(s.date!)),
                    Icons.calendar_today_outlined,
                  ),
                  const SizedBox(width: 12),
                  _infoCard(
                    'Time',
                    '${s.startTime} - ${s.endTime}',
                    Icons.access_time_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _infoCard(
                    'Duration',
                    '${DateFormat('h:mm a').parse(s.endTime!).difference(DateFormat('h:mm a').parse(s.startTime!)).inHours} Hours',
                    Icons.timer_outlined,
                  ),
                  const SizedBox(width: 12),
                  _infoCard(
                    'Pay Rate',
                    '\$${s.payPerHour}/hr',
                    Icons.attach_money,
                    valueColor: Colors.green,
                  ),
                ],
              ),

              if (!canClaim && disableReason != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          disableReason!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // ==================================================
              // CLAIM BUTTON
              // ==================================================
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (canClaim && !workerController.isLoading.value)
                          ? () async {
                              final success = await workerController
                                  .claimShiftFromDetail(s.id!);

                              if (!success) return; // 🚫 STOP ON ERROR

                              Get.off(() => ShiftClaimedView(shift: s));
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: workerController.isLoading.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Claim This Shift',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                    ),
                  )),
            ],
          ),
        );
      }),
    );
  }

  // ==========================================================
  // INFO CARD
  // ==========================================================
  Widget _infoCard(
    String title,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
