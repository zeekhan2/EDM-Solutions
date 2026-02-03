import 'dart:async';
import 'dart:ui';
import 'package:edm_solutions/views/UserApp/UploadDoc/UploadDocumnetationView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/controllers/auth_controller.dart';
import '../../consts/buttons.dart';
import '../../consts/colors.dart';
import '../UserApp/Auth/WorkerForgotPassword/WorkerResetPasswordView.dart';
import '../FacilityApp/Home/dashboard.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  final AuthController authController = Get.find<AuthController>();

  final List<TextEditingController> codeControllers =
      List.generate(4, (_) => TextEditingController());

  bool isLoading = false;
  String? otpError;
  int resendSeconds = 0;
  Timer? resendTimer;

  @override
  void dispose() {
    resendTimer?.cancel();
    for (var controller in codeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getEnteredCode() {
    return codeControllers.map((c) => c.text).join('');
  }

  Future<void> _handleContinue() async {
    final code = _getEnteredCode();

    if (code.length != 4 || int.tryParse(code) == null) {
      setState(() {
        otpError = 'Please enter a valid 4-digit code';
      });
      return;
    }

    setState(() {
      isLoading = true;
      otpError = null; // ✅ clear previous error
    });

    final bool success = await authController.verifyEmail(
      code: int.parse(code),
      forgetPassword: authController.isForgetPassword.value,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    // ❌ WRONG OTP
    if (!success) {
      setState(() {
        otpError = 'Invalid or expired verification code';
      });
      return;
    }

    // ================= FORGOT PASSWORD FLOW =================
    if (authController.isForgetPassword.value) {
      Get.offAll(() => const WorkerResetPasswordView());
      return;
    }

    // ================= SIGN-UP FLOW =================
    final String role = authController.role.value;

    if (role == 'worker_mode') {
      Get.offAll(() => const UploadDocumnetationView());
    } else if (role == 'facility_mode') {
      Get.offAll(() => DashboardScreen());
    } else {
      Get.snackbar(
        'Error',
        'Invalid role. Please login again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleResendCode() async {
    if (resendSeconds > 0) return;

    final email = authController.verificationEmail.value;

    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Email not found. Please go back and try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final success = await authController.resendOtp(email);

    if (success) {
      for (var controller in codeControllers) {
        controller.clear();
      }

      setState(() {
        otpError = null; // ✅ clear error on resend
        resendSeconds = 30;
      });

      resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (resendSeconds == 0) {
          timer.cancel();
        } else {
          setState(() => resendSeconds--);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            authController.isForgetPassword.value
                ? "Forgot Password"
                : "Verify Email",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/password.png", fit: BoxFit.contain),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.white.withOpacity(0.4)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Enter 4 Digit Code",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: appPrimeryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => Text(
                      authController.isForgetPassword.value
                          ? "Enter the 4 digit code that was sent to\nyour email to reset your password."
                          : "Enter the 4 digit code that was sent to\nyour email to verify your account.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) => _otpBox(index)),
                  ),

                  // ✅ ERROR MESSAGE (NO UI CHANGE)
                  if (otpError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      otpError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: resendSeconds == 0 ? _handleResendCode : null,
                    child: Text(
                      resendSeconds == 0
                          ? "Didn't receive code? Resend"
                          : "Resend in ${resendSeconds}s",
                      style: TextStyle(
                        fontSize: 14,
                        color: resendSeconds == 0
                            ? const Color(0xFF007AFF)
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : PrimaryButton(
                          onPressed: _handleContinue,
                          label: 'Continue',
                          icon: Icons.arrow_forward,
                        ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpBox(int index) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffE6E6E6), width: 1.4),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: codeControllers[index],
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}
