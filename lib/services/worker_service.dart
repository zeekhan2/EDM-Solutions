import 'dart:io';

import '../consts/api_constants.dart';
import '../models/api_response.dart';
import '../models/shift_models.dart';
import '../models/worker_models.dart';
import '../models/worker_shift_requests.dart';
import 'api_service.dart';
import 'dart:typed_data';

class WorkerService {
// ==========================================================
// WORKER HOME SHIFTS
// GET /api/get/shifts?date=YYYY-MM-DD
// ==========================================================
  static Future<ApiResponse<List<Shift>>> getShifts(
    String token, {
    String? date,
  }) async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.getShifts,
        token: token,
        queryParams: date != null ? {'date': date} : null,
      );

      final list = (response.data?['data'] ?? []) as List;
      final shifts = list
          .map((e) => Shift.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return ApiResponse.success(shifts, message: response.message);
    } catch (e) {
      return ApiResponse.error(e, message: 'Failed to fetch shifts');
    }
  }

// ==========================================================
// GET CLAIMED SHIFT DETAILS (DETAIL SCREEN)
// GET /api/get/claimed-shift/{id}
// ==========================================================
  static Future<ApiResponse<Shift>> getClaimedShiftDetails(
    String token,
    int shiftId, // THIS IS shift_id = 37
  ) async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.getClaimedShift,
        token: token,
      );

      final list = (response.data?['data'] ?? []) as List;

      final match = list.firstWhere(
        (e) => e['shift_id'] == shiftId,
        orElse: () => null,
      );

      if (match == null) {
        return ApiResponse.error(
          null,
          message: 'Claimed shift not found',
        );
      }

      return ApiResponse.success(
        Shift.fromClaimedJson(
          Map<String, dynamic>.from(match),
        ),
      );
    } catch (e) {
      return ApiResponse.error(
        e,
        message: 'Failed to fetch claimed shift details',
      );
    }
  }

  // ==========================================================
  // GET SINGLE SHIFT DETAILS
  // GET /api/get/shifts/{id}
  // ==========================================================
  static Future<ApiResponse<Shift>> getShiftDetails(
      String token, int shiftId) async {
    try {
      final response = await ApiService.get(
        endpoint: '${ApiConstants.getShiftDetails}/$shiftId',
        token: token,
      );

      final json = response.data?['data'] ?? response.data;
      return ApiResponse.success(
        Shift.fromJson(Map<String, dynamic>.from(json)),
        message: response.message,
      );
    } catch (e) {
      return ApiResponse.error(e, message: 'Failed to fetch shift details');
    }
  }

  // ==========================================================
  // CLAIM SHIFT
  // POST /api/claim-shift
  // ==========================================================
  static Future<ApiResponse<dynamic>> claimShift(
      String token, ClaimShiftRequest request) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.claimShift,
      body: request.toJson(),
      token: token,
    );

    return response.success
        ? ApiResponse.success(response.data, message: response.message)
        : ApiResponse.error(response.error, message: response.message);
  }

  // ==========================================================
  // CHECK IN SHIFT
  // POST /api/shift-check-in
  // ==========================================================
  static Future<ApiResponse<dynamic>> shiftCheckIn(
      String token, ShiftCheckInRequest request) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.shiftCheckIn,
      body: request.toJson(),
      token: token,
    );

    return response.success
        ? ApiResponse.success(response.data, message: response.message)
        : ApiResponse.error(response.error, message: response.message);
  }

  // ==========================================================
  // CHECK OUT SHIFT
  // POST /api/checkout-shift
  // ==========================================================
  static Future<ApiResponse<dynamic>> checkoutShift(
      String token, CheckoutShiftRequest request) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.checkoutShift,
      body: request.toJson(),
      token: token,
    );

    return response.success
        ? ApiResponse.success(response.data, message: response.message)
        : ApiResponse.error(response.error, message: response.message);
  }

  // ==========================================================
  // LOCATION SERVICES
  // GET /api/location-services
  // ==========================================================
  static Future<ApiResponse<List<LocationService>>> getLocationServices(
      String token) async {
    final response = await ApiService.get(
      endpoint: ApiConstants.locationServices,
      token: token,
    );

    final list = (response.data?['data'] ?? []) as List;
    return ApiResponse.success(
      list.map((e) => LocationService.fromJson(e)).toList(),
      message: response.message,
    );
  }

// ==========================================================
// CONFIRM SUPERVISOR VERIFICATION
// POST /api/confirm-verification
// ==========================================================
  static Future<ApiResponse<dynamic>> confirmSupervisorVerification(
    String token,
    int shiftId, {
    Uint8List? signature,
  }) async {
    if (signature != null) {
      final tempFile = File(
        '${Directory.systemTemp.path}/signature_$shiftId.png',
      );

      await tempFile.writeAsBytes(signature);

      final response = await ApiService.postMultipart(
        endpoint: ApiConstants.confirmVerification,
        token: token,
        fields: {
          'shift_id': shiftId.toString(),
        },
        files: {
          'signature': tempFile,
        },
      );

      return response.success
          ? ApiResponse.success(response.data, message: response.message)
          : ApiResponse.error(response.error, message: response.message);
    }

    final response = await ApiService.post(
      endpoint: ApiConstants.confirmVerification,
      token: token,
      body: {
        'shift_id': shiftId,
      },
    );

    return response.success
        ? ApiResponse.success(response.data, message: response.message)
        : ApiResponse.error(response.error, message: response.message);
  }

  // ==========================================================
  // WEEKLY SUMMARY
  // GET /api/get/weekly-summary
  // ==========================================================
  static Future<ApiResponse<WeeklySummary>> getWeeklySummary(
      String token) async {
    final response = await ApiService.get(
      endpoint: ApiConstants.getWeeklySummary,
      token: token,
    );

    if (response.data?['data'] != null) {
      return ApiResponse.success(
        WeeklySummary.fromJson(response.data['data']),
        message: response.message,
      );
    }

    return ApiResponse.error(response.error, message: response.message);
  }

  // ==========================================================
  // PROFILE UPDATE
  // POST /api/profile/update (multipart)
  // ==========================================================
  static Future<ApiResponse<dynamic>> profileUpdate(
    String token,
    ProfileUpdateRequest request,
    File? image,
  ) async {
    final Map<String, String> fields = {};

    request.toJson().forEach((key, value) {
      if (value != null) fields[key] = value.toString();
    });

    final response = await ApiService.postMultipart(
      endpoint: ApiConstants.profileUpdate,
      fields: fields,
      files: image != null ? {'image': image} : null,
      token: token,
    );

    return response.success
        ? ApiResponse.success(response.data, message: response.message)
        : ApiResponse.error(response.error, message: response.message);
  }

  // ==========================================================
  // GET BANK ACCOUNT
  // GET /api/get/bank-account
  // ==========================================================
  static Future<ApiResponse<BankAccount>> getBankAccount(String token) async {
    final response = await ApiService.get(
      endpoint: ApiConstants.getBankAccount,
      token: token,
    );

    if (response.data?['data'] != null) {
      return ApiResponse.success(
        BankAccount.fromJson(response.data['data']),
        message: response.message,
      );
    }

    return ApiResponse.error(response.error, message: response.message);
  }

  // ==========================================================
// WORKER ONBOARD (STRIPE CONNECT)
// POST /api/payment/onboard
// ==========================================================
  static Future<ApiResponse<Map<String, dynamic>>> workerOnboard(
    String token,
  ) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.workerOnboard, // define constant
        token: token,
      );

      return response.success
          ? ApiResponse.success(
              Map<String, dynamic>.from(response.data ?? {}),
              message: response.message,
            )
          : ApiResponse.error(
              response.error,
              message: response.message,
            );
    } catch (e) {
      return ApiResponse.error(
        e,
        message: 'Failed to create onboarding link',
      );
    }
  }

  // ==========================================================
  // ADD BANK ACCOUNT
  // POST /api/add/bank-account
  // ==========================================================
  static Future<ApiResponse<dynamic>> addBankAccount(
      String token, BankAccountRequest request) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.addBankAccount,
      body: request.toJson(),
      token: token,
    );

    return response.success
        ? ApiResponse.success(response.data, message: response.message)
        : ApiResponse.error(response.error, message: response.message);
  }

// ==========================================================
// GET PAYMENT HISTORY
// GET api/payment/history
// ==========================================================
  static Future<ApiResponse<dynamic>> getPaymentHistory(String token) async {
    return await ApiService.get(
      endpoint: ApiConstants.getPaymentHistory,
      token: token,
    );
  }

// ==========================================================
// CANCEL SHIFT
// POST /api/cancelled-shift
// ==========================================================
  static Future<ApiResponse<dynamic>> cancelShift(
    String token,
    int shiftId,
  ) async {
    final response = await ApiService.post(
      endpoint: ApiConstants.cancelledShift,
      body: {
        'shift_id': shiftId,
      },
      token: token,
    );

    return response.success
        ? ApiResponse.success(response.data, message: response.message)
        : ApiResponse.error(response.error, message: response.message);
  }
}
