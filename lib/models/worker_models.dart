// Profile Update Request
class ProfileUpdateRequest {
  final String? address;
  final String? city;
  final String? zipCode;

  ProfileUpdateRequest({
    this.address,
    this.city,
    this.zipCode,
  });

  Map<String, dynamic> toJson() => {
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (zipCode != null) 'zip_code': zipCode,
      };
}

// Bank Account Models
class BankAccountRequest {
  final String bankName;
  final String accountHolderName;
  final String accountNumber;
  final String routingNumber;

  BankAccountRequest({
    required this.bankName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.routingNumber,
  });

  Map<String, dynamic> toJson() => {
        'bank_name': bankName,
        'account_holder_name': accountHolderName,
        'account_number': accountNumber,
        'routing_number': routingNumber,
      };
}

class BankAccount {
  final int? id;
  final String? bankName;
  final String? accountHolderName;
  final String? accountNumber;
  final String? routingNumber;

  BankAccount({
    this.id,
    this.bankName,
    this.accountHolderName,
    this.accountNumber,
    this.routingNumber,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      bankName: json['bank_name'],
      accountHolderName: json['account_holder_name'],
      accountNumber: json['account_number'],
      routingNumber: json['routing_number'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bank_name': bankName,
        'account_holder_name': accountHolderName,
        'account_number': accountNumber,
        'routing_number': routingNumber,
      };
}

// Weekly Summary Model
class WeeklySummary {
  final int? totalShifts;
  final int? completedShifts;
  final double? totalEarnings;
  final int? totalHours;

  WeeklySummary({
    this.totalShifts,
    this.completedShifts,
    this.totalEarnings,
    this.totalHours,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      totalShifts: json['total_shifts'],
      completedShifts: json['completed_shifts'],
      totalEarnings: json['total_earnings']?.toDouble(),
      totalHours: json['total_hours'],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_shifts': totalShifts,
        'completed_shifts': completedShifts,
        'total_earnings': totalEarnings,
        'total_hours': totalHours,
      };
}

// Location Services Model
class LocationService {
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;

  LocationService({
    this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory LocationService.fromJson(Map<String, dynamic> json) {
    return LocationService(
      name: json['name'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };
}
