import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/worker_service.dart';
import '../../../services/storage_service.dart';
import '../../../models/worker_models.dart';

class EditBankDetailsView extends StatefulWidget {
  final BankAccount? bankAccount;
  const EditBankDetailsView({super.key, this.bankAccount});

  @override
  State<EditBankDetailsView> createState() => _EditBankDetailsViewState();
}

class _EditBankDetailsViewState extends State<EditBankDetailsView> {
  final _formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  late final TextEditingController holder;
  late final TextEditingController bank;
  late final TextEditingController account;
  late final TextEditingController routing;

  @override
  void initState() {
    super.initState();
    holder = TextEditingController(
        text: widget.bankAccount?.accountHolderName ?? '');
    bank = TextEditingController(
        text: widget.bankAccount?.bankName ?? '');
    account = TextEditingController(
        text: widget.bankAccount?.accountNumber ?? '');
    routing = TextEditingController(
        text: widget.bankAccount?.routingNumber ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final token = await StorageService.getToken();
      if (token == null) return;

      final req = BankAccountRequest(
        bankName: bank.text.trim(),
        accountHolderName: holder.text.trim(),
        accountNumber: account.text.trim(),
        routingNumber: routing.text.trim(),
      );

      final res = await WorkerService.addBankAccount(token, req);

      if (res.success) {
        Get.back(result: true);
      } else {
        Get.snackbar('Error', res.message ?? 'Failed');
      }
    } finally {
      isLoading.value = false;
    }
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
            color: Color(0xFF1E3A8A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field('Account Holder', holder),
              const SizedBox(height: 18),

              _field('Bank Name', bank),
              const SizedBox(height: 18),

              _field('Account Number', account),
              const SizedBox(height: 18),

              _field('Routing Number', routing),
              const SizedBox(height: 40),

              Center(
                child: Obx(
                  () => SizedBox(
                    width: 180,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: isLoading.value ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Saved Record',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
