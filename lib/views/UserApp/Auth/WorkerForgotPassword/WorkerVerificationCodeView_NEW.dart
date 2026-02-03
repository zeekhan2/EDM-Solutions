import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Common_Widgets/safe_snackbar_helper.dart';
import '../../../../consts/colors.dart';
import '../../../../controllers/auth_controller.dart';
import 'WorkerResetPasswordView.dart';
import '../Login/login_views.dart';

class WorkerVerificationCodeView extends StatefulWidget {
  const WorkerVerificationCodeView({super.key});

  @override
  State<WorkerVerificationCodeView> createState() =>
      _WorkerVerificationCodeViewState();
}

class _WorkerVerificationCodeViewState
    extends State<WorkerVerificationCodeView> {
  late final AuthController authController;
  final List<TextEditingController> otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeController();
    });
  }

  void _initializeController() {
    try {
      authController = Get.find<AuthController>();
      print('✅ [VERIFY] AuthController found successfully');
      print('📧 [VERIFY] Verification email: ${authController.verificationEmail.value}');
      setState(() {
        _controllerInitialized = true;
      });
    } catch (e) {
      print('❌ [VERIFY] Failed to find AuthController: $e');
      // Try to initialize it
      try {
        authController = Get.put(AuthController());
        print('✅ [VERIFY] AuthController initialized');
        setState(() {
          _controllerInitialized = true;
        });
      } catch (e2) {
        print('❌ [VERIFY] Critical error initializing AuthController: $e2');
        // Navigate back if we can't get the controller
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.back();
          SafeSnackbarHelper.showSafeSnackbar(
            title: 'Error',
            message: 'Unable to initialize verification. Please try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        });
      }
    }
  }

  Future<void> _handleVerify() async {
    String otp = otpControllers.map((c) => c.text).join();
    
    print('🔵 [VERIFY] Verify button clicked!');
    print('📝 [VERIFY] OTP entered: $otp');
    
    if (otp.length != 4) {
      print('❌ [VERIFY] Validation failed: OTP must be 4 digits');
      SafeSnackbarHelper.showSafeSnackbar(
        title: 'Error',
        message: 'Please enter the 4-digit code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    print('📧 [VERIFY] Email: ${authController.verificationEmail.value}');
    print('🔐 [VERIFY] Forget Password Mode: ${authController.isForgetPassword.value}');
    print('📤 [VERIFY] Calling verify-email API...');
    
    final success = await authController.verifyEmail(
      code: int.parse(otp),
      forgetPassword: authController.isForgetPassword.value,
    );

    print('📊 [VERIFY] API Response - Success: $success');

    if (success) {
      if (authController.isForgetPassword.value) {
        // Go to reset password screen
        print('✅ [VERIFY] Verified for password reset, navigating...');
        Get.to(() => WorkerResetPasswordView());
      } else {
        // Email verification after registration - navigate to login
        print('✅ [VERIFY] Email verified successfully!');
        SafeSnackbarHelper.showSafeSnackbar(
          title: 'Success',
          message: 'Email verified successfully! Please login to continue.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
        // Navigate to login after 1 second
        Future.delayed(const Duration(seconds: 1), () {
          print('🔄 [VERIFY] Navigating to login...');
          Get.offAll(() => const LoginViews());
        });
      }
    } else {
      print('❌ [VERIFY] Verification failed!');
    }
  }

  Future<void> _handleResendOtp() async {
    print('🔵 [VERIFY] Resend OTP button clicked!');
    print('📧 [VERIFY] Resending to: ${authController.verificationEmail.value}');
    
    final success = await authController.resendOtp(
      authController.verificationEmail.value,
    );
    
    print('📊 [VERIFY] Resend Response - Success: $success');
    
    if (success) {
      print('✅ [VERIFY] OTP resent successfully!');
      // Clear OTP fields
      for (var controller in otpControllers) {
        controller.clear();
      }
      focusNodes[0].requestFocus();
    } else {
      print('❌ [VERIFY] Resend OTP failed!');
    }
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ [VERIFY] Building verification screen');
    
    // Add a loading check
    if (!_controllerInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: appPrimeryColor),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Verification Code",
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Illustration
            SizedBox(
              height: 200,
              child: Image.asset(
                "assets/images/password.png",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.email, size: 100, color: Colors.blue);
                },
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              "Verification Code",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: appPrimeryColor,
              ),
            ),

            const SizedBox(height: 10),

            // Description
            Builder(
              builder: (context) {
                try {
                  final email = authController.verificationEmail.value;
                  return Text(
                    "We have sent the code to\n${email.isNotEmpty ? email : 'your email'}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black54,
                    ),
                  );
                } catch (e) {
                  print('❌ [VERIFY] Error displaying email: $e');
                  return const Text(
                    "We have sent the code to your email",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black54,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 30),

            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                4,
                (index) => SizedBox(
                  width: 60,
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: appPrimeryColor, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      try {
                        if (value.isNotEmpty && index < 3) {
                          focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                      } catch (e) {
                        print('❌ [VERIFY] Focus error: $e');
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Resend Code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't receive the code? ",
                  style: TextStyle(color: Colors.black54),
                ),
                GestureDetector(
                  onTap: _handleResendOtp,
                  child: Text(
                    "Resend",
                    style: TextStyle(
                      color: appPrimeryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimeryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _handleVerify(),
                child: const Text(
                  "Verify",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
