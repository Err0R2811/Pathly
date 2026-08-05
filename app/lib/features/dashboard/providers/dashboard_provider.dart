import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pathly_app/features/auth/providers/auth_provider.dart';
import 'package:pathly_app/core/services/progress_service.dart';

final userProgressProvider = FutureProvider<UserProgress>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;

  if (user != null && user.id != 'demo_user_001') {
    try {
      final stats = await ProgressService.getUserStats();
      return UserProgress(
        currentSkill: stats['current_skill'] as String? ?? 'No active course',
        currentRoadmapId: stats['current_roadmap_id'] as String?,
        currentModuleId: stats['current_module_id'] as String?,
        lessonsCompleted: stats['lessons_completed'] as int? ?? 0,
        totalLessons: stats['total_lessons'] as int? ?? 0,
        progressPercentage: stats['progress_percentage'] as int? ?? 0,
        streakDays: stats['streak_days'] as int? ?? 0,
        totalMinutes: stats['total_minutes'] as int? ?? 0,
        xp: stats['xp'] as int? ?? 0,
        level: stats['level'] as int? ?? 1,
        xpToNextLevel: stats['xp_to_next_level'] as int? ?? 500,
        levelProgress: (stats['level_progress'] as double?) ?? 0.0,
        title: stats['title'] as String? ?? 'Beginner',
      );
    } catch (e) {
      // Fallback to user data if API fails
      return UserProgress(
        currentSkill: 'No active course',
        currentRoadmapId: null,
        currentModuleId: null,
        lessonsCompleted: user.lessonsCompleted,
        totalLessons: 0,
        progressPercentage: 0,
        streakDays: user.streakDays,
        totalMinutes: user.totalMinutes,
        xp: user.xp,
        level: user.level,
        xpToNextLevel: (user.level + 1) * 500 - user.xp,
        levelProgress: (user.xp % 500) / 500,
        title: user.title,
      );
    }
  }

  // Demo user fallback
  return UserProgress(
    currentSkill: 'No active course',
    currentRoadmapId: null,
    currentModuleId: null,
    lessonsCompleted: user?.lessonsCompleted ?? 0,
    totalLessons: 0,
    progressPercentage: 0,
    streakDays: user?.streakDays ?? 0,
    totalMinutes: user?.totalMinutes ?? 0,
    xp: user?.xp ?? 0,
    level: user?.level ?? 1,
    xpToNextLevel: 500,
    levelProgress: 0.0,
    title: user?.title ?? 'Beginner',
  );
});

class UserProgress {
  final String currentSkill;
  final String? currentRoadmapId;
  final String? currentModuleId;
  final int lessonsCompleted;
  final int totalLessons;
  final int progressPercentage;
  final int streakDays;
  final int totalMinutes;
  final int xp;
  final int level;
  final int xpToNextLevel;
  final double levelProgress;
  final String title;

  const UserProgress({
    required this.currentSkill,
    this.currentRoadmapId,
    this.currentModuleId,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.progressPercentage,
    required this.streakDays,
    required this.totalMinutes,
    required this.xp,
    required this.level,
    required this.xpToNextLevel,
    required this.levelProgress,
    required this.title,
  });

  String get dailyGoal => '$streakDays day streak';
}

final dailyGoalProvider = FutureProvider<DailyGoal>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;

  if (user != null && user.id != 'demo_user_001') {
    try {
      final goalData = await ProgressService.getDailyGoal();
      return DailyGoal(
        targetMinutes: goalData['target_minutes'] as int? ?? 15,
        completedMinutes: goalData['completed_minutes'] as int? ?? 0,
        lessonsCompleted: goalData['lessons_completed'] as int? ?? 0,
        streakDays: goalData['streak_days'] as int? ?? 0,
        isGoalMet: goalData['is_goal_met'] as bool? ?? false,
        progress: (goalData['progress'] as double?) ?? 0.0,
      );
    } catch (e) {
      // Fallback
      return DailyGoal(
        targetMinutes: 15,
        completedMinutes: user.totalMinutes % 60,
        lessonsCompleted: user.lessonsCompleted,
        streakDays: user.streakDays,
        isGoalMet: (user.totalMinutes % 60) >= 15,
        progress: (user.totalMinutes % 60) / 15,
      );
    }
  }

  // Demo user fallback
  return DailyGoal(
    targetMinutes: 15,
    completedMinutes: (user?.totalMinutes ?? 0) % 60,
    lessonsCompleted: user?.lessonsCompleted ?? 0,
    streakDays: user?.streakDays ?? 0,
    isGoalMet: false,
    progress: 0.0,
  );
});

class DailyGoal {
  final int targetMinutes;
  final int completedMinutes;
  final int lessonsCompleted;
  final int streakDays;
  final bool isGoalMet;
  final double progress;

  const DailyGoal({
    required this.targetMinutes,
    required this.completedMinutes,
    required this.lessonsCompleted,
    required this.streakDays,
    required this.isGoalMet,
    required this.progress,
  });
}

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;

  if (user != null && user.isDemo) {
    // Demo users get all achievements unlocked for preview
    return _getDefaultAchievements(user, allUnlocked: true);
  }

  if (user != null) {
    try {
      final achievementsData = await ProgressService.getAchievements();
      if (achievementsData.isEmpty) {
        // Backend returned empty or failed, return locked achievements
        return _getDefaultAchievements(user, allUnlocked: false);
      }
      return achievementsData.map((data) {
        return Achievement(
          id: data['id'] as String,
          name: data['name'] as String,
          description: data['description'] as String,
          iconName: data['icon_name'] as String? ?? 'emoji_events',
          isUnlocked: data['is_unlocked'] as bool? ?? false,
          unlockedAt: data['unlocked_at'] as String?,
        );
      }).toList();
    } catch (e) {
      // Fallback to locked achievements for real users
      return _getDefaultAchievements(user, allUnlocked: false);
    }
  }

  // No user - return empty list
  return [];
});

List<Achievement> _getDefaultAchievements(user, {bool allUnlocked = false}) {
  return [
    Achievement(
      id: 'sprout',
      name: 'Sprout',
      description: 'Complete your first lesson',
      iconName: 'eco',
      isUnlocked: allUnlocked,
      unlockedAt: allUnlocked ? '2024-01-15T10:00:00Z' : null,
    ),
    Achievement(
      id: 'spark',
      name: 'Spark',
      description: 'Complete 5 lessons',
      iconName: 'local_fire_department',
      isUnlocked: allUnlocked,
      unlockedAt: allUnlocked ? '2024-01-20T10:00:00Z' : null,
    ),
    Achievement(
      id: 'streak',
      name: 'Streak Master',
      description: '7-day learning streak',
      iconName: 'trending_up',
      isUnlocked: allUnlocked,
      unlockedAt: allUnlocked ? '2024-01-25T10:00:00Z' : null,
    ),
    Achievement(
      id: 'dedicated',
      name: 'Dedicated Learner',
      description: 'Complete 20 lessons',
      iconName: 'school',
      isUnlocked: allUnlocked,
      unlockedAt: allUnlocked ? '2024-02-01T10:00:00Z' : null,
    ),
    Achievement(
      id: 'expert',
      name: 'Expert',
      description: 'Reach level 10',
      iconName: 'workspace_premium',
      isUnlocked: allUnlocked,
      unlockedAt: allUnlocked ? '2024-02-10T10:00:00Z' : null,
    ),
  ];
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final String? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.isUnlocked,
    this.unlockedAt,
  });
}
