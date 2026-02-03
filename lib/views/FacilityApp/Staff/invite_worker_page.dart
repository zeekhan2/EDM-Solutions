import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/shift_controller.dart';
import '../../../controllers/staff_controller.dart';
import '../../../models/shift_models.dart';
import '../../../consts/consts.dart';
import '../../../Common_Widgets/safe_snackbar_helper.dart';

class InviteWorkersPage extends StatefulWidget {
  final int workerId;

  const InviteWorkersPage({
    super.key,
    required this.workerId,
  });

  @override
  State<InviteWorkersPage> createState() => _InviteWorkersPageState();
}

class _InviteWorkersPageState extends State<InviteWorkersPage> {
  final ShiftController shiftController = Get.find<ShiftController>();
  final StaffController staffController = Get.find<StaffController>();

  int? selectedShiftId;

  @override
  void initState() {
    super.initState();
    shiftController.fetchAll(); // fetch facility shifts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select Open Shift'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (shiftController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // ONLY OPEN SHIFTS
        final List<Shift> openShifts = shiftController.openShifts;

        if (openShifts.isEmpty) {
          return const Center(child: Text('No open shifts available'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: openShifts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final shift = openShifts[index];
                  final bool selected = selectedShiftId == shift.id;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedShiftId = shift.id;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shift.title ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: semibold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              shift.date ?? '',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.schedule, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                  '${shift.startTime} - ${shift.endTime}'),
                            ]),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.location_on_outlined, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(shift.location ?? ''),
                              ),
                            ]),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.attach_money, size: 16),
                              const SizedBox(width: 6),
                              Text('${shift.payPerHour ?? ''} / hr'),
                            ]),
                          ]),
                    ),
                  );
                },
              ),
            ),

            // INVITE BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: selectedShiftId == null
                      ? null
                      : () async {
                          final success =
                              await staffController.sendShiftInvitation(
                            workerId: widget.workerId,
                            shiftId: selectedShiftId!,
                          );

                          if (success) {
                            SafeSnackbarHelper.showSafeSnackbar(
                              title: 'Invitation Sent',
                              message:
                                  'Worker has been invited to the shift',
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.95),
                              colorText: Colors.white,
                            );
                            Get.back();
                          } else {
                            SafeSnackbarHelper.showSafeSnackbar(
                              title: 'Failed',
                              message: 'Could not send invitation',
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Invite',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
