import 'package:flutter/material.dart';
import '../services/app_theme.dart';
import '../services/auth_service.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoginMode = true;
  String _role = 'user';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 500));

    if (_isLoginMode) {
      final user = AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role: _role,
      );
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _loading = false;
          _error = 'Invalid credentials.\nUser: user@bsl.app | Admin: admin@bsl.app\nPassword: 123456';
        });
        return;
      }
      _goHome(user);
    } else {
      final user = AuthService.signup(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role: _role,
      );
      if (!mounted) return;
      _goHome(user);
    }
  }

  void _goHome(UserModel user) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // Header
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.teal, AppColors.blue]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.sign_language_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_isLoginMode ? 'Welcome back' : 'Create account',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
                  Text(_isLoginMode ? 'Sign in to continue' : 'Join BST today',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ]),
              ]),
              const SizedBox(height: 32),

              // Role toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(children: [
                  _RoleTab(label: 'User', icon: Icons.person_outline,
                      isActive: _role == 'user', onTap: () => setState(() => _role = 'user')),
                  _RoleTab(label: 'Admin', icon: Icons.admin_panel_settings_outlined,
                      isActive: _role == 'admin', onTap: () => setState(() => _role = 'admin')),
                ]),
              ),
              const SizedBox(height: 24),

              // Error
              if (_error != null)
                Container(
                  width: double.infinity, margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(fontSize: 12, color: AppColors.error)),
                ),

              // Form
              Form(
                key: _formKey,
                child: Column(children: [
                  AppTextField(
                    label: 'EMAIL',
                    hint: _role == 'admin' ? 'admin@bsl.app' : 'user@bsl.app',
                    controller: _emailCtrl,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email required';
                      if (!v.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'PASSWORD',
                    hint: '••••••',
                    controller: _passCtrl,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password required';
                      if (v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                  if (!_isLoginMode) ...[
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'CONFIRM PASSWORD',
                      hint: '••••••',
                      controller: _confirmCtrl,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (v) {
                        if (v != _passCtrl.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 28),

              _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2))
                  : PrimaryButton(
                      label: _isLoginMode ? 'Sign In' : 'Create Account',
                      icon: _isLoginMode ? Icons.login_rounded : Icons.person_add_outlined,
                      onTap: _submit,
                    ),
              const SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  _isLoginMode ? "Don't have an account? " : 'Already have an account? ',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _isLoginMode = !_isLoginMode;
                    _error = null;
                  }),
                  child: Text(
                    _isLoginMode ? 'Sign Up' : 'Sign In',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.teal),
                  ),
                ),
              ]),

              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Demo Credentials',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    SizedBox(height: 8),
                    Text('User  →  user@bsl.app',
                        style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.teal)),
                    Text('Admin →  admin@bsl.app',
                        style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.teal)),
                    Text('Password →  123456',
                        style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.teal)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _RoleTab({required this.label, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.teal.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: isActive ? Border.all(color: AppColors.teal.withOpacity(0.4)) : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: isActive ? AppColors.teal : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: isActive ? AppColors.teal : AppColors.textMuted)),
          ]),
        ),
      ),
    );
  }
}