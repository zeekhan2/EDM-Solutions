class ClaimedShift {
  /// 🔑 CLAIMED SHIFT ID
  /// Backend: `id`
  /// Used for: shift details, cancel shift, check-in/out
  final int claimedShiftId;

  /// 🔗 ORIGINAL SHIFT ID
  /// Backend: `shift_id`
  /// Used only for reference / UI
  final int shiftId;

  final int userId;

  final String? startTime;
  final String? endTime;

  final bool checkInEnabled;
  final bool checkOutEnabled;

  final String? status;     // Pending Approval, Confirmed, In Progress, Completed
  final String? createdAt;

  ClaimedShift({
    required this.claimedShiftId,
    required this.shiftId,
    required this.userId,
    this.startTime,
    this.endTime,
    required this.checkInEnabled,
    required this.checkOutEnabled,
    this.status,
    this.createdAt,
  });

  factory ClaimedShift.fromJson(Map<String, dynamic> json) {
    return ClaimedShift(
      claimedShiftId: json['id'],                // ✅ CLAIM ID
      shiftId: json['shift_id'],                 // ✅ ORIGINAL SHIFT ID
      userId: json['user_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      checkInEnabled: json['check_in_enabled'] == true,
      checkOutEnabled: json['check_out_enabled'] == true,
      status: json['status'],
      createdAt: json['created_at'],
    );
  }

  /// 🧪 Helpful for debugging
  Map<String, dynamic> toJson() {
    return {
      'claimedShiftId': claimedShiftId,
      'shiftId': shiftId,
      'userId': userId,
      'startTime': startTime,
      'endTime': endTime,
      'checkInEnabled': checkInEnabled,
      'checkOutEnabled': checkOutEnabled,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
