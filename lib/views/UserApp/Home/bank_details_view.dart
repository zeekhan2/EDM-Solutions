import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../services/worker_service.dart';
import '../../../services/storage_service.dart';
import '../../../models/worker_models.dart';
import 'edit_bank_details_view.dart';

class BankDetailsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isOnboarding = false.obs;

  final Rx<BankAccount?> bankAccount = Rx<BankAccount?>(null);
  final RxString onboardingUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBankAccount();
  }

  Future<void> loadBankAccount() async {
    isLoading.value = true;

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return;

      final response = await WorkerService.getBankAccount(token);

      if (response.success) {
        bankAccount.value = response.data;
      } else {
        bankAccount.value = null;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ================= WORKER ONBOARD =================
  Future<void> startOnboarding() async {
    if (isOnboarding.value) return;

    isOnboarding.value = true;
    onboardingUrl.value = '';

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return;

      final response = await WorkerService.workerOnboard(token);

      if (response.success) {
        onboardingUrl.value =
            response.data?['data']?['onboarding_url']?.toString() ?? '';

        if (onboardingUrl.value.isEmpty) {
          Get.snackbar('Error', 'Onboarding link not found in response');
        }
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to start onboarding',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isOnboarding.value = false;
    }
  }

  Future<void> openOnboardingLink() async {
    final url = onboardingUrl.value;
    if (url.isEmpty) return;

    final uri = Uri.parse(url);

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // fallback without snackbar (see issue 2)
      debugPrint('Failed to launch URL: $e');
    }
  }
}

class BankDetailsView extends StatefulWidget {
  const BankDetailsView({super.key});

  @override
  State<BankDetailsView> createState() => _BankDetailsViewState();
}

class _BankDetailsViewState extends State<BankDetailsView> {
  late final BankDetailsController controller;
  static const navy = Color(0xFF1E3A8A);

  @override
  void initState() {
    super.initState();
    controller = Get.put(BankDetailsController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Bank Details',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: navy),
          );
        }

        final bank = controller.bankAccount.value;

        // ================= NO BANK =================
        if (bank == null) {
          return Center(
            child: ElevatedButton(
              onPressed: () async {
                final ok = await Get.to(() => const EditBankDetailsView());
                if (ok == true) controller.loadBankAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Add Bank Account',
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          );
        }

        // ================= BANK DETAILS =================
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bank Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: navy,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _item('Account Holder', bank.accountHolderName),
                    const SizedBox(height: 14),
                    _item('Bank Name', bank.bankName),
                    const SizedBox(height: 14),
                    _item('Account Number', _mask(bank.accountNumber)),
                    const SizedBox(height: 14),
                    _item('Routing Number', _mask(bank.routingNumber)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ================= EDIT =================
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await Get.to(
                      () => EditBankDetailsView(bankAccount: bank),
                    );
                    if (ok == true) controller.loadBankAccount();
                  },
                  icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                  label: const Text(
                    'Edit Bank Details',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ================= WORKER ONBOARD =================
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: controller.isOnboarding.value
                            ? null
                            : controller.startOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isOnboarding.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Connect to Stripe',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      if (controller.onboardingUrl.value.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Text(
                          'Click the link to connect your account to Stripe',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: controller.openOnboardingLink,
                          child: Text(
                            controller.onboardingUrl.value,
                            style: const TextStyle(
                              color: navy,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  )),
            ],
          ),
        );
      }),
    );
  }

  Widget _item(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value ?? '-',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ],
    );
  }

  String _mask(String? v) =>
      v == null || v.length < 4 ? '-' : '••••${v.substring(v.length - 4)}';
}
