import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:edm_solutions/consts/images.dart';
import 'package:edm_solutions/consts/styles.dart';

import '../../../../Common_Widgets/SocialLoginButton.dart';
import '../../../../Common_Widgets/custom_textfield.dart';
import '../../../../Common_Widgets/our_button.dart';
import '../../../../consts/colors.dart';
import '../../../../consts/strings.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../services/storage_service.dart';
import '../../Home/dashboard.dart';
import '../SignUpView/facility_signup_views.dart';
import '../ForgotPassword/facility_forgot_password_view.dart';

class FacilityLoginViews extends StatefulWidget {
  const FacilityLoginViews({super.key});

  @override
  State<FacilityLoginViews> createState() => _FacilityLoginViewsState();
}

class _FacilityLoginViewsState extends State<FacilityLoginViews> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  bool rememberMe = false;

  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final savedEmail = await StorageService.getEmail();
    if (savedEmail != null && mounted) {
      emailController.text = savedEmail;
      setState(() => rememberMe = true);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
  setState(() {
    emailError = null;
    passwordError = null;
  });

  // ---------- FRONTEND VALIDATION ----------
  if (emailController.text.trim().isEmpty) {
    setState(() => emailError = 'Email is required');
    return;
  }

  if (!GetUtils.isEmail(emailController.text.trim())) {
    setState(() => emailError = 'Invalid email address');
    return;
  }

  if (passwordController.text.trim().isEmpty) {
    setState(() => passwordError = 'Password is required');
    return;
  }

  if (rememberMe) {
    await StorageService.saveEmail(emailController.text.trim());
  }

  final success = await authController.login(
    email: emailController.text.trim(),
    password: passwordController.text.trim(),
    role: 'facility_mode',
  );

  if (success && mounted) {
    Get.offAll(() => DashboardScreen());
  }

  // ❌ DO NOTHING on failure
  // Banner is already handled by AuthController
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          loginText,
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
            10.heightBox,

            /// 🔴 BACKEND ERROR BANNER (FROM AUTH CONTROLLER ONLY)
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

            /// Email
            CustomTextField(
              title: email,
              hint: "Enter your email",
              controller: emailController,
              errorText: emailError,
            ),

            10.heightBox,

            /// Password
            CustomTextField(
              title: password,
              hint: "Enter your password",
              controller: passwordController,
              isPass: true,
              errorText: passwordError,
            ),

            20.heightBox,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() => rememberMe = value ?? false);
                      },
                    ),
                    5.widthBox,
                    Text("Remember me")
                        .text
                        .fontFamily(regular)
                        .make(),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Get.to(() => FacilityForgotPasswordView());
                  },
                  child: Text(
                    "Forgot Password",
                    style: const TextStyle(
                      color: appPrimeryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            20.heightBox,

            /// Login Button
            Center(
              child: Obx(
                () => AppButton(
                  text: authController.isLoading.value
                      ? "Signing In..."
                      : "Sign In",
                  onPressed:
                      authController.isLoading.value ? () {} : _handleLogin,
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

            25.heightBox,

            /// Google Login
            Row(
              children: [
                SocialLoginButton(
                  text: "Google",
                  assetPath: g,
                  onPressed: () {
                    if (authController.isLoading.value) return;

                    setState(() {
                      emailError = null;
                      passwordError = null;
                    });

                    // ❗ DO NOT clear authErrorMessage here
                    authController
                        .googleLogin(selectedRole: 'facility_mode')
                        .then((success) {
                      if (success && mounted) {
                        Get.offAll(() => DashboardScreen());
                      }
                    });
                  },
                ),
                SocialLoginButton(
                  text: "Apple",
                  assetPath: a,
                  onPressed: () {},
                ),
              ],
            ),

            25.heightBox,

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?")
                    .text
                    .fontFamily(regular)
                    .make(),
                5.widthBox,
                InkWell(
                  onTap: () {
                    Get.to(() => const FacilitySignupView());
                  },
                  child: Text("Sign Up")
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
