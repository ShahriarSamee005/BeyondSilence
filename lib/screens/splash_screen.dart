import 'package:flutter/material.dart';
import '../services/app_theme.dart';
import '../widgets/widgets.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

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

  // Check stored session
  final storedUser = await AuthService.getStoredSession();

  if (!mounted) return;
  if (storedUser != null) {
    // Still logged in — go straight to home
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => HomeScreen(user: storedUser),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  } else {
    // Not logged in — go to login
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: AnimatedBuilder(
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
                // Logo
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withOpacity(0.35),
                        blurRadius: 40, offset: const Offset(0, 8),
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
                const SizedBox(height: 32),

                // App name
                const Text('BEYONDSILENCE',
                    style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900,
                      color: AppColors.text, letterSpacing: 4,
                    )),
                const SizedBox(height: 4),
                const Text('SIGN LANGUAGE TRANSLATOR',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500,
                      color: AppColors.teal, letterSpacing: 4,
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
      ),
    );
  }
}