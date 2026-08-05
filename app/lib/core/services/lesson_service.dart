import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class LessonService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    return 'http://10.0.2.2:8000';
  }
  static const String _tokenBox = 'auth_token';

  static Future<String?> _getToken() async {
    final tokenBox = Hive.box<String>(_tokenBox);
    return tokenBox.get('token');
  }

  /// Get all lessons for a specific module
  static Future<Map<String, dynamic>> getModuleLessons(String moduleId) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('$baseUrl/lessons/module/$moduleId');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to fetch lessons: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching module lessons: $e');
    }
  }

  /// Get detailed lesson content including steps
  static Future<Map<String, dynamic>> getLesson(String lessonId) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('$baseUrl/lessons/$lessonId');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to fetch lesson: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching lesson: $e');
    }
  }

  /// Mark a lesson as completed
  static Future<Map<String, dynamic>> completeLesson(String lessonId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final uri = Uri.parse('$baseUrl/lessons/$lessonId/complete');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to complete lesson: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error completing lesson: $e');
    }
  }

  /// Get practice quiz for a specific module
  static Future<Map<String, dynamic>> getModuleQuiz(String moduleId) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('$baseUrl/lessons/module/$moduleId/quiz');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to fetch quiz: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching module quiz: $e');
    }
  }
}
