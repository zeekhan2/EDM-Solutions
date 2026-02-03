import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:edm_solutions/views/FacilityApp/Home/dashboard.dart';

class PostShiftSuccessScreen extends StatefulWidget {
  const PostShiftSuccessScreen({super.key});

  @override
  State<PostShiftSuccessScreen> createState() =>
      _PostShiftSuccessScreenState();
}

class _PostShiftSuccessScreenState extends State<PostShiftSuccessScreen> {
  static const navy = Color(0xFF173B7A);
  bool _loading = false;

  Future<void> _goHomeAndReload() async {
    if (_loading) return;

    setState(() => _loading = true);

    /// ✅ Navigate to dashboard and tell it to refresh itself
    Get.offAll(
      () => const DashboardScreen(),
      arguments: {'refresh': true},
    );

    /// Loader stops (dashboard will handle its own loading)
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// MAIN CONTENT
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// SUCCESS ICON
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF22C55E),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// TEXT
                    const Text(
                      '✅ Shift Posted\nSuccessfully',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: navy,
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// BACK TO HOME
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _loading ? null : _goHomeAndReload,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// FULL SCREEN LOADER
            if (_loading)
              Container(
                color: Colors.black.withOpacity(0.25),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: navy,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
