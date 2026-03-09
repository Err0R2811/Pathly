import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pathly_app/features/auth/providers/auth_provider.dart';

final userProgressProvider = Provider<UserProgress>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;

  if (user != null) {
    return UserProgress(
      currentSkill: 'Magic Tricks',
      lessonsCompleted: user.lessonsCompleted,
      totalLessons: 18,
      progressPercentage: (user.lessonsCompleted / 18 * 100).round(),
      streakDays: user.streakDays,
      totalMinutes: user.totalMinutes,
      xp: user.xp,
      level: user.level,
    );
  }

  return const UserProgress(
    currentSkill: 'Magic Tricks',
    lessonsCompleted: 12,
    totalLessons: 18,
    progressPercentage: 65,
    streakDays: 7,
    totalMinutes: 240,
    xp: 1250,
    level: 5,
  );
});

class UserProgress {
  final String currentSkill;
  final int lessonsCompleted;
  final int totalLessons;
  final int progressPercentage;
  final int streakDays;
  final int totalMinutes;
  final int xp;
  final int level;

  const UserProgress({
    required this.currentSkill,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.progressPercentage,
    required this.streakDays,
    required this.totalMinutes,
    required this.xp,
    required this.level,
  });

  String get dailyGoal => '$streakDays day streak';
  int get xpToNextLevel => (level + 1) * 500 - xp;
  double get levelProgress => xp % 500 / 500;
}

final dailyGoalProvider = Provider<DailyGoal>((ref) {
  final progress = ref.watch(userProgressProvider);

  return DailyGoal(
    targetMinutes: 15,
    completedMinutes: progress.totalMinutes % 60,
    lessonsCompleted: progress.lessonsCompleted,
    streakDays: progress.streakDays,
  );
});

class DailyGoal {
  final int targetMinutes;
  final int completedMinutes;
  final int lessonsCompleted;
  final int streakDays;

  const DailyGoal({
    required this.targetMinutes,
    required this.completedMinutes,
    required this.lessonsCompleted,
    required this.streakDays,
  });

  bool get isGoalMet => completedMinutes >= targetMinutes;
  double get progress => completedMinutes / targetMinutes;
}

final achievementsProvider = Provider<List<Achievement>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.user;

  final allAchievements = [
    const Achievement(
      id: 'sprout',
      name: 'Sprout',
      description: 'Complete your first lesson',
      iconName: 'eco',
      isUnlocked: true,
      unlockedAt: '2026-02-15',
    ),
    const Achievement(
      id: 'spark',
      name: 'Spark',
      description: 'Maintain a 7-day streak',
      iconName: 'local_fire_department',
      isUnlocked: true,
      unlockedAt: '2026-02-22',
    ),
    const Achievement(
      id: 'scholar',
      name: 'Scholar',
      description: 'Complete 10 lessons',
      iconName: 'school',
      isUnlocked: false,
    ),
    const Achievement(
      id: 'master',
      name: 'Master',
      description: 'Reach level 10',
      iconName: 'military_tech',
      isUnlocked: false,
    ),
    const Achievement(
      id: 'dedicated',
      name: 'Dedicated',
      description: '30-day streak',
      iconName: 'workspace_premium',
      isUnlocked: false,
    ),
    const Achievement(
      id: 'explorer',
      name: 'Explorer',
      description: 'Try 5 different skills',
      iconName: 'explore',
      isUnlocked: false,
    ),
  ];

  if (user != null) {
    return allAchievements.map((a) {
      if (a.id == 'sprout' && user.lessonsCompleted >= 1) {
        return a.copyWith(isUnlocked: true);
      }
      if (a.id == 'spark' && user.streakDays >= 7) {
        return a.copyWith(isUnlocked: true);
      }
      if (a.id == 'scholar' && user.lessonsCompleted >= 10) {
        return a.copyWith(isUnlocked: true);
      }
      if (a.id == 'master' && user.level >= 10) {
        return a.copyWith(isUnlocked: true);
      }
      return a;
    }).toList();
  }

  return allAchievements;
});

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

  Achievement copyWith({
    bool? isUnlocked,
    String? unlockedAt,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      iconName: iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
