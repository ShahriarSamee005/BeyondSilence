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

    if (_isLoginMode) {
      final user = await AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _loading = false;
          _error = 'Invalid email or password. Please try again.';
        });
        return;
      }
      _goHome(user);
    } else {
      final user = await AuthService.signup(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
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
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Logo
                  Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal.withOpacity(0.25),
                          blurRadius: 20, offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/logoBD.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    _isLoginMode ? 'Welcome back!' : 'Create account',
                    style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isLoginMode ? 'Sign in to continue' : 'Join BeyondSilence today',
                    style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 36),

                  // Error
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
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
                        hint: 'Enter your email',
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
                        hint: 'Enter your password',
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
                          hint: 'Re-enter your password',
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
                      ? const CircularProgressIndicator(
                          color: AppColors.teal, strokeWidth: 2)
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
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800,
                            color: AppColors.teal),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}