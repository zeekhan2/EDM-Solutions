import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyEmail = 'user_email';
  static const String _keyRole = 'user_role';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // ADDED KEY (clock-in persistence)
  static const String _keyClockInTime = 'clock_in_time';

  static const _secureStorage = FlutterSecureStorage();

  /// Save authentication token securely
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  /// Delete authentication token
  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  /// Save user data
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  /// Get user data
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // static Future<void> saveFirebaseUid(String uid) async {
  //   final box = GetStorage();
  //   await box.write('firebase_uid', uid);
  // }

  // static String? getFirebaseUid() {
  //   final box = GetStorage();
  //   return box.read('firebase_uid');
  // }

  /// Save email for remember me functionality
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
  }

  /// Get saved email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Save user role
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, role);
  }

  /// Get user role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  /// Save login status
  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  /// Get login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Clear all stored data (logout)
  static Future<void> clearAll() async {
    await deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.remove(_keyRole);
    await prefs.setBool(_keyIsLoggedIn, false);
    // Keep email for remember me
  }

  /// Clear everything including email
  static Future<void> clearAllIncludingEmail() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Save clock-in timestamp (for restoring timer)
  static Future<void> saveClockInTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyClockInTime, time.toIso8601String());
  }

  /// Get saved clock-in timestamp
  static Future<DateTime?> getClockInTime() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyClockInTime);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Clear clock-in timestamp (on clock out)
  static Future<void> clearClockInTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyClockInTime);
  }
}
