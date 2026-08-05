import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/services/curriculum_service.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/features/auth/providers/auth_provider.dart';
import 'package:pathly_app/features/dashboard/presentation/widgets/custom_course_dialog.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
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

  List<Map<String, dynamic>> _roadmaps = [];
  bool _isLoading = true;
  String? _roadmapsError;

  @override
  void initState() {
    super.initState();
    _loadRoadmaps();
  }

  Future<void> _loadRoadmaps() async {
    try {
      final roadmaps = await CurriculumService.listRoadmaps();
      if (mounted) {
        setState(() {
          _roadmaps = roadmaps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _roadmapsError = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteRoadmap(String roadmapId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete roadmap?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await CurriculumService.deleteRoadmap(roadmapId);
      await _loadRoadmaps();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final isDemo = authState.user?.isDemo ?? false;

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

              // ─── My Roadmaps ──────────────────────────────
              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: AppConstants.spacingLg),
              ] else if (_roadmapsError != null) ...[
                Text(
                  'Could not load your roadmaps.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
              ] else if (_roadmaps.isNotEmpty) ...[
                Text(
                  'Your Roadmaps',
                  style: AppTextStyles.h3.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _roadmaps.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final roadmap = _roadmaps[index];
                      return _RoadmapCard(
                        roadmap: roadmap,
                        isDark: isDark,
                        onTap: () => context.push('/roadmap/${roadmap['id']}'),
                        onDelete: () => _deleteRoadmap(roadmap['id'] as String),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppConstants.spacingLg),
              ],

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
                      onTap: () {
                        if (isDemo) {
                          // Demo users can see preview content
                          context.push(
                            '/curriculum/preview/${Uri.encodeComponent(skill.title)}',
                          );
                        } else {
                          // Real users create custom course
                          showDialog(
                            context: context,
                            builder: (context) => CustomCourseDialog(
                              initialSkill: skill.title,
                            ),
                          );
                        }
                      },
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

class _RoadmapCard extends StatelessWidget {
  final Map<String, dynamic> roadmap;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _RoadmapCard({
    required this.roadmap,
    required this.isDark,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final skillName = roadmap['skill_name'] as String? ?? 'Roadmap';
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withValues(alpha: isDark ? 0.3 : 1.0),
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neonBlackBg : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                    width: AppConstants.cardBorderWidth,
                  ),
                ),
                child: Icon(
                  Icons.map_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: Text(
              skillName,
              style: AppTextStyles.h3.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
