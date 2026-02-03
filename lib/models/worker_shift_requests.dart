class ClaimShiftRequest {
  final int shiftId;

  ClaimShiftRequest({required this.shiftId});

  Map<String, dynamic> toJson() => {
        'shift_id': shiftId,
      };
}

class ShiftCheckInRequest {
  final int shiftId;
  final String? location; // ✅ FIXED

  ShiftCheckInRequest({
    required this.shiftId,
    this.location,
  });

  Map<String, dynamic> toJson() => {
        'shift_id': shiftId,
        if (location != null) 'location': location,
      };
}

class CheckoutShiftRequest {
  final int shiftId;

  CheckoutShiftRequest({required this.shiftId});

  Map<String, dynamic> toJson() => {
        'shift_id': shiftId,
      };
}

class CancelledShiftRequest {
  final int shiftId;

  CancelledShiftRequest({required this.shiftId});

  Map<String, dynamic> toJson() => {
        'shift_id': shiftId,
      };
      
}

// ==========================================================
// CONFIRM VERIFICATION REQUEST
// ==========================================================
class ConfirmVerificationRequest {
  final int shiftId;

  ConfirmVerificationRequest({required this.shiftId});

  Map<String, dynamic> toJson() => {
        'shift_id': shiftId,
      };
}

