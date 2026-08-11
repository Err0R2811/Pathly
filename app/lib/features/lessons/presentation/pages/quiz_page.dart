import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pathly_app/core/services/lesson_service.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';

class QuizPage extends StatefulWidget {
  final String moduleId;

  const QuizPage({
    super.key,
    required this.moduleId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<dynamic> _questions = [];
  bool _isLoading = true;
  String? _error;
  
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<bool> _answeredCorrectly = [];
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await LessonService.getModuleQuiz(widget.moduleId);
      setState(() {
        _questions = response['questions'] as List<dynamic>;
        _answeredCorrectly = List.filled(_questions.length, false);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(int optionIndex) {
    if (_showResults) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final correctAnswer = currentQuestion['correct_answer'] as String;
    final selectedLetter = String.fromCharCode(65 + optionIndex); // A, B, C, D
    
    final isCorrect = selectedLetter == correctAnswer;
    
    setState(() {
      _answeredCorrectly[_currentQuestionIndex] = isCorrect;
      if (isCorrect) {
        _score++;
      }
    });

    // Move to next question or show results
    if (_currentQuestionIndex < _questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _currentQuestionIndex++;
          });
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showResults = true;
          });
        }
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _answeredCorrectly = List.filled(_questions.length, false);
      _showResults = false;
    });
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
                      : _showResults
                          ? _buildResultsWidget(context, isDark)
                          : _buildQuestionWidget(context, isDark),
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
                  'Practice Quiz',
                  style: AppTextStyles.h3.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                if (!_showResults && _questions.isNotEmpty)
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Generating quiz...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.neonPink,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load quiz',
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
            onPressed: _loadQuiz,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(BuildContext context, bool isDark) {
    if (_questions.isEmpty) {
      return Center(
        child: Text(
          'No questions available',
          style: AppTextStyles.h3.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final question = currentQuestion['question'] as String;
    final options = currentQuestion['options'] as List<dynamic>;
    final hasAnswered = _answeredCorrectly[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonPurple),
          ),
          const SizedBox(height: 24),
          // Question
          Text(
            question,
            style: AppTextStyles.h2.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 32),
          // Options
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value.toString();
            final letter = String.fromCharCode(65 + index);
            
            bool isCorrect = false;
            bool isSelected = false;
            
            if (hasAnswered) {
              final correctAnswer = currentQuestion['correct_answer'] as String;
              isCorrect = letter == correctAnswer;
              isSelected = true;
            }

            return _OptionCard(
              letter: letter,
              option: option,
              isCorrect: isCorrect,
              isSelected: isSelected,
              isDark: isDark,
              onTap: hasAnswered ? null : () => _selectAnswer(index),
            );
          }),
          // Explanation (shown after answering)
          if (hasAnswered) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _answeredCorrectly[_currentQuestionIndex]
                    ? AppColors.neonGreen.withValues(alpha: 0.1)
                    : AppColors.neonPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _answeredCorrectly[_currentQuestionIndex]
                      ? AppColors.neonGreen
                      : AppColors.neonPink,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _answeredCorrectly[_currentQuestionIndex]
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: _answeredCorrectly[_currentQuestionIndex]
                            ? AppColors.neonGreen
                            : AppColors.neonPink,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _answeredCorrectly[_currentQuestionIndex]
                            ? 'Correct!'
                            : 'Incorrect',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: _answeredCorrectly[_currentQuestionIndex]
                              ? AppColors.neonGreen
                              : AppColors.neonPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuestion['explanation'] as String? ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsWidget(BuildContext context, bool isDark) {
    final percentage = (_score / _questions.length * 100).toInt();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score circle
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonPurple,
                    AppColors.neonBlue,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_score',
                      style: AppTextStyles.h1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '/ ${_questions.length}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Quiz Complete!',
              style: AppTextStyles.h2.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You scored $percentage%',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            // Performance message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: percentage >= 75
                    ? AppColors.neonGreen.withValues(alpha: 0.1)
                    : percentage >= 50
                        ? AppColors.neonBlue.withValues(alpha: 0.1)
                        : AppColors.neonPink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: percentage >= 75
                      ? AppColors.neonGreen
                      : percentage >= 50
                          ? AppColors.neonBlue
                          : AppColors.neonPink,
                  width: 1,
                ),
              ),
              child: Text(
                percentage >= 75
                    ? 'Excellent work! You have a strong understanding of this module.'
                    : percentage >= 50
                        ? 'Good job! Review the explanations to improve your understanding.'
                        : 'Keep practicing! Review the module content and try again.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.neonBlackSurface : AppColors.neonLightSurface,
                      foregroundColor: isDark ? Colors.white : Colors.black,
                    ),
                    child: const Text('Back to Lessons'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _restartQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonPurple,
                    ),
                    child: const Text('Try Again'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String letter;
  final String option;
  final bool isCorrect;
  final bool isSelected;
  final bool isDark;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.letter,
    required this.option,
    required this.isCorrect,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;

    if (!isSelected) {
      borderColor = isDark ? AppColors.strokeDark : AppColors.strokeLight;
      backgroundColor = isDark ? AppColors.neonBlackCard : AppColors.neonLightCard;
    } else if (isCorrect) {
      borderColor = AppColors.neonGreen;
      backgroundColor = AppColors.neonGreen.withValues(alpha: 0.1);
    } else {
      borderColor = AppColors.neonPink;
      backgroundColor = AppColors.neonPink.withValues(alpha: 0.1);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? borderColor.withValues(alpha: 0.3)
                    : isDark
                        ? AppColors.neonBlackSurface
                        : AppColors.neonLightSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isSelected ? borderColor : (isDark ? Colors.white : Colors.black),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                isCorrect ? Icons.check_rounded : Icons.close_rounded,
                color: borderColor,
              ),
          ],
        ),
      ),
    );
  }
}
