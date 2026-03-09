import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/shared/widgets/pathly_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _goalController = TextEditingController(text: 'Magic Tricks');
  final _durationController = TextEditingController(text: 'Maybe 15 mins?');
  final int _currentStep = 1;
  final int _totalSteps = 3;

  @override
  void dispose() {
    _goalController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            children: [
              // ─── Top Bar: Back + Progress + Step Counter ────
              Row(
                children: [
                  _BackButton(isDark: isDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProgressBar(
                      progress: _currentStep / _totalSteps,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$_currentStep/$_totalSteps',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingXl),

              // ─── Rocket Icon ────────────────────────────────
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                  border: Border.all(
                    color:
                        isDark ? AppColors.strokeDark : AppColors.strokeLight,
                    width: AppConstants.cardBorderWidth,
                  ),
                  boxShadow: [
                    if (isDark)
                      BoxShadow(
                        color: AppColors.neonGreen.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                  ],
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // ─── Heading ────────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Let's learn\n",
                      style: AppTextStyles.h1.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    TextSpan(
                      text: 'something cool!',
                      style: AppTextStyles.h1.copyWith(
                        color: isDark
                            ? AppColors.neonGreen
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXl),

              // ─── Goal Input ─────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      "What's the goal?",
                      style: AppTextStyles.h3.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('🎯', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextField(
                controller: _goalController,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // ─── Duration Input ─────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'How long per day?',
                      style: AppTextStyles.h3.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('⏱️', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextField(
                controller: _durationController,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Little steps lead to big jumps! 🐇',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neonPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              // ─── CTA Button ─────────────────────────────────
              const Text('⭐', style: TextStyle(fontSize: 28)),
              const SizedBox(height: AppConstants.spacingSm),
              PathlyButton(
                label: 'START MY JOURNEY',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: AppConstants.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final bool isDark;
  const _BackButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          width: AppConstants.cardBorderWidth,
        ),
      ),
      child: Icon(
        Icons.arrow_back_rounded,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 14,
      decoration: BoxDecoration(
        color: isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(
          color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          width: 2.0,
        ),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.neonPink,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
          ),
        ),
      ),
    );
  }
}
