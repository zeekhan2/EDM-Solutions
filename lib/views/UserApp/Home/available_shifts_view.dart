import 'package:edm_solutions/models/worker_shift_requests.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/shift_models.dart';
import '../../../services/worker_service.dart';
import '../../../services/storage_service.dart';
import 'shift_claimed_view.dart';

class AvailableShiftsController extends GetxController {
  RxList<Shift> shifts = <Shift>[].obs;
  RxList<Shift> filteredShifts = <Shift>[].obs;
  RxString searchQuery = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Delay to ensure MaterialApp is ready for snackbars
    Future.delayed(Duration.zero, () => loadShifts());
  }

  Future<void> loadShifts() async {
    try {
      isLoading.value = true;
      final token = await StorageService.getToken();
      
      if (token == null || token.isEmpty) {
        if (Get.context != null) {
          Get.snackbar(
            'Error',
            'Please login to view shifts',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return;
      }

      final response = await WorkerService.getShifts(token);
      
      if (response.success && response.data != null) {
        shifts.value = response.data ?? [];
        filteredShifts.value = shifts;
      } else {
        // Handle 401 Unauthenticated - token expired
        if (response.message?.contains('Unauthenticated') ?? false) {
          await StorageService.clearAll();
          if (Get.context != null) {
            Get.snackbar(
              'Session Expired',
              'Please login again',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            // Navigate to login
            Get.offAllNamed('/login');
          }
        } else {
          if (Get.context != null) {
            Get.snackbar(
              'Error',
              response.message ?? 'Failed to load shifts',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      }
    } catch (e) {
      print('Error loading shifts: $e');
      if (Get.context != null) {
        Get.snackbar(
          'Error',
          'An error occurred while loading shifts',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void searchShifts(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredShifts.value = shifts;
    } else {
      filteredShifts.value = shifts
          .where((shift) =>
              (shift.licenseType?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (shift.location?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }
  }

  Future<void> claimShift(int shiftId) async {
    try {
      isLoading.value = true;
      final token = await StorageService.getToken();
      
      if (token == null || token.isEmpty) {
        if (Get.context != null) {
          Get.snackbar(
            'Error',
            'Please login to claim shift',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return;
      }

      final request = ClaimShiftRequest(shiftId: shiftId);
      final response = await WorkerService.claimShift(token, request);
      
      if (response.success) {
        if (Get.context != null) {
          Get.snackbar(
            'Success',
            response.message ?? 'Shift claimed successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // Navigate to shift claimed view
          Get.to(() => ShiftClaimedView(shift: Shift()));
        }
        // Reload shifts
        await loadShifts();
      } else {
        if (Get.context != null) {
          Get.snackbar(
            'Error',
            response.message ?? 'Failed to claim shift',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error claiming shift: $e');
      if (Get.context != null) {
        Get.snackbar(
          'Error',
          'An error occurred while claiming shift',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

class AvailableShiftsView extends StatefulWidget {
  const AvailableShiftsView({super.key});

  @override
  State<AvailableShiftsView> createState() => _AvailableShiftsViewState();
}

class _AvailableShiftsViewState extends State<AvailableShiftsView> {
  late AvailableShiftsController controller;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AvailableShiftsController());
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Available Shifts',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              Icons.tune,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  controller.searchShifts(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),

          // Shifts List
          Expanded(
            child: Obx(
              () => controller.filteredShifts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No shifts found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: controller.filteredShifts.length,
                      itemBuilder: (context, index) {
                        final shift = controller.filteredShifts[index];
                        return _buildShiftCard(shift, index);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(Shift shift, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // License Type/Shift Title
          Text(
            shift.licenseType ?? 'Shift',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Location Info
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  shift.location ?? 'Location not specified',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date, Time and Payment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift.createdAt ?? 'TBD',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${shift.startTime ?? ''} - ${shift.endTime ?? ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${shift.payPerHour?.toStringAsFixed(2) ?? '0'}/hr',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (shift.id != null) {
                    controller.claimShift(shift.id!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A), // Dark blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Claim',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
