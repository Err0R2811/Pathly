import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/services/lesson_service.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';

class LessonListPage extends StatefulWidget {
  final String moduleId;
  final String moduleName;

  const LessonListPage({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  State<LessonListPage> createState() => _LessonListPageState();
}

class _LessonListPageState extends State<LessonListPage> {
  List<dynamic> _lessons = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await LessonService.getModuleLessons(widget.moduleId);
      setState(() {
        _lessons = response['lessons'] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.neonBlackBg : AppColors.neonLightBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),
            // Content
            Expanded(
              child: _isLoading
                  ? _buildLoadingIndicator()
                  : _error != null
                      ? _buildErrorWidget()
                      : _buildLessonsList(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neonBlackCard : AppColors.neonLightCard,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                  width: 1.0,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.moduleName,
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '${_lessons.length} Lessons',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.neonPink,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load lessons',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadLessons,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsList(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lessons.isEmpty ? 1 : _lessons.length + 1,
      itemBuilder: (context, index) {
        // Practice Quiz card at the top
        if (index == 0) {
          return _PracticeQuizCard(
            moduleId: widget.moduleId,
            isDark: isDark,
          );
        }
        
        // Lesson cards
        final lessonIndex = index - 1;
        if (_lessons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                const SizedBox(height: 16),
                Text(
                  'Generating lessons...',
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a few seconds on first load',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }
        
        final lesson = _lessons[lessonIndex];
        final isCompleted = lesson['is_completed'] as bool? ?? false;
        
        return _LessonCard(
          lesson: lesson,
          isCompleted: isCompleted,
          isDark: isDark,
          onTap: () {
            context.push('/lesson/${lesson['id']}');
          },
        );
      },
    );
  }
}

class _LessonCard extends StatelessWidget {
  final dynamic lesson;
  final bool isCompleted;
  final bool isDark;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.isCompleted,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.neonBlackCard : AppColors.neonLightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.neonGreen
                : isDark
                    ? AppColors.strokeDark
                    : AppColors.strokeLight,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Completion status
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.neonGreen.withOpacity(0.2)
                    : isDark
                        ? AppColors.neonBlackSurface
                        : AppColors.neonLightSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.neonGreen
                      : isDark
                          ? AppColors.strokeDark
                          : AppColors.strokeLight,
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
                color: isCompleted ? AppColors.neonGreen : (isDark ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(width: 12),
            // Lesson info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson['lesson_title'] ?? 'Untitled Lesson',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: isCompleted ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson['estimated_minutes'] ?? 30} min',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(lesson['difficulty_level']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lesson['difficulty_level'] ?? 'beginner',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _getDifficultyColor(lesson['difficulty_level']),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return AppColors.neonBlue;
      case 'intermediate':
        return AppColors.neonPurple;
      case 'advanced':
        return AppColors.neonPink;
      default:
        return AppColors.neonBlue;
    }
  }
}

class _PracticeQuizCard extends StatelessWidget {
  final String moduleId;
  final bool isDark;

  const _PracticeQuizCard({
    required this.moduleId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/modules/$moduleId/quiz');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.neonPurple.withOpacity(0.2),
              AppColors.neonBlue.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonPurple,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.neonPurple.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.neonPurple,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.quiz_rounded,
                color: AppColors.neonPurple,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Practice Quiz',
                    style: AppTextStyles.h3.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Test your knowledge with 4 questions',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neonPurple,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
