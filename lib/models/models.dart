// lib/models/models.dart

class UserModel {
  final String id, name, email, role;
  final String? profilePicture;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePicture,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'profilePicture': profilePicture,
      };
}

class HistoryEntry {
  final String word, time;
  final int confidencePercent;

  const HistoryEntry({
    required this.word,
    required this.confidencePercent,
    required this.time,
  });
}

class FeedbackModel {
  final String id;
  final String type;
  final String? message;
  final String? mediaUrl;
  final String status;
  final String userId;
  final String? userEmail;
  final String createdAt;

  const FeedbackModel({
    required this.id,
    required this.type,
    this.message,
    this.mediaUrl,
    required this.status,
    required this.userId,
    this.userEmail,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    // Handle populated user field (admin endpoint) vs plain user id
    String userId = '';
    String? userEmail;

    if (json['user'] is Map) {
      userId = json['user']['_id'] ?? '';
      userEmail = json['user']['email'];
    } else {
      userId = json['user'] ?? '';
    }

    return FeedbackModel(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      message: json['message'],
      mediaUrl: json['mediaUrl'],
      status: json['status'] ?? 'pending',
      userId: userId,
      userEmail: userEmail,
      createdAt: json['createdAt'] ?? '',
    );
  }

  String get timeAgo {
    try {
      final dt = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }
}

class LearnWord {
  final String id;
  final String banglaWord;
  final String englishWord;
  final String emoji;
  final String category;
  final String? videoUrl;
  final String? description;
  final List<String> steps;

  const LearnWord({
    required this.id,
    required this.banglaWord,
    required this.englishWord,
    required this.emoji,
    required this.category,
    this.videoUrl,
    this.description,
    this.steps = const [],
  });

  // Combined display like the original "মা\nMaa"
  String get word => '$banglaWord\n$englishWord';

  factory LearnWord.fromJson(Map<String, dynamic> json) {
    return LearnWord(
      id: json['_id'] ?? json['id'] ?? '',
      banglaWord: json['banglaWord'] ?? '',
      englishWord: json['englishWord'] ?? '',
      emoji: json['emoji'] ?? '🤟',
      category: json['category'] ?? 'Basics',
      videoUrl: json['videoUrl'],
      description: json['description'],
      steps: json['steps'] != null ? List<String>.from(json['steps']) : [],
    );
  }
}

class AdminUser {
  final String id, name, email, role;
  final bool isVerified;
  final String? profilePicture;
  final String? createdAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isVerified,
    this.profilePicture,
    this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      isVerified: json['isVerified'] ?? false,
      profilePicture: json['profilePicture'],
      createdAt: json['createdAt'],
    );
  }
}
