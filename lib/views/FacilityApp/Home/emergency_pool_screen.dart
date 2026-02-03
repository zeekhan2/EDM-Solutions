import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import 'Shift/post_shift_success_screen.dart';

class EmergencyPoolScreen extends StatefulWidget {
  const EmergencyPoolScreen({super.key});

  @override
  State<EmergencyPoolScreen> createState() => _EmergencyPoolScreenState();
}

class _EmergencyPoolScreenState extends State<EmergencyPoolScreen> {
  static const Color navy = Color(0xFF173B7A);
  static const Color emergencyRed = Color(0xFFEC4D4D);

  final _dateCtrl = TextEditingController();
  final _payCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _instructionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;

  bool _loading = false;
  final Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _dateCtrl.text = DateFormat('MM-dd-yyyy').format(_date!);
    _start = const TimeOfDay(hour: 9, minute: 0);
    _startCtrl.text = _formatTime(_start!);
  }

  String _formatTime(TimeOfDay t) {
    final dt = DateTime(2020, 1, 1, t.hour, t.minute);
    return DateFormat('hh:mm a').format(dt);
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

  Widget _error(String key) => _errors[key] == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _errors[key]!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        );

  bool _validate() {
    _errors.clear();

    if (_date == null) _errors['date'] = 'Select shift date';
    if (_payCtrl.text.trim().isEmpty) _errors['pay'] = 'Enter pay rate';
    if (_start == null) _errors['start'] = 'Select start time';
    if (_end == null) _errors['end'] = 'Select end time';
    if (_licenseCtrl.text.trim().isEmpty) {
      _errors['license'] = 'Enter license type';
    }
    if (_locationCtrl.text.trim().isEmpty) {
      _errors['location'] = 'Enter location';
    }

    if (_start != null && _end != null) {
      final s = _start!.hour * 60 + _start!.minute;
      final e = _end!.hour * 60 + _end!.minute;
      if (e <= s) _errors['end'] = 'End time must be after start time';
    }

    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _date = picked;
      _dateCtrl.text = DateFormat('MM-dd-yyyy').format(picked);
      setState(() {});
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isStart ? (_start ?? TimeOfDay.now()) : (_end ?? TimeOfDay.now()),
    );
    if (picked != null) {
      if (isStart) {
        _start = picked;
        _startCtrl.text = _formatTime(picked);
      } else {
        _end = picked;
        _endCtrl.text = _formatTime(picked);
      }
      setState(() {});
    }
  }

  Future<void> _activate() async {
    if (_loading) return;
    if (!_validate()) return;

    try {
      _loading = true;
      setState(() {});

      final token = await StorageService.getToken();
      if (token == null) return;

      final startDT = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _start!.hour,
        _start!.minute,
      );

      final endDT = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _end!.hour,
        _end!.minute,
      );

      final res = await ApiService.post(
        endpoint: '/api/create/shift',
        token: token,
        body: {
          'title': _licenseCtrl.text.trim(),
          'date': DateFormat('yyyy-MM-dd').format(_date!),
          'start_time': DateFormat('HH:mm').format(startDT),
          'end_time': DateFormat('HH:mm').format(endDT),
          'pay_per_hour':
              _payCtrl.text.replaceAll(RegExp(r'[^0-9.]'), ''),
          'license_type': _licenseCtrl.text.trim(),
          'location': _locationCtrl.text.trim(),
          'special_instruction': _instructionCtrl.text.trim(),
          'is_emergency': true,
        },
      );

      if (res.success == true) {
        Get.showSnackbar(
          const GetSnackBar(
            message: 'Emergency Pool Activated',
            backgroundColor: Color(0xFF22C55E),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        /// ✅ ONLY CHANGE: NAVIGATE TO SUCCESS SCREEN
        Get.offAll(() => const PostShiftSuccessScreen());
      }
    } finally {
      _loading = false;
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
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.arrow_back_ios, color: Colors.black54),
          ),
        ),
        title:
            const Text('Emergency Pool', style: TextStyle(color: navy)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// DATE + PAY
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Shift Date',
                          style: TextStyle(fontSize: 13, color: navy)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: _inputBox(
                          child: Row(
                            children: [
                              Expanded(child: Text(_dateCtrl.text)),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: navy,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.calendar_today,
                                    size: 18, color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      _error('date'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pay Rate ( hour )',
                          style: TextStyle(fontSize: 13, color: navy)),
                      const SizedBox(height: 8),
                      _inputBox(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: TextField(
                          controller: _payCtrl,
                          decoration: const InputDecoration(
                              border: InputBorder.none, isDense: true),
                        ),
                      ),
                      _error('pay'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// START / END TIME
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Time',
                          style: TextStyle(fontSize: 13, color: navy)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickTime(true),
                        child: _inputBox(
                          child: Row(
                            children: [
                              Expanded(child: Text(_startCtrl.text)),
                              _timeIcon(),
                            ],
                          ),
                        ),
                      ),
                      _error('start'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Time',
                          style: TextStyle(fontSize: 13, color: navy)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickTime(false),
                        child: _inputBox(
                          child: Row(
                            children: [
                              Expanded(child: Text(_endCtrl.text)),
                              _timeIcon(),
                            ],
                          ),
                        ),
                      ),
                      _error('end'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Text('License Type',
                style: TextStyle(fontSize: 13, color: navy)),
            const SizedBox(height: 8),
            _inputBox(
              child: TextField(
                controller: _licenseCtrl,
                decoration: const InputDecoration(
                    border: InputBorder.none, isDense: true),
              ),
            ),
            _error('license'),

            const SizedBox(height: 14),

            const Text('Special Instructions',
                style: TextStyle(fontSize: 13, color: navy)),
            const SizedBox(height: 8),
            _inputBox(
              child: TextField(
                controller: _instructionCtrl,
                decoration: const InputDecoration(
                    border: InputBorder.none, isDense: true),
              ),
            ),

            const SizedBox(height: 14),

            const Text('Location',
                style: TextStyle(fontSize: 13, color: navy)),
            const SizedBox(height: 8),
            _inputBox(
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: navy),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                          border: InputBorder.none, isDense: true),
                    ),
                  ),
                ],
              ),
            ),
            _error('location'),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _activate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: emergencyRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Activate Emergency Pool',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _timeIcon() => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.access_time,
            size: 18, color: Colors.white),
      );
}
