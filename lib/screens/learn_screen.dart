// lib/screens/learn_screen.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _category = 'All';
  List<String> _categories = ['All'];

  List<LearnWord> _allWords = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final words = await ApiService.getAllLearningWords();

      final cats = <String>{'All'};
      for (final w in words) {
        if (w.category.isNotEmpty) cats.add(w.category);
      }

      if (!mounted) return;
      setState(() {
        _allWords = words;
        _categories = cats.toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  List<LearnWord> get _filtered => _category == 'All'
      ? _allWords
      : _allWords.where((w) => w.category == _category).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Learn'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: AppBackground(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.teal, strokeWidth: 2))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _loadWords,
                          child: const Text('Tap to retry',
                              style: TextStyle(
                                  color: AppColors.teal, fontSize: 13)),
                        ),
                      ],
                    ),
                  )
                : Column(children: [
                    const SizedBox(height: 12),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: active ? AppColors.teal : AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: active
                                        ? AppColors.teal
                                        : AppColors.border),
                              ),
                              child: Text(cat,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: active
                                          ? AppColors.bg
                                          : AppColors.textMuted)),
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
                      child: _filtered.isEmpty
                          ? const Center(
                              child: Text('No signs in this category',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13)))
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) {
                                final word = _filtered[i];
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              LearnDetailScreen(word: word))),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(14),
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          word.banglaWord,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.text,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          word.englishWord,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textMuted,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DETAIL SCREEN WITH REAL VIDEO PLAYER
// ═══════════════════════════════════════════════════════════════

class LearnDetailScreen extends StatefulWidget {
  final LearnWord word;
  const LearnDetailScreen({super.key, required this.word});

  @override
  State<LearnDetailScreen> createState() => _LearnDetailScreenState();
}

class _LearnDetailScreenState extends State<LearnDetailScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoLoading = false;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final url = widget.word.videoUrl;

    // No video URL available
    if (url == null || url.isEmpty) {
      return;
    }

    setState(() {
      _videoLoading = true;
      _videoError = null;
    });

    try {
      final uri = Uri.parse(url);
      _videoController = VideoPlayerController.networkUrl(uri);

      await _videoController!.initialize();

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        showControls: true,
        aspectRatio: _videoController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        placeholder: Container(
          color: AppColors.surface,
          child: const Center(
            child: Icon(Icons.play_circle_outline,
                color: AppColors.teal, size: 48),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Video error: $errorMessage',
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.teal,
          handleColor: AppColors.teal,
          backgroundColor: Colors.white10,
          bufferedColor: AppColors.teal.withOpacity(0.3),
        ),
      );

      setState(() => _videoLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _videoLoading = false;
        _videoError = 'Failed to load video: $e';
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bangla = widget.word.banglaWord;
    final english = widget.word.englishWord;
    final hasVideo =
        widget.word.videoUrl != null && widget.word.videoUrl!.isNotEmpty;

    final steps = widget.word.steps.isNotEmpty
        ? widget.word.steps
        : [
            'Position your hand in front of the camera',
            'Form the sign for "$english"',
            'Hold the position for 1-2 seconds',
            'Keep your hand in the detection frame',
          ];

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Word card ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.teal.withOpacity(0.2)),
              ),
              child: Row(children: [
                Text(widget.word.emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bangla,
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text)),
                      Text(english,
                          style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.teal,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      StatusBadge(
                          label: widget.word.category.toUpperCase(),
                          color: AppColors.blue),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Description (if available) ─────────────────
            if (widget.word.description != null &&
                widget.word.description!.isNotEmpty) ...[
              const SectionHeader(title: 'Description'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  widget.word.description!,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Video Section ──────────────────────────────
            const SectionHeader(title: 'Tutorial Video'),

            if (hasVideo) ...[
              // Has video URL — show real player
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: _videoLoading
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                                color: AppColors.teal, strokeWidth: 2),
                            SizedBox(height: 12),
                            Text('Loading video...',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      )
                    : _videoError != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.error, size: 32),
                                  const SizedBox(height: 8),
                                  Text(
                                    _videoError!,
                                    style: const TextStyle(
                                        color: AppColors.error, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: _initVideo,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.teal,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Retry',
                                          style: TextStyle(
                                              color: AppColors.bg,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _chewieController != null
                            ? Chewie(controller: _chewieController!)
                            : const Center(
                                child: Text('Preparing video...',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12)),
                              ),
              ),
            ] else ...[
              // No video URL — show placeholder
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.word.emoji,
                        style: const TextStyle(fontSize: 60)),
                    const SizedBox(height: 12),
                    const Text('No video available',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('Video will be added soon',
                        style:
                            TextStyle(color: AppColors.textDim, fontSize: 11)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // ── How to Sign steps ──────────────────────────
            const SectionHeader(title: 'How to Sign'),
            ...steps.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.15),
                            shape: BoxShape.circle),
                        child: Center(
                          child: Text('${e.key + 1}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.teal)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(e.value,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                height: 1.4)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
