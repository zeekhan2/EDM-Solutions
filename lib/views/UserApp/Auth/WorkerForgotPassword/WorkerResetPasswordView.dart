import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../consts/buttons.dart';
import '../../../../consts/colors.dart';
import '../../../../controllers/auth_controller.dart';
import '../Login/login_views.dart';

class WorkerResetPasswordView extends StatefulWidget {
  const WorkerResetPasswordView({super.key});

  @override
  State<WorkerResetPasswordView> createState() =>
      _WorkerResetPasswordViewState();
}

class _WorkerResetPasswordViewState extends State<WorkerResetPasswordView> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  /// 🔴 Validation messages
  String? passwordError;
  String? confirmPasswordError;

  /// 👁️ Show / Hide
  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    setState(() {
      passwordError = null;
      confirmPasswordError = null;
    });

    bool hasError = false;

    if (passwordController.text.trim().isEmpty) {
      passwordError = 'Password is required';
      hasError = true;
    } else if (passwordController.text.length < 8) {
      passwordError = 'Password must be at least 8 characters';
      hasError = true;
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      confirmPasswordError = 'Please confirm password';
      hasError = true;
    } else if (passwordController.text != confirmPasswordController.text) {
      confirmPasswordError = 'Passwords do not match';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    final success = await authController.resetPassword(
      password: passwordController.text,
      passwordConfirmation: confirmPasswordController.text,
    );

    if (success) {
      Get.offAll(() => const LoginViews());
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
          Positioned.fill(
            child: Image.asset(
              "assets/images/password.png",
              fit: BoxFit.contain,
            ),
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
              child: SingleChildScrollView(
                child: Column(
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
                      "Set new password\nfor account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: appPrimeryColor,
                      ),
                    ),

                    const SizedBox(height: 35),

                    /// PASSWORD
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Password",
                          style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        hintText: "Enter new password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => showPassword = !showPassword),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: appPrimeryColor),
                        ),
                      ),
                    ),

                    if (passwordError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            passwordError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ),

                    const SizedBox(height: 25),

                    /// CONFIRM PASSWORD
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Confirm Password",
                          style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !showConfirmPassword,
                      decoration: InputDecoration(
                        hintText: "Re-enter password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() =>
                              showConfirmPassword = !showConfirmPassword),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: appPrimeryColor),
                        ),
                      ),
                    ),

                    if (confirmPasswordError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            confirmPasswordError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),

                    Obx(() => PrimaryButton(
                          label: authController.isLoading.value
                              ? "Updating..."
                              : "Update Password",
                          icon: Icons.arrow_forward,
                          onPressed: authController.isLoading.value
                              ? () {}
                              : _handleResetPassword,
                        )),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
