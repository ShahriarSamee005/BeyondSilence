import 'package:flutter/material.dart';
import '../services/app_theme.dart';
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
      backgroundColor: AppColors.bg,
      body: CustomScrollView(slivers: [
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
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.teal, AppColors.blue]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(user.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Hello, ${user.name.split(' ').first}! 👋',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.text)),
                      Text(user.email,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ])),
                    StatusBadge(
                      label: user.role.toUpperCase(),
                      color: user.isAdmin ? AppColors.adminGold : AppColors.teal,
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid(
            delegate: SliverChildListDelegate([
              HomeNavCard(icon: Icons.camera_alt_rounded, label: 'Detection',
                  subtitle: 'Translate signs live', accentColor: AppColors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DetectionScreen()))),
              HomeNavCard(icon: Icons.history_rounded, label: 'History',
                  subtitle: 'Past translations', accentColor: AppColors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
              HomeNavCard(icon: Icons.play_lesson_rounded, label: 'Learn',
                  subtitle: 'Sign library', accentColor: const Color(0xFFFF6B6B),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnScreen()))),
              HomeNavCard(icon: Icons.person_rounded, label: 'Profile',
                  subtitle: 'Posts & settings', accentColor: const Color(0xFFD65DB1),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: user)))),
              HomeNavCard(icon: Icons.info_outline_rounded, label: 'About',
                  subtitle: 'App information', accentColor: AppColors.warning,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
            ]),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.0,
            ),
          ),
        ),
      ]),
    );
  }

  void _showLogout(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
      title: const Text('Logout', style: TextStyle(color: AppColors.text, fontSize: 17, fontWeight: FontWeight.w700)),
      content: const Text('Are you sure you want to log out?', style: TextStyle(color: AppColors.textMuted)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
        ElevatedButton(
          onPressed: () => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white,
              elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ));
  }
}