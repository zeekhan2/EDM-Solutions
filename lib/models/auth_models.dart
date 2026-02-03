class RegisterRequest {
  final String role;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String passwordConfirmation;
  final int isGoogle; // REGISTER ONLY
  final String firebaseUid; // REGISTER ONLY

  RegisterRequest({
    required this.role,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.passwordConfirmation,
    required this.isGoogle,
    required this.firebaseUid,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'is_google': isGoogle,
      'firebase_uid': firebaseUid,
    };
  }
}

// ================= LOGIN =================
class LoginRequest {
  final String email;
  final String password;
  final String role;

  LoginRequest({
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'role': role,
    };
  }
}

class VerifyEmailRequest {
  final int code;
  final bool forgetPassword;

  VerifyEmailRequest({
    required this.code,
    this.forgetPassword = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'forget_password': forgetPassword,
    };
  }
}

class ResendOtpRequest {
  final String email;

  ResendOtpRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class ForgetPasswordRequest {
  final String email;

  ForgetPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class ResetPasswordRequest {
  final String email;
  final String password;
  final String passwordConfirmation;

  ResetPasswordRequest({
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    };
  }
}
