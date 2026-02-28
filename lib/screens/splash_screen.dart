import 'package:flutter/material.dart';
import '../services/app_theme.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<double>(begin: 30, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(0, _slide.value),
            child: child,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.teal, AppColors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withOpacity(0.35),
                      blurRadius: 40, offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.sign_language_rounded,
                    size: 52, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const Text('BANGLA SIGN',
                  style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w900,
                    color: AppColors.text, letterSpacing: 4,
                  )),
              const SizedBox(height: 4),
              const Text('TRANSLATOR',
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: AppColors.teal, letterSpacing: 8,
                  )),
              const SizedBox(height: 64),
              const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.teal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}