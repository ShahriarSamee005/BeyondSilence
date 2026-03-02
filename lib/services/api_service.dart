// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';

class ApiService {
  ApiService._();

  static const String baseUrl = 'https://beyond-silence-seven.vercel.app/api';

  // ─── Token helpers ─────────────────────────────────────────
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── MIME type helper ──────────────────────────────────────
  static MediaType _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'avi':
        return MediaType('video', 'x-msvideo');
      case 'webm':
        return MediaType('video', 'webm');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════════════════════

  static Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 201) {
      return body['message'] ?? 'Registered successfully';
    } else {
      throw ApiException(body['message'] ?? 'Registration failed');
    }
  }

  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) {
      await _saveToken(body['token']);
      return UserModel.fromJson(body['user']);
    } else {
      throw ApiException(body['message'] ?? 'Login failed');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FEEDBACK — WEB + MOBILE COMPATIBLE
  // ═══════════════════════════════════════════════════════════

  static Future<FeedbackModel> addFeedback({
    required String type,
    String? message,
    XFile? pickedFile,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/feedback');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['type'] = type;

    if (message != null && message.isNotEmpty) {
      request.fields['message'] = message;
    }

    // Attach file using BYTES (works on Web + Mobile)
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final fileName = pickedFile.name;
      final mimeType = _getMimeType(fileName);

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: mimeType,
        ),
      );
    }

    final streamRes = await request.send();
    final res = await http.Response.fromStream(streamRes);
    final body = jsonDecode(res.body);

    if (res.statusCode == 201 && body['success'] == true) {
      return FeedbackModel.fromJson(body['data']);
    } else {
      throw ApiException(body['message'] ?? 'Failed to submit');
    }
  }

  static Future<List<FeedbackModel>> getMyFeedback() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/feedback/my'),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => FeedbackModel.fromJson(e)).toList();
    } else {
      throw ApiException('Failed to load feedback');
    }
  }

  static Future<List<FeedbackModel>> getHistory() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/feedback/history'),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => FeedbackModel.fromJson(e)).toList();
    } else {
      throw ApiException('Failed to load history');
    }
  }

  static Future<List<FeedbackModel>> getAllFeedback() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/feedback/admin/all'),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => FeedbackModel.fromJson(e)).toList();
    } else {
      throw ApiException('Failed to load all feedback');
    }
  }

  static Future<void> approveFeedback(String id) async {
    final headers = await _authHeaders();
    final res = await http.patch(
      Uri.parse('$baseUrl/feedback/admin/$id/approve'),
      headers: headers,
    );
    if (res.statusCode != 200) {
      throw ApiException('Failed to approve');
    }
  }

  static Future<void> rejectFeedback(String id) async {
    final headers = await _authHeaders();
    final res = await http.patch(
      Uri.parse('$baseUrl/feedback/admin/$id/reject'),
      headers: headers,
    );
    if (res.statusCode != 200) {
      throw ApiException('Failed to reject');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // LEARNING
  // ═══════════════════════════════════════════════════════════

  static Future<List<LearnWord>> getAllLearningWords() async {
    final res = await http.get(
      Uri.parse('$baseUrl/learning'),
      headers: {'Content-Type': 'application/json'},
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      final List data = body['data'];
      return data.map((e) => LearnWord.fromJson(e)).toList();
    } else {
      throw ApiException('Failed to load learning words');
    }
  }

  static Future<LearnWord> getSingleLearningWord(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/learning/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return LearnWord.fromJson(body['data']);
    } else {
      throw ApiException('Word not found');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ADMIN
  // ═══════════════════════════════════════════════════════════

  static Future<List<AdminUser>> getAllUsers() async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => AdminUser.fromJson(e)).toList();
    } else {
      throw ApiException('Failed to load users');
    }
  }

  static Future<void> updateUserRole(String userId, String role) async {
    final headers = await _authHeaders();
    final res = await http.patch(
      Uri.parse('$baseUrl/admin/users/$userId/role'),
      headers: headers,
      body: jsonEncode({'role': role}),
    );

    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw ApiException(body['message'] ?? 'Failed to update role');
    }
  }

  static Future<void> deleteUser(String userId) async {
    final headers = await _authHeaders();
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/users/$userId'),
      headers: headers,
    );

    if (res.statusCode != 200) {
      throw ApiException('Failed to delete user');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
