import 'dart:ui';
import 'package:edm_solutions/views/UserApp/Auth/WorkerForgotPassword/WorkerResetPasswordView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../consts/buttons.dart';
import '../../../../consts/colors.dart';
// ⭐ Reusable Button

class WorkerVerificationCodeView extends StatefulWidget {
  const WorkerVerificationCodeView({super.key});

  @override
  State<WorkerVerificationCodeView> createState() =>
      _WorkerVerificationCodeViewState();
}

class _WorkerVerificationCodeViewState
    extends State<WorkerVerificationCodeView> {
  final List<TextEditingController> codeControllers =
  List.generate(4, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black),
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

      body: Stack(
        children: [
          // 🖼 Background image (password.png)
          Positioned.fill(
            child: Image.asset(
              "assets/images/password.png",
              fit: BoxFit.contain,
            ),
          ),

          // Blur overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ),

          // Bottom Sheet Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 22, vertical: 32),
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
                  // Drag handle
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Title
                  Text(
                    "Enter 4 Digit Code",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: appPrimeryColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Enter the 4 digit code that was sent to\nyour email.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // OTP Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) => _otpBox(index)),
                  ),

                  const SizedBox(height: 45),

                  // ⭐ Continue Button (Reusable)
                  PrimaryButton(

                    onPressed: () {
                      Get.to(WorkerResetPasswordView());
                    },
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

  // OTP Box Builder
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
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
