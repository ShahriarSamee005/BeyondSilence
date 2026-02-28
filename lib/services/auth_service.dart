import '../models/models.dart';

class AuthService {
  AuthService._();
  static const _userEmail = 'user@bsl.app';
  static const _adminEmail = 'admin@bsl.app';
  static const _password = '123456';

  static UserModel? login({
    required String email,
    required String password,
    required String role,
  }) {
    if (password != _password) return null;
    if (role == 'admin' && email == _adminEmail) {
      return const UserModel(name: 'Admin User', email: _adminEmail, role: 'admin');
    }
    if (role == 'user' && email == _userEmail) {
      return const UserModel(name: 'Rahim Uddin', email: _userEmail, role: 'user');
    }
    return null;
  }

  static UserModel signup({
    required String email,
    required String password,
    required String role,
  }) {
    return UserModel(
      name: email.split('@').first,
      email: email,
      role: role,
    );
  }
}