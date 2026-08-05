import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pathly_app/core/services/auth_service.dart';

class LeaderboardService {
  static Future<String?> _getAuthToken() async {
    final box = await Hive.openBox('auth_token');
    return box.get('token') as String?;
  }

  static Future<List<Map<String, dynamic>>> getLeaderboard({
    String type = 'all_time',
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return [];

      final uri = Uri.parse('${AuthService.baseUrl}/leaderboard')
          .replace(queryParameters: {
        'leaderboard_type': type,
        'limit': limit.toString(),
        'offset': offset.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['entries'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error fetching leaderboard: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getMyRank({
    String type = 'all_time',
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return null;

      final uri = Uri.parse('${AuthService.baseUrl}/leaderboard/my-rank')
          .replace(queryParameters: {
        'leaderboard_type': type,
      });

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
      return null;
    } catch (e) {
      if (kDebugMode) print('Error fetching my rank: $e');
      return null;
    }
  }
}
