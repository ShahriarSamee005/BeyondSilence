import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AuthService {
  AuthService._();

  static const _keyEmail = 'logged_email';
  static const _keyRole = 'logged_role';
  static const _keyName = 'logged_name';
  static const _keyLoginTime = 'login_time';
  static const _sessionDays = 10;

  // Dummy accounts — in real app this comes from backend
  static const _accounts = [
    {'email': 'user@bsl.app', 'password': '123456', 'role': 'user', 'name': 'Rahim Uddin'},
    {'email': 'admin@bsl.app', 'password': '123456', 'role': 'admin', 'name': 'Admin User'},
  ];

  // Login — returns UserModel if valid, null if invalid
  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final account = _accounts.where((a) =>
        a['email'] == email.trim().toLowerCase() &&
        a['password'] == password).firstOrNull;

    if (account == null) return null;

    // Save session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, account['email']!);
    await prefs.setString(_keyRole, account['role']!);
    await prefs.setString(_keyName, account['name']!);
    await prefs.setString(_keyLoginTime, DateTime.now().toIso8601String());

    return UserModel(
      name: account['name']!,
      email: account['email']!,
      role: account['role']!,
    );
  }

  // Signup — always succeeds, defaults to user role
  static Future<UserModel> signup({
    required String email,
    required String password,
  }) async {
    final name = email.split('@').first;
    const role = 'user'; // role assigned by backend in real app

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyLoginTime, DateTime.now().toIso8601String());

    return UserModel(name: name, email: email, role: role);
  }

  // Check if session is still valid (within 10 days)
  static Future<UserModel?> getStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail);
    final role = prefs.getString(_keyRole);
    final name = prefs.getString(_keyName);
    final loginTimeStr = prefs.getString(_keyLoginTime);

    if (email == null || role == null || name == null || loginTimeStr == null) {
      return null;
    }

    final loginTime = DateTime.tryParse(loginTimeStr);
    if (loginTime == null) return null;

    final difference = DateTime.now().difference(loginTime).inDays;
    if (difference >= _sessionDays) {
      await logout(); // Session expired
      return null;
    }

    return UserModel(name: name, email: email, role: role);
  }

  // Logout — clear session
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}