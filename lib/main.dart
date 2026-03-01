import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const BeyondSilenceApp());
}

class BeyondSilenceApp extends StatelessWidget {
  const BeyondSilenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeyondSilence',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}