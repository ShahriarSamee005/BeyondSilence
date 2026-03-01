import 'package:flutter/material.dart';
import '../services/app_theme.dart';
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
  bool _hasImage = false;
  bool _hasVideo = false;
  List<PostModel> _posts = List.from(DummyData.dummyPosts);

  @override
  void dispose() { _postCtrl.dispose(); super.dispose(); }

  void _submitPost() {
    final text = _postCtrl.text.trim();
    if (text.isEmpty && !_hasImage && !_hasVideo) return;
    setState(() {
      _posts.insert(0, PostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userName: widget.user.name,
        userRole: widget.user.role,
        content: text.isEmpty ? '[Media post]' : text,
        timestamp: 'Just now',
        hasImage: _hasImage,
        hasVideo: _hasVideo,
      ));
      _postCtrl.clear();
      _hasImage = false;
      _hasVideo = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published!')));
  }

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
        
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isAdmin ? AppColors.adminGold.withOpacity(0.3) : AppColors.teal.withOpacity(0.2)),
            ),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: isAdmin
                      ? [AppColors.adminGold, const Color(0xFFFF8C00)]
                      : [AppColors.teal, AppColors.blue]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(widget.user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white))),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.text)),
                const SizedBox(height: 3),
                Text(widget.user.email, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 6),
                StatusBadge(label: widget.user.role.toUpperCase(),
                    color: isAdmin ? AppColors.adminGold : AppColors.teal),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
        
          // Admin notice
          if (isAdmin) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.adminGold.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.adminGold.withOpacity(0.25)),
              ),
              child: Row(children: [
                const Icon(Icons.admin_panel_settings_rounded, color: AppColors.adminGold, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Admin Panel — View User Posts',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.adminGold)),
                  const SizedBox(height: 2),
                  const Text('You can view and delete any user post below.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ])),
              ]),
            ),
            const SizedBox(height: 16),
          ],
        
          // Create post
          const SectionHeader(title: 'Create Post'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: [
              TextField(
                controller: _postCtrl, maxLines: 3,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Share your progress...',
                  border: InputBorder.none, enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none, fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 10),
              Row(children: [
                GestureDetector(
                  onTap: () => setState(() => _hasImage = !_hasImage),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _hasImage ? AppColors.blue.withOpacity(0.1) : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _hasImage ? AppColors.blue.withOpacity(0.4) : AppColors.border),
                    ),
                    child: Row(children: [
                      Icon(Icons.image_outlined, size: 16, color: _hasImage ? AppColors.blue : AppColors.textMuted),
                      const SizedBox(width: 5),
                      Text('Image', style: TextStyle(fontSize: 12, color: _hasImage ? AppColors.blue : AppColors.textMuted, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _hasVideo = !_hasVideo),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _hasVideo ? AppColors.error.withOpacity(0.1) : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _hasVideo ? AppColors.error.withOpacity(0.4) : AppColors.border),
                    ),
                    child: Row(children: [
                      Icon(Icons.videocam_outlined, size: 16, color: _hasVideo ? AppColors.error : AppColors.textMuted),
                      const SizedBox(width: 5),
                      Text('Video', style: TextStyle(fontSize: 12, color: _hasVideo ? AppColors.error : AppColors.textMuted, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _submitPost,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(9)),
                    child: const Text('Post', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.bg)),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
        
          SectionHeader(title: isAdmin ? 'All User Posts' : 'My Posts', trailing: '${_posts.length}'),
          ..._posts.map((post) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card, borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 34, height: 34,
                    decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
                    child: Center(child: Text(post.userName.substring(0, 1),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.teal, fontSize: 14)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(post.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(width: 6),
                    StatusBadge(label: post.userRole.toUpperCase(),
                        color: post.userRole == 'admin' ? AppColors.adminGold : AppColors.teal),
                  ]),
                  Text(post.timestamp, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ])),
                if (isAdmin)
                  GestureDetector(
                    onTap: () => setState(() => _posts.remove(post)),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(7)),
                      child: const Icon(Icons.delete_outline, size: 14, color: AppColors.error),
                    ),
                  ),
              ]),
              const SizedBox(height: 10),
              Text(post.content, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
              if (post.hasImage || post.hasVideo) ...[
                const SizedBox(height: 8),
                Row(children: [
                  if (post.hasImage) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: AppColors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.blue.withOpacity(0.2))),
                    child: const Row(children: [Icon(Icons.image_outlined, size: 12, color: AppColors.blue), SizedBox(width: 4), Text('Image', style: TextStyle(fontSize: 10, color: AppColors.blue))]),
                  ),
                  if (post.hasVideo) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.error.withOpacity(0.2))),
                    child: const Row(children: [Icon(Icons.videocam_outlined, size: 12, color: AppColors.error), SizedBox(width: 4), Text('Video', style: TextStyle(fontSize: 10, color: AppColors.error))]),
                  ),
                ]),
              ],
            ]),
          )).toList(),
        ]),
      ),
    );
  }
}