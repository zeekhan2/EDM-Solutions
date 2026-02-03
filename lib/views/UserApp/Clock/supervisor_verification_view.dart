import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

import '../../../models/shift_models.dart';
import '../../../controllers/verification_controller.dart';

class SupervisorVerificationView extends StatelessWidget {
  final Shift shift;

  const SupervisorVerificationView({super.key, required this.shift});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerificationController(shift));

    final SignatureController signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    final supervisorName =
        shift.facility?['full_name'] ?? 'Supervisor';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Verification',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            /// TITLE
            const Text(
              'Supervisor Shift\nverification',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A8A),
              ),
            ),

            const SizedBox(height: 12),

            /// DESCRIPTION
            Text(
              'I Confirm That ${shift.claimedBy?['name'] ?? 'Worker'} '
              'Worked The Shift Scheduled\n'
              'On ${DateFormat('MMMM dd, yyyy').format(DateTime.now())} '
              'At ${shift.startTime ?? ''}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 32),

            /// SIGNATURE PAD
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Signature(
                controller: signatureController,
                backgroundColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 8),

            /// CLEAR SIGNATURE
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => signatureController.clear(),
                child: const Text(
                  'Clear Signature',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// SUPERVISOR NAME
            Text(
              supervisorName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A8A),
              ),
            ),

            const Spacer(),

            /// CONFIRM BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (signatureController.isEmpty) {
                    Get.snackbar(
                      'Signature Required',
                      'Please provide supervisor signature',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  // 🔹 Export signature as PNG
                  Uint8List? signatureBytes =
                      await signatureController.toPngBytes();

                  if (signatureBytes == null) return;

                  // ✅ You can now send signatureBytes to backend later
                  controller.confirmVerification(
                    signature: signatureBytes,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirm Verification →',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
