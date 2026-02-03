class User {
  final int? id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? zipCode;
  final String? image;
  final String? firebaseUid;

  const User({
    this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.address,
    this.city,
    this.zipCode,
    this.image,
    this.firebaseUid,
  });

  /// Used for API responses (e.g. GET /api/user)
  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return User(
      id: data['id'] as int?,
      fullName: data['name'] as String?,
      email: data['email'] as String?,
      phoneNumber: data['phone'] as String?,
      address: data['address'] as String?,
      city: data['city'] as String?,
      zipCode: data['zip_code'] as String?,
      image: data['image'] as String?,
      firebaseUid: data['firebase_uid'] as String?,
    );
  }

  /// Used for local storage (SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': fullName,
      'email': email,
      'phone': phoneNumber,
      'address': address,
      'city': city,
      'zip_code': zipCode,
      'image': image,
      'firebase_uid': firebaseUid,
    };
  }

  /// Optional helper for safe updates later
  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? address,
    String? city,
    String? zipCode,
    String? image,
    String? firebaseUid,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      image: image ?? this.image,
      firebaseUid: firebaseUid ?? this.firebaseUid,
    );
  }
}
