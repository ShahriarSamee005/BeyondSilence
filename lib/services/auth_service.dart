// lib/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_service.dart';

class AuthService {
  AuthService._();

  static const _keyUserId = 'user_id';
  static const _keyEmail = 'logged_email';
  static const _keyRole = 'logged_role';
  static const _keyName = 'logged_name';
  static const _keyProfilePic = 'profile_pic';
  static const _keyLoginTime = 'login_time';
  static const _sessionDays = 10;

  // ─── Login via API ───────────────────────────────────────────
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Call real API
    final user = await ApiService.login(
      email: email.trim().toLowerCase(),
      password: password,
    );

    // Save session locally
    await _saveSession(user);
    return user;
  }

  // ─── Register via API ────────────────────────────────────────
  static Future<String> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    // Call real API — returns message (email verification needed)
    final message = await ApiService.register(
      name: name,
      email: email.trim().toLowerCase(),
      password: password,
    );
    return message;
  }

  // ─── Save session to SharedPreferences ───────────────────────
  static Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyEmail, user.email);
    await prefs.setString(_keyRole, user.role);
    await prefs.setString(_keyName, user.name);
    if (user.profilePicture != null) {
      await prefs.setString(_keyProfilePic, user.profilePicture!);
    }
    await prefs.setString(_keyLoginTime, DateTime.now().toIso8601String());
  }

  // ─── Check if session is still valid (within 10 days) ────────
  static Future<UserModel?> getStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    final email = prefs.getString(_keyEmail);
    final role = prefs.getString(_keyRole);
    final name = prefs.getString(_keyName);
    final profilePic = prefs.getString(_keyProfilePic);
    final loginTimeStr = prefs.getString(_keyLoginTime);
    final token = prefs.getString('jwt_token');

    if (email == null ||
        role == null ||
        name == null ||
        loginTimeStr == null ||
        token == null) {
      return null;
    }

    final loginTime = DateTime.tryParse(loginTimeStr);
    if (loginTime == null) return null;

    final difference = DateTime.now().difference(loginTime).inDays;
    if (difference >= _sessionDays) {
      await logout(); // Session expired
      return null;
    }

    return UserModel(
      id: id ?? '',
      name: name,
      email: email,
      role: role,
      profilePicture: profilePic,
    );
  }

  // ─── Logout — clear session ──────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
