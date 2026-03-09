import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pathly_app/features/auth/providers/auth_provider.dart';
import 'package:pathly_app/features/dashboard/providers/dashboard_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Greeting Header ──────────────────────────
              _GreetingHeader(isDark: isDark),
              const SizedBox(height: AppConstants.spacingLg),

              // ─── Current Skill Card ───────────────────────
              _CurrentSkillCard(isDark: isDark),
              const SizedBox(height: AppConstants.spacingMd),

              // ─── Daily Goal Card ──────────────────────────
              _DailyGoalCard(isDark: isDark),
              const SizedBox(height: AppConstants.spacingLg),

              // ─── Quick Actions ────────────────────────────
              Text(
                'QUICK ACTIONS',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              _QuickActionsRow(isDark: isDark),
              const SizedBox(height: AppConstants.spacingLg),

              // ─── Achievements Preview ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ACHIEVEMENTS',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'VIEW ALL',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.neonPink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              _AchievementPreview(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Greeting Header ──────────────────────────────────────────
class _GreetingHeader extends ConsumerWidget {
  final bool isDark;
  const _GreetingHeader({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userName = authState.user?.name ?? 'there';
    
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.pastelPeach,
          child: Text(
            authState.user?.avatarUrl.isNotEmpty == true 
                ? '' 
                : '📔', 
            style: const TextStyle(fontSize: 22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey $userName 👋',
                style: AppTextStyles.h3.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                'Ready to grow today?',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color:
                isDark ? AppColors.neonBlackCard : AppColors.neonLightSurface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
              width: AppConstants.cardBorderWidth,
            ),
          ),
          child: Icon(
            Icons.notifications_rounded,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

// ─── Current Skill Card ───────────────────────────────────────
class _CurrentSkillCard extends ConsumerWidget {
  final bool isDark;
  const _CurrentSkillCard({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    
    return GestureDetector(
      onTap: () => context.push('/curriculum/preview'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A28) : AppColors.pastelMint,
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.neonBlackSurface.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                    border: Border.all(
                      color:
                          isDark ? AppColors.strokeDark : AppColors.strokeLight,
                    ),
                  ),
                  child: Text(
                    'CURRENT SKILL',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.neonTeal
                          : AppColors.textPrimaryLight,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.neonBlackBg : Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    border: Border.all(
                      color:
                          isDark ? AppColors.strokeDark : AppColors.strokeLight,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.rocket_launch_rounded,
                    color:
                        isDark ? AppColors.neonTeal : AppColors.textPrimaryLight,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              progress.currentSkill,
              style: AppTextStyles.h2.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.progressPercentage}% Complete',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${progress.lessonsCompleted}/${progress.totalLessons} Lessons',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 10,
              percent: progress.progressPercentage / 100,
              backgroundColor:
                  isDark ? AppColors.neonBlackBg : const Color(0xFFE0F5F0),
              progressColor: AppColors.neonTeal,
              barRadius: const Radius.circular(5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Daily Goal Card ──────────────────────────────────────────
class _DailyGoalCard extends ConsumerWidget {
  final bool isDark;
  const _DailyGoalCard({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyGoal = ref.watch(dailyGoalProvider);
    final timeString = '${dailyGoal.targetMinutes}:00';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dailyGoalBg : AppColors.dailyGoalBgLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3C5E) : const Color(0xFF2D2F4E),
          width: AppConstants.cardBorderWidth,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.neonBlackBg : AppColors.neonLightSurface,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              border: Border.all(
                color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                width: 2,
              ),
            ),
            child: const Center(
              child: Text('⏱️', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY GOAL',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  timeString,
                  style: AppTextStyles.h2.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/curriculum/preview'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.neonPink,
                borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                border: Border.all(
                  color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                  width: 2,
                ),
              ),
              child: Text(
                dailyGoal.isGoalMet ? 'CONTINUE' : 'START',
                style: AppTextStyles.labelLarge.copyWith(
                  color: isDark ? Colors.white : AppColors.strokeLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions Row ────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  final bool isDark;
  const _QuickActionsRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _QuickActionChip(
            icon: Icons.search_rounded,
            label: 'Explore Topics',
            isDark: isDark,
            onTap: () => context.go('/explore'),
          ),
          const SizedBox(width: 12),
          _QuickActionChip(
            icon: Icons.edit_note_rounded,
            label: 'Practice',
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          _QuickActionChip(
            icon: Icons.emoji_events_rounded,
            label: 'Challenges',
            isDark: isDark,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.neonBlackCard : AppColors.neonLightSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
            width: AppConstants.cardBorderWidth,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.neonBlackBg : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                  width: 2,
                ),
              ),
              child: Icon(icon, size: 20, color: AppColors.neonPurple),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Achievement Preview ──────────────────────────────────────
class _AchievementPreview extends StatelessWidget {
  final bool isDark;
  const _AchievementPreview({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neonBlackCard : AppColors.neonLightSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          width: AppConstants.cardBorderWidth,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BadgeItem(emoji: '🌱', label: 'Sprout', unlocked: true),
          _BadgeItem(emoji: '✨', label: 'Spark', unlocked: true),
          _BadgeItem(emoji: '🦉', label: 'Wise Owl', unlocked: false),
          _BadgeItem(emoji: '🏰', label: 'Keeper', unlocked: false),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String emoji;
  final String label;
  final bool unlocked;

  const _BadgeItem({
    required this.emoji,
    required this.label,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Opacity(
      opacity: unlocked ? 1.0 : 0.4,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? AppColors.pastelPurple.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              border: Border.all(
                color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
