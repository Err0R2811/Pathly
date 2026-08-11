import 'package:flutter/material.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/core/services/badges_service.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({super.key});

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _myBadges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    final achievements = await BadgesService.getAchievements();
    final myBadges = await BadgesService.getMyBadges();
    setState(() {
      _achievements = achievements;
      _myBadges = myBadges;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: isDark ? AppColors.neonBlackSurface : Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Badges',
                      style: AppTextStyles.h3.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    if (_myBadges.isEmpty)
                      Text(
                        'No badges earned yet. Keep learning!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: _myBadges.map((badge) => _BadgeCard(
                              badge: badge,
                              isDark: isDark,
                              unlocked: true,
                            ),).toList(),
                      ),
                    const SizedBox(height: AppConstants.spacingXl),
                    Text(
                      'All Achievements',
                      style: AppTextStyles.h3.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: _achievements.map((badge) {
                        final isUnlocked = _myBadges.any((b) => b['id'] == badge['id']);
                        return _BadgeCard(
                          badge: badge,
                          isDark: isDark,
                          unlocked: isUnlocked,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final Map<String, dynamic> badge;
  final bool isDark;
  final bool unlocked;

  const _BadgeCard({
    required this.badge,
    required this.isDark,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.4,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(AppConstants.spacingSm),
        decoration: BoxDecoration(
          color: unlocked
              ? AppColors.pastelLavender.withValues(alpha: isDark ? 0.3 : 0.5)
              : (isDark ? AppColors.neonBlackCard : AppColors.neonLightElevated),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: unlocked ? AppColors.neonPurple : (isDark ? AppColors.strokeDark : AppColors.strokeLight),
            width: AppConstants.cardBorderWidth,
          ),
        ),
        child: Column(
          children: [
            Text(
              badge['icon_url'] ?? '🏅',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              badge['name'] ?? 'Badge',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (badge['description'] != null) ...[
              const SizedBox(height: 4),
              Text(
                badge['description'],
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
