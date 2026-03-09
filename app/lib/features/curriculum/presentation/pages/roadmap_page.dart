import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/core/services/curriculum_service.dart';

/// Polls a generation job and then shows the full verified roadmap.
/// The [jobId] comes from [CurriculumService.requestFullCurriculum].
class RoadmapPage extends StatefulWidget {
  final String jobId;
  const RoadmapPage({super.key, required this.jobId});

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
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
    _poll(); // Run immediately
  }

  Future<void> _poll() async {
    try {
      final status = await CurriculumService.pollStatus(widget.jobId);
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
        final roadmap = await CurriculumService.fetchRoadmap(roadmapId);
        if (mounted) setState(() => _roadmap = roadmap);
      } else if (s == 'FAILED') {
        _timer?.cancel();
        if (mounted) {
          setState(
            () => _error = status['error'] as String? ?? 'Generation failed',
          );
        }
      }
    } catch (e) {
      // Network hiccup — keep polling, will resolve
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

        // ── Modules ──────────────────────────
        ...List.generate(modules.length, (index) {
          final mod = modules[index] as Map<String, dynamic>;
          final color = _pastelColors[index % _pastelColors.length];
          final alignScore =
              (mod['verification_alignment_score'] as num?)?.toInt() ?? 0;
          final sources = (mod['sources'] as List?) ?? [];
          return Container(
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
                if (sources.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    'SOURCES',
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('📄 ', style: TextStyle(fontSize: 12)),
                          Expanded(
                            child: Text(
                              src['title'] as String? ?? 'Unknown source',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
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
