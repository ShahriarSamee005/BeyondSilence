import 'package:flutter/material.dart';
import '../services/app_theme.dart';
import '../widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── App identity card ────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A1628), AppColors.card],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.teal.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.teal, AppColors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal.withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.sign_language_rounded, size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'BANGLA SIGN TRANSLATOR',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900,
                        color: AppColors.text, letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const StatusBadge(label: 'v1.0.0', color: AppColors.teal),
                  ],
                ),
              ),
              const SizedBox(height: 24),
        
              // ── Description ──────────────────────────────────────────────
              const SectionHeader(title: 'About This App'),
              const _InfoCard(
                icon: Icons.info_outline,
                color: AppColors.blue,
                content:
                    'Bangla Sign Language Translator is an AI-powered mobile application '
                    'that helps bridge the communication gap for the Deaf and Hard of Hearing '
                    'community in Bangladesh.\n\n'
                    'Using a TFLite deep learning model trained on Bangla Sign Language gestures, '
                    'the app recognizes hand signs through the device camera and translates them '
                    'into spoken or written Bangla in real time.',
              ),
              const SizedBox(height: 20),
        
              // ── Features ─────────────────────────────────────────────────
              const SectionHeader(title: 'Key Features'),
              const _FeatureRow(
                icon: Icons.camera_alt_rounded, color: AppColors.teal,
                label: 'Real-time Sign Detection',
                sub: 'Live camera translation using TFLite',
              ),
              const _FeatureRow(
                icon: Icons.history_rounded, color: AppColors.blue,
                label: 'Translation History',
                sub: 'Review all past recognized signs',
              ),
              const _FeatureRow(
                icon: Icons.play_lesson_rounded, color: Color(0xFFFF6B6B),
                label: 'Learn Signs',
                sub: 'Video library for each sign word',
              ),
              const _FeatureRow(
                icon: Icons.volume_up_rounded, color: AppColors.warning,
                label: 'Text-to-Speech',
                sub: 'Speak recognized words aloud',
              ),
              const _FeatureRow(
                icon: Icons.people_rounded, color: Color(0xFFD65DB1),
                label: 'Community Posts',
                sub: 'Share progress with other learners',
              ),
              const SizedBox(height: 20),
        
              // ── Tech stack ───────────────────────────────────────────────
              const SectionHeader(title: 'Tech Stack'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    _TechRow(label: 'Framework',  value: 'Flutter (Dart)'),
                    Divider(color: AppColors.border, height: 20),
                    _TechRow(label: 'ML Model',   value: 'TensorFlow Lite'),
                    Divider(color: AppColors.border, height: 20),
                    _TechRow(label: 'Backend',    value: 'Node.js + Express'),
                    Divider(color: AppColors.border, height: 20),
                    _TechRow(label: 'Database',   value: 'MongoDB Atlas'),
                    Divider(color: AppColors.border, height: 20),
                    _TechRow(label: 'Auth',       value: 'JWT (Role-based)'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
        
              // ── Developer credits ────────────────────────────────────────
              const SectionHeader(title: 'Developer'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.teal, AppColors.blue]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.code_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BST Dev Team',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                          const SizedBox(height: 3),
                          const Text('Bangladesh Sign Language Project',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              StatusBadge(label: 'Day 1 Build', color: AppColors.teal),
                              SizedBox(width: 6),
                              StatusBadge(label: 'UI Skeleton', color: AppColors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
        
              // ── Footer ───────────────────────────────────────────────────
              const Text(
                '© 2024 BST Dev Team',
                style: TextStyle(fontSize: 11, color: AppColors.textDim),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'All rights reserved',
                style: TextStyle(fontSize: 10, color: AppColors.textDim),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(content,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textMuted, height: 1.6)),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String sub;

  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.text)),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Icon(Icons.check_circle_outline,
              color: color.withOpacity(0.5), size: 16),
        ],
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  final String label;
  final String value;

  const _TechRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: AppColors.teal, fontFamily: 'monospace')),
      ],
    );
  }
}