import 'package:edm_solutions/services/safe_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/worker_service.dart';
import '../../../services/storage_service.dart';
import '../../../models/payment_history.dart';

class PaymentsController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxList<PaymentHistory> payments = <PaymentHistory>[].obs;

  final RxDouble currentMonthEarnings = 0.0.obs;
  final RxDouble lastMonthEarnings = 0.0.obs;

  int get completedShifts =>
      payments.where((p) => p.status == 'completed').length;

  @override
  void onInit() {
    super.onInit();
    loadPayments();
  }

  Future<void> loadPayments() async {
    isLoading.value = true;

    try {
      final token = await StorageService.getToken();

      //  FIX: prevent loading from getting stuck
      if (token == null || token.isEmpty) {
        isLoading.value = false;
        return;
      }

      final response = await WorkerService.getPaymentHistory(token);

      if (!response.success || response.data == null) {
        debugPrint(
          'Payments error: ${response.message}',
        );

        return;
      }

      final body = response.data as Map<String, dynamic>;

      currentMonthEarnings.value =
          double.tryParse(body['current_month_earnings']?.toString() ?? '0') ??
              0;

      lastMonthEarnings.value =
          double.tryParse(body['last_month_earnings']?.toString() ?? '0') ?? 0;

      final List list = body['data'] ?? [];

      payments.assignAll(
        list.map((e) => PaymentHistory.fromJson(e)).toList(),
      );
    } catch (e) {
      SafeSnackbar.show('Error', 'Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }
}

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentsController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Payments',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= SUMMARY =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Month',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${controller.currentMonthEarnings.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${controller.completedShifts} shifts completed',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Payment History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                ),
              ),

              const SizedBox(height: 16),

              if (controller.payments.isEmpty)
                const Text('No payment history found'),

              ...controller.payments.map(_buildPaymentCard).toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPaymentCard(PaymentHistory p) {
    final isCompleted = p.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.shiftTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _statusChip(p.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            p.shiftDate,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Hours: ${p.totalHours}'),
              const SizedBox(width: 16),
              Text('Rate: \$${p.rate.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Total: \$${p.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(height: 6),
            Text(
              'Paid on ${p.createdAt}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.green,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final isCompleted = status == 'completed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFE6FBEE) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color:
              isCompleted ? const Color(0xFF1B9E4A) : const Color(0xFF856404),
        ),
      ),
    );
  }
}
