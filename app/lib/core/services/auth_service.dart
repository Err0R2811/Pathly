import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pathly_app/infrastructure/models/user_model.dart';

class AuthService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    return 'http://10.0.2.2:8000';
  }
  static const String _tokenBox = 'auth_token';
  static const String _userBox = 'current_user';

  static Future<AuthResult> login(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/login');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['access_token'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        await _saveToken(token);
        await _saveUser(UserModel.fromJson(userData));

        return AuthResult.success(UserModel.fromJson(userData));
      } else if (response.statusCode == 401) {
        return AuthResult.failure('Invalid email or password');
      }
      return AuthResult.failure('Login failed: ${response.statusCode}');
    } catch (e) {
      return AuthResult.failure('Network error: $e');
    }
  }

  static Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/register');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['access_token'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        await _saveToken(token);
        await _saveUser(UserModel.fromJson(userData));

        return AuthResult.success(UserModel.fromJson(userData));
      } else if (response.statusCode == 409) {
        return AuthResult.failure('Email already exists');
      }
      return AuthResult.failure('Registration failed: ${response.statusCode}');
    } catch (e) {
      return AuthResult.failure('Network error: $e');
    }
  }

  static Future<void> logout() async {
    final tokenBox = Hive.box<String>(_tokenBox);
    final userBox = Hive.box<String>(_userBox);
    await tokenBox.clear();
    await userBox.clear();
  }

  static Future<UserModel?> getCurrentUser() async {
    try {
      final userBox = Hive.box<String>(_userBox);
      final userData = userBox.get('data');
      if (userData != null) {
        return UserModel.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getToken() async {
    final tokenBox = Hive.box<String>(_tokenBox);
    return tokenBox.get('token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> _saveToken(String token) async {
    final tokenBox = Hive.box<String>(_tokenBox);
    await tokenBox.put('token', token);
  }

  static Future<void> _saveUser(UserModel user) async {
    final userBox = Hive.box<String>(_userBox);
    await userBox.put('data', jsonEncode(user.toJson()));
  }

  static Future<UserModel> loginWithDemo() async {
    final demoUser = UserModel(
      id: 'demo_user_001',
      email: 'demo@pathly.app',
      name: 'Demo User',
      avatarUrl: '',
      title: 'Beginner Wizard',
      level: 5,
      xp: 1250,
      streakDays: 7,
      totalMinutes: 240,
      lessonsCompleted: 12,
      isDemo: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    final tokenBox = Hive.box<String>(_tokenBox);
    final userBox = Hive.box<String>(_userBox);

    await tokenBox.put(
      'token',
      'demo_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    await userBox.put('data', jsonEncode(demoUser.toJson()));

    return demoUser;
  }
}

class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(UserModel user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}
