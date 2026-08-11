import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/core/services/curriculum_service.dart';

/// Shows a full verified roadmap either by [roadmapId] directly or by
/// polling a [jobId] from [CurriculumService.requestFullCurriculum].
class RoadmapPage extends StatefulWidget {
  final String? jobId;
  final String? roadmapId;
  const RoadmapPage({super.key, this.jobId, this.roadmapId});

  @override
  State<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage> {
  String _status = 'PENDING';
  int _progress = 0;
  Map<String, dynamic>? _roadmap;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final savedId = widget.roadmapId;
    if (savedId != null && savedId.isNotEmpty) {
      _loadRoadmap(savedId);
    } else if (widget.jobId != null && widget.jobId!.isNotEmpty) {
      _startPolling();
    } else {
      setState(() => _error = 'No roadmap or job provided');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRoadmap(String roadmapId) async {
    setState(() => _status = 'LOADING');
    try {
      final roadmap = await CurriculumService.fetchRoadmap(roadmapId);
      if (mounted) {
        setState(() {
        _roadmap = roadmap;
        _status = 'COMPLETED';
        _progress = 100;
      });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to load roadmap: $e');
      }
    }
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
    _poll(); // Run immediately
  }

  Future<void> _poll() async {
    try {
      final status = await CurriculumService.pollStatus(widget.jobId!);
      final s = status['status'] as String;
      final p = (status['progress'] as num?)?.toInt() ?? 0;
      if (!mounted) return;
      setState(() {
        _status = s;
        _progress = p;
      });

      if (s == 'COMPLETED') {
        _timer?.cancel();
        final roadmapId = status['roadmap_id'] as String;
        await _loadRoadmap(roadmapId);
      } else if (s == 'FAILED') {
        _timer?.cancel();
        if (mounted) {
          setState(
            () => _error = status['error'] as String? ?? 'Generation failed',
          );
        }
      }
    } catch (e) {
      // Network hiccup during polling — keep polling, will resolve
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
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
                      width: 44,
                      height: 44,
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _roadmap != null
                        ? _roadmap!['skill_name'] as String
                        : 'Generating Roadmap…',
                    style: AppTextStyles.h3.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────
            Expanded(
              child: _error != null
                  ? _ErrorView(message: _error!, isDark: isDark)
                  : _roadmap == null
                      ? _LoadingView(
                          status: _status,
                          progress: _progress,
                          isDark: isDark,
                        )
                      : _RoadmapBody(roadmap: _roadmap!, isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading state ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String status;
  final int progress;
  final bool isDark;
  const _LoadingView({
    required this.status,
    required this.progress,
    required this.isDark,
  });

  static const _statusLabels = {
    'PENDING': 'Starting up…',
    'RUNNING': 'AI is generating your roadmap…',
    'COMPLETED': 'Done!',
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧠', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              _statusLabels[status] ?? 'Processing…',
              style: AppTextStyles.h3.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            // Progress bar
            Container(
              height: 14,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.neonBlackSurface
                    : AppColors.neonLightSurface,
                borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                border: Border.all(
                  color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                  width: AppConstants.cardBorderWidth,
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress / 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.neonPink,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusRound),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPink.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              '$progress%',
              style:
                  AppTextStyles.labelLarge.copyWith(color: AppColors.neonPink),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Reviewing sources and scoring modules…',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Roadmap body ───────────────────────────────────────────────────────────────

class _RoadmapBody extends StatelessWidget {
  final Map<String, dynamic> roadmap;
  final bool isDark;
  const _RoadmapBody({required this.roadmap, required this.isDark});

  static const _pastelColors = [
    AppColors.pastelMint,
    AppColors.pastelLavender,
    AppColors.pastelPeach,
    AppColors.pastelBlue,
    AppColors.pastelPurple,
    AppColors.pastelPink,
  ];

  @override
  Widget build(BuildContext context) {
    final score = (roadmap['verification_score'] as num?)?.toInt() ?? 0;
    final modules = (roadmap['modules'] as List?) ?? [];
    final certificationInfo = roadmap['certification_info'] as Map<String, dynamic>?;
    final prerequisites = (roadmap['prerequisites'] as List?) ?? [];
    final learningObjectives = (roadmap['learning_objectives'] as List?) ?? [];
    final careerOutcomes = (roadmap['career_outcomes'] as List?) ?? [];
    final salaryRange = roadmap['salary_range'] as String?;
    final marketDemand = roadmap['market_demand'] as String?;
    
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      children: [
        // ── Verification banner ──────────────
        Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: score >= 85
                ? AppColors.neonGreen.withValues(alpha: isDark ? 0.2 : 0.15)
                : AppColors.neonYellow.withValues(alpha: isDark ? 0.2 : 0.15),
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: score >= 85 ? AppColors.neonGreen : AppColors.neonYellow,
              width: AppConstants.cardBorderWidth,
            ),
          ),
          child: Row(
            children: [
              Text(
                score >= 85 ? '✅' : '⚠️',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      score >= 85 ? 'Research Verified' : 'Partially Verified',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: score >= 85
                            ? AppColors.neonGreen
                            : AppColors.neonYellow,
                      ),
                    ),
                    Text(
                      'Alignment score: $score / 100',
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
        ),

        // ── Certification Info ──────────────
        if (certificationInfo != null)
          Container(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.neonPurple.withValues(alpha: 0.15)
                  : AppColors.neonPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppColors.neonPurple,
                width: AppConstants.cardBorderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎓', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Certification',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.neonPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSm),
                if (certificationInfo['recommended_certification'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommended: ',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            certificationInfo['recommended_certification'] as String,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (certificationInfo['certification_body'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Certified by: ',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            certificationInfo['certification_body'] as String,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (certificationInfo['available_certifications'] != null)
                  ...List.generate(
                    (certificationInfo['available_certifications'] as List).length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '• ${certificationInfo['available_certifications'][i]}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // ── Career Info ─────────────────────
        if (careerOutcomes.isNotEmpty || salaryRange != null || marketDemand != null)
          Container(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.neonTeal.withValues(alpha: 0.15)
                  : AppColors.neonTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppColors.neonTeal,
                width: AppConstants.cardBorderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💼', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Career Outlook',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.neonTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSm),
                if (salaryRange != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Salary Range: ',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            salaryRange,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (marketDemand != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Market Demand: ',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            marketDemand,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (careerOutcomes.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    'Career Paths',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...careerOutcomes.map((outcome) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $outcome',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),),
                ],
              ],
            ),
          ),

        // ── Prerequisites ───────────────────
        if (prerequisites.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.info.withValues(alpha: 0.15)
                  : AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppColors.info,
                width: AppConstants.cardBorderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Prerequisites',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSm),
                ...prerequisites.map((req) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $req',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),),
              ],
            ),
          ),

        // ── Learning Objectives ─────────────
        if (learningObjectives.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.neonPink.withValues(alpha: 0.15)
                  : AppColors.neonPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppColors.neonPink,
                width: AppConstants.cardBorderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎯', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Learning Objectives',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.neonPink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSm),
                ...learningObjectives.map((obj) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $obj',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),),
              ],
            ),
          ),

        // ── Modules ──────────────────────────
        ...List.generate(modules.length, (index) {
          final mod = modules[index] as Map<String, dynamic>;
          final color = _pastelColors[index % _pastelColors.length];
          final alignScore =
              (mod['verification_alignment_score'] as num?)?.toInt() ?? 0;
          final sources = (mod['sources'] as List?) ?? [];
          final learningObjectives = (mod['learning_objectives'] as List?) ?? [];
          final skillsGained = (mod['skills_gained'] as List?) ?? [];
          final projects = (mod['projects'] as List?) ?? [];
          final assessmentCriteria = mod['assessment_criteria'] as String?;
          final moduleId = mod['id'] as String? ?? '';
          final moduleName = mod['module_name'] as String? ?? '';
          
          return GestureDetector(
            onTap: () {
              if (moduleId.isNotEmpty) {
                context.push('/lessons/$moduleId', extra: {'moduleName': moduleName});
              }
            },
            child: Container(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: isDark ? color.withValues(alpha: 0.15) : color,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                width: AppConstants.cardBorderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Module header
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.neonBlackBg : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.strokeDark
                              : AppColors.strokeLight,
                          width: AppConstants.cardBorderWidth,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        mod['module_name'] as String? ?? '',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    // Alignment score badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: alignScore >= 85
                            ? AppColors.neonGreen.withValues(alpha: 0.2)
                            : AppColors.neonYellow.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusRound),
                        border: Border.all(
                          color: alignScore >= 85
                              ? AppColors.neonGreen
                              : AppColors.neonYellow,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '$alignScore',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: alignScore >= 85
                              ? AppColors.neonGreen
                              : AppColors.neonYellow,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSm),
                // Meta row
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Chip(
                      label: mod['level'] as String? ?? '',
                      color: AppColors.neonTeal,
                    ),
                    _Chip(
                      label: '${mod['difficulty_score'] ?? 0}% difficulty',
                      color: AppColors.neonPink,
                    ),
                    _Chip(
                      label: '${mod['estimated_hours'] ?? 0}h',
                      color: AppColors.neonPurple,
                    ),
                  ],
                ),
                
                // Learning objectives
                if (learningObjectives.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    '🎯 Learning Objectives',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...learningObjectives.map((obj) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• $obj',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),),
                ],
                
                // Skills gained
                if (skillsGained.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    '💪 Skills You\'ll Gain',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: skillsGained.map((skill) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? AppColors.neonGreen.withValues(alpha: 0.2)
                            : AppColors.neonGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                        border: Border.all(
                          color: AppColors.neonGreen,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        skill,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neonGreen,
                        ),
                      ),
                    ),).toList(),
                  ),
                ],
                
                // Projects
                if (projects.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    '🛠️ Projects',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...projects.map((project) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• $project',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),),
                ],
                
                // Assessment criteria
                if (assessmentCriteria != null) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    '✅ Assessment',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assessmentCriteria,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
                
                // Sources
                if (sources.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    '📚 SOURCES',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...sources.map((s) {
                    final src = s as Map<String, dynamic>;
                    final sourceType = src['type'] as String?;
                    final isVideo = sourceType == 'video';
                    final videoDuration = src['video_duration'] as int?;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isVideo ? '🎬 ' : '📄 ',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  src['title'] as String? ?? 'Unknown source',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                if (isVideo && videoDuration != null)
                                  Text(
                                    'Duration: ${videoDuration ~/ 60}m ${videoDuration % 60}s',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.textTertiaryDark
                                          : AppColors.textTertiaryLight,
                                      fontSize: 10,
                                    ),
                                  ),
                                if (src['author'] != null)
                                  Text(
                                    'By ${src['author']}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.textTertiaryDark
                                          : AppColors.textTertiaryLight,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
            ),
          );
        }),
        const SizedBox(height: AppConstants.spacingLg),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorView({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('❌', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Generation failed:\n$message',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
