import 'user_model.dart'; // <-- IMPORTANT

class AuthResponse {
  final String? message;
  final String? token;

  AuthResponse({this.message, this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    String? messageStr;
    final messageField = json['message'];
    if (messageField is List && messageField.isNotEmpty) {
      messageStr = messageField.first.toString();
    } else if (messageField is String) {
      messageStr = messageField;
    }

    return AuthResponse(
      message: messageStr,
      token: json['token'],
      // ❌ DO NOT parse user here anymore
    );
  }
}
