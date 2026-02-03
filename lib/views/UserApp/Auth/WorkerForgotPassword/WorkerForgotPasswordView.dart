import 'package:edm_solutions/views/Common/email_verification_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../consts/colors.dart';
import '../../../../controllers/auth_controller.dart';

class WorkerForgotPasswordView extends StatefulWidget {
  const WorkerForgotPasswordView({super.key});

  @override
  State<WorkerForgotPasswordView> createState() =>
      _WorkerForgotPasswordViewState();
}

class _WorkerForgotPasswordViewState extends State<WorkerForgotPasswordView> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();

  String? emailError;

  Future<void> _handleForgotPassword() async {
    if (authController.isLoading.value) return;

    setState(() => emailError = null); // clear old error

    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        emailError = 'Please enter your email address';
      });
      return;
    }

    final success = await authController.forgetPassword(email);

    if (!success) {
      // ❌ INVALID EMAIL / USER NOT FOUND
      setState(() {
        emailError = 'This email does not exist';
      });
      return;
    }

    // ✅ SUCCESS → NAVIGATE
    if (mounted) {
      Get.to(() => const EmailVerificationView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            SizedBox(
              height: 210,
              child: Image.asset(
                "assets/images/password.png",
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Forgot password",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: appPrimeryColor,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Enter e-mail for verification. A 4-digit\ncode will be sent to your email.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 35),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Enter Email Address for Recovery",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Email Address",
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: appPrimeryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // ✅ INLINE ERROR MESSAGE
            if (emailError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    emailError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appPrimeryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 14),
                  ),
                  onPressed: () {
                    if (!authController.isLoading.value) {
                      _handleForgotPassword();
                    }
                  },
                  child: authController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward,
                                size: 18, color: Colors.white),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
