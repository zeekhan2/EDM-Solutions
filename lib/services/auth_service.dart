import 'dart:io';

import '../consts/api_constants.dart';
import '../models/api_response.dart';
import '../models/auth_models.dart';
import '../models/auth_response.dart';
import 'api_service.dart';
import '../models/user_model.dart';
import 'storage_service.dart';


class AuthService {
  // ================= REGISTER =================
  static Future<ApiResponse<AuthResponse>> register(
  RegisterRequest request,
) async {
  try {
    final response = await ApiService.post(
      endpoint: ApiConstants.register,
      body: request.toJson(), // firebase_uid already inside
    );

    if (response.success && response.data != null) {
      final responseData = response.data as Map<String, dynamic>;
      final apiSuccess = responseData['success'] ?? false;

      if (apiSuccess == true) {
        return ApiResponse.success(
          AuthResponse(message: response.message),
          message: response.message,
        );
      } else {
        return ApiResponse.error(
          responseData,
          message: response.message ?? 'Registration failed',
        );
      }
    }

    return ApiResponse.error(
      response.error,
      message: response.message ?? 'Registration failed',
    );
  } catch (e) {
    return ApiResponse.error(
      e.toString(),
      message: 'An unexpected error occurred',
    );
  }
}


  // ================= VERIFY EMAIL =================
  static Future<ApiResponse<AuthResponse>> verifyEmail(
    VerifyEmailRequest request,
  ) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.verifyEmail,
        body: request.toJson(),
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(
          AuthResponse.fromJson(response.data),
          message: response.message,
        );
      }

      return ApiResponse.error(response.error, message: response.message);
    } catch (e) {
      return ApiResponse.error(e, message: e.toString());
    }
  }

  // ================= RESEND OTP =================
  static Future<ApiResponse<dynamic>> resendOtp(
    ResendOtpRequest request,
  ) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.resendOtp,
        body: request.toJson(),
      );

      return response.success
          ? ApiResponse.success(response.data, message: response.message)
          : ApiResponse.error(response.error, message: response.message);
    } catch (e) {
      return ApiResponse.error(e, message: e.toString());
    }
  }

  // ================= FORGET PASSWORD =================
  static Future<ApiResponse<dynamic>> forgetPassword(
    ForgetPasswordRequest request,
  ) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.forgetPassword,
        body: request.toJson(),
      );

      return response.success
          ? ApiResponse.success(response.data, message: response.message)
          : ApiResponse.error(response.error, message: response.message);
    } catch (e) {
      return ApiResponse.error(e, message: e.toString());
    }
  }

  // ================= RESET PASSWORD =================
  static Future<ApiResponse<dynamic>> resetPassword(
  ResetPasswordRequest request,
) async {
  try {
    final token = await StorageService.getToken(); // ✅ get token saved after verify-email

    final response = await ApiService.post(
      endpoint: ApiConstants.resetPassword,
      body: request.toJson(),
      token: token, // ✅ REQUIRED by backend
    );

    return response.success
        ? ApiResponse.success(response.data, message: response.message)
        : ApiResponse.error(response.error, message: response.message);
  } catch (e) {
    return ApiResponse.error(e, message: e.toString());
  }
}


  // ================= GOOGLE REGISTER =================
  static Future<ApiResponse<AuthResponse>> googleRegister(
  RegisterRequest request,
) async {
  try {
    final resp = await ApiService.post(
      endpoint: ApiConstants.googleRegister,
      body: request.toJson(), // firebase_uid already inside
    );

    if (resp.success && resp.data != null) {
      return ApiResponse.success(
        AuthResponse.fromJson(resp.data),
        message: resp.message,
      );
    }

    return ApiResponse.error(resp.error, message: resp.message);
  } catch (e) {
    return ApiResponse.error(e, message: e.toString());
  }
}


  // ================= GOOGLE LOGIN =================
  static Future<ApiResponse<AuthResponse>> googleLogin(
    LoginRequest request,
  ) async {
    try {
      final resp = await ApiService.post(
        endpoint: ApiConstants.googleLogin,
        body: request.toJson(),
      );

      if (resp.success && resp.data != null) {
        return ApiResponse.success(
          AuthResponse.fromJson(resp.data),
          message: resp.message,
        );
      }

      return ApiResponse.error(resp.error, message: resp.message);
    } catch (e) {
      return ApiResponse.error(e, message: e.toString());
    }
  }

  // ================= LOGIN (NORMAL) =================
  static Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.login,
        body: request.toJson(),
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(
          AuthResponse.fromJson(response.data),
          message: response.message,
        );
      }

      return ApiResponse.error(response.error, message: response.message);
    } catch (e) {
      return ApiResponse.error(e, message: e.toString());
    }
  }

  // ================= UPLOAD DOCUMENT =================
  static Future<ApiResponse<dynamic>> uploadDocument({
    required String token,
    File? idCard,
    File? certificate,
  }) async {
    try {
      final files = <String, File>{};
      if (idCard != null) files['id_card'] = idCard;
      if (certificate != null) files['certificate'] = certificate;

      final response = await ApiService.postMultipart(
        endpoint: ApiConstants.uploadDocument,
        fields: {},
        files: files,
        token: token,
      );

      return response.success
          ? ApiResponse.success(response.data, message: response.message)
          : ApiResponse.error(response.error, message: response.message);
    } catch (e) {
      return ApiResponse.error(e, message: e.toString());
    }
  }

  // ================= GET USER =================
  static Future<ApiResponse<User>> getUser(String token) async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.getuser,
        token: token,
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(
          User.fromJson(response.data['user'] ?? response.data),
          message: response.message,
        );
      }

      return ApiResponse.error(response.error, message: response.message);
    } catch (e) {
      return ApiResponse.error(e, message: e.toString());
    }
  }

  // ================= CHANGE PASSWORD =================
  static Future<ApiResponse<dynamic>> changePassword({
    required String token,
    required ChangePasswordRequest request,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.passwordChange,
        body: request.toJson(),
        token: token,
      );

      return response.success
          ? ApiResponse.success(response.data, message: response.message)
          : ApiResponse.error(response.error, message: response.message);
    } catch (e) {
      return ApiResponse.error(e, message: e.toString());
    }
  }

  // ================= UPDATE PROFILE =================
  static Future<ApiResponse<dynamic>> updateProfile({
    required String token,
    File? image,
    String? address,
    String? city,
    String? zipCode,
  }) async {
    try {
      final fields = <String, String>{};
      if (address != null) fields['address'] = address;
      if (city != null) fields['city'] = city;
      if (zipCode != null) fields['zip_code'] = zipCode;

      final files = <String, File>{};
      if (image != null) files['image'] = image;

      final response = await ApiService.postMultipart(
        endpoint: ApiConstants.profileUpdate,
        fields: fields,
        files: files,
        token: token,
      );

      return response.success
          ? ApiResponse.success(response.data, message: response.message)
          : ApiResponse.error(response.error, message: response.message);
    } catch (e) {
      return ApiResponse.error(e, message: e.toString());
    }
  }

  //-----------logout---------------
  static Future<ApiResponse<dynamic>> logout(String token) async {
  final response = await ApiService.post(
    endpoint: ApiConstants.logout,
    token: token,
  );

  return response.success
      ? ApiResponse.success(response.data, message: response.message)
      : ApiResponse.error(response.error, message: response.message);
}

static Future<ApiResponse<dynamic>> deleteAccount(String token) async {
  return ApiService.post(
    endpoint: ApiConstants.deleteAccount,
    token: token,
  );
}

}
