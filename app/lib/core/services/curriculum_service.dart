/// HTTP client for the Pathly Curriculum API.
///
/// Pass `--dart-define=PATHLY_API_BASE_URL=https://api.example.com` for builds.
library;

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:pathly_app/core/config/api_config.dart';

class CurriculumService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Lists saved roadmaps for the current user.
  static Future<List<Map<String, dynamic>>> listRoadmaps() async {
    final token = Hive.box<String>('auth_token').get('token');
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('$baseUrl/curriculum/');
    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as List<dynamic>;
      return body.cast<Map<String, dynamic>>();
    }
    throw Exception('List roadmaps failed: ${response.statusCode}');
  }

  /// Fetches a fast draft roadmap preview for [skillName].
  /// Returns the full JSON map on success; throws on HTTP error.
  static Future<Map<String, dynamic>> fetchPreview(String skillName) async {
    final uri = Uri.parse(
      '$baseUrl/curriculum/preview?skill_name=${Uri.encodeComponent(skillName)}',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Preview failed: ${response.statusCode} ${response.body}');
  }

  /// Kicks off a full generate-review pipeline and returns the job_id.
  static Future<String> requestFullCurriculum(
    String skillName, {
    int maxRetries = 3,
    String difficulty = 'beginner',
    int deadlineWeeks = 4,
  }) async {
    final uri = Uri.parse('$baseUrl/curriculum/request');
    final token = Hive.box<String>('auth_token').get('token');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http
        .post(
          uri,
          headers: headers,
          body: jsonEncode({
            'skill_name': skillName,
            'max_retries': maxRetries,
            'difficulty': difficulty,
            'deadline_weeks': deadlineWeeks,
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 202) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['job_id'] as String;
    }
    throw Exception('Request failed: ${response.statusCode} ${response.body}');
  }

  /// Polls job status; returns a map with keys: status, progress, roadmap_id.
  static Future<Map<String, dynamic>> pollStatus(String jobId) async {
    final uri = Uri.parse('$baseUrl/curriculum/status/$jobId');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Status check failed: ${response.statusCode}');
  }

  /// Fetches the completed, verified roadmap by its [roadmapId].
  static Future<Map<String, dynamic>> fetchRoadmap(String roadmapId) async {
    final uri = Uri.parse('$baseUrl/curriculum/$roadmapId');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Fetch roadmap failed: ${response.statusCode}');
  }

  /// Deletes a saved roadmap and all its associated data.
  static Future<void> deleteRoadmap(String roadmapId) async {
    final token = Hive.box<String>('auth_token').get('token');
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    final uri = Uri.parse('$baseUrl/curriculum/$roadmapId');
    final response = await http
        .delete(uri, headers: headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }
    throw Exception('Delete roadmap failed: ${response.statusCode}');
  }
}
