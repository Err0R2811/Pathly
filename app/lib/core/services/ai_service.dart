import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pathly_app/core/services/auth_service.dart';

class AIService {
  static Future<String?> _getAuthToken() async {
    final box = await Hive.openBox('auth_token');
    return box.get('token') as String?;
  }

  static Future<String?> explainConcept(String concept, {String? lessonId}) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final uri = Uri.parse('${AuthService.baseUrl}/ai/explain');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'concept': concept,
          if (lessonId != null) 'lesson_id': lessonId,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['explanation'] as String?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error explaining concept: $e');
      return null;
    }
  }

  static Future<String?> getQuizHint(String question, List<String> options) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final uri = Uri.parse('${AuthService.baseUrl}/ai/quiz-hint');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'question': question,
          'options': options,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['hint'] as String?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting quiz hint: $e');
      return null;
    }
  }
}
