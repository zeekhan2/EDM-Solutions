import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../consts/app_radius.dart';
import '../../../../consts/app_text_styles.dart';
import '../../../../consts/colors.dart';
import '../../../../models/shift_models.dart';
import '../../../../services/worker_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../controllers/auth_controller.dart';
import 'package:edm_solutions/views/UserApp/Home/chat_detail_view.dart';
import 'package:edm_solutions/controllers/worker_home_controller.dart';


class WorkerShiftDetailsView extends StatefulWidget {
  final int claimedShiftId;

  const WorkerShiftDetailsView({
    super.key,
    required this.claimedShiftId,
  });

  @override
  State<WorkerShiftDetailsView> createState() =>
      _WorkerShiftDetailsViewState();
}

class _WorkerShiftDetailsViewState extends State<WorkerShiftDetailsView> {
  Shift? shift;
  bool isLoading = true;
  bool canCancel = false;

  @override
  void initState() {
    super.initState();
    _loadShift();
  }

  // ==========================================================
  // LOAD CLAIMED SHIFT
  // ==========================================================
  Future<void> _loadShift() async {
    final token = await StorageService.getToken();
    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final res = await WorkerService.getClaimedShiftDetails(
      token,
      widget.claimedShiftId,
    );

    if (res.success && res.data != null) {
      shift = res.data;
      _checkCancelEligibility();
    }

    setState(() => isLoading = false);
  }

  // ==========================================================
  // DATE
  // ==========================================================
  String get displayDate {
    if (shift?.date == null) return '--';
    try {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.parse(shift!.date!));
    } catch (_) {
      return '--';
    }
  }

  // ==========================================================
  // 4-HOUR RULE
  // ==========================================================
  void _checkCancelEligibility() {
    if (shift?.startTime == null || shift?.date == null) {
      canCancel = false;
      return;
    }

    try {
      final date = DateTime.parse(shift!.date!);
      final time = DateFormat('h:mm a').parse(shift!.startTime!);

      final startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      canCancel =
          startDateTime.difference(DateTime.now()).inHours >= 4;
    } catch (_) {
      canCancel = false;
    }
  }

  // ==========================================================
  // CANCEL SHIFT (✅ ALWAYS CLAIMED SHIFT ID)
  // ==========================================================
  Future<void> _cancelShift() async {
  final token = await StorageService.getToken();
  if (token == null || shift?.realShiftId == null) return;

  final res = await WorkerService.cancelShift(
    token,
    shift!.realShiftId!, // ✅ correct shift_id
  );

  if (!res.success) {
    Get.snackbar('Error', res.message ?? 'Failed to cancel shift');
    return;
  }

  // ✅ FIND HOME CONTROLLER
  final homeController = Get.find<WorkerHomeController>();

  // ✅ SHOW LOADING ON HOME
  homeController.isLoading.value = true;

  // ✅ RELOAD SHIFTS (CURRENT DATE)
  await homeController.fetchShiftsByDate(
    homeController.selectedDate.value,
  );

  homeController.isLoading.value = false;

  // ✅ NAVIGATE BACK TO HOME (FORCE REFRESH)
  Get.back(result: true);
}



  // ==========================================================
  // OPEN CHAT (❌ DISABLED IF firebase_uid IS NULL)
  // ==========================================================
  void _openChat() {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;

    if (user == null || shift == null) return;

    if (shift!.facilityFirebaseUid == null ||
        shift!.facilityFirebaseUid!.isEmpty) {
      Get.snackbar(
        'Chat unavailable',
        'Facility chat is not enabled yet',
      );
      return;
    }

    final chatId =
        'facility_${shift!.facilityId}_worker_${user.id}';

    Get.to(
      () => ChatDetailView(
        chatId: chatId,
        contactName: shift!.facilityName ?? 'Facility',
        workerId: user.id!,
        facilityId: shift!.facilityId!,
        workerName: user.fullName ?? 'Worker',
        facilityName: shift!.facilityName ?? 'Facility',
        otherUserFirebaseUid: shift!.facilityFirebaseUid!,
      ),
    );
  }

  String _duration(String? s, String? e) {
    if (s == null || e == null) return '--';
    try {
      final f = DateFormat('h:mm a');
      return '${f.parse(e).difference(f.parse(s)).inHours} Hours';
    } catch (_) {
      return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (shift == null) {
      return const Scaffold(
        body: Center(child: Text('Unable to load shift')),
      );
    }

    final isChatEnabled =
        shift!.facilityFirebaseUid != null &&
        shift!.facilityFirebaseUid!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text('Shift Details'),
      ),
      body: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFE6F4EA),
                  child: Icon(Icons.calendar_today,
                      color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift!.facilityName ?? '—',
                        style: AppTextStyles.h3,
                      ),
                      Text(
                        shift!.address ?? '—',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble,
                    color: isChatEnabled
                        ? AppColors.primary
                        : Colors.grey,
                  ),
                  onPressed: isChatEnabled ? _openChat : null,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                _InfoBadge(title: 'Date', value: displayDate),
                const SizedBox(width: 12),
                _InfoBadge(
                  title: 'Time',
                  value:
                      '${shift!.startTime} - ${shift!.endTime}',
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _InfoBadge(
                  title: 'Duration',
                  value:
                      _duration(shift!.startTime, shift!.endTime),
                ),
                const SizedBox(width: 12),
                _InfoBadge(
                  title: 'Pay Rate',
                  value: '\$${shift!.payPerHour}/hr',
                  valueColor: Colors.green,
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canCancel ? const Color(0xFFD62828) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: canCancel ? _cancelShift : null,
                child: const Text(
                  'Cancel Shift',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// INFO BADGE
// ==========================================================
class _InfoBadge extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoBadge({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.caption),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
