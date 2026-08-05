import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pathly_app/core/services/auth_service.dart';

class SearchService {
  static Future<String?> _getAuthToken() async {
    final box = await Hive.openBox('auth_token');
    return box.get('token') as String?;
  }

  static Future<List<Map<String, dynamic>>> searchContent(
    String query, {
    int limit = 10,
    String? contentType,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) return [];

      final queryParams = {
        'q': query,
        'limit': limit.toString(),
      };
      if (contentType != null) {
        queryParams['content_type'] = contentType;
      }

      final uri = Uri.parse('${AuthService.baseUrl}/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['results'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print('Error searching content: $e');
      return [];
    }
  }
}
