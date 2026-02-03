class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://admin.edmsolutions.org';

  // API Base Path
  static const String apiBasePath = '/api';

  // Auth Endpoints
  static const String register = '$apiBasePath/auth/register';
  static const String verifyEmail = '$apiBasePath/auth/verify-email';
  static const String resendOtp = '$apiBasePath/auth/resend-otp';
  static const String forgetPassword = '$apiBasePath/auth/forget-password';
  static const String resetPassword = '$apiBasePath/reset-password';
  static const String login = '$apiBasePath/auth/login';
  static const String uploadDocument = '$apiBasePath/auth/upload/document';
  static const String getuser = '$apiBasePath/user';
  static const String logout = '$apiBasePath/logout';
  static const String googleLogin = '$apiBasePath/auth/google/login';
  static const String googleRegister = '$apiBasePath/auth/google/register';
  static const String passwordChange = '$apiBasePath/password/change';

  // Worker Mode Endpoints
  static const String getShifts = '$apiBasePath/get/shifts';
  static const String getShiftDetails = '$apiBasePath/get/shifts'; // + /{id}
  static const String claimShift = '$apiBasePath/claim-shift';
  static const String getClaimedShift = '$apiBasePath/get/claimed-shift';
  static const String shiftCheckIn = '$apiBasePath/shift-check-in';
  static const String checkoutShift = '$apiBasePath/checkout-shift';
  static const String confirmVerification = '$apiBasePath/confirm-verification';
  static const String profileUpdate = '$apiBasePath/profile/update';
  static const String changePassword = '$apiBasePath/profile/change/password';
  static const String uploadDoc = '$apiBasePath/upload/document';
  static const String cancelledShift = '$apiBasePath/cancelled-shift';
  static const String locationServices = '$apiBasePath/location-services';
  static const String getBankAccount = '$apiBasePath/get/bank-account';
  static const String addBankAccount = '$apiBasePath/add/bank-account';
  static const String getWeeklySummary = '$apiBasePath/get/weekly-summary';
  static const String ratingSummary = '$apiBasePath/get/rating-summary';
  static const String getReviews = '$apiBasePath/get/reviews';
  static const String getReviewsDetailed = '$apiBasePath/get/reviews/detailed';
  static const String timesheetWeek = '$apiBasePath/weekly/timesheet';
  static const String timesheetMonthly = '$apiBasePath/timesheet/monthly';
  static const String deleteAccount = '$apiBasePath/delete/account';
  static const String getComplianceDocuments =
      '$apiBasePath/get/compliance-document';
  static const String uploadComplianceDocument =
      '$apiBasePath/upload/compliance-document';
  static const String updateComplianceDocument =
      '$apiBasePath/update/compliance-document';
  static const String workerOnboard = '$apiBasePath/payment/onboard';
  static const String getReportStats = '$apiBasePath/get/report/stats';
  static const String getPaymentHistory = '$apiBasePath/payment/history';
  static const String getFacilityPaymentHistory =
      '$apiBasePath/get/payment-history';

  // Facility Mode Endpoints
  static const String facilityGetShifts = '$apiBasePath/facility/get/shifts';
  static const String getShiftsGroup = '$apiBasePath/get/shifts-group';
  static const String acceptPendingShift =
      '$apiBasePath/accept-pending-shift'; // + /{id}
  static const String filledShiftDetails = '$apiBasePath/filled-shift-details';
  static const String getCompleteShiftSummary =
      '$apiBasePath/get/complete-shift-summary'; // + /{id}
  static const String createShift = '$apiBasePath/create/shift';
  static const String getStaffAttendanceDetails =
      '$apiBasePath/get/staff-attendance-details';
  static const String getdeleteShift = '$apiBasePath/delete/shift'; // + /{id}
  static const String rejectShift = '$apiBasePath/reject/shift'; // + /{id}
  static const String updateShift = '$apiBasePath/create/update'; // + /{id}
  static const String getWorkersList = '$apiBasePath/get/workers-list';
  static const String facilityProfileUpdate =
      '$apiBasePath/facility/profile/update';
  static const String facilityChangePassword =
      '$apiBasePath/facility/change/password';
  static const String facilityProfile = '$apiBasePath/facility/profile';
  static const String saveFirebaseUid = '$apiBasePath/save/firebase/uid';

  // Headers
  static Map<String, String> get headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  static Map<String, String> headersWithToken(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> multipartHeadersWithToken(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
