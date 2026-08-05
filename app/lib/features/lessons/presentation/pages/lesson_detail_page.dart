import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/services/lesson_service.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonDetailPage extends StatefulWidget {
  final String lessonId;

  const LessonDetailPage({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _lesson;
  bool _isLoading = true;
  String? _error;
  bool _isCompleting = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLesson();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLesson() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final lesson = await LessonService.getLesson(widget.lessonId);
      setState(() {
        _lesson = lesson;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _completeLesson() async {
    setState(() => _isCompleting = true);
    
    try {
      await LessonService.completeLesson(widget.lessonId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson completed! +50 XP'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
        // Reload lesson to update completion status
        await _loadLesson();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete lesson: $e'),
            backgroundColor: AppColors.neonPink,
          ),
        );
      }
    } finally {
      setState(() => _isCompleting = false);
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
                      : _buildLessonContent(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final lessonTitle = _lesson?['lesson_title'] ?? 'Lesson';
    final isCompleted = _lesson?['is_completed'] as bool? ?? false;

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
                  lessonTitle,
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '${_lesson?['estimated_minutes'] ?? 30} min',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neonGreen, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.neonGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Completed',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.neonGreen,
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
            'Failed to load lesson',
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
            onPressed: _loadLesson,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent(BuildContext context, bool isDark) {
    final steps = _lesson?['steps'] as List<dynamic>? ?? [];
    if (steps.isEmpty) {
      return Center(
        child: Text(
          'No content available',
          style: AppTextStyles.bodyLarge.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    final isCompleted = _lesson?['is_completed'] as bool? ?? false;

    return Column(
      children: [
        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.neonBlackCard : AppColors.neonLightCard,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                width: 1.0,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.neonBlue,
            labelColor: AppColors.neonBlue,
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Video'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, isDark, steps),
              _buildVideoTab(context, isDark, steps),
            ],
          ),
        ),
        // Complete button
        _buildCompleteButton(context, isDark, isCompleted),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context, bool isDark, List<dynamic> steps) {
    // Consolidate all text content from steps
    final textSteps = steps.where((step) => step['step_type'] == 'text').toList();
    final learningObjectives = _lesson?['learning_objectives'] as List<dynamic>? ?? [];
    final skillsGained = _lesson?['skills_gained'] as List<dynamic>? ?? [];
    final prerequisites = _lesson?['prerequisites'] as List<dynamic>? ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description / summary
          if (_lesson?['summary'] != null) ...[
            Text(
              _lesson!['summary'] as String,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Learning objectives
          if (learningObjectives.isNotEmpty) ...[
            Text(
              'Learning Objectives',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            ...learningObjectives.map((objective) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.neonBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      objective.toString(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
          // Skills gained
          if (skillsGained.isNotEmpty) ...[
            Text(
              'Skills You\'ll Gain',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skillsGained.map((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neonPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.neonPurple, width: 1),
                ),
                child: Text(
                  skill.toString(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.neonPurple,
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],
          // Prerequisites
          if (prerequisites.isNotEmpty) ...[
            Text(
              'Prerequisites',
              style: AppTextStyles.h3.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            ...prerequisites.map((prereq) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.bookmark_rounded,
                    size: 16,
                    color: AppColors.neonBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prereq.toString(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
          ],
          // Text content from steps
          if (textSteps.isNotEmpty) ...[
            ...textSteps.map((step) => _buildTextContent(context, isDark, step['content'] as Map<String, dynamic>? ?? {})),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No text content available for this lesson yet.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoTab(BuildContext context, bool isDark, List<dynamic> steps) {
    // Find video step
    final videoStep = steps.firstWhere(
      (step) => step['step_type'] == 'video',
      orElse: () => {'content': {}},
    );
    
    final content = videoStep['content'] as Map<String, dynamic>? ?? {};
    
    if (content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(height: 16),
            Text(
              'No video content available',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _buildVideoContent(context, isDark, content),
    );
  }

  Widget _buildCompleteButton(BuildContext context, bool isDark, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neonBlackCard : AppColors.neonLightCard,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
            width: 1.0,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isCompleted ? null : _isCompleting ? null : _completeLesson,
          style: ElevatedButton.styleFrom(
            backgroundColor: isCompleted ? AppColors.neonGreen : AppColors.neonBlue,
            disabledBackgroundColor: isCompleted ? AppColors.neonGreen.withOpacity(0.5) : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isCompleting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  isCompleted ? 'Lesson Completed' : 'Complete Lesson',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, bool isDark, Map<String, dynamic> content) {
    final explanation = content['explanation'] as String? ?? '';
    final examples = content['examples'] as List<dynamic>? ?? [];
    final keyPoints = content['key_points'] as List<dynamic>? ?? [];
    final exercise = content['exercise'] as String? ?? '';
    final solution = content['solution'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (explanation.isNotEmpty) ...[
          Text(
            explanation,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (keyPoints.isNotEmpty) ...[
          Text(
            'Key Points:',
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...keyPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.neonBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
        ],
        if (examples.isNotEmpty) ...[
          Text(
            'Examples:',
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...examples.map((example) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                    width: 1,
                  ),
                ),
                child: Text(
                  example.toString(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              )),
          const SizedBox(height: 16),
        ],
        if (exercise.isNotEmpty) ...[
          Text(
            'Exercise:',
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                width: 1,
              ),
            ),
            child: Text(
              exercise,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (solution.isNotEmpty) ...[
          Text(
            'Solution / Expected Approach:',
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface).withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                width: 1,
              ),
            ),
            child: Text(
              solution,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoContent(BuildContext context, bool isDark, Map<String, dynamic> content) {
    final videoUrl = content['video_url'] as String? ?? '';
    final description = content['description'] as String? ?? '';
    final keyTakeaways = content['key_takeaways'] as List<dynamic>? ?? [];
    final isSearch = videoUrl.contains('youtube.com/results');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video placeholder
        GestureDetector(
          onTap: () async {
            if (videoUrl.isNotEmpty) {
              final uri = Uri.parse(videoUrl);
              await launchUrl(
                uri,
                mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
                webViewConfiguration: const WebViewConfiguration(
                  enableJavaScript: true,
                  enableDomStorage: true,
                ),
              );
            }
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSearch ? Icons.search_rounded : Icons.play_circle_rounded,
                    size: 64,
                    color: AppColors.neonBlue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSearch ? 'Tap to Search YouTube' : 'Tap to Watch Video',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (videoUrl.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      isSearch ? 'Find topic-related videos on YouTube' : 'Click to open in YouTube',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neonBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (description.isNotEmpty) ...[
          Text(
            description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (keyTakeaways.isNotEmpty) ...[
          Text(
            'Key Takeaways:',
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...keyTakeaways.map((takeaway) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      size: 16,
                      color: AppColors.neonPurple,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        takeaway.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

}
