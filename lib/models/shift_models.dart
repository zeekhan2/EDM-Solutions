class Shift {
  final int? id;
  final int? realShiftId;
  final String? date;
  final String? createdAt;
  final double? payPerHour;
  final String? startTime;
  final String? endTime;
  final String? licenseType;
  final String? title;
  final String? specialInstruction;
  final String? location;
  final int? status;
  final double? totalAmount;
  final String? dutyTime;

  // FACILITY / CHAT SUPPORT
  final int? facilityId;
  final String? facilityFirebaseUid;
  final String? facilityName;
  final String? address;

  final String? checkIn;
  final String? checkOut;

  // FILLED SHIFT (FLAT WORKER)
  final String? filledWorkerName;
  final String? filledWorkerImage;
  final int? filledWorkerId;

  final Map<String, dynamic>? claimedBy;
  final Map<String, dynamic>? facility;
  final Map<String, dynamic>? worker;

  final bool? delete;

  Shift({
    this.id,
    this.realShiftId,
    this.date,
    this.createdAt,
    this.payPerHour,
    this.startTime,
    this.endTime,
    this.licenseType,
    this.title,
    this.specialInstruction,
    this.location,
    this.status,
    this.totalAmount,
    this.dutyTime,
    this.facilityId,
    this.facilityFirebaseUid,
    this.facilityName,
    this.address,
    this.checkIn,
    this.checkOut,
    this.claimedBy,
    this.facility,
    this.worker,
    this.delete,
    this.filledWorkerName,
    this.filledWorkerImage,
    this.filledWorkerId,
  });

  // ==========================================================
  // NORMAL SHIFT (GET /api/get/shifts)
  // ==========================================================
  factory Shift.fromJson(Map<String, dynamic> json) {
    final int? resolvedStatus = json['status'] is int
        ? json['status']
        : json['status'] != null && int.tryParse('${json['status']}') != null
            ? int.tryParse('${json['status']}')
            : _mapResultStatus(json['result']);

    return Shift(
      id: json['id'],
      realShiftId: json['id'], // public shift id

      date: json['date']?.toString(),
      createdAt: json['created_at']?.toString(),
      payPerHour: _parsePay(json['per_hour'] ?? json['pay_per_hour']),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      totalAmount: _parsePay(json['total_amount']),
      dutyTime: json['duty_time']?.toString(),

      licenseType:
          json['license-type']?.toString() ?? json['license_type']?.toString(),
      title: json['title']?.toString(),
      specialInstruction: json['special_instruction']?.toString(),
      location: json['location']?.toString(),

      status: resolvedStatus,

      checkIn: json['check_in']?.toString(),
      checkOut: json['check_out']?.toString(),

      facility: json['facility'] != null
          ? Map<String, dynamic>.from(json['facility'])
          : null,

      worker: json['worker'] != null
          ? Map<String, dynamic>.from(json['worker'])
          : null,

      claimedBy: json['claimed_by'] != null
          ? Map<String, dynamic>.from(json['claimed_by'])
          : null,

      facilityId: json['facility_id'] ?? json['facility']?['id'],
      facilityFirebaseUid: json['facility_firebase_uid'] ??
          json['firebase_uid'] ??
          json['facility']?['firebase_uid'],
      facilityName: json['facility_name'] ?? json['facility']?['name'],
      address: json['address'] ?? json['facility']?['address'],

      filledWorkerName: json['user_name']?.toString() ??
          json['claimed_by']?['name']?.toString(),

      filledWorkerImage:
          json['image']?.toString() ?? json['claimed_by']?['image']?.toString(),

      filledWorkerId: json['worker_id'] ?? json['claimed_by']?['id'],
    );
  }

  // ==========================================================
  // CLAIMED SHIFT (GET /api/get/claimed-shift/{id})
  // ==========================================================
  factory Shift.fromClaimedJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'], // claimed shift row id
      realShiftId: json['shift_id'], // ✅ THIS IS USED TO CANCEL

      date: json['date']?.toString(),
      createdAt: json['created_at']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      payPerHour: _parsePay(json['pay_per_hour']),

      facilityId: json['facility_id'],
      facilityFirebaseUid: json['firebase_uid'],
      facilityName: json['facility_name']?.toString(),
      address: json['address']?.toString(),

      status: _mapClaimedStatus(json['status']),
      location: json['location']?.toString(),
    );
  }

  // ==========================================================
  // STATUS LABEL
  // ==========================================================
  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Opened';
      case 2:
        return 'Pending Approval';
      case 3:
        return 'Confirmed';
      case 4:
        return 'In Progress';
      case 5:
        return 'Completed';
      case 6:
        return 'Paid';
      case -1:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  // ==========================================================
  // COPY
  // ==========================================================
  Shift copyWith({
    int? status,
    String? checkIn,
    String? checkOut,
  }) {
    return Shift(
      id: id,
      realShiftId: realShiftId,
      date: date,
      createdAt: createdAt,
      payPerHour: payPerHour,
      startTime: startTime,
      endTime: endTime,
      licenseType: licenseType,
      title: title,
      specialInstruction: specialInstruction,
      location: location,
      status: status ?? this.status,
      totalAmount: totalAmount,
      dutyTime: dutyTime,
      facilityId: facilityId,
      facilityFirebaseUid: facilityFirebaseUid,
      facilityName: facilityName,
      address: address,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      facility: facility,
      worker: worker,
      claimedBy: claimedBy,
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================
  static double? _parsePay(dynamic value) {
    if (value == null) return null;
    final cleaned = value.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned);
  }

  static int _mapClaimedStatus(String? status) {
    switch (status) {
      case 'Pending Approval':
        return 2;
      case 'Confirmed':
        return 3;
      case 'In Progress':
        return 4;
      case 'Completed':
        return 5;
      default:
        return 0;
    }
  }

  static int? _mapResultStatus(String? result) {
    switch (result) {
      case 'Awaiting':
        return 2;
      case 'Completed':
        return 5;
      case 'Paid':
        return 6;
      default:
        return null;
    }
  }
}
