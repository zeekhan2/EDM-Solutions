import 'package:edm_solutions/consts/images.dart';
import 'package:edm_solutions/consts/styles.dart';
import 'package:edm_solutions/Common_Widgets/custom_textfield.dart';
import 'package:edm_solutions/services/storage_service.dart';
import 'package:edm_solutions/views/UserApp/Auth/WorkerForgotPassword/WorkerForgotPasswordView.dart';
import 'package:edm_solutions/views/UserApp/Home/workerhomeview_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../../Common_Widgets/SocialLoginButton.dart';
import '../../../../Common_Widgets/our_button.dart';
import '../../../../consts/colors.dart';
import '../../../../consts/strings.dart';
import '../../../../controllers/auth_controller.dart';
import '../SignUpView/signup_views.dart';
import '../../../../controllers/worker_home_controller.dart';

class LoginViews extends StatefulWidget {
  const LoginViews({super.key});

  @override
  State<LoginViews> createState() => _LoginViewsState();
}

class _LoginViewsState extends State<LoginViews> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool isNavigating = false;
  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final savedEmail = await StorageService.getEmail();
    if (savedEmail != null) {
      emailController.text = savedEmail;
      setState(() => rememberMe = true);
    }
  }

 Future<void> _handleLogin() async {
  // ❗ DO NOT clear backend banner here
  setState(() {
    emailError = null;
    passwordError = null;
    isNavigating = false;
  });

  // ================= FRONTEND VALIDATION =================
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
    role: 'worker_mode',
  );

  // ❌ DO NOTHING ON FAILURE
  // 🔴 Banner is already handled by AuthController
  if (!success) return;

  setState(() => isNavigating = true);

  await Future.delayed(const Duration(milliseconds: 150));
  authController.navigateAfterLogin();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          loginText,
          style: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.heightBox,

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

            /// Navigating Message
            if (isNavigating) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Login successful! Loading your dashboard...',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
                    Text("Remember me")
                        .text
                        .size(14)
                        .fontFamily(regular)
                        .fontWeight(FontWeight.w400)
                        .make(),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Get.to(WorkerForgotPasswordView());
                  },
                  child: Text("Forgot Password")
                      .text
                      .semiBold
                      .fontFamily(regular)
                      .make(),
                ),
              ],
            ),

            30.heightBox,

            Center(
              child: Obx(
                () => authController.isLoading.value
                    ? const CircularProgressIndicator()
                    : AppButton(
                        text: "Log in",
                        onPressed: _handleLogin,
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

            Row(
              children: [
                SocialLoginButton(
  text: "Google",
  assetPath: g,
  onPressed: () async {
    if (authController.isLoading.value) return;

    final success = await authController.googleLogin(
      selectedRole: 'worker_mode',
    );

    if (success && mounted) {
      authController.navigateAfterLogin();
    }
    // ❌ DO NOTHING on failure
    // 🔴 Banner already handled by controller
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
                Text(" Don’t Have an account?")
                    .text
                    .size(14)
                    .fontFamily(regular)
                    .make(),
                5.widthBox,
                InkWell(
                  onTap: () {
                    Get.to(() => WorkerSignupView());
                  },
                  child: Text("Sign Up")
                      .text
                      .size(14)
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
