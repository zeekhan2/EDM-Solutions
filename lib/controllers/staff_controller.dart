import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffController extends GetxController {
  // ===================== COMMON =====================
  final isLoading = false.obs;
  final error = RxnString();
  RxInt unreadCount = 0.obs;
  final attendanceLoading = false.obs;
  final attendanceList = <Map<String, dynamic>>[].obs;

  // ===================== STAFF =====================
  final staff = <Map<String, dynamic>>[].obs;

  // ===================== REPORT STATS =====================
  final reportLoading = false.obs;

  final totalCost = 0.0.obs;
  final totalShifts = 0.obs;
  final avgRate = 0.0.obs;
  final pendingAmount = 0.0.obs;

  final monthlyShifts = <int>[].obs;
  final costByDepartment = <String, int>{}.obs;
  final roleDistribution = <String, int>{}.obs;

  // ===================== LIFECYCLE =====================
  @override
  void onInit() {
    super.onInit();
    fetchStaff();
  }

  // ===================== NORMALIZE WORKER =====================
  Map<String, dynamic> _normalizeWorker(Map<String, dynamic> w) {
    final String name = (w['name'] ?? '').toString().trim();

    return {
      // REQUIRED
      'id': w['id'],
      'name': name.isNotEmpty ? name : '—',
      'initials': name.isNotEmpty ? name[0].toUpperCase() : '?',

      // OPTIONAL
      'email': w['email'],
      'phone': w['phone'],
      'address': w['address'],
      'city': w['city'],
      'zip': w['zip_code'], // 🔧 API uses zip_code
      'image': (w['image'] is String && w['image'].toString().isNotEmpty)
          ? w['image']
          : null,

      // ✅ UI EXPECTED KEYS (THIS IS THE FIX)
      'rating': w['rating']?.toString() ?? '0.0',
      'total_shifts': w['total_shifts'] ?? 0,
      'experience_years': w['experience_years'] ?? 0,

      // OTHER UI DATA
      'credentials': (w['credentials'] is List) ? w['credentials'] : [],
      'job_title': w['job_title'] ?? '',
      'profile_visibility': w['profile_visibility'] ?? 1,

      // 🔑 REQUIRED FOR CHAT
      'firebase_uid': w['firebase_uid'],

      // INTERNAL
      'invited': false,
    };
  }

  // ===================== FETCH STAFF =====================
  Future<void> fetchStaff() async {
    try {
      isLoading.value = true;
      error.value = null;

      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        error.value = 'Session expired';
        return;
      }

      final res = await ApiService.get(
        endpoint: '/api/get/workers-list',
        token: token,
      );

      if (res.success == true && res.data != null) {
        final List raw = res.data['workers'] ?? [];

        staff.assignAll(
          raw.map<Map<String, dynamic>>((w) => _normalizeWorker(w)),
        );
      } else {
        error.value = res.message ?? 'Failed to load staff';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

//--------unread count-------
  void listenUnreadMessages(String facilityFirebaseUid) {
    FirebaseFirestore.instance
        .collection('chat_rooms')
        .where('facility_uid', isEqualTo: facilityFirebaseUid)
        .snapshots()
        .listen((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        total += (doc['unread_facility'] ?? 0) as int;
      }
      unreadCount.value = total;
    });
  }

  // ===================== SEND INVITATION =====================
  Future<bool> sendShiftInvitation({
    required int workerId,
    required int shiftId,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return false;

      final res = await ApiService.post(
        endpoint: '/api/send/shift-invitations',
        token: token,
        body: {
          'worker_id': workerId,
          'shift_id': shiftId,
        },
      );

      return res.success == true;
    } catch (_) {
      return false;
    }
  }
}
