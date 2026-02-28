class UserModel {
  final String name, email, role;
  const UserModel({required this.name, required this.email, required this.role});
  bool get isAdmin => role == 'admin';
}

class HistoryEntry {
  final String word, time;
  final int confidencePercent;
  const HistoryEntry({required this.word, required this.confidencePercent, required this.time});
}

class PostModel {
  final String id, userName, userRole, content, timestamp;
  final bool hasImage, hasVideo;
  const PostModel({
    required this.id, required this.userName, required this.userRole,
    required this.content, required this.timestamp,
    this.hasImage = false, this.hasVideo = false,
  });
}

class LearnWord {
  final String word, emoji, category;
  const LearnWord({required this.word, required this.emoji, required this.category});
}

class DummyData {
  DummyData._();

  static const List<HistoryEntry> historyEntries = [
    HistoryEntry(word: 'ভাই (Bhai)', confidencePercent: 92, time: '10:35 PM'),
    HistoryEntry(word: 'মা (Maa)', confidencePercent: 88, time: '10:37 PM'),
    HistoryEntry(word: 'ডাক্তার (Doctor)', confidencePercent: 95, time: '10:41 PM'),
    HistoryEntry(word: 'বন্ধু (Friend)', confidencePercent: 79, time: '10:44 PM'),
    HistoryEntry(word: 'বই (Book)', confidencePercent: 84, time: '10:48 PM'),
    HistoryEntry(word: 'স্কুল (School)', confidencePercent: 91, time: '10:52 PM'),
    HistoryEntry(word: 'পানি (Water)', confidencePercent: 87, time: '11:02 PM'),
    HistoryEntry(word: 'হ্যাঁ (Yes)', confidencePercent: 97, time: '11:10 PM'),
  ];

  static const List<LearnWord> learnWords = [
    LearnWord(word: 'মা\nMaa', emoji: '👩', category: 'Family'),
    LearnWord(word: 'ভাই\nBhai', emoji: '👦', category: 'Family'),
    LearnWord(word: 'ডাক্তার\nDoctor', emoji: '🩺', category: 'Profession'),
    LearnWord(word: 'স্কুল\nSchool', emoji: '🏫', category: 'Places'),
    LearnWord(word: 'বন্ধু\nFriend', emoji: '🤝', category: 'Social'),
    LearnWord(word: 'বই\nBook', emoji: '📚', category: 'Objects'),
    LearnWord(word: 'পানি\nWater', emoji: '💧', category: 'Basics'),
    LearnWord(word: 'হ্যাঁ\nYes', emoji: '✅', category: 'Basics'),
    LearnWord(word: 'না\nNo', emoji: '❌', category: 'Basics'),
    LearnWord(word: 'ধন্যবাদ\nThankYou', emoji: '🙏', category: 'Social'),
    LearnWord(word: 'বাড়ি\nHome', emoji: '🏠', category: 'Places'),
    LearnWord(word: 'খাবার\nFood', emoji: '🍚', category: 'Basics'),
  ];

  static const List<PostModel> dummyPosts = [
    PostModel(id: '1', userName: 'Rahim Uddin', userRole: 'user',
        content: 'Just practiced the Family category. Really improving!',
        timestamp: '2 hours ago', hasImage: true),
    PostModel(id: '2', userName: 'Nadia Islam', userRole: 'user',
        content: 'The detection feature is amazing!',
        timestamp: '4 hours ago'),
    PostModel(id: '3', userName: 'Karim Hossain', userRole: 'admin',
        content: 'New lesson pack added: Professions. Check the Learn tab!',
        timestamp: '1 day ago', hasVideo: true),
    PostModel(id: '4', userName: 'Sara Ahmed', userRole: 'user',
        content: 'Can we add more words in the basics category?',
        timestamp: '2 days ago'),
  ];
}