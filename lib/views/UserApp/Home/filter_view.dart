import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterController extends GetxController {
  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);

  late TextEditingController shiftTypeController;
  late TextEditingController locationController;
  late TextEditingController payMinController;
  late TextEditingController payMaxController;

  @override
  void onInit() {
    super.onInit();
    shiftTypeController = TextEditingController();
    locationController = TextEditingController();
    payMinController = TextEditingController();
    payMaxController = TextEditingController();
  }

  @override
  void onClose() {
    shiftTypeController.dispose();
    locationController.dispose();
    payMinController.dispose();
    payMaxController.dispose();
    super.onClose();
  }

  void setStartDate(DateTime date) => startDate.value = date;
  void setEndDate(DateTime date) => endDate.value = date;

  /// ✅ APPLY FILTERS (LOGIC HANDLED IN SHIFT LIST)
  void applyFilters() {
    Get.back();

    Get.snackbar(
      'Filters Applied',
      'Shifts list updated',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E3A8A),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void resetFilters() {
    startDate.value = null;
    endDate.value = null;
    shiftTypeController.clear();
    locationController.clear();
    payMinController.clear();
    payMaxController.clear();
  }
}

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  late FilterController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(FilterController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Filter',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Start Date',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            /// START DATE
            Obx(() => _dateBox(
                  context,
                  controller.startDate.value,
                  () => _selectStartDate(context),
                )),

            const SizedBox(height: 16),
            const Text('End Date',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            /// END DATE
            Obx(() => _dateBox(
                  context,
                  controller.endDate.value,
                  () => _selectEndDate(context),
                )),

            const SizedBox(height: 24),
            _textField('Shift Type', controller.shiftTypeController),
            const SizedBox(height: 24),
            _textField('Location', controller.locationController),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child:
                        _textField('Pay Min', controller.payMinController)),
                const SizedBox(width: 16),
                Expanded(
                    child:
                        _textField('Pay Max', controller.payMaxController)),
              ],
            ),

            const SizedBox(height: 40),

            /// APPLY
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.applyFilters,
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
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// RESET
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.resetFilters,
                style: OutlinedButton.styleFrom(
                  side:
                      const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Reset Filters',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _dateBox(
      BuildContext context, DateTime? date, VoidCallback onTap) {
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

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.startDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) controller.setStartDate(picked);
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.endDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) controller.setEndDate(picked);
  }
}
