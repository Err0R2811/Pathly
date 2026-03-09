/// HTTP client for the Pathly Curriculum API.
///
/// All calls target the FastAPI backend running on localhost:8000.
/// Override [baseUrl] via a build flavor or environment variable if needed.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;

class CurriculumService {
  static const String baseUrl =
      'http://10.0.2.2:8000'; // Android emulator → host localhost

  // ── Preview (synchronous) ──────────────────────────────────────────────────

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

  // ── Full generation (async job) ────────────────────────────────────────────

  /// Kicks off a full generate-review pipeline and returns the job_id.
  static Future<String> requestFullCurriculum(
    String skillName, {
    String userId = 'anonymous',
    int maxRetries = 3,
  }) async {
    final uri = Uri.parse('$baseUrl/curriculum/request');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'skill_name': skillName,
            'user_id': userId,
            'max_retries': maxRetries,
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
}
