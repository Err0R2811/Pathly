import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/shared/widgets/pathly_button.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class LessonPlayerPage extends StatefulWidget {
  final String lessonId;
  const LessonPlayerPage({super.key, required this.lessonId});

  @override
  State<LessonPlayerPage> createState() => _LessonPlayerPageState();
}

class _LessonPlayerPageState extends State<LessonPlayerPage> {
  int _currentStep = 1;
  final int _totalSteps = 3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: AppConstants.spacingSm,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.neonBlackSurface
                            : AppColors.neonLightSurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.strokeDark
                              : AppColors.strokeLight,
                          width: AppConstants.cardBorderWidth,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Magic Trick #1: Coin Vanish',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.neonBlackSurface
                          : AppColors.neonLightSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AppColors.strokeDark
                            : AppColors.strokeLight,
                        width: AppConstants.cardBorderWidth,
                      ),
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Progress Bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STEP PROGRESS',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '${(_currentStep / _totalSteps * 100).toInt()}% COMPLETE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.neonGreen,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    lineHeight: 8,
                    percent: _currentStep / _totalSteps,
                    backgroundColor: isDark
                        ? AppColors.neonBlackCard
                        : const Color(0xFFE0E0E0),
                    progressColor: AppColors.neonGreen,
                    barRadius: const Radius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),

            // ─── Lesson Content ───────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media Card
                    Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.neonBlackCard
                            : AppColors.neonLightCard,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusLg),
                        border: Border.all(
                          color: isDark
                              ? AppColors.strokeDark
                              : AppColors.strokeLight,
                          width: AppConstants.cardBorderWidth,
                        ),
                        boxShadow: [
                          if (isDark)
                            BoxShadow(
                              color:
                                  AppColors.neonPurple.withValues(alpha: 0.1),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusLg - 2),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              color: const Color(0xFFF0E0D0),
                              child: const Center(
                                child: Text(
                                  '🪙',
                                  style: TextStyle(fontSize: 64),
                                ),
                              ),
                            ),
                            // Play button overlay
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.neonPink.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neonPink
                                        .withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),

                    // Content Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.spacingLg),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.neonBlackSurface
                            : AppColors.neonLightSurface,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusLg),
                        border: Border.all(
                          color: isDark
                              ? AppColors.strokeDark
                              : AppColors.strokeLight,
                          width: AppConstants.cardBorderWidth,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Phase tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusRound,
                              ),
                              border: Border.all(
                                color: AppColors.neonPink,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              'PHASE 1: THE CONCEAL',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.neonPink,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMd),

                          // Title
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Master the ',
                                  style: AppTextStyles.h2.copyWith(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Classic Palm',
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.neonPink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMd),

                          // Description
                          Text(
                            "Hold the coin between your thumb and index finger. Keep your palm facing yourself to hide the movement from your audience. It's all about the angle!",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingLg),

                          // Pro Tip
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(
                              AppConstants.spacingMd,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.neonBlackBg
                                  : AppColors.neonLightElevated,
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusMd,
                              ),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.strokeDark
                                    : AppColors.strokeLight,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '💡',
                                  style: TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Pro Tip: Relax your fingers!',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppColors.neonYellow
                                          : AppColors.textPrimaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Navigation Buttons ───────────────────────
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PathlyOutlineButton(
                      label: 'Prev',
                      onPressed: _currentStep > 1
                          ? () => setState(() => _currentStep--)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: PathlyButton(
                      label: _currentStep < _totalSteps
                          ? 'Continue'
                          : 'Complete 🎉',
                      onPressed: () {
                        if (_currentStep < _totalSteps) {
                          setState(() => _currentStep++);
                        } else {
                          context.pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
