// payment_success.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Home/dashboard.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);
    const navy = Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEFFCF0)),
                  child: const Center(
                    child: Icon(Icons.check, size: 44, color: green),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Payment successful', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {
                    // Back to home (clear stack)
                    Get.offAll(() => const DashboardScreen());
                  },
                  icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white),
                  label: const Text('Back to Home', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
