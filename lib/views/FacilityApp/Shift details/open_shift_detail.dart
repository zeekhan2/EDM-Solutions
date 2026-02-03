// lib/views/FacilityApp/Shift details/open_shift_detail.dart

import 'package:edm_solutions/views/FacilityApp/Home/Shift/edit_shift_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/shift_models.dart';
import '../../../controllers/shift_controller.dart';

class OpenShiftDetailScreen extends StatelessWidget {
  final Shift shift;
  const OpenShiftDetailScreen({super.key, required this.shift});

  Widget _infoBox(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ShiftController controller = Get.find<ShiftController>();
    const primary = Color(0xFF1E3A8A);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Back + title
              Row(
                children: [
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
                    'Open Shift Details',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// Title + location
              Text(
                shift.title ?? shift.licenseType ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                shift.location ?? '',
                style: const TextStyle(color: Color(0xFF9AA3BD)),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _infoBox('DATE', shift.date ?? '-'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoBox(
                      'Time',
                      '${shift.startTime ?? ''} - ${shift.endTime ?? ''}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _infoBox(
                      'Pay Rate',
                      shift.payPerHour != null
                          ? '\$${shift.payPerHour!.toStringAsFixed(0)}/hr'
                          : '-',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Spacer(),

              /// Buttons
              Row(
                children: [
                  /// UPDATE
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => EditShiftScreen(
                            shift: shift,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Update Shift',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// DELETE
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Delete Shift',
                          middleText:
                              'Are you sure you want to delete this shift?',
                          textConfirm: 'Delete',
                          textCancel: 'Cancel',
                          confirmTextColor: Colors.white,
                          onConfirm: () async {
                            Get.back(); // close confirmation dialog

                            // 🔄 show blocking loader
                            Get.dialog(
                              const Center(child: CircularProgressIndicator()),
                              barrierDismissible: false,
                            );

                            final success =
                                await controller.deleteShift(shift.id!);

                            Get.back(); // close loader

                            if (success) {
                              Get.back(); // go back to shift list screen
                              Get.snackbar(
                                  'Success', 'Shift deleted successfully');
                            } else {
                              Get.snackbar(
                                'Error',
                                controller.errorMessage.value.isNotEmpty
                                    ? controller.errorMessage.value
                                    : 'Delete failed',
                              );
                            }
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4D4D),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Delete Shift',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
