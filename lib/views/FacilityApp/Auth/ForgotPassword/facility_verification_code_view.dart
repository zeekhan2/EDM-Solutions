import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../../Common_Widgets/safe_snackbar_helper.dart';
import '../../../../consts/colors.dart';
import 'facility_reset_password_view.dart';

class FacilityVerificationCodeView extends StatefulWidget {
  const FacilityVerificationCodeView({super.key});

  @override
  State<FacilityVerificationCodeView> createState() =>
      _FacilityVerificationCodeViewState();
}

class _FacilityVerificationCodeViewState
    extends State<FacilityVerificationCodeView> {
  final AuthController authController = Get.find<AuthController>();

  final List<TextEditingController> otpControllers =
      List.generate(4, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(4, (_) => FocusNode());

  Future<void> _verify() async {
    final otp = otpControllers.map((e) => e.text).join();

    if (otp.length != 4) {
      SafeSnackbarHelper.showSafeSnackbar(
        title: 'Error',
        message: 'Enter 4 digit code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await authController.verifyEmail(
      code: int.parse(otp),
      forgetPassword: true,
    );

    if (success) {
      Get.to(() => const FacilityResetPasswordView());
    }
  }

  Future<void> _resendOtp() async {
    if (authController.verificationEmail.value.isEmpty) return;

    final success = await authController.resendOtp(
      authController.verificationEmail.value,
    );

    if (success) {
      for (var c in otpControllers) {
        c.clear();
      }
      focusNodes.first.requestFocus();
    }
  }

  @override
  void dispose() {
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text("Verification Code"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: [
            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: Image.asset("assets/images/password.png"),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (i) => SizedBox(
                  width: 60,
                  child: TextField(
                    controller: otpControllers[i],
                    focusNode: focusNodes[i],
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (value) {
                      if (value.isNotEmpty && i < 3) {
                        focusNodes[i + 1].requestFocus();
                      }
                      if (value.isEmpty && i > 0) {
                        focusNodes[i - 1].requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: _resendOtp,
              child: Text(
                "Resend Code",
                style: TextStyle(
                  color: appPrimeryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimeryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Verify",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
