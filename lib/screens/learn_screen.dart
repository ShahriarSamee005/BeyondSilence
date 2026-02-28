import 'package:flutter/material.dart';
import '../services/app_theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _category = 'All';
  final _categories = ['All', 'Family', 'Basics', 'Profession', 'Places', 'Social', 'Objects'];

  List<LearnWord> get _filtered => _category == 'All'
      ? DummyData.learnWords
      : DummyData.learnWords.where((w) => w.category == _category).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Learn'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Column(children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final active = cat == _category;
              return GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? AppColors.teal : AppColors.border),
                  ),
                  child: Text(cat, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: active ? AppColors.bg : AppColors.textMuted)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SectionHeader(title: '${_filtered.length} Signs'),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.9,
            ),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final word = _filtered[i];
              return GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => LearnDetailScreen(word: word))),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card, borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(word.emoji, style: const TextStyle(fontSize: 30)),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(word.word,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                              color: AppColors.text, height: 1.4),
                          textAlign: TextAlign.center),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class LearnDetailScreen extends StatefulWidget {
  final LearnWord word;
  const LearnDetailScreen({super.key, required this.word});

  @override
  State<LearnDetailScreen> createState() => _LearnDetailScreenState();
}

class _LearnDetailScreenState extends State<LearnDetailScreen> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final lines = widget.word.word.split('\n');
    final bangla = lines[0];
    final english = lines.length > 1 ? lines[1] : '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(english),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Word card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.teal.withOpacity(0.2)),
            ),
            child: Row(children: [
              Text(widget.word.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(width: 20),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(bangla, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.text)),
                Text(english, style: const TextStyle(fontSize: 16, color: AppColors.teal, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                StatusBadge(label: widget.word.category.toUpperCase(), color: AppColors.blue),
              ])),
            ]),
          ),
          const SizedBox(height: 24),

          // Video placeholder
          const SectionHeader(title: 'Tutorial Video'),
          GestureDetector(
            onTap: () => setState(() => _playing = !_playing),
            child: Container(
              width: double.infinity, height: 220,
              decoration: BoxDecoration(
                color: AppColors.surface, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(alignment: Alignment.center, children: [
                Column(mainAxisSize: MainAxisSize.min, children: [
                  if (!_playing) ...[
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.12), shape: BoxShape.circle,
                        border: Border.all(color: AppColors.teal.withOpacity(0.4), width: 2),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: AppColors.teal, size: 36),
                    ),
                    const SizedBox(height: 12),
                    const Text('Tap to play', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ] else ...[
                    Text(widget.word.emoji, style: const TextStyle(fontSize: 60)),
                    const SizedBox(height: 12),
                    const Text('▶ Playing...', style: TextStyle(color: AppColors.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ]),
                Positioned(
                  bottom: 12, left: 16, right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: _playing ? 0.45 : 0,
                      backgroundColor: Colors.white10,
                      color: AppColors.teal, minHeight: 3,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          const SectionHeader(title: 'How to Sign'),
          ...['Position your hand in front of the camera',
            'Form the sign for "$english"',
            'Hold the position for 1–2 seconds',
            'Keep your hand in the detection frame',
          ].asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 22, height: 22,
                  decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.15), shape: BoxShape.circle),
                  child: Center(child: Text('${e.key + 1}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.teal)))),
              const SizedBox(width: 12),
              Expanded(child: Text(e.value,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4))),
            ]),
          )),
        ]),
      ),
    );
  }
}