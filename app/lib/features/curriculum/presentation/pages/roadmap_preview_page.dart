import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/core/services/curriculum_service.dart';
import 'package:pathly_app/shared/widgets/pathly_button.dart';

/// Shows an instant draft roadmap (no reviewer pass).
/// Tapping "Generate Full Roadmap" kicks off the async job and navigates
/// to [RoadmapPage] which polls for completion.
class RoadmapPreviewPage extends StatefulWidget {
  final String skillName;
  const RoadmapPreviewPage({super.key, required this.skillName});

  @override
  State<RoadmapPreviewPage> createState() => _RoadmapPreviewPageState();
}

class _RoadmapPreviewPageState extends State<RoadmapPreviewPage> {
  Map<String, dynamic>? _preview;
  String? _error;
  bool _loading = true;
  bool _launching = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final data = await CurriculumService.fetchPreview(widget.skillName);
      if (mounted) {
        setState(() {
          _preview = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _launchFullGeneration() async {
    setState(() => _launching = true);
    try {
      final jobId =
          await CurriculumService.requestFullCurriculum(widget.skillName);
      if (mounted) context.push('/curriculum/roadmap/$jobId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start generation: $e')),
        );
        setState(() => _launching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DRAFT ROADMAP',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.neonPink,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          widget.skillName,
                          style: AppTextStyles.h3.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ───────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _ErrorState(
                          message: _error!,
                          onRetry: _loadPreview,
                          isDark: isDark,
                        )
                      : _PreviewBody(preview: _preview!, isDark: isDark),
            ),

            // ── CTA ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                children: [
                  Text(
                    '⚡ This is an instant preview. Generate the full research-verified roadmap below.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  PathlyButton(
                    label: 'Generate Full Roadmap',
                    isLoading: _launching,
                    onPressed: _launching ? null : _launchFullGeneration,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Inner widgets ─────────────────────────────────────────────────────────────

class _PreviewBody extends StatelessWidget {
  final Map<String, dynamic> preview;
  final bool isDark;
  const _PreviewBody({required this.preview, required this.isDark});

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
    final modules = (preview['modules'] as List?) ?? [];
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      itemCount: modules.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppConstants.spacingMd),
      itemBuilder: (context, index) {
        final mod = modules[index] as Map<String, dynamic>;
        final color = _pastelColors[index % _pastelColors.length];
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: isDark ? color.withValues(alpha: 0.2) : color,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
              width: AppConstants.cardBorderWidth,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neonBlackBg : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isDark ? AppColors.strokeDark : AppColors.strokeLight,
                    width: AppConstants.cardBorderWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mod['module_name'] ?? '',
                      style: AppTextStyles.h3.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Badge(
                          label: mod['level'] ?? '',
                          color: AppColors.neonTeal,
                        ),
                        const SizedBox(width: 8),
                        _Badge(
                          label: '${mod['estimated_hours'] ?? 0}h',
                          color: AppColors.neonPurple,
                        ),
                      ],
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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😵', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Could not reach the API server.\nMake sure the backend is running.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
