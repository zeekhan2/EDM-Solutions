import 'package:edm_solutions/models/create_shift_request.dart';

import '../consts/api_constants.dart';
import '../models/api_response.dart';
import '../models/shift_models.dart';
import 'api_service.dart';

class FacilityService {
  /// Get all shifts for facility
  static Future<ApiResponse<List<Shift>>> getFacilityShifts(String token) async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.facilityGetShifts,
        token: token,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final shiftsJson = data['data'] as List;
          final shifts = shiftsJson.map((json) => Shift.fromJson(json)).toList();
          return ApiResponse.success(shifts, message: response.message);
        }
        return ApiResponse.success([], message: response.message);
      } else {
        return ApiResponse.error(
          response.error,
          message: response.message ?? 'Failed to fetch facility shifts',
        );
      }
    } catch (e) {
      print('❌ Get Facility Shifts error: $e');
      return ApiResponse.error(
        e.toString(),
        message: 'An error occurred while fetching facility shifts',
      );
    }
  }

  /// Get group shifts
  static Future<ApiResponse<dynamic>> getShiftsGroup(String token) async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.getShiftsGroup,
        token: token,
      );

      if (response.success) {
        return ApiResponse.success(
          response.data,
          message: response.message ?? 'Shifts group fetched successfully',
        );
      } else {
        return ApiResponse.error(
          response.error,
          message: response.message ?? 'Failed to fetch shifts group',
        );
      }
    } catch (e) {
      print('❌ Get Shifts Group error: $e');
      return ApiResponse.error(
        e.toString(),
        message: 'An error occurred while fetching shifts group',
      );
    }
  }

  /// Accept pending shift
  static Future<ApiResponse<dynamic>> acceptPendingShift(
      String token, int shiftId) async {
    try {
      final response = await ApiService.get(
        endpoint: '${ApiConstants.acceptPendingShift}/$shiftId',
        token: token,
      );

      if (response.success) {
        return ApiResponse.success(
          response.data,
          message: response.message ?? 'Shift accepted successfully',
        );
      } else {
        return ApiResponse.error(
          response.error,
          message: response.message ?? 'Failed to accept shift',
        );
      }
    } catch (e) {
      print('❌ Accept Pending Shift error: $e');
      return ApiResponse.error(
        e.toString(),
        message: 'An error occurred while accepting shift',
      );
    }
  }

  /// Get filled shift details
  static Future<ApiResponse<dynamic>> getFilledShiftDetails(String token) async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.filledShiftDetails,
        token: token,
      );

      if (response.success) {
        return ApiResponse.success(
          response.data,
          message: response.message ?? 'Filled shift details fetched successfully',
        );
      } else {
        return ApiResponse.error(
          response.error,
          message: response.message ?? 'Failed to fetch filled shift details',
        );
      }
    } catch (e) {
      print('❌ Get Filled Shift Details error: $e');
      return ApiResponse.error(
        e.toString(),
        message: 'An error occurred while fetching filled shift details',
      );
    }
  }

  /// Get complete shift summary
  static Future<ApiResponse<dynamic>> getCompleteShiftSummary(
      String token, int shiftId) async {
    try {
      final response = await ApiService.get(
        endpoint: '${ApiConstants.getCompleteShiftSummary}/$shiftId',
        token: token,
      );

      if (response.success) {
        return ApiResponse.success(
          response.data,
          message: response.message ?? 'Complete shift summary fetched successfully',
        );
      } else {
        return ApiResponse.error(
          response.error,
          message: response.message ?? 'Failed to fetch complete shift summary',
        );
      }
    } catch (e) {
      print('❌ Get Complete Shift Summary error: $e');
      return ApiResponse.error(
        e.toString(),
        message: 'An error occurred while fetching complete shift summary',
      );
    }
  }

  /// Create a new shift
  static Future<ApiResponse<dynamic>> createShift(
      String token, CreateShiftRequest request) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.createShift,
        body: request.toJson(),
        token: token,
      );

      if (response.success) {
        return ApiResponse.success(
          response.data,
          message: response.message ?? 'Shift created successfully',
        );
      } else {
        return ApiResponse.error(
          response.error,
          message: response.message ?? 'Failed to create shift',
        );
      }
    } catch (e) {
      print('❌ Create Shift error: $e');
      return ApiResponse.error(
        e.toString(),
        message: 'An error occurred while creating shift',
      );
    }
  }

  /// Get staff attendance details
  static Future<ApiResponse<dynamic>> getStaffAttendanceDetails(String token) async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.getStaffAttendanceDetails,
        token: token,
      );

      if (response.success) {
        return ApiResponse.success(
          response.data,
          message: response.message ?? 'Staff attendance details fetched successfully',
        );
      } else {
        return ApiResponse.error(
          response.error,
          message: response.message ?? 'Failed to fetch staff attendance details',
        );
      }
    } catch (e) {
      print('❌ Get Staff Attendance Details error: $e');
      return ApiResponse.error(
        e.toString(),
        message: 'An error occurred while fetching staff attendance details',
      );
    }
  }

    /// Reject pending shift (move back to Open)
  static Future<ApiResponse<dynamic>> rejectShift(
    String token,
    int shiftId,
  ) async {
    try {
      final response = await ApiService.get(
        endpoint: '${ApiConstants.rejectShift}/$shiftId',
        token: token,
      );

      if (response.success) {
        return ApiResponse.success(
          response.data,
          message: response.message ?? 'Shift rejected successfully',
        );
      } else {
        return ApiResponse.error(
          response.error,
          message: response.message ?? 'Failed to reject shift',
        );
      }
    } catch (e) {
      print('❌ Reject Shift error: $e');
      return ApiResponse.error(
        e.toString(),
        message: 'An error occurred while rejecting shift',
      );
    }
  }

}
