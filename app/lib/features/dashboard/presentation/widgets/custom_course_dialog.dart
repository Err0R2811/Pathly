// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/core/services/curriculum_service.dart';

class CustomCourseDialog extends ConsumerStatefulWidget {
  final String? initialSkill;
  const CustomCourseDialog({super.key, this.initialSkill});

  @override
  ConsumerState<CustomCourseDialog> createState() => _CustomCourseDialogState();
}

class _CustomCourseDialogState extends ConsumerState<CustomCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _skillNameController = TextEditingController();
  
  String _selectedDifficulty = 'Beginner';
  int _selectedWeeks = 4;
  bool _isGenerating = false;

  final List<String> _difficultyLevels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<int> _weekOptions = [2, 4, 6, 8, 12];

  @override
  void initState() {
    super.initState();
    if (widget.initialSkill != null) {
      _skillNameController.text = widget.initialSkill!;
    }
  }

  @override
  void dispose() {
    _skillNameController.dispose();
    super.dispose();
  }

  Future<void> _generateCustomCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    try {
      // Request curriculum generation with custom parameters
      final response = await CurriculumService.requestFullCurriculum(
        _skillNameController.text.trim(),
        difficulty: _selectedDifficulty.toLowerCase(),
        deadlineWeeks: _selectedWeeks,
      );

      if (mounted) {
        context.pop();
        // Navigate to roadmap page with the job ID
        context.push('/curriculum/roadmap/$response');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate course: $e'),
            backgroundColor: AppColors.neonPink,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.neonBlackCard : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
            width: AppConstants.cardBorderWidth,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Custom Course',
                    style: AppTextStyles.h3.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.neonBlackBg
                            : AppColors.neonLightSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Skill Name Input
              Text(
                'Skill or Topic',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              TextFormField(
                controller: _skillNameController,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Python, Machine Learning, UI Design',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.neonBlackBg
                      : AppColors.neonLightSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a skill or topic';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Difficulty Level
              Text(
                'Difficulty Level',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingSm),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.neonBlackBg
                      : AppColors.neonLightSurface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(
                    color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                  ),
                ),
                child: Column(
                  children: _difficultyLevels.map((level) {
                    return RadioListTile<String>(
                      title: Text(
                        level,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      value: level,
                      groupValue: _selectedDifficulty,
                      onChanged: (value) {
                        setState(() => _selectedDifficulty = value!);
                      },
                      activeColor: AppColors.neonTeal,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Deadline/Duration
              Text(
                'Learning Duration',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingSm),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.neonBlackBg
                      : AppColors.neonLightSurface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(
                    color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
                  ),
                ),
                child: Wrap(
                  spacing: 8,
                  children: _weekOptions.map((weeks) {
                    final isSelected = _selectedWeeks == weeks;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedWeeks = weeks),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.neonTeal
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.neonTeal
                                : (isDark
                                    ? AppColors.strokeDark
                                    : AppColors.strokeLight),
                          ),
                        ),
                        child: Text(
                          '$weeks weeks',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Generate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateCustomCourse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                    ),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Generate Course',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
