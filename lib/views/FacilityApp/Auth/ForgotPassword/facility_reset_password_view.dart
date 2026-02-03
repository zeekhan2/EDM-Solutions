import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../../consts/colors.dart';
import '../../../../consts/buttons.dart';
import '../Login/facility_login_views.dart';

class FacilityResetPasswordView extends StatefulWidget {
  const FacilityResetPasswordView({super.key});

  @override
  State<FacilityResetPasswordView> createState() =>
      _FacilityResetPasswordViewState();
}

class _FacilityResetPasswordViewState
    extends State<FacilityResetPasswordView> {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _loading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  String? passwordError;
  String? confirmPasswordError;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_loading) return;

    setState(() {
      passwordError = null;
      confirmPasswordError = null;
    });

    bool hasError = false;

    if (passwordController.text.trim().isEmpty) {
      passwordError = 'Please enter new password';
      hasError = true;
    } else if (passwordController.text.length < 6) {
      passwordError = 'Password must be at least 6 characters';
      hasError = true;
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      confirmPasswordError = 'Please confirm your password';
      hasError = true;
    } else if (passwordController.text !=
        confirmPasswordController.text) {
      confirmPasswordError = 'Passwords do not match';
      hasError = true;
    }

    if (authController.verificationEmail.value.isEmpty) {
      passwordError = 'Session expired. Please restart reset flow';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _loading = true);

    final success = await authController.resetPassword(
      password: passwordController.text.trim(),
      passwordConfirmation: confirmPasswordController.text.trim(),
    );

    if (mounted) {
      setState(() => _loading = false);
    }

    if (success) {
      Get.snackbar(
        'Success',
        'Password reset successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      authController.isForgetPassword.value = false;
      authController.verificationEmail.value = '';

      Future.delayed(const Duration(seconds: 1), () {
        Get.offAll(() => const FacilityLoginViews());
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Reset Password",
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
              child: Container(
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ),

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
              child: SingleChildScrollView(
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

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Password"),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        hintText: "Enter new password",
                        errorText: passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Confirm Password"),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      decoration: InputDecoration(
                        hintText: "Re-enter password",
                        errorText: confirmPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _showConfirmPassword =
                                  !_showConfirmPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    PrimaryButton(
                      label:
                          _loading ? "Updating..." : "Update Password",
                      icon: Icons.arrow_forward,
                      onPressed:
                          _loading ? () {} : _handleResetPassword,
                    ),
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
