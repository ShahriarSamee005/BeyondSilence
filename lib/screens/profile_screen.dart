// lib/screens/profile_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/app_theme.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _postCtrl = TextEditingController();
  final _picker = ImagePicker();

  XFile? _selectedFile;
  Uint8List? _selectedFileBytes;
  String _fileType = 'none'; // 'none', 'image', 'video'

  List<FeedbackModel> _feedbacks = [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  @override
  void dispose() {
    _postCtrl.dispose();
    super.dispose();
  }

  // ─── Load feedbacks ──────────────────────────────────────────
  Future<void> _loadFeedbacks() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      List<FeedbackModel> data;
      if (widget.user.isAdmin) {
        data = await ApiService.getAllFeedback();
      } else {
        data = await ApiService.getMyFeedback();
      }

      if (!mounted) return;
      setState(() {
        _feedbacks = data;
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

  // ─── Pick image (Web + Mobile) ───────────────────────────────
  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedFile = picked;
          _selectedFileBytes = bytes;
          _fileType = 'image';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  // ─── Pick video (Web + Mobile) ───────────────────────────────
  Future<void> _pickVideo() async {
    try {
      final picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedFile = picked;
          _selectedFileBytes = bytes;
          _fileType = 'video';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error picking video: $e')));
    }
  }

  // ─── Remove selected file ───────────────────────────────────
  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _selectedFileBytes = null;
      _fileType = 'none';
    });
  }

  // ─── Submit post ─────────────────────────────────────────────
  Future<void> _submitPost() async {
    final text = _postCtrl.text.trim();
    if (text.isEmpty && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please write something or attach a file')));
      return;
    }

    setState(() => _submitting = true);

    try {
      String type = 'text';
      if (_fileType == 'image') type = 'image';
      if (_fileType == 'video') type = 'video';

      await ApiService.addFeedback(
        type: type,
        message: text.isNotEmpty ? text : null,
        pickedFile: _selectedFile,
      );

      if (!mounted) return;

      _postCtrl.clear();
      _removeFile();

      setState(() => _submitting = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Post published!')));

      _loadFeedbacks();
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ─── Admin actions ───────────────────────────────────────────
  Future<void> _approveFeedback(FeedbackModel feedback) async {
    try {
      await ApiService.approveFeedback(feedback.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Feedback approved')));
      _loadFeedbacks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectFeedback(FeedbackModel feedback) async {
    try {
      await ApiService.rejectFeedback(feedback.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Feedback rejected')));
      _loadFeedbacks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  // ─── BUILD ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.user.isAdmin;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Panel' : 'Profile'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context)),
      ),
      body: AppBackground(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          // ── Profile card ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: isAdmin
                      ? AppColors.adminGold.withOpacity(0.3)
                      : AppColors.teal.withOpacity(0.2)),
            ),
            child: Row(children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: isAdmin
                          ? [AppColors.adminGold, const Color(0xFFFF8C00)]
                          : [AppColors.teal, AppColors.blue]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: widget.user.profilePicture != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.user.profilePicture!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              widget.user.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          widget.user.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.user.name,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text)),
                    const SizedBox(height: 3),
                    Text(widget.user.email,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    StatusBadge(
                        label: widget.user.role.toUpperCase(),
                        color: isAdmin ? AppColors.adminGold : AppColors.teal),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // ── Admin notice ─────────────────────────────────
          if (isAdmin) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.adminGold.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.adminGold.withOpacity(0.25)),
              ),
              child: const Row(children: [
                Icon(Icons.admin_panel_settings_rounded,
                    color: AppColors.adminGold, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin Panel — View User Feedback',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.adminGold)),
                      SizedBox(height: 2),
                      Text(
                          'You can view, approve and reject any user feedback.',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
          ],

          // ── Create post ──────────────────────────────────
          const SectionHeader(title: 'Create Post'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              TextField(
                controller: _postCtrl,
                maxLines: 3,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Share your progress...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              // ── File preview (Web safe — uses bytes) ─────
              if (_selectedFile != null && _selectedFileBytes != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    if (_fileType == 'image')
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(
                          _selectedFileBytes!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.videocam_rounded,
                            color: AppColors.error, size: 24),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileType == 'image'
                                ? 'Image selected'
                                : 'Video selected',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text),
                          ),
                          Text(
                            _selectedFile!.name,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _removeFile,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.error),
                      ),
                    ),
                  ]),
                ),
              ],

              const SizedBox(height: 10),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 10),

              // ── Action buttons ───────────────────────────
              Row(children: [
                GestureDetector(
                  onTap: _submitting ? null : _pickImage,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _fileType == 'image'
                          ? AppColors.blue.withOpacity(0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _fileType == 'image'
                              ? AppColors.blue.withOpacity(0.4)
                              : AppColors.border),
                    ),
                    child: Row(children: [
                      Icon(Icons.image_outlined,
                          size: 16,
                          color: _fileType == 'image'
                              ? AppColors.blue
                              : AppColors.textMuted),
                      const SizedBox(width: 5),
                      Text('Image',
                          style: TextStyle(
                              fontSize: 12,
                              color: _fileType == 'image'
                                  ? AppColors.blue
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _submitting ? null : _pickVideo,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _fileType == 'video'
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _fileType == 'video'
                              ? AppColors.error.withOpacity(0.4)
                              : AppColors.border),
                    ),
                    child: Row(children: [
                      Icon(Icons.videocam_outlined,
                          size: 16,
                          color: _fileType == 'video'
                              ? AppColors.error
                              : AppColors.textMuted),
                      const SizedBox(width: 5),
                      Text('Video',
                          style: TextStyle(
                              fontSize: 12,
                              color: _fileType == 'video'
                                  ? AppColors.error
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _submitting ? null : _submitPost,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                        color: _submitting
                            ? AppColors.teal.withOpacity(0.5)
                            : AppColors.teal,
                        borderRadius: BorderRadius.circular(9)),
                    child: _submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.bg))
                        : const Text('Post',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.bg)),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Feedback list ────────────────────────────────
          SectionHeader(
              title: isAdmin ? 'All User Feedback' : 'My Feedback',
              trailing: _loading ? '...' : '${_feedbacks.length}'),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.teal, strokeWidth: 2)),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(children: [
                  Text(_error!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 13)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _loadFeedbacks,
                    child: const Text('Tap to retry',
                        style: TextStyle(color: AppColors.teal, fontSize: 13)),
                  ),
                ]),
              ),
            )
          else if (_feedbacks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No feedback yet',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
            )
          else
            ..._feedbacks.map((fb) => _buildFeedbackCard(fb, isAdmin)).toList(),
        ]),
      ),
    );
  }

  // ─── Feedback card ───────────────────────────────────────────
  Widget _buildFeedbackCard(FeedbackModel fb, bool isAdmin) {
    final displayName = fb.userEmail ?? 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9)),
                child: Center(
                    child: Text(initial,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.teal,
                            fontSize: 14)))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(displayName,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 6),
                    StatusBadge(
                        label: fb.status.toUpperCase(),
                        color: _statusColor(fb.status)),
                  ]),
                  Text(fb.timeAgo,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
            if (isAdmin) ...[
              if (fb.status == 'pending') ...[
                GestureDetector(
                  onTap: () => _approveFeedback(fb),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(7)),
                    child: const Icon(Icons.check,
                        size: 14, color: AppColors.success),
                  ),
                ),
              ],
              GestureDetector(
                onTap: () => _rejectFeedback(fb),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(7)),
                  child:
                      const Icon(Icons.close, size: 14, color: AppColors.error),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 10),
          Text(fb.message ?? '[No message]',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted, height: 1.5)),
          if (fb.type != 'text') ...[
            const SizedBox(height: 8),
            Row(children: [
              if (fb.type == 'image' || fb.type == 'media')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: AppColors.blue.withOpacity(0.2))),
                  child: const Row(children: [
                    Icon(Icons.image_outlined, size: 12, color: AppColors.blue),
                    SizedBox(width: 4),
                    Text('Image',
                        style: TextStyle(fontSize: 10, color: AppColors.blue))
                  ]),
                ),
              if (fb.type == 'video' || fb.type == 'media')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: AppColors.error.withOpacity(0.2))),
                  child: const Row(children: [
                    Icon(Icons.videocam_outlined,
                        size: 12, color: AppColors.error),
                    SizedBox(width: 4),
                    Text('Video',
                        style: TextStyle(fontSize: 10, color: AppColors.error))
                  ]),
                ),
            ]),
          ],
          if (fb.mediaUrl != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                fb.mediaUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 180,
                    color: AppColors.surface,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.teal, strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: AppColors.textDim, size: 18),
                        SizedBox(width: 8),
                        Text('Media unavailable',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
