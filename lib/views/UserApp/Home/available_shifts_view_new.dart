import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../consts/app_text_styles.dart';
import '../../../consts/colors.dart';
import '../../../controllers/worker_home_controller.dart';
import '../../../models/shift_models.dart';
import 'shift_details_view.dart';
import 'filter_view.dart';
import 'package:intl/intl.dart';

class AvailableShiftsViewNew extends StatefulWidget {
  const AvailableShiftsViewNew({super.key});

  @override
  State<AvailableShiftsViewNew> createState() => _AvailableShiftsViewNewState();
}

class _AvailableShiftsViewNewState extends State<AvailableShiftsViewNew> {
  final WorkerHomeController controller = Get.find<WorkerHomeController>();

  final FilterController filterController = Get.put(FilterController());

  final RxBool showFilter = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchShifts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _header(),
                _search(),
                Expanded(child: _list()),
              ],
            ),

            /// 🔥 FILTER OVERLAY
            Obx(() => showFilter.value ? _filterOverlay() : const SizedBox()),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Available Shifts',
            style: AppTextStyles.h2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          /// 🔍 FILTER TOGGLE
          SizedBox(
            height: 36,
            width: 36,
            child: ElevatedButton(
              onPressed: () => showFilter.toggle(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 4,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Icon(
                Icons.tune,
                size: 20,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTER OVERLAY =================
  Widget _filterOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          showFilter.value = false;
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Colors.black.withOpacity(0.35),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.92,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                child: _filterContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= FILTER CONTENT =================
  Widget _filterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter Shifts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        const Text('Start Date', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Obx(() => _dateBox(
              filterController.startDate.value,
              _selectStartDate,
            )),
        const SizedBox(height: 16),
        const Text('End Date', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Obx(() => _dateBox(
              filterController.endDate.value,
              _selectEndDate,
            )),
        const SizedBox(height: 20),
        _textField(
          label: 'Shift Type',
          controller: filterController.shiftTypeController,
          action: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _textField(
          label: 'Location',
          controller: filterController.locationController,
          action: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _textField(
                label: 'Pay Min',
                controller: filterController.payMinController,
                keyboardType: TextInputType.number,
                action: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _textField(
                label: 'Pay Max',
                controller: filterController.payMaxController,
                keyboardType: TextInputType.number,
                action: TextInputAction.done,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              filterController.applyFilters();
              showFilter.value = false;
              FocusScope.of(context).unfocus();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Apply Filter',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              filterController.resetFilters();
              showFilter.value = false;
              FocusScope.of(context).unfocus();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Reset Filters',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= SEARCH =================
  Widget _search() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // ================= LIST =================
  Widget _list() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final shifts = controller.availableShifts;

      if (shifts.isEmpty) {
        return const Center(child: Text('No Available Shifts'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shifts.length,
        itemBuilder: (_, i) => _card(shifts[i]),
      );
    });
  }

  // ================= CARD =================
  Widget _card(Shift shift) {
    final isPast = _isShiftPast(shift);

    return Opacity(
      opacity: isPast ? 0.5 : 1,
      child: GestureDetector(
        onTap: isPast
            ? null
            : () async {
                await Get.to(() => ShiftDetailsView(shiftId: shift.id!));
                controller.fetchShifts();
              },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.title ?? shift.licenseType ?? 'Shift',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shift.location ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shift.startTime ?? ''} - ${shift.endTime ?? ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              _statusButton(shift),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusButton(Shift shift) {
    if (_isShiftPast(shift)) {
      return _disabledButton('Expired');
    }

    if (shift.status == 1) {
      return ElevatedButton(
        onPressed: () async {
          await Get.to(() => ShiftDetailsView(shiftId: shift.id!));
          controller.fetchShifts();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Claim',
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      );
    }

    if (shift.status == 2) {
      return _disabledButton('Pending');
    }

    return _disabledButton(shift.statusLabel);
  }

  Widget _disabledButton(String text) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
  }

  // ================= HELPERS =================
  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputAction action = TextInputAction.next,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          textInputAction: action,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateBox(DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          date == null
              ? 'Select Date'
              : '${date.day}/${date.month}/${date.year}',
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filterController.startDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) filterController.setStartDate(picked);
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filterController.endDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) filterController.setEndDate(picked);
  }

  bool _isShiftPast(Shift shift) {
    if (shift.date == null || shift.endTime == null) return false;

    try {
      final date = DateFormat('yyyy-MM-dd').parse(shift.date!);
      final time = DateFormat('hh:mm a').parse(shift.endTime!);

      final endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      return endDateTime.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}
