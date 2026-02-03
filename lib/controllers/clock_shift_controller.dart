import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/shift_models.dart';
import '../models/worker_shift_requests.dart';
import '../services/worker_service.dart';
import '../services/storage_service.dart';

import '../views/UserApp/Clock/clock_in_success_view.dart';
import '../views/UserApp/Clock/supervisor_verification_view.dart';

class ClockShiftController extends GetxController {
  final Shift shift;
  ClockShiftController(this.shift);

  // =========================================================
  // 🔴 FEATURE FLAG — TEMP DISABLE GEOFENCE
  // =========================================================
  static const bool ENABLE_GEOFENCE = false;

  // ================= STATE =================
  final RxBool isClockedIn = false.obs;
  final RxBool isClockedOut = false.obs;

  final RxBool locationGranted = false.obs;
  final RxBool isWithinGeofence = true.obs; // default true (safe)
  final RxBool isWithinShiftTime = false.obs;

  final RxString timerText = '00:00:00'.obs;

  // ================= LIVE LOCATION =================
  final RxDouble currentLat = 0.0.obs;
  final RxDouble currentLng = 0.0.obs;
  final Rx<GoogleMapController?> mapController = Rx<GoogleMapController?>(null);

  bool _cameraMovedOnce = false;

  LatLng? get currentLatLng =>
      (currentLat.value != 0.0 && currentLng.value != 0.0)
          ? LatLng(currentLat.value, currentLng.value)
          : null;

  StreamSubscription<Position>? _positionSub;
  Timer? _timer;
  DateTime? _clockInAt;
  String? _token;

  // Backend-approved location (kept for future)
  double? approvedLat;
  double? approvedLng;
  double? approvedRadius;

  final Duration earlyGrace = const Duration(minutes: 15);

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _token = await StorageService.getToken();
    if (_token == null) return;

    await _restoreClockIn(); // 🔥 timer restore
    await _initLocationFlow(); // permission + GPS
    _checkShiftTime(); // shift window
  }

  // ================= RESTORE CLOCK-IN (PERSISTENT TIMER) =================
  Future<void> _restoreClockIn() async {
    final saved = await StorageService.getClockInTime();
    if (saved != null) {
      _clockInAt = saved;
      isClockedIn.value = true;
      _startTimer(); // 🔥 resumes correctly after app kill
    }
  }

  // ================= LOCATION FLOW =================
  Future<void> _initLocationFlow() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      locationGranted.value = false;
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      locationGranted.value = false;
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      locationGranted.value = true;

      await _fetchLocationServices();
      await _startLiveLocationTracking();
    }
  }

  // ================= BACKEND LOCATION (DISABLED SAFELY) =================
  Future<void> _fetchLocationServices() async {
    if (!ENABLE_GEOFENCE) {
      isWithinGeofence.value = true;
      return;
    }

    final res = await WorkerService.getLocationServices(_token!);

    if (!res.success || res.data == null || res.data!.isEmpty) {
      isWithinGeofence.value = false;
      return;
    }

    final location = res.data!.first;
    approvedLat = location.latitude;
    approvedLng = location.longitude;
    approvedRadius = 100;
  }

  // ================= LIVE LOCATION =================
  Future<void> _startLiveLocationTracking() async {
    _positionSub?.cancel();

    final initial = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentLat.value = initial.latitude;
    currentLng.value = initial.longitude;
    _checkGeofenceWithPosition(initial);

// MOVE CAMERA ONCE AFTER FIRST FIX
    _moveCameraOnce();

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((position) {
      currentLat.value = position.latitude;
      currentLng.value = position.longitude;
      _checkGeofenceWithPosition(position);
    });
  }

  void _moveCameraOnce() {
    if (_cameraMovedOnce) return;

    final map = mapController.value;
    final latLng = currentLatLng;

    if (map != null && latLng != null) {
      map.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 16),
      );
      _cameraMovedOnce = true;
    }
  }

  // ================= GEOFENCE CHECK =================
  void _checkGeofenceWithPosition(Position position) {
    if (!ENABLE_GEOFENCE) {
      isWithinGeofence.value = true;
      return;
    }

    if (approvedLat == null || approvedLng == null) return;

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      approvedLat!,
      approvedLng!,
    );

    isWithinGeofence.value = distance <= (approvedRadius ?? 100);
  }

  // ================= SHIFT TIME CHECK =================
  void _checkShiftTime() {
    if (shift.startTime == null || shift.endTime == null) {
      isWithinShiftTime.value = false;
      return;
    }

    final now = DateTime.now();
    final start = _parseShiftTime(shift.startTime!);
    final end = _parseShiftTime(shift.endTime!);

    if (start == null || end == null) return;

    final shiftEnd =
        end.isBefore(start) ? end.add(const Duration(days: 1)) : end;

    isWithinShiftTime.value =
        now.isAfter(start.subtract(earlyGrace)) && now.isBefore(shiftEnd);
  }

  DateTime? _parseShiftTime(String time) {
    try {
      final now = DateTime.now();
      final parts = time.split(' ');
      final hm = parts[0].split(':');

      int h = int.parse(hm[0]) % 12;
      if (parts[1].toUpperCase() == 'PM') h += 12;

      return DateTime(now.year, now.month, now.day, h, int.parse(hm[1]));
    } catch (_) {
      return null;
    }
  }

  // ================= BUTTON RULES =================
  bool get canClockIn =>
      locationGranted.value &&
      isWithinGeofence.value &&
      isWithinShiftTime.value &&
      !isClockedIn.value &&
      !isClockedOut.value;

  bool get canClockOut =>
      locationGranted.value &&
      isWithinGeofence.value &&
      isClockedIn.value &&
      !isClockedOut.value;

  // ================= CLOCK IN =================
  Future<void> clockIn() async {
    if (!canClockIn) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final res = await WorkerService.shiftCheckIn(
      _token!,
      ShiftCheckInRequest(
        shiftId: shift.id!,
        location: '${position.latitude},${position.longitude}',
      ),
    );

    if (!res.success) {
      Get.snackbar('Error', res.message ?? 'Clock in failed');
      return;
    }

    // ✅ START TIMER ONLY AFTER SUCCESS
    _clockInAt = DateTime.now();
    isClockedIn.value = true;

    await StorageService.saveClockInTime(_clockInAt!);
    _startTimer();

    Get.off(() => ClockInSuccessView(shift: shift));
  }

  // ================= CLOCK OUT =================
  Future<void> clockOut() async {
    if (!canClockOut) return;

    final res = await WorkerService.checkoutShift(
      _token!,
      CheckoutShiftRequest(shiftId: shift.id!),
    );

    if (!res.success) {
      Get.snackbar('Error', res.message ?? 'Clock out failed');
      return;
    }

    isClockedOut.value = true;
    _stopTimer();

    await StorageService.clearClockInTime();
    Get.off(() => SupervisorVerificationView(shift: shift));
  }

  // ================= TIMER (PERSISTENT) =================
  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_clockInAt == null) return;

      final diff = DateTime.now().difference(_clockInAt!);
      timerText.value =
          '${_two(diff.inHours)}:${_two(diff.inMinutes % 60)}:${_two(diff.inSeconds % 60)}';
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  void onClose() {
    _timer?.cancel();
    _positionSub?.cancel();
    super.onClose();
  }
}
