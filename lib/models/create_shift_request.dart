class CreateShiftRequest {
  final String title; // ✅ REQUIRED
  final String date;
  final double payPerHour;
  final String startTime;
  final String endTime;
  final String licenseType;
  final String location;
  final String? specialInstruction;

  CreateShiftRequest({
    required this.title,
    required this.date,
    required this.payPerHour,
    required this.startTime,
    required this.endTime,
    required this.licenseType,
    required this.location,
    this.specialInstruction,
  });

  Map<String, dynamic> toJson() => {
        'title': title, // ✅ REQUIRED BY API
        'date': date,
        'pay_per_hour': payPerHour,
        'start_time': startTime,
        'end_time': endTime,
        'license_type': licenseType,
        'location': location,
        'status': 'open',
        if (specialInstruction != null)
          'special_instruction': specialInstruction,
      };
}
