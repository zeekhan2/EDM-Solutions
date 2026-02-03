import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Common_Widgets/custom_textfield.dart';
import '../../../../Common_Widgets/our_button.dart';
import '../../../../Common_Widgets/safe_snackbar_helper.dart';
import '../../../../consts/colors.dart';
import '../../../../consts/strings.dart';
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
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? passwordError;
  String? confirmPasswordError;

  bool showPassword = false;
  bool showConfirmPassword = false;

  Future<void> _handleResetPassword() async {
    if (authController.isLoading.value) return;

    setState(() {
      passwordError = null;
      confirmPasswordError = null;
    });

    bool hasError = false;

    if (passwordController.text.isEmpty) {
      passwordError = 'Password is required';
      hasError = true;
    } else if (passwordController.text.length < 6) {
      passwordError = 'Password must be at least 6 characters';
      hasError = true;
    }

    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError = 'Confirm password is required';
      hasError = true;
    } else if (passwordController.text != confirmPasswordController.text) {
      confirmPasswordError = 'Passwords do not match';
      hasError = true;
    }

    if (hasError) {
      setState(() {}); // ✅ forces UI redraw for red text
      return;
    }

    final success = await authController.resetPassword(
      password: passwordController.text,
      passwordConfirmation: confirmPasswordController.text,
    );

    if (success) {
      SafeSnackbarHelper.showSafeSnackbar(
        title: 'Success',
        message: 'Password reset successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAll(() => const LoginViews());
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Center(
              child: SizedBox(
                height: 180,
                child: Image.asset(
                  "assets/images/password.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Create New Password",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: appPrimeryColor,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Your new password must be different\nfrom previously used passwords.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            /// 🔐 New Password
            CustomTextField(
              title: password,
              hint: "Enter new password",
              controller: passwordController,
              isPass: !showPassword,
              errorText: passwordError,
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => showPassword = !showPassword);
                },
              ),
            ),

            const SizedBox(height: 16),

            /// 🔐 Confirm Password
            CustomTextField(
              title: confrimPassword,
              hint: "Confirm new password",
              controller: confirmPasswordController,
              isPass: !showConfirmPassword,
              errorText: confirmPasswordError,
              suffixIcon: IconButton(
                icon: Icon(
                  showConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(
                      () => showConfirmPassword = !showConfirmPassword);
                },
              ),
            ),

            const SizedBox(height: 40),

            Obx(
              () => AppButton(
                text: authController.isLoading.value
                    ? "Updating..."
                    : "Reset Password",
                onPressed: authController.isLoading.value
                    ? () {}
                    : _handleResetPassword,
                width: 281,
                height: 57,
                color: appPrimeryColor,
                textColor: appSeconderyColor,
                borderRadius: 50,
                borderColor: appPrimeryColor,
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
