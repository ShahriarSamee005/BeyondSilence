import 'package:flutter/material.dart';
import '../services/app_theme.dart';
import '../services/auth_service.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'login_screen.dart';
import 'detection_screen.dart';
import 'history_screen.dart';
import 'learn_screen.dart';
import 'profile_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: CustomScrollView(slivers: [

          // App Bar
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: AppColors.surface,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, size: 20),
                onPressed: () => _showLogout(context),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hello, ${user.name.split(' ').first}! 👋',
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w800,
                                    color: AppColors.text)),
                            const SizedBox(height: 2),
                            Text(user.email,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      if (user.isAdmin)
                        const StatusBadge(label: 'ADMIN', color: AppColors.adminGold),
                    ]),
                  ],
                ),
              ),
            ),
          ),

          // Detection card — full width
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DetectionScreen())),
                child: Container(
                   width: double.infinity,
                   height: MediaQuery.of(context).size.width/2 - 26,
                   padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.teal.withOpacity(0.4)),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.teal.withOpacity(0.15),
                        AppColors.card,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: AppColors.teal, size: 26),
                      ),
                      const SizedBox(height: 10),
                      const Text('Start Detection',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: AppColors.text)),
                      const SizedBox(height: 2),
                      const Text('Translate signs live',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2x2 grid — History, Learn, Profile, About
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate([
                HomeNavCard(
                  icon: Icons.history_rounded, label: 'History',
                  subtitle: 'Past translations', accentColor: AppColors.blue,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen())),
                ),
                HomeNavCard(
                  icon: Icons.play_lesson_rounded, label: 'Learn',
                  subtitle: 'Sign library', accentColor: const Color(0xFFFF6B6B),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LearnScreen())),
                ),
                HomeNavCard(
                  icon: Icons.person_rounded, label: 'Profile',
                  subtitle: 'Posts & settings', accentColor: const Color(0xFFD65DB1),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ProfileScreen(user: user))),
                ),
                HomeNavCard(
                  icon: Icons.info_outline_rounded, label: 'About',
                  subtitle: 'App information', accentColor: AppColors.warning,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AboutScreen())),
                ),
              ]),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12,
                crossAxisSpacing: 12, childAspectRatio: 1.0,
              ),
            ),
          ),

        ]),
      ),
    );
  }

  void _showLogout(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border)),
      title: const Text('Logout',
          style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w700)),
      content: const Text('Are you sure you want to log out?',
          style: TextStyle(color: AppColors.textMuted)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
        ElevatedButton(
          onPressed: () async {
            await AuthService.logout();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error, foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ));
  }
}