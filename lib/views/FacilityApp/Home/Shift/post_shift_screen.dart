import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/controllers/post_shift_controller.dart';
import 'post_shift_success_screen.dart';
import 'package:flutter/scheduler.dart';

class PostNewShiftScreen extends StatefulWidget {
  const PostNewShiftScreen({Key? key}) : super(key: key);

  @override
  State<PostNewShiftScreen> createState() => _PostNewShiftScreenState();
}

class _PostNewShiftScreenState extends State<PostNewShiftScreen> {
  late final PostShiftController controller;

  final ScrollController _scrollController = ScrollController();

  final _dateKey = GlobalKey();
  final _payKey = GlobalKey();
  final _timeKey = GlobalKey();
  final _roleKey = GlobalKey();
  final _locationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = Get.put(PostShiftController());
  }

  // ---------------- ERROR MATCHERS ----------------

  bool _hasDateError() =>
      controller.error.value?.toLowerCase().contains('date') == true;

  bool _hasPayError() =>
      controller.error.value?.toLowerCase().contains('pay') == true;

  bool _hasTimeError() =>
      controller.error.value?.toLowerCase().contains('time') == true;

  bool _hasRoleError() =>
      controller.error.value?.toLowerCase().contains('title') == true;

  bool _hasLocationError() =>
      controller.error.value?.toLowerCase().contains('location') == true;

  // ---------------- AUTO SCROLL ----------------

  void _scrollToFirstError() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_hasDateError()) {
        Scrollable.ensureVisible(_dateKey.currentContext!,
            duration: const Duration(milliseconds: 400));
      } else if (_hasPayError()) {
        Scrollable.ensureVisible(_payKey.currentContext!,
            duration: const Duration(milliseconds: 400));
      } else if (_hasTimeError()) {
        Scrollable.ensureVisible(_timeKey.currentContext!,
            duration: const Duration(milliseconds: 400));
      } else if (_hasRoleError()) {
        Scrollable.ensureVisible(_roleKey.currentContext!,
            duration: const Duration(milliseconds: 400));
      } else if (_hasLocationError()) {
        Scrollable.ensureVisible(_locationKey.currentContext!,
            duration: const Duration(milliseconds: 400));
      }
    });
  }

  // ---------------- CLEAR FORM ----------------

  void _clearForm() {
    controller.error.value = null;
    controller.payRateController.clear();
    controller.roleController.clear();
    controller.instructionsController.clear();
    controller.locationController.clear();
    controller.selectedDate.value = null;
    controller.startTime.value = null;
    controller.endTime.value = null;
  }

  // ---------------- UI HELPERS ----------------

  Widget _errorText(bool show) {
    if (!show) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        controller.error.value ?? '',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  Widget _inputBox({
    required Widget child,
    bool hasError = false,
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(
          color: hasError ? Colors.red : Colors.grey.shade300,
          width: hasError ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: child,
    );
  }

  // ---------------- PICKERS ----------------

  Future<void> _pickDate() async {
    controller.error.value = null;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) controller.selectedDate.value = picked;
  }

  Future<void> _pickTime({required bool isStart}) async {
    controller.error.value = null;
    final initial = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? controller.startTime.value ?? initial
          : controller.endTime.value ?? initial,
    );
    if (picked != null) {
      isStart
          ? controller.startTime.value = picked
          : controller.endTime.value = picked;
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black54),
        ),
        title: const Text(
          'Post New Shift',
          style: TextStyle(color: Color(0xFF173B7A)),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DATE + PAY
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        key: _dateKey,
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
                              hasError: _hasDateError(),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      controller.selectedDate.value == null
                                          ? 'MM - DD - YYYY'
                                          : "${controller.selectedDate.value!.month.toString().padLeft(2, '0')}-${controller.selectedDate.value!.day.toString().padLeft(2, '0')}-${controller.selectedDate.value!.year}",
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today,
                                      color: Color(0xFF173B7A)),
                                ],
                              ),
                            ),
                          ),
                          _errorText(_hasDateError()),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 110,
                      child: Column(
                        key: _payKey,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pay Rate ( hour )',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF173B7A)),
                          ),
                          const SizedBox(height: 8),
                          _inputBox(
                            hasError: _hasPayError(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: TextField(
                              controller: controller.payRateController,
                              onChanged: (_) => controller.error.value = null,
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
                          _errorText(_hasPayError()),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                /// START / END TIME (ICON FIXED)
                Column(
                  key: _timeKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(isStart: true),
                            child: _inputBox(
                              hasError: _hasTimeError(),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      controller.startTime.value == null
                                          ? '09:00 am'
                                          : controller.formatTime(
                                              controller.startTime.value),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF173B7A),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.access_time,
                                        size: 18, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(isStart: false),
                            child: _inputBox(
                              hasError: _hasTimeError(),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      controller.endTime.value == null
                                          ? ''
                                          : controller.formatTime(
                                              controller.endTime.value),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF173B7A),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.access_time,
                                        size: 18, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _errorText(_hasTimeError()),
                  ],
                ),

                const SizedBox(height: 18),

                /// ROLE
                Column(
                  key: _roleKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Required Role',
                      style: TextStyle(fontSize: 13, color: Color(0xFF173B7A)),
                    ),
                    const SizedBox(height: 8),
                    _inputBox(
                      hasError: _hasRoleError(),
                      child: TextField(
                        controller: controller.roleController,
                        onChanged: (_) => controller.error.value = null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Cardiologist',
                          isDense: true,
                        ),
                      ),
                    ),
                    _errorText(_hasRoleError()),
                  ],
                ),

                const SizedBox(height: 14),

                /// INSTRUCTIONS
                const Text(
                  'Special Instructions',
                  style: TextStyle(fontSize: 13, color: Color(0xFF173B7A)),
                ),
                const SizedBox(height: 8),
                _inputBox(
                  child: TextField(
                    controller: controller.instructionsController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// LOCATION
                Column(
                  key: _locationKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(fontSize: 13, color: Color(0xFF173B7A)),
                    ),
                    const SizedBox(height: 8),
                    _inputBox(
                      hasError: _hasLocationError(),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Color(0xFF173B7A)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: controller.locationController,
                              onChanged: (_) => controller.error.value = null,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _errorText(_hasLocationError()),
                  ],
                ),

                const SizedBox(height: 28),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final success = await controller.submitShift();
                            if (!success) {
                              _scrollToFirstError();
                              return;
                            }

                            _clearForm(); // ✅ CLEAR FORM
                            Get.offAll(() => const PostShiftSuccessScreen());
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF173B7A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
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
                              Text(
                                'Post Shift',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
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
