class PaymentHistory {
  final int id;
  final String status;
  final double amount;
  final String createdAt;

  final String totalHours; // 👈 NEW (from backend)

  final String shiftTitle;
  final String shiftDate;
  final double rate;

  PaymentHistory({
    required this.id,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.totalHours,
    required this.shiftTitle,
    required this.shiftDate,
    required this.rate,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'],
      status: json['status'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      createdAt: json['created_at'] ?? '',

      // 👇 THIS IS THE KEY FIX
      totalHours: json['total_hours'] ?? '0h 0m',

      shiftTitle: json['shift']?['title'] ?? '',
      shiftDate: json['shift']?['date'] ?? '',
      rate: double.tryParse(
            json['shift']?['pay_per_hour']?.toString() ?? '0',
          ) ??
          0.0,
    );
  }
}
