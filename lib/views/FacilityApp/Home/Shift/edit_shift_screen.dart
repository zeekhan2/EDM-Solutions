// lib/views/FacilityApp/Home/Shift/edit_shift_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:edm_solutions/controllers/post_shift_controller.dart';
import '../../../../models/shift_models.dart';
import 'post_shift_success_screen.dart';

class EditShiftScreen extends StatefulWidget {
  final Shift shift;

  const EditShiftScreen({Key? key, required this.shift}) : super(key: key);

  @override
  State<EditShiftScreen> createState() => _EditShiftScreenState();
}

class _EditShiftScreenState extends State<EditShiftScreen> {
  late final PostShiftController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PostShiftController());

    /// PREFILL DATA
    controller.roleController.text = widget.shift.title ?? '';
    controller.locationController.text = widget.shift.location ?? '';
    controller.instructionsController.text =
        widget.shift.specialInstruction ?? '';
    controller.payRateController.text =
        widget.shift.payPerHour?.toString() ?? '';

    controller.selectedDate.value = DateTime.parse(widget.shift.date!);
    controller.startTime.value = _parseApiTime(widget.shift.startTime!);
    controller.endTime.value = _parseApiTime(widget.shift.endTime!);
  }

  /// SAFE TIME PARSER
  TimeOfDay _parseApiTime(String raw) {
    final value = raw.trim().toUpperCase();
    final formats = [
      DateFormat('h:mm a'),
      DateFormat('h:mma'),
    ];

    for (final f in formats) {
      try {
        final dt = f.parseStrict(value.replaceAll(' ', ''));
        return TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (_) {}
    }
    throw FormatException('Invalid time format: $raw');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value!,
      firstDate: DateTime.now().subtract(const Duration(days: 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      controller.selectedDate.value = picked;
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStart ? controller.startTime.value! : controller.endTime.value!,
    );

    if (picked != null) {
      isStart
          ? controller.startTime.value = picked
          : controller.endTime.value = picked;
    }
  }

  Widget _inputBox({
    required Widget child,
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.arrow_back_ios, color: Colors.black54),
          ),
        ),
        title: const Text(
          'Update Shift',
          style: TextStyle(color: Color(0xFF173B7A)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DATE + PAY (SAME AS POST SHIFT)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Shift Date',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF173B7A)),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDate,
                            child: _inputBox(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${controller.selectedDate.value!.month.toString().padLeft(2, '0')}-${controller.selectedDate.value!.day.toString().padLeft(2, '0')}-${controller.selectedDate.value!.year}",
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF173B7A),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.calendar_today,
                                        size: 18, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pay Rate ( hour )',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF173B7A)),
                          ),
                          const SizedBox(height: 8),
                          _inputBox(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: TextField(
                              controller: controller.payRateController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                hintText: '10\$',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// START / END TIME (SAME AS POST SHIFT)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Time',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF173B7A)),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _pickTime(isStart: true),
                            child: _inputBox(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(controller.formatTime(
                                        controller.startTime.value)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF173B7A),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.access_time,
                                        size: 18, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Time',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF173B7A)),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _pickTime(isStart: false),
                            child: _inputBox(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(controller
                                        .formatTime(controller.endTime.value)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF173B7A),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.access_time,
                                        size: 18, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// ROLE
                const Text('Required Role',
                    style: TextStyle(fontSize: 13, color: Color(0xFF173B7A))),
                const SizedBox(height: 8),
                _inputBox(
                  child: TextField(
                    controller: controller.roleController,
                    decoration: const InputDecoration(
                        border: InputBorder.none, isDense: true),
                  ),
                ),

                const SizedBox(height: 14),

                /// INSTRUCTIONS
                const Text('Special Instructions',
                    style: TextStyle(fontSize: 13, color: Color(0xFF173B7A))),
                const SizedBox(height: 8),
                _inputBox(
                  child: TextField(
                    controller: controller.instructionsController,
                    decoration: const InputDecoration(
                        border: InputBorder.none, isDense: true),
                  ),
                ),

                const SizedBox(height: 14),

                /// LOCATION
                const Text('Location',
                    style: TextStyle(fontSize: 13, color: Color(0xFF173B7A))),
                const SizedBox(height: 8),
                _inputBox(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Color(0xFF173B7A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller.locationController,
                          decoration: const InputDecoration(
                              border: InputBorder.none, isDense: true),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                /// UPDATE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final success =
                                await controller.updateShift(widget.shift.id!);
                            if (!success) return;
                            Get.offAll(() => const PostShiftSuccessScreen());
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF173B7A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Update Shift',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
