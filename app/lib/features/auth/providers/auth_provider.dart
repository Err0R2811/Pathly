import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pathly_app/core/services/auth_service.dart';
import 'package:pathly_app/infrastructure/models/user_model.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      state = AuthState(user: user);
    } else {
      state = const AuthState();
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await AuthService.login(email, password);
    
    if (result.isSuccess && result.user != null) {
      state = AuthState(user: result.user);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await AuthService.register(name, email, password);
    
    if (result.isSuccess && result.user != null) {
      state = AuthState(user: result.user);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorMessage,
      );
      return false;
    }
  }

  Future<bool> loginWithDemo() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await AuthService.loginWithDemo();
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to login with demo',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
