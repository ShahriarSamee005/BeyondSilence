import 'dart:async';
import 'package:flutter/material.dart';
import '../services/app_theme.dart';

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  bool _isDetecting = false;
  String _word = '';
  int _confidence = 0;
  bool _hasResult = false;
  Timer? _timer;
  int _index = 0;

  static const _words = [
    ('ভাই', 'Bhai', 92), ('মা', 'Maa', 88), ('ডাক্তার', 'Doctor', 95),
    ('বন্ধু', 'Friend', 79), ('বই', 'Book', 84), ('হ্যাঁ', 'Yes', 97),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleDetection() {
    if (_isDetecting) {
      _timer?.cancel();
      setState(() => _isDetecting = false);
    } else {
      setState(() { _isDetecting = true; _hasResult = false; });
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        final entry = _words[_index % _words.length];
        setState(() {
          _word = '${entry.$1} (${entry.$2})';
          _confidence = entry.$3;
          _hasResult = true;
          _index++;
        });
      });
    }
  }

  void _clear() => setState(() { _hasResult = false; _word = ''; _confidence = 0; });

  void _speak() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Speaking: ${_word.isNotEmpty ? _word : "nothing"}'),
      duration: const Duration(seconds: 2),
    ));
  }

  Color get _confColor {
    if (_confidence >= 90) return AppColors.success;
    if (_confidence >= 70) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        // Mock camera — black background with grid
        CustomPaint(painter: _GridPainter()),

        // Corner brackets when detecting
        if (_isDetecting) CustomPaint(painter: _BracketPainter()),

        // Top bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              GestureDetector(
                onTap: () { _timer?.cancel(); Navigator.pop(context); },
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
              ),
              const Spacer(),
              if (_isDetecting)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.teal.withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    Container(width: 7, height: 7,
                        decoration: BoxDecoration(color: AppColors.teal, shape: BoxShape.circle)),
                    const SizedBox(width: 7),
                    const Text('Detecting...', style: TextStyle(color: AppColors.teal, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
            ]),
          ),
        ),

        // Bottom panel
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.97), Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (_hasResult) ...[
                Text(_word, style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0),
                    textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text('$_confidence% confidence',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _confColor)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _confidence / 100,
                    backgroundColor: Colors.white10,
                    color: _confColor, minHeight: 4,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (!_hasResult && !_isDetecting)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text('Press Start to detect signs',
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
                ),
              Row(children: [
                Expanded(flex: 2, child: GestureDetector(
                  onTap: _toggleDetection,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: _isDetecting ? AppColors.error.withOpacity(0.15) : AppColors.teal,
                      borderRadius: BorderRadius.circular(13),
                      border: _isDetecting ? Border.all(color: AppColors.error.withOpacity(0.5), width: 1.5) : null,
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(_isDetecting ? Icons.stop_rounded : Icons.play_arrow_rounded,
                          color: _isDetecting ? AppColors.error : AppColors.bg, size: 20),
                      const SizedBox(width: 6),
                      Text(_isDetecting ? 'Stop' : 'Start',
                          style: TextStyle(
                              color: _isDetecting ? AppColors.error : AppColors.bg,
                              fontWeight: FontWeight.w700, fontSize: 14)),
                    ]),
                  ),
                )),
                if (_hasResult) ...[
                  const SizedBox(width: 10),
                  Expanded(child: GestureDetector(
                    onTap: _speak,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.teal.withOpacity(0.4), width: 1.5),
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.volume_up_rounded, color: AppColors.teal, size: 18),
                        SizedBox(width: 6),
                        Text('Speak', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700, fontSize: 14)),
                      ]),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: GestureDetector(
                    onTap: _clear,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                        SizedBox(width: 6),
                        Text('Clear', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w700, fontSize: 14)),
                      ]),
                    ),
                  )),
                ],
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.teal.withOpacity(0.5)
      ..strokeWidth = 2.5..style = PaintingStyle.stroke;
    const len = 32.0; const margin = 70.0;
    final l = margin; final t = size.height * 0.25;
    final r = size.width - margin; final b = size.height * 0.75;
    canvas.drawLine(Offset(l, t), Offset(l + len, t), paint);
    canvas.drawLine(Offset(l, t), Offset(l, t + len), paint);
    canvas.drawLine(Offset(r, t), Offset(r - len, t), paint);
    canvas.drawLine(Offset(r, t), Offset(r, t + len), paint);
    canvas.drawLine(Offset(l, b), Offset(l + len, b), paint);
    canvas.drawLine(Offset(l, b), Offset(l, b - len), paint);
    canvas.drawLine(Offset(r, b), Offset(r - len, b), paint);
    canvas.drawLine(Offset(r, b), Offset(r, b - len), paint);
  }
  @override bool shouldRepaint(_) => false;
}