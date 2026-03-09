import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  static const _skills = [
    _SkillData('Magic Tricks', Icons.auto_awesome, AppColors.pastelPurple),
    _SkillData('Coding Basics', Icons.terminal, AppColors.pastelPeach),
    _SkillData('Memory Hacks', Icons.psychology, AppColors.pastelMint),
    _SkillData('Drawing', Icons.palette, AppColors.pastelBlue),
    _SkillData(
      'Public Speaking',
      Icons.record_voice_over,
      AppColors.pastelPink,
    ),
    _SkillData('Fitness', Icons.fitness_center, AppColors.pastelLavender),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── App Bar ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _IconButton(
                    icon: Icons.arrow_back_rounded,
                    isDark: isDark,
                    onTap: () => context.go('/home'),
                  ),
                  Text(
                    'Explore Learning',
                    style: AppTextStyles.h3.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  _IconButton(
                    icon: Icons.search_rounded,
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // ─── Heading ──────────────────────────────────
              Text(
                'Pick your next\nadventure 🚀',
                style: AppTextStyles.h1.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // ─── Skill Grid ───────────────────────────────
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _skills.length,
                  itemBuilder: (context, index) {
                    final skill = _skills[index];
                    return _SkillCard(
                      skill: skill,
                      isDark: isDark,
                      onTap: () => context.push(
                        '/curriculum/preview/${Uri.encodeComponent(skill.title)}',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillData {
  final String title;
  final IconData icon;
  final Color color;
  const _SkillData(this.title, this.icon, this.color);
}

class _SkillCard extends StatelessWidget {
  final _SkillData skill;
  final bool isDark;
  final VoidCallback onTap;

  const _SkillCard({
    required this.skill,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: skill.color.withValues(alpha: isDark ? 0.3 : 1.0),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
            width: AppConstants.cardBorderWidth,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.neonBlackBg : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                  width: AppConstants.cardBorderWidth,
                ),
              ),
              child: Icon(
                skill.icon,
                size: 22,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const Spacer(),
            Text(
              skill.title,
              style: AppTextStyles.h3.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
            width: AppConstants.cardBorderWidth,
          ),
        ),
        child: Icon(
          icon,
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}
