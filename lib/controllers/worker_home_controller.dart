import 'package:edm_solutions/views/UserApp/Home/shift_claimed_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../services/worker_service.dart';
import '../services/storage_service.dart';
import '../models/shift_models.dart';
import '../models/worker_shift_requests.dart';
import 'auth_controller.dart';
import 'dart:async';

class WorkerHomeController extends GetxController {
  // ==========================================================
  // STATE
  // ==========================================================
  final RxList<Shift> shifts = <Shift>[].obs;
  final RxList<Shift> todayShifts = <Shift>[].obs;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // ==========================================================
  // CALENDAR
  // ==========================================================
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> currentMonth = DateTime.now().obs;

  String? _token;

  // ==========================================================
  // LIVE COUNTDOWN TICKER (✅ ADDED)
  // ==========================================================
  Timer? _countdownTimer;
  final RxInt _tick = 0.obs;

  // ==========================================================
  // INIT
  // ==========================================================
  @override
  void onInit() {
    super.onInit();
    _bootstrap();
    _startCountdownTicker(); // ✅ START LIVE TIMER
  }

  @override
  void onClose() {
    _countdownTimer?.cancel(); // ✅ CLEANUP
    super.onClose();
  }

  void _startCountdownTicker() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick.value++; // forces reactive rebuild every second
    });
  }

  Future<void> _bootstrap() async {
    _token = await StorageService.getToken();
    if (_token == null || _token!.isEmpty) return;
    await fetchShifts();
  }

  // ==========================================================
  // CALENDAR ACTIONS
  // ==========================================================
  void selectDate(DateTime date) async {
    selectedDate.value = date;
    await fetchShiftsByDate(date);
  }

  void nextMonth() {
    currentMonth.value =
        DateTime(currentMonth.value.year, currentMonth.value.month + 1);
  }

  void previousMonth() {
    currentMonth.value =
        DateTime(currentMonth.value.year, currentMonth.value.month - 1);
  }

  String get monthYearText =>
      DateFormat('MMMM yyyy').format(currentMonth.value).toUpperCase();

  // ==========================================================
  // DASHBOARD FILTER
  // ==========================================================
  void _applyStatusFilter() {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;

    if (currentUserId == null) {
      todayShifts.clear();
      return;
    }

    todayShifts.assignAll(
      shifts.where((s) {
        final claimedUserId = s.claimedBy?['id'];
        if (claimedUserId != currentUserId) return false;

        // ✅ now only removes COMPLETED shifts
        if (_isShiftExpired(s)) return false;

        return s.status == 2 || s.status == 3 || s.status == 4 || s.status == 5;
      }).toList(),
    );
  }

  // ==========================================================
  // NEXT UPCOMING SHIFT
  // ==========================================================
  Shift? get nextUpcomingShift {
    final now = DateTime.now();

    for (final s in todayShifts) {
      if (s.status != 3) continue;

      final start = _parseShiftDateTime(s.date, s.startTime);
      if (start != null && start.isAfter(now)) {
        return s;
      }
    }
    return null;
  }

  // ==========================================================
  // COUNTDOWN (HH : MM : SS) — LIVE
  // ==========================================================
  Duration get upcomingShiftCountdown {
    _tick.value; // 👈 makes it LIVE

    final shift = nextUpcomingShift;
    if (shift == null) return Duration.zero;

    final start = _parseShiftDateTime(shift.date, shift.startTime);
    if (start == null) return Duration.zero;

    return start.difference(DateTime.now());
  }

  DateTime? _parseShiftDateTime(String? date, String? time) {
    if (date == null || time == null) return null;

    try {
      final d = DateFormat('yyyy-MM-dd').parse(date);
      final t = DateFormat('h:mm a').parse(time);

      return DateTime(d.year, d.month, d.day, t.hour, t.minute);
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // UPCOMING SHIFT HELPERS (USED BY HOME UI)
  // ==========================================================
  bool get hasUpcomingShiftSoon {
    _tick.value; // 👈 reactive
    final d = upcomingShiftCountdown;
    return d > Duration.zero && d.inHours < 2;
  }

  String get upcomingShiftCountdownText {
    _tick.value;

    final d = upcomingShiftCountdown;
    if (d <= Duration.zero) return '0h 0m 0s';

    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    return '${hours}h ${minutes}m ${seconds}s';
  }

  // ==========================================================
  // SHIFT OVERLAP CHECK
  // ==========================================================
  bool hasOverlap(Shift newShift) {
    return shifts.any((s) {
      if (s.date != newShift.date) return false;

      // ✅ 1. IGNORE EXPIRED SHIFTS (missed / ended)
      if (_isShiftExpired(s)) return false;

      // ✅ 2. ONLY APPROVED (3) or IN-PROGRESS (4) CAN BLOCK
      if (!(s.status == 3 || s.status == 4)) return false;

      // ❌ pending (2) does NOT block
      // ❌ expired shifts do NOT block

      return _isTimeOverlapping(
        s.startTime,
        s.endTime,
        newShift.startTime,
        newShift.endTime,
      );
    });
  }

  bool _isTimeOverlapping(
    String? start1,
    String? end1,
    String? start2,
    String? end2,
  ) {
    if (start1 == null || end1 == null || start2 == null || end2 == null) {
      return false;
    }

    final format = DateFormat('h:mm a');
    final s1 = format.parse(start1);
    final e1 = format.parse(end1);
    final s2 = format.parse(start2);
    final e2 = format.parse(end2);

    return s1.isBefore(e2) && s2.isBefore(e1);
  }

  // ==========================================================
  // STATUS GETTERS
  // ==========================================================
  List<Shift> get pendingApprovalShifts =>
      todayShifts.where((s) => s.status == 2).toList();

  List<Shift> get upcomingShifts =>
      todayShifts.where((s) => s.status == 3).toList();

  List<Shift> get inProgressShifts =>
      todayShifts.where((s) => s.status == 4).toList();

  List<Shift> get availableShifts =>
      shifts.where((s) => s.status == 1).toList();

  // ==========================================================
  // REQUIRED BY SHIFT DETAILS SCREEN
  // ==========================================================
  Future<Shift?> getShiftDetail(int shiftId) async {
    try {
      return shifts.firstWhere((s) => s.id == shiftId);
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // API — GET SHIFTS
  // ==========================================================
  Future<void> fetchShifts() async {
    if (_token == null) return;

    isLoading.value = true;
    error.value = '';

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final result = await WorkerService.getShifts(_token!, date: today);

    if (result.success) {
      shifts.assignAll(result.data ?? []);
      _applyStatusFilter();
    } else {
      error.value = result.message ?? 'Failed to load shifts';
    }

    isLoading.value = false;
  }

  Future<void> fetchShiftsByDate(DateTime date) async {
    if (_token == null) return;

    isLoading.value = true;
    error.value = '';

    final formatted = DateFormat('yyyy-MM-dd').format(date);

    final result = await WorkerService.getShifts(_token!, date: formatted);

    if (result.success) {
      shifts.assignAll(result.data ?? []);
      _applyStatusFilter();
    } else {
      error.value = result.message ?? 'Failed to load shifts';
    }

    isLoading.value = false;
  }

  // ==========================================================
  // ACTIONS
  // ==========================================================
  Future<void> claimShift(int shiftId) async {
    if (_token == null) return;

    final result = await WorkerService.claimShift(
      _token!,
      ClaimShiftRequest(shiftId: shiftId),
    );

    if (result.success) {
      await fetchShiftsByDate(selectedDate.value);
      Get.snackbar('Success', 'Shift claimed');
    } else {
      Get.snackbar('Error', result.message ?? 'Claim failed');
    }
  }

  Future<void> checkInShift(int shiftId) async {
    if (_token == null) return;
    await WorkerService.shiftCheckIn(
      _token!,
      ShiftCheckInRequest(shiftId: shiftId),
    );
    await fetchShiftsByDate(selectedDate.value);
  }

  Future<void> checkOutShift(int shiftId) async {
    if (_token == null) return;
    await WorkerService.checkoutShift(
      _token!,
      CheckoutShiftRequest(shiftId: shiftId),
    );
    await fetchShiftsByDate(selectedDate.value);
  }

  bool _isShiftExpired(Shift s) {
    // ❌ Do NOT expire shifts that still need action
    // Only remove AFTER supervisor verification / completion

    // Assuming:
    // status 5 = completed / supervisor verified
    return s.status == 5;
  }

  Future<bool> claimShiftFromDetail(int shiftId) async {
    if (_token == null) return false;

    isLoading.value = true;

    final result = await WorkerService.claimShift(
      _token!,
      ClaimShiftRequest(shiftId: shiftId),
    );

    isLoading.value = false;

    if (result.success) {
      await fetchShiftsByDate(selectedDate.value);
      return true; // ✅ success
    } else {
      Get.snackbar('Error', result.message ?? 'Claim failed');
      return false; // ✅ failure
    }
  }
}
