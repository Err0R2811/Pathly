import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pathly_app/core/config/api_config.dart';

class ProgressService {
  static String get baseUrl => ApiConfig.baseUrl;
  static const String _tokenBox = 'auth_token';

  static Future<String?> _getToken() async {
    final tokenBox = Hive.box<String>(_tokenBox);
    return tokenBox.get('token');
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse('$baseUrl/progress/user-stats');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to fetch user stats: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> getDailyGoal() async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse('$baseUrl/progress/daily-goal');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to fetch daily goal: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final token = await _getToken();
      if (token == null) {
        // Return empty list for demo users or unauthenticated
        return [];
      }

      final uri = Uri.parse('$baseUrl/badges/achievements');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((item) => item as Map<String, dynamic>).toList();
      }
      // Return empty list on error instead of throwing
      return [];
    } catch (e) {
      // Return empty list on any error
      return [];
    }
  }

  static Future<void> completeLesson({
    required String roadmapId,
    String? moduleId,
    String? lessonId,
    int xpEarned = 10,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      final uri = Uri.parse('$baseUrl/progress/complete');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'roadmap_id': roadmapId,
              'module_id': moduleId,
              'lesson_id': lessonId,
              'xp_earned': xpEarned,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to complete lesson: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
