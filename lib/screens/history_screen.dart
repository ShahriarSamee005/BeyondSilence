import 'package:flutter/material.dart';
import '../services/app_theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _entries = List.from(DummyData.historyEntries);

  void _deleteAll() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
      title: const Text('Clear History', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
      content: const Text('Delete all history entries?', style: TextStyle(color: AppColors.textMuted)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
        ElevatedButton(
          onPressed: () { setState(() => _entries = []); Navigator.pop(context); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white,
              elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Clear All'),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context)),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                onPressed: _deleteAll),
        ],
      ),
      body: _entries.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.history_rounded, size: 64, color: AppColors.textMuted.withOpacity(0.4)),
              const SizedBox(height: 16),
              const Text('No history yet', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
            ]))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final e = _entries[i];
                final color = e.confidencePercent >= 90 ? AppColors.success
                    : e.confidencePercent >= 75 ? AppColors.warning : AppColors.error;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card, borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
                      child: Center(child: Text('${i + 1}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.teal))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(e.word, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                      const SizedBox(height: 3),
                      Text(e.time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${e.confidencePercent}%',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: e.confidencePercent / 100,
                            backgroundColor: Colors.white10,
                            color: color, minHeight: 3,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _entries.removeAt(i)),
                      child: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}