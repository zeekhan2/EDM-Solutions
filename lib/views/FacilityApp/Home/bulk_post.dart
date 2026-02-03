import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/post_shift_controller.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import 'Shift/post_shift_success_screen.dart';

class BulkPostScreen extends StatefulWidget {
  const BulkPostScreen({super.key});

  @override
  State<BulkPostScreen> createState() => _BulkPostScreenState();
}

class _BulkPostScreenState extends State<BulkPostScreen> {
  static const Color navy = Color(0xFF173B7A);

  bool isLoading = false;
  final RxList<_BulkShiftForm> forms = <_BulkShiftForm>[].obs;

  @override
  void initState() {
    super.initState();
    _addForm();
  }

  void _addForm() {
    forms.add(_BulkShiftForm(controller: PostShiftController()));
  }

  void _removeForm(int index) {
    if (forms.length > 1) {
      forms.removeAt(index);
    }
  }

  Future<void> _submitBulk() async {
    if (isLoading) return;

    bool hasError = false;

    for (final f in forms) {
      if (!f.controller.validateForBulk()) {
        hasError = true;
      }
    }

    setState(() {});
    if (hasError) return;

    try {
      isLoading = true;
      setState(() {});

      final token = await StorageService.getToken();
      if (token == null) return;

      final shifts = forms.map((f) {
        final c = f.controller;
        return {
          'date': DateFormat('yyyy-MM-dd').format(c.selectedDate.value!),
          'pay_per_hour': double.parse(c.payRateController.text),
          'start_time': c.formatTimeForApi(c.startTime.value!),
          'end_time': c.formatTimeForApi(c.endTime.value!),
          'title': c.roleController.text.trim(),
          'license_type': c.roleController.text.trim(),
          'special_instruction': c.instructionsController.text.trim(),
          'location': c.locationController.text.trim(),
          'is_emergency': false,
        };
      }).toList();

      final res = await ApiService.post(
        endpoint: '/api/create/bulk/shift',
        token: token,
        body: {'shifts': shifts},
      );

      if (res.success == true) {
        Get.offAll(() => const PostShiftSuccessScreen());
      }
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Bulk Post', style: TextStyle(color: navy)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              ...List.generate(forms.length, (i) {
                return _BulkShiftCard(
                  index: i,
                  form: forms[i],
                  onRemove: () => _removeForm(i),
                );
              }),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _addForm,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Another Post'),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBulk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Post Shift',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulkShiftCard extends StatefulWidget {
  final int index;
  final _BulkShiftForm form;
  final VoidCallback onRemove;

  const _BulkShiftCard({
    required this.index,
    required this.form,
    required this.onRemove,
  });

  @override
  State<_BulkShiftCard> createState() => _BulkShiftCardState();
}

class _BulkShiftCardState extends State<_BulkShiftCard> {
  static const Color navy = Color(0xFF173B7A);
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    final c = widget.form.controller;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Shift ${widget.index + 1}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                icon:
                    Icon(expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => expanded = !expanded),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: widget.onRemove,
              ),
            ],
          ),

          if (expanded) ...[
            const SizedBox(height: 12),

            _errorText(c),

            _dateAndPay(context, c),
            const SizedBox(height: 14),
            _timeRow(context, c),
            const SizedBox(height: 14),
            _textField('Title', c.roleController),
            const SizedBox(height: 14),
            _textField('Special Instructions', c.instructionsController),
            const SizedBox(height: 14),
            _textField('Location', c.locationController),
          ],
        ],
      ),
    );
  }

  Widget _errorText(PostShiftController c) {
    return Obx(() => c.error.value == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              c.error.value!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ));
  }

  Widget _dateAndPay(BuildContext context, PostShiftController c) {
    return Row(
      children: [
        Expanded(
          child: _label(
            'Select Shift Date',
            _pickerBox(
              () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: c.selectedDate.value ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  c.selectedDate.value = picked;
                }
              },
              Obx(() => Text(
                    c.selectedDate.value == null
                        ? 'MM-DD-YYYY'
                        : DateFormat('MM-dd-yyyy')
                            .format(c.selectedDate.value!),
                  )),
              Icons.calendar_today,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: _label(
            'Pay Rate (hour)',
            _box(TextField(
              controller: c.payRateController,
              decoration: const InputDecoration(
                hintText: '10',
                border: InputBorder.none,
                isDense: true,
              ),
            )),
          ),
        ),
      ],
    );
  }

  Widget _timeRow(BuildContext context, PostShiftController c) {
    return Row(
      children: [
        Expanded(
          child: _timePicker(context, 'Start Time', c.startTime),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _timePicker(context, 'End Time', c.endTime),
        ),
      ],
    );
  }

  Widget _timePicker(
      BuildContext context, String label, Rx<TimeOfDay?> time) {
    return _label(
      label,
      _pickerBox(
        () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time.value ?? TimeOfDay.now(),
          );
          if (picked != null) time.value = picked;
        },
        Obx(() => Text(time.value == null
            ? 'HH:MM'
            : DateFormat('hh:mm a').format(
                DateTime(2020, 1, 1, time.value!.hour,
                    time.value!.minute)))),
        Icons.access_time,
      ),
    );
  }

  Widget _textField(String label, TextEditingController c) {
    return _label(
      label,
      _box(TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          isDense: true,
        ),
      )),
    );
  }

  Widget _label(String t, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: const TextStyle(fontSize: 13, color: navy)),
          const SizedBox(height: 6),
          child,
        ],
      );

  Widget _box(Widget child) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );

  Widget _pickerBox(
      VoidCallback onTap, Widget text, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: _box(Row(
        children: [
          Expanded(child: text),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ],
      )),
    );
  }
}

class _BulkShiftForm {
  final PostShiftController controller;
  _BulkShiftForm({required this.controller});
}
