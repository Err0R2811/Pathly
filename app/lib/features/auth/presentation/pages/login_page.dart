import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/shared/widgets/pathly_button.dart';
import 'package:pathly_app/features/auth/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    final success = await ref.read(authStateProvider.notifier).login(email, password);
    
    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      final error = ref.read(authStateProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Login failed')),
      );
    }
  }

  Future<void> _loginWithDemo() async {
    try {
      final success = await ref.read(authStateProvider.notifier).loginWithDemo();
      
      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        final error = ref.read(authStateProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Login failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.neonBlackBg : AppColors.neonLightBg;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingXl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spacingXl),

              // ── Logo / Brand ─────────────────────────────
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.neonPink.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isDark ? AppColors.strokeDark : AppColors.strokeLight,
                      width: AppConstants.cardBorderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPink.withValues(alpha: 0.3),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🚀', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              Text(
                'Welcome back!',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue your journey',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXl),

              // ── Email ────────────────────────────────────
              _InputLabel(label: 'Email', isDark: isDark),
              const SizedBox(height: 6),
              _TextField(
                controller: _emailController,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                isDark: isDark,
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // ── Password ─────────────────────────────────
              _InputLabel(label: 'Password', isDark: isDark),
              const SizedBox(height: 6),
              _TextField(
                controller: _passwordController,
                hint: '••••••••',
                obscureText: _obscurePassword,
                isDark: isDark,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password?',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.neonPink),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // ── Login Button ──────────────────────────────
              Consumer(
                builder: (context, ref, _) {
                  final isLoading = ref.watch(authStateProvider).isLoading;
                  return PathlyButton(
                    label: 'Sign In',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _login,
                  );
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // ── Demo Login ─────────────────────────────────
              TextButton(
                onPressed: _loginWithDemo,
                child: Text(
                  'Try Demo Account',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neonPink,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // ── Divider ───────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color:
                          isDark ? AppColors.strokeDark : AppColors.strokeLight,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color:
                          isDark ? AppColors.strokeDark : AppColors.strokeLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // ── Google Sign-In ────────────────────────────
              _SocialButton(
                label: 'Continue with Google',
                emoji: '🔵',
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google sign-in coming soon!')),
                  );
                },
              ),
              const SizedBox(height: AppConstants.spacingXl),

              // ── Register link ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text(
                      'Sign Up',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neonPink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _InputLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _InputLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelLarge.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isDark;
  final Widget? suffixIcon;

  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.isDark,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        filled: true,
        fillColor:
            isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          borderSide: BorderSide(
            color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
            width: AppConstants.cardBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          borderSide: BorderSide(
            color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
            width: AppConstants.cardBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          borderSide: const BorderSide(color: AppColors.neonPink, width: 2.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isDark;
  final VoidCallback onTap;
  const _SocialButton({
    required this.label,
    required this.emoji,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          border: Border.all(
            color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
            width: AppConstants.cardBorderWidth,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
