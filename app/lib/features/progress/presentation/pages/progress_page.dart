import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/features/dashboard/providers/dashboard_provider.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProgressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ──────────────────────────────────
              Text(
                'Your Progress',
                style: AppTextStyles.h1.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your learning journey',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // ─── XP Progress Card ─────────────────────────
              userProgressAsync.when(
                data: (userProgress) {
                  return Column(
                    children: [
                      _XPProgressCard(
                        isDark: isDark,
                        currentXP: userProgress.xp,
                        level: userProgress.level,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),

                      // ─── Stats Grid ───────────────────────────────
                      _StatsGrid(
                        isDark: isDark,
                        streakDays: userProgress.streakDays,
                        totalMinutes: userProgress.totalMinutes,
                        lessonsCompleted: userProgress.lessonsCompleted,
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // ─── Recent Activity ─────────────────────────
              Text(
                'RECENT ACTIVITY',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              _RecentActivityList(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _XPProgressCard extends StatelessWidget {
  final bool isDark;
  final int currentXP;
  final int level;

  const _XPProgressCard({
    required this.isDark,
    required this.currentXP,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final xpForNextLevel = (level + 1) * 100;
    final xpInCurrentLevel = currentXP % 100;
    final progress = xpInCurrentLevel / 100.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.neonPurple.withValues(alpha: isDark ? 0.2 : 0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          width: AppConstants.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level',
                style: AppTextStyles.h2.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                '$xpInCurrentLevel / 100 XP',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.neonBlackCard
                  : AppColors.neonLightElevated,
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.neonPurple,
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            '${xpForNextLevel - currentXP} XP to Level ${level + 1}',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final bool isDark;
  final int streakDays;
  final int totalMinutes;
  final int lessonsCompleted;

  const _StatsGrid({
    required this.isDark,
    required this.streakDays,
    required this.totalMinutes,
    required this.lessonsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '$streakDays days',
            color: AppColors.neonPink,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatItem(
            icon: Icons.schedule_rounded,
            label: 'Time',
            value: '${totalMinutes}m',
            color: AppColors.neonTeal,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatItem(
            icon: Icons.check_circle_rounded,
            label: 'Lessons',
            value: '$lessonsCompleted',
            color: AppColors.neonPurple,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          width: AppConstants.cardBorderWidth,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  final bool isDark;
  const _RecentActivityList({required this.isDark});

  final _activities = const [
    _Activity('Completed Magic Trick #1', '2 hours ago', Icons.check_circle),
    _Activity('Started Coin Vanish module', '5 hours ago', Icons.play_circle),
    _Activity('Earned "Spark" badge', '1 day ago', Icons.emoji_events),
    _Activity('7-day streak achieved', '2 days ago', Icons.local_fire_department),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: isDark ? AppColors.neonBlackCard : AppColors.neonLightSurface,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
              width: AppConstants.cardBorderWidth,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neonPink.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity.icon,
                  color: AppColors.neonPink,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      activity.time,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Activity {
  final String title;
  final String time;
  final IconData icon;
  const _Activity(this.title, this.time, this.icon);
}
