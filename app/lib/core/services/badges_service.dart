import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pathly_app/core/services/auth_service.dart';

class BadgesService {
  static Future<String?> _getAuthToken() async {
    final box = await Hive.openBox('auth_token');
    return box.get('token') as String?;
  }

  static Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return [];

      final uri = Uri.parse('${AuthService.baseUrl}/badges/achievements');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error fetching achievements: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMyBadges() async {
    try {
      final token = await _getAuthToken();
      if (token == null) return [];

      final uri = Uri.parse('${AuthService.baseUrl}/badges/my');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error fetching my badges: $e');
      return [];
    }
  }
}
