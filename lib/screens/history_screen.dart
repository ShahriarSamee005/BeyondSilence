// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<FeedbackModel> _history = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final data = await ApiService.getHistory();

      if (!mounted) return;
      setState(() {
        _history = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: _loadHistory,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AppBackground(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.teal, strokeWidth: 2))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 40),
                          const SizedBox(height: 12),
                          Text(_error!,
                              style: const TextStyle(
                                  color: AppColors.error, fontSize: 13),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _loadHistory,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.teal,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Retry',
                                  style: TextStyle(
                                      color: AppColors.bg,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.history_rounded,
                                color: AppColors.textDim, size: 48),
                            SizedBox(height: 12),
                            Text('No history yet',
                                style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('Your approved translations will appear here',
                                style: TextStyle(
                                    color: AppColors.textDim, fontSize: 12)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.teal,
                        backgroundColor: AppColors.card,
                        onRefresh: _loadHistory,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _history.length + 1, // +1 for header
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: SectionHeader(
                                    title: 'Approved Translations',
                                    trailing: '${_history.length} items'),
                              );
                            }

                            final fb = _history[index - 1];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  // Type icon
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.teal.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Icon(
                                      fb.type == 'image'
                                          ? Icons.image_outlined
                                          : fb.type == 'video'
                                              ? Icons.videocam_outlined
                                              : Icons.text_fields_rounded,
                                      color: AppColors.teal,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fb.message ?? fb.type,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          fb.timeAgo,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const StatusBadge(
                                    label: 'APPROVED',
                                    color: AppColors.success,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
