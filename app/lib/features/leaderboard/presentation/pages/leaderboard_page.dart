import 'package:flutter/material.dart';
import 'package:pathly_app/core/theme/app_colors.dart';
import 'package:pathly_app/core/theme/app_text_styles.dart';
import 'package:pathly_app/core/constants/app_constants.dart';
import 'package:pathly_app/core/services/leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> _leaderboard = [];
  Map<String, dynamic>? _myRank;
  bool _isLoading = true;
  String _selectedType = 'all_time';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final leaderboard = await LeaderboardService.getLeaderboard(type: _selectedType);
    final myRank = await LeaderboardService.getMyRank(type: _selectedType);
    setState(() {
      _leaderboard = leaderboard;
      _myRank = myRank;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: isDark ? AppColors.neonBlackSurface : Colors.white,
        actions: [
          DropdownButton<String>(
            value: _selectedType,
            dropdownColor: isDark ? AppColors.neonBlackCard : Colors.white,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            items: const [
              DropdownMenuItem(value: 'all_time', child: Text('All Time')),
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedType = value;
                  _isLoading = true;
                });
                _loadLeaderboard();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_myRank != null) _MyRankCard(rank: _myRank!, isDark: isDark),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      itemCount: _leaderboard.length,
                      itemBuilder: (context, index) {
                        final entry = _leaderboard[index];
                        return _LeaderboardEntry(
                          rank: index + 1,
                          entry: entry,
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MyRankCard extends StatelessWidget {
  final Map<String, dynamic> rank;
  final bool isDark;

  const _MyRankCard({required this.rank, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingMd),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.pastelLavender.withValues(alpha: isDark ? 0.3 : 0.5),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          width: AppConstants.cardBorderWidth,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your Rank',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            '#${rank['rank'] ?? 'N/A'}',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.neonPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEntry extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> entry;
  final bool isDark;

  const _LeaderboardEntry({
    required this.rank,
    required this.entry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final score = entry['score'] ?? 0;
    final userName = entry['user_name'] ?? 'User';

    String rankEmoji;
    Color rankColor;
    if (rank == 1) {
      rankEmoji = '🥇';
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankEmoji = '🥈';
      rankColor = Colors.grey;
    } else if (rank == 3) {
      rankEmoji = '🥉';
      rankColor = Colors.brown;
    } else {
      rankEmoji = '#$rank';
      rankColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neonBlackCard : AppColors.neonLightElevated,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          width: AppConstants.cardBorderWidth,
        ),
      ),
      child: Row(
        children: [
          Text(
            rankEmoji,
            style: TextStyle(fontSize: 24, color: rankColor),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Text(
              userName,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
          Text(
            '$score XP',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neonPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
