import 'package:edm_solutions/consts/consts.dart';
import 'package:edm_solutions/Common_Widgets/custom_textfield.dart';
import 'package:edm_solutions/Common_Widgets/our_button.dart';
import 'package:edm_solutions/views/Common/email_verification_view.dart';
import 'package:edm_solutions/views/UserApp/Home/workerhomeview_new.dart';

import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../Common_Widgets/SocialLoginButton.dart';
import '../../../../controllers/auth_controller.dart';
import '../Login/login_views.dart';
import 'package:edm_solutions/views/UserApp/UploadDoc/UploadDocumnetationView.dart';

class WorkerSignupView extends StatefulWidget {
  const WorkerSignupView({super.key});

  @override
  State<WorkerSignupView> createState() => _WorkerSignupViewState();
}

class _WorkerSignupViewState extends State<WorkerSignupView> {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? nameError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;

  Future<void> _handleSignup() async {
    if (authController.isLoading.value) return;

    setState(() {
      nameError = null;
      emailError = null;
      phoneError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    bool hasError = false;

    if (nameController.text.isEmpty) {
      nameError = 'Name is required';
      hasError = true;
    }

    if (emailController.text.isEmpty) {
      emailError = 'Email is required';
      hasError = true;
    } else if (!GetUtils.isEmail(emailController.text)) {
      emailError = 'Invalid email format';
      hasError = true;
    }

    if (phoneController.text.isEmpty) {
      phoneError = 'Phone number is required';
      hasError = true;
    } else if (phoneController.text.length < 10) {
      phoneError = 'Phone number must be at least 10 digits';
      hasError = true;
    }

    if (passwordController.text.isEmpty) {
      passwordError = 'Password is required';
      hasError = true;
    } else if (passwordController.text.length < 8) {
      passwordError = 'Password must be at least 8 characters';
      hasError = true;
    }

    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError = 'Please confirm your password';
      hasError = true;
    } else if (passwordController.text != confirmPasswordController.text) {
      confirmPasswordError = 'Passwords do not match';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    final success = await authController.register(
      role: 'worker_mode',
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      password: passwordController.text,
      passwordConfirmation: confirmPasswordController.text,
    );

    // ❌ DO NOTHING ON FAILURE
    // 🔴 Backend error is already handled by AuthController
    if (!success) return;

    if (mounted) {
      authController.isForgetPassword.value = false;
      Get.off(() => const EmailVerificationView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          SignUpText,
          style: const TextStyle(
              color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.heightBox,

            /// 🔴 BACKEND ERROR MESSAGE (FROM CONTROLLER ONLY)
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
              errorText: nameError,
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
                  onPressed: authController.isLoading.value
                      ? () {}
                      : _handleSignup,
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
                    if (authController.isLoading.value) return;

                    final success =
                        await authController.googleSignup(
                      selectedRole: 'worker_mode',
                    );

                    if (success && mounted) {
                      Get.offAll(() => UploadDocumnetationView());
                    }
                    // ❌ DO NOTHING on failure
                    // 🔴 Error already set by controller
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
                    Get.to(() => const LoginViews());
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
