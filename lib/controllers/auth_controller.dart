import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../views/UserApp/Home/workerhomeview_new.dart';
import 'package:edm_solutions/views/FacilityApp/Home/dashboard.dart';
import 'package:edm_solutions/views/choose_Mood_Views/ChooseModeViews.dart';

import '../models/auth_models.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

import '../services/auth_service.dart';
import '../services/storage_service.dart';

// ROLE BASED CONTROLLERS
import '../controllers/worker_home_controller.dart';
import '../controllers/shift_controller.dart';
import '../controllers/facility_dashboard_controller.dart';

class AuthController extends GetxController {
  // ================= STATE =================
  final isLoading = false.obs;
  final isLoggedIn = false.obs;

  final token = ''.obs;
  final role = ''.obs;
  final RxString authErrorMessage = ''.obs;

  final Rx<User?> currentUser = Rx<User?>(null);

  final verificationEmail = ''.obs;
  final isForgetPassword = false.obs;
  final tempPassword = ''.obs;

  // 🔑 Firebase UID (single source of truth)
  final firebaseUid = ''.obs;

  // ================= FIREBASE =================
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  // ================= CHECK LOGIN STATUS =================
  Future<void> checkLoginStatus() async {
    try {
      final loggedIn = await StorageService.isLoggedIn();
      if (!loggedIn) return;

      final savedToken = await StorageService.getToken();
      final savedUser = await StorageService.getUser();
      final savedRole = await StorageService.getRole();

      if (savedToken == null || savedUser == null) return;

      token.value = savedToken;
      currentUser.value = savedUser;
      role.value = savedRole ?? '';

      isLoggedIn.value = true;
      _setupRoleControllers(role.value);
    } catch (_) {}
  }

  // ================= GOOGLE Sign up =================
  Future<bool> googleSignup({required String selectedRole}) async {
    if (selectedRole.isEmpty ||
        (selectedRole != 'worker_mode' && selectedRole != 'facility_mode')) {
      authErrorMessage.value =
          'Role missing. Please select Worker or Facility again.';
      return false;
    }

    try {
      authErrorMessage.value = '';
      isLoading.value = true;

      role.value = selectedRole;
      await StorageService.saveRole(selectedRole);

      // ---------- Firebase Google Sign-in ----------
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        authErrorMessage.value = 'Google sign-up cancelled';
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fbCred = await _firebaseAuth.signInWithCredential(credential);
      final fbUser = fbCred.user;
      if (fbUser == null) {
        authErrorMessage.value = 'Google authentication failed';
        return false;
      }

      firebaseUid.value = fbUser.uid;

      final email = fbUser.email!;
      final name = fbUser.displayName ?? 'Google User';

      // ---------- UNIQUE phone (backend requires unique) ----------
      final phone =
          '9${DateTime.now().millisecondsSinceEpoch.toString().substring(4, 13)}';

      // ---------- BACKEND REGISTER ----------
      final registerResp = await AuthService.googleRegister(
        RegisterRequest(
          role: selectedRole,
          fullName: name,
          email: email,
          phoneNumber: phone,
          password: 'google_auth',
          passwordConfirmation: 'google_auth',
          isGoogle: 1,
          firebaseUid: firebaseUid.value,
        ),
      );

      // SHOW BACKEND MESSAGE AS-IS
      if (!registerResp.success) {
        authErrorMessage.value = _normalizeMessage(registerResp.message);
        return false;
      }
      // ---------- BACKEND LOGIN (after register) ----------
      final loginResp = await AuthService.googleLogin(
        LoginRequest(
          email: email,
          password: 'google_auth',
          role: selectedRole,
        ),
      );

      if (loginResp.success != true ||
          loginResp.data == null ||
          loginResp.data!.token == null ||
          loginResp.data!.token!.isEmpty) {
        await _firebaseLogoutOnly();
        authErrorMessage.value = _normalizeMessage(loginResp.message);
        'Google signup failed. Please try again.';
        return false;
      }

      await _saveUserData(loginResp.data!);
      await _ensureFirebaseSession();
      return true;
    } catch (e) {
      debugPrint('Google signup crash: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= GOOGLE LOGIN =================
  Future<bool> googleLogin({required String selectedRole}) async {
    authErrorMessage.value = '';
    isLoading.value = true;

    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        authErrorMessage.value = 'Google sign-in cancelled';
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final fbCred = await _firebaseAuth.signInWithCredential(credential);
      final fbUser = fbCred.user;

      if (fbUser == null) {
        authErrorMessage.value = 'Google authentication failed';
        return false;
      }

      final loginResp = await AuthService.googleLogin(
        LoginRequest(
          email: fbUser.email!,
          password: 'google_auth',
          role: selectedRole,
        ),
      );

      // ✅ TRUST BACKEND
      if (loginResp.success != true || loginResp.data == null) {
        authErrorMessage.value = _normalizeMessage(loginResp.message);
        await _firebaseLogoutOnly();
        return false;
      }

      // ✅ TOKEN GUARD
      if (loginResp.data!.token == null || loginResp.data!.token!.isEmpty) {
        authErrorMessage.value = _normalizeMessage(loginResp.message);
        await _firebaseLogoutOnly();
        return false;
      }

      role.value = selectedRole;
      await StorageService.saveRole(selectedRole);
      await _saveUserData(loginResp.data!);
      return true;
    } catch (e) {
      await _firebaseLogoutOnly();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

//-----------hard logout------
  Future<void> _hardLogout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (_) {}

    await StorageService.clearAll();

    token.value = '';
    role.value = '';
    firebaseUid.value = '';
    currentUser.value = null;
    isLoggedIn.value = false;
  }

  // 🔑 Firebase-only logout (used when backend rejects auth)
  Future<void> _firebaseLogoutOnly() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
  }

  // ================= NORMAL LOGIN =================
  Future<bool> login({
    required String email,
    required String password,
    required String role,
  }) async {
    // ---------- INPUT VALIDATION ----------
    if (email.trim().isEmpty) {
      authErrorMessage.value = 'Email is required';
      return false;
    }

    if (!GetUtils.isEmail(email.trim())) {
      authErrorMessage.value = 'Enter a valid email address';
      return false;
    }

    if (password.isEmpty) {
      authErrorMessage.value = 'Password is required';
      return false;
    }

    try {
      authErrorMessage.value = '';
      isLoading.value = true;

      final response = await AuthService.login(
        LoginRequest(
          email: email.trim(),
          password: password,
          role: role,
        ),
      );

      // ❌ BACKEND REJECTED (wrong email / password)
      if (response.success != true || response.data == null) {
        authErrorMessage.value = _normalizeMessage(response.message);
        return false;
      }

      // ❌ BACKEND BUG GUARD (missing token)
      if (response.data!.token == null || response.data!.token!.isEmpty) {
        authErrorMessage.value = 'Email or password is incorrect';
        return false;
      }

      // ✅ BACKEND APPROVED
      this.role.value = role;
      await StorageService.saveRole(role);

      await _saveUserData(response.data!);
      await _ensureFirebaseSession();
      return true;
    } catch (e) {
      // SAFETY NET — never show generic crash on wrong password
      authErrorMessage.value = 'Email or password is incorrect';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= REGISTER =================
  Future<bool> register({
    required String role,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      authErrorMessage.value = '';
      isLoading.value = true;

      verificationEmail.value = email;
      tempPassword.value = password;
      this.role.value = role;

      firebaseUid.value = await _generateNewFirebaseUid();

      final response = await AuthService.register(
        RegisterRequest(
          role: role,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
          passwordConfirmation: passwordConfirmation,
          isGoogle: 0,
          firebaseUid: firebaseUid.value,
        ),
      );

      if (!response.success) {
        _showError(response.message);
        return false;
      }

      return true;
    } catch (e) {
      _showError('Registration failed. Please try again.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= VERIFY EMAIL =================
  Future<bool> verifyEmail({
    required int code,
    required bool forgetPassword,
  }) async {
    try {
      final response = await AuthService.verifyEmail(
        VerifyEmailRequest(
          code: code,
          forgetPassword: forgetPassword,
        ),
      );

      if (!response.success) {
        _showError(response.message);
        return false;
      }

      if (forgetPassword) {
        token.value = response.data?.token ?? '';
        await StorageService.saveToken(token.value);
        return true;
      }

      final loginResp = await AuthService.login(
        LoginRequest(
          email: verificationEmail.value,
          password: tempPassword.value,
          role: role.value,
        ),
      );

      if (loginResp.success != true ||
          loginResp.data == null ||
          loginResp.data!.token == null ||
          loginResp.data!.token!.isEmpty) {
        _showError(loginResp.message);
        return false;
      }

      await _saveUserData(loginResp.data!);
      return true;
    } catch (e) {
      // ✅ FIX: was silent
      _showError('Invalid or expired verification code');
      return false;
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<bool> forgetPassword(String email) async {
    try {
      authErrorMessage.value = '';
      isLoading.value = true;

      final response = await AuthService.forgetPassword(
        ForgetPasswordRequest(email: email),
      );

      if (!response.success) {
        final msg = response.message?.toString() ?? 'Invalid email';

        _showError(msg);
        return false;
      }

      verificationEmail.value = email;
      isForgetPassword.value = true;
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= RESEND OTP =================
  Future<bool> resendOtp(String email) async {
    try {
      isLoading.value = true;

      final response = await AuthService.resendOtp(
        ResendOtpRequest(email: email),
      );

      if (!response.success) {
        _showError(response.message);
        return false;
      }

      return true;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= RESET PASSWORD =================
  Future<bool> resetPassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    if (verificationEmail.value.isEmpty) {
      _showError('Session expired. Please restart password reset.');
      return false;
    }

    try {
      isLoading.value = true;

      final response = await AuthService.resetPassword(
        ResetPasswordRequest(
          email: verificationEmail.value,
          password: password,
          passwordConfirmation: passwordConfirmation,
        ),
      );

      if (!response.success) {
        _showError(response.message);
        return false;
      }

      verificationEmail.value = '';
      isForgetPassword.value = false;
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= CHANGE PASSWORD =================
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      isLoading.value = true;
      authErrorMessage.value = '';

      // 🔒 HARD GUARD: old & new password must be different
      if (currentPassword.trim() == newPassword.trim()) {
        authErrorMessage.value =
            'New password must be different from current password.';
        return false;
      }

      final savedToken = await StorageService.getToken();
      if (savedToken == null || savedToken.isEmpty) {
        authErrorMessage.value = 'Session expired. Please login again.';
        return false;
      }

      final response = await AuthService.changePassword(
        token: savedToken,
        request: ChangePasswordRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
          newPasswordConfirmation: newPasswordConfirmation,
        ),
      );

      // 🔥 DO NOT TRUST response.success
      final backendMessage = _normalizeMessage(response.message);

      // ❌ BACKEND ERROR (wrong current password, etc.)
      if (backendMessage.isNotEmpty &&
          backendMessage.toLowerCase().contains('incorrect')) {
        authErrorMessage.value = backendMessage;
        return false;
      }

      // ✅ BACKEND CONFIRMED SUCCESS
      if (backendMessage.toLowerCase().contains('success')) {
        authErrorMessage.value = '';
        return true;
      }

      // ❌ UNKNOWN → FAIL SAFE
      authErrorMessage.value =
          backendMessage.isNotEmpty ? backendMessage : 'Password change failed';
      return false;
    } catch (_) {
      authErrorMessage.value = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      if (token.value.isNotEmpty) {
        await AuthService.logout(token.value);
      }
    } catch (_) {
    } finally {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      await StorageService.clearAll();

      currentUser.value = null;
      token.value = '';
      role.value = '';
      firebaseUid.value = '';
      isLoggedIn.value = false;

      Get.offAll(() => ChooseModeViews());
    }
  }

  // ================= DELETE ACCOUNT =================
  Future<bool> deleteAccount() async {
    try {
      isLoading.value = true;

      final savedToken = await StorageService.getToken();
      if (savedToken == null || savedToken.isEmpty) return false;

      final response = await AuthService.deleteAccount(savedToken);

      if (!response.success) {
        _showError(response.message ?? 'Failed to delete account');
        return false;
      }

      // Clear everything locally
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      await StorageService.clearAll();

      currentUser.value = null;
      token.value = '';
      role.value = '';
      firebaseUid.value = '';
      isLoggedIn.value = false;

      // ALWAYS go to choose mode after delete
      Get.offAll(() => ChooseModeViews());

      return true;
    } catch (e) {
      _showError('Something went wrong');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ================= SAVE USER =================
  Future<void> _saveUserData(AuthResponse authResponse) async {
    // 🔒 HARD GUARD — NEVER TRUST BACKEND
    if (authResponse.token == null || authResponse.token!.isEmpty) {
      throw Exception('Token missing from backend response');
    }

    // ================= SAVE TOKEN =================
    token.value = authResponse.token!;
    await StorageService.saveToken(token.value);

    // ================= FETCH USER FROM BACKEND =================
    final userResponse = await AuthService.getUser(token.value);
    if (!userResponse.success || userResponse.data == null) {
      throw Exception('Failed to fetch user');
    }

    final user = userResponse.data!;

    // ================= SYNC FIREBASE UID =================
    if (user.firebaseUid != null && user.firebaseUid!.isNotEmpty) {
      firebaseUid.value = user.firebaseUid!;
    }

    // ================= SAVE USER =================
    currentUser.value = user;
    currentUser.refresh();

    await StorageService.saveUser(user);
    await StorageService.saveLoginStatus(true);

    // ================= FINAL STATE =================
    isLoggedIn.value = true;
    _setupRoleControllers(role.value);
  }

  // ================= ROLE CONTROLLERS =================
  void _setupRoleControllers(String role) {
    Get.delete<WorkerHomeController>(force: true);
    Get.delete<ShiftController>(force: true);
    Get.delete<FacilityDashboardController>(force: true);

    if (role == 'worker_mode') {
      Get.put(WorkerHomeController(), permanent: true);
    } else if (role == 'facility_mode') {
      Get.put(ShiftController(), permanent: true);
      Get.put(FacilityDashboardController(), permanent: true);
    }
  }

  // ================= HELPERS =================
  Future<String> _generateNewFirebaseUid() async {
    // Always sign out first to avoid UID reuse
    await _firebaseAuth.signOut();

    final cred = await _firebaseAuth.signInAnonymously();
    return cred.user!.uid;
  }

  String _normalizeMessage(dynamic message) {
    if (message is List && message.isNotEmpty) {
      return message.first.toString();
    }
    return message?.toString() ?? 'Something went wrong';
  }

  Future<void> _ensureFirebaseSession() async {
    final auth = fb.FirebaseAuth.instance;

    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }

  void _showError(dynamic message) {
    final msg = _normalizeMessage(message);
    authErrorMessage.value = msg;

    // ✅ SAFE snackbar check
    if (Get.context == null) return;
    if (Get.key.currentState == null) return;

    Get.snackbar(
      'Error',
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateAfterLogin() async {
    await _ensureFirebaseSession();

    if (role.value == 'worker_mode') {
      Get.offAll(() => WorkerHomeViewNew());
    } else if (role.value == 'facility_mode') {
      Get.offAll(() => DashboardScreen());
    }
  }
}
