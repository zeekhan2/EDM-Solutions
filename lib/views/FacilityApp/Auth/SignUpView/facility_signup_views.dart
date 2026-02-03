import 'package:edm_solutions/consts/consts.dart';
import 'package:edm_solutions/Common_Widgets/custom_textfield.dart';
import 'package:edm_solutions/Common_Widgets/our_button.dart';
import 'package:edm_solutions/views/Common/email_verification_view.dart';
import 'package:edm_solutions/views/FacilityApp/Auth/Login/facility_login_views.dart';
import 'package:edm_solutions/views/FacilityApp/Home/dashboard.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../Common_Widgets/SocialLoginButton.dart';
import '../../../../controllers/auth_controller.dart';

class FacilitySignupView extends StatefulWidget {
  const FacilitySignupView({super.key});

  @override
  State<FacilitySignupView> createState() => _FacilitySignupViewState();
}

class _FacilitySignupViewState extends State<FacilitySignupView> {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;

  Future<void> _handleSignup() async {
    authController.authErrorMessage.value = '';
    if (authController.isLoading.value) return;

    setState(() {
      emailError = null;
      phoneError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    bool hasError = false;

    // ================= FRONTEND VALIDATION =================

    if (!GetUtils.isEmail(emailController.text.trim())) {
      emailError = 'Invalid email address';
      hasError = true;
    }

    if (phoneController.text.trim().length < 10) {
      phoneError = 'Invalid phone number';
      hasError = true;
    }

    if (passwordController.text.length < 6) {
      passwordError = 'Password must be at least 6 characters';
      hasError = true;
    }

    if (passwordController.text != confirmPasswordController.text) {
      confirmPasswordError = 'Passwords do not match';
      hasError = true;
    }

    // 🔴 SHOW ALL ERRORS AT ONCE
    if (hasError) {
      setState(() {});
      return;
    }

    // ================= API CALL =================
    final success = await authController.register(
      role: 'facility_mode',
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      password: passwordController.text,
      passwordConfirmation: confirmPasswordController.text,
    );

    if (success && mounted) {
      authController.isForgetPassword.value = false;
      Get.to(() => const EmailVerificationView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FacilitySignUpText,
          style: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.heightBox,

            /// 🔴 BACKEND ERROR MESSAGE
            Obx(() {
              final msg = authController.authErrorMessage.value;
              if (msg.isEmpty) return const SizedBox();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        msg,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: Colors.red.shade700, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        authController.authErrorMessage.value = '';
                      },
                    ),
                  ],
                ),
              );
            }),

            CustomTextField(
              title: username,
              hint: "Enter your full name",
              controller: nameController,
            ),

            10.heightBox,
            CustomTextField(
              title: email,
              hint: "Enter your email",
              controller: emailController,
              errorText: emailError,
            ),

            10.heightBox,
            CustomTextField(
              title: phone,
              hint: "Enter your phone number",
              controller: phoneController,
              errorText: phoneError,
            ),

            10.heightBox,
            CustomTextField(
              title: password,
              hint: "Enter your password",
              controller: passwordController,
              isPass: true,
              errorText: passwordError,
            ),

            10.heightBox,
            CustomTextField(
              title: confrimPassword,
              hint: "Re-enter your password",
              controller: confirmPasswordController,
              isPass: true,
              errorText: confirmPasswordError,
            ),

            20.heightBox,

            Center(
              child: Obx(
                () => AppButton(
                  text: authController.isLoading.value
                      ? "Signing Up..."
                      : "Sign Up",
                  onPressed:
                      authController.isLoading.value ? () {} : _handleSignup,
                  width: 281,
                  height: 57,
                  color: appPrimeryColor,
                  textColor: appSeconderyColor,
                  borderRadius: 50,
                  borderColor: appPrimeryColor,
                ),
              ),
            ),

            15.heightBox,
            Center(
              child: Text("or continue with")
                  .text
                  .color(textColor)
                  .make(),
            ),

            10.heightBox,
            Row(
              children: [
                SocialLoginButton(
                  text: "Google",
                  assetPath: g,
                  onPressed: () async {
                    final success =
                        await authController.googleSignup(
                      selectedRole: 'facility_mode',
                    );

                    if (success && mounted) {
                      Get.offAll(() => DashboardScreen());
                    }
                  },
                ),
                SocialLoginButton(
                  text: "Apple",
                  assetPath: a,
                  onPressed: () {},
                ),
              ],
            ),

            20.heightBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Have an account?")
                    .text
                    .fontFamily(regular)
                    .make(),
                5.widthBox,
                InkWell(
                  onTap: () {
                    Get.to(() => FacilityLoginViews());
                  },
                  child: Text("Log in")
                      .text
                      .color(appPrimeryColor)
                      .fontFamily(regular)
                      .make(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
