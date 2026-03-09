import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/features/auth/providers/auth_provider.dart';

import 'package:pathly_app/infrastructure/models/user_model.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── App Bar ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.settings_rounded,
                    isDark: isDark,
                  ),
                  Text(
                    'Profile',
                    style: AppTextStyles.h3.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  _CircleIconButton(
                    icon: Icons.share_rounded,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // ─── Profile Card ─────────────────────────────
              _ProfileCard(isDark: isDark, user: authState.user),
              const SizedBox(height: AppConstants.spacingMd),

              // ─── Stats Row ────────────────────────────────
              _StatsRow(isDark: isDark, user: authState.user),
              const SizedBox(height: AppConstants.spacingLg),

              // ─── Achievements ─────────────────────────────
              Row(
                children: [
                  const Text('🏅', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Achievements',
                    style: AppTextStyles.h3.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              _AchievementsGrid(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;

  const _CircleIconButton({required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.neonBlackCard : AppColors.neonLightElevated,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          width: AppConstants.cardBorderWidth,
        ),
      ),
      child: Icon(
        icon,
        color:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        size: 22,
      ),
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final bool isDark;
  final UserModel? user;
  const _ProfileCard({required this.isDark, this.user});

  @override
  Widget build(BuildContext context) {
    final userName = user?.name ?? 'Guest';
    final userTitle = user?.title ?? 'Beginner Wizard';
    final userLevel = user?.level ?? 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.pastelLavender.withValues(alpha: isDark ? 0.2 : 0.5),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          width: AppConstants.cardBorderWidth,
        ),
      ),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor:
                    isDark ? AppColors.neonBlackCard : const Color(0xFF8A9A8A),
                child: const Text('🧙‍♀️', style: TextStyle(fontSize: 48)),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.neonPinkLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isDark ? AppColors.strokeDark : AppColors.strokeLight,
                      width: AppConstants.cardBorderWidth,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            userName,
            style: AppTextStyles.h2.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$userTitle 🧙',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.neonBlackCard.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppConstants.radiusRound),
              border: Border.all(
                color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                width: AppConstants.cardBorderWidth,
              ),
            ),
            child: Text(
              'Level $userLevel',
              style: AppTextStyles.labelLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final bool isDark;
  final UserModel? user;
  const _StatsRow({required this.isDark, this.user});

  @override
  Widget build(BuildContext context) {
    final streakDays = user?.streakDays ?? 7;
    final totalMinutes = user?.totalMinutes ?? 240;
    final lessonsCompleted = user?.lessonsCompleted ?? 12;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'STREAK',
            value: '$streakDays Days',
            emoji: '🔥',
            color: AppColors.statPink,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'MINUTES',
            value: '$totalMinutes',
            emoji: '🕐',
            color: AppColors.statMint,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'LESSONS',
            value: '$lessonsCompleted',
            emoji: '📖',
            color: AppColors.statBlue,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.4),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          width: AppConstants.cardBorderWidth,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

// ─── Achievements Grid ────────────────────────────────────────
class _AchievementsGrid extends StatelessWidget {
  final bool isDark;
  const _AchievementsGrid({required this.isDark});

  static const _badges = [
    _Badge('Sprout', '🌱', true, AppColors.pastelMint),
    _Badge('Spark', '✨', true, AppColors.pastelLavender),
    _Badge('Wise Owl', '🦉', false, Colors.grey),
    _Badge('Keeper', '🏰', false, Colors.grey),
    _Badge('Explorer', '🧭', false, Colors.grey),
    _Badge('Master', '👑', false, Colors.grey),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _badges
          .map((badge) => _BadgeCircle(badge: badge, isDark: isDark))
          .toList(),
    );
  }
}

class _Badge {
  final String name;
  final String emoji;
  final bool unlocked;
  final Color color;
  const _Badge(this.name, this.emoji, this.unlocked, this.color);
}

class _BadgeCircle extends StatelessWidget {
  final _Badge badge;
  final bool isDark;

  const _BadgeCircle({required this.badge, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: badge.unlocked ? 1.0 : 0.35,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badge.unlocked
                  ? badge.color.withValues(alpha: isDark ? 0.3 : 0.4)
                  : (isDark
                      ? AppColors.neonBlackCard
                      : AppColors.neonLightElevated),
              border: Border.all(
                color: badge.unlocked
                    ? AppColors.neonPurple
                    : (isDark ? AppColors.strokeDark : AppColors.strokeLight),
                width: AppConstants.cardBorderWidth,
              ),
            ),
            child: Center(
              child: Text(badge.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.name,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
