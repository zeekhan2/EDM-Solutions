import 'package:edm_solutions/consts/api_constants.dart';
import 'package:edm_solutions/services/safe_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';
import 'package:edm_solutions/services/api_service.dart';
import 'package:edm_solutions/services/storage_service.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final List<Map<String, dynamic>> transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  // ==========================================================
  // FETCH TRANSACTIONS (FACILITY)
  // ==========================================================
  Future<void> _fetchTransactions() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return;

      final response = await ApiService.get(
        endpoint: ApiConstants.getFacilityPaymentHistory,
        token: token,
      );

      if (response.success && response.data != null) {
        final List list = response.data['payments'] ?? [];

        transactions.clear();

        for (final item in list) {
          transactions.add({
            // Shift title
            'title': item['shift']?['title'] ?? 'Payment',

            // Paid date (fallback to shift date)
            'date': _formatDate(
              item['paid_at'] ?? item['shift']?['date'] ?? '',
            ),

            // Amount
            'amount': double.tryParse(item['amount'].toString()) ?? 0,

            // Status
            'status': (item['status'] ?? 'completed').toString().toUpperCase(),
          });
        }
      } else {
        SafeSnackbar.show(
          'Error',
          response.message ?? 'Failed to load transactions',
        );
      }
    } catch (_) {
      SafeSnackbar.show(
        'Error',
        'Something went wrong',
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // ==========================================================
  // HELPERS
  // ==========================================================
  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatCurrency(double v) {
    final n = v.round();
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buf.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buf.write(',');
    }
    return '\$$buf';
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Transactions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: semibold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : transactions.isEmpty
                  ? const Center(child: Text('No transactions found'))
                  : ListView.separated(
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, idx) {
                        final t = transactions[idx];

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      t['date'],
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatCurrency(t['amount']),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6FBEE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      t['status'],
                                      style: const TextStyle(
                                        color: Color(0xFF1B9E4A),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
