import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _configuredBaseUrl =
      String.fromEnvironment('PATHLY_API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _normalize(_configuredBaseUrl);
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    return 'https://pathly-backend-5fow.onrender.com';
  }

  static String _normalize(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
