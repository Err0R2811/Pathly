import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final onboardingPreferencesProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingPreferences>((ref) {
  return OnboardingNotifier();
});

class OnboardingPreferences {
  final String skillGoal;
  final String duration;
  final bool hasCompletedOnboarding;

  const OnboardingPreferences({
    this.skillGoal = '',
    this.duration = '',
    this.hasCompletedOnboarding = false,
  });

  OnboardingPreferences copyWith({
    String? skillGoal,
    String? duration,
    bool? hasCompletedOnboarding,
  }) {
    return OnboardingPreferences(
      skillGoal: skillGoal ?? this.skillGoal,
      duration: duration ?? this.duration,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingPreferences> {
  OnboardingNotifier() : super(const OnboardingPreferences()) {
    _loadPreferences();
  }

  static const String _boxName = 'onboarding_preferences';

  Future<void> _loadPreferences() async {
    try {
      final box = Hive.box<String>(_boxName);
      state = OnboardingPreferences(
        skillGoal: box.get('skill_goal', defaultValue: '') ?? '',
        duration: box.get('duration', defaultValue: '') ?? '',
        hasCompletedOnboarding:
            box.get('completed', defaultValue: 'false') == 'true',
      );
    } catch (e) {
      state = const OnboardingPreferences();
    }
  }

  Future<void> setSkillGoal(String skill) async {
    state = state.copyWith(skillGoal: skill);
    await _savePreference('skill_goal', skill);
  }

  Future<void> setDuration(String duration) async {
    state = state.copyWith(duration: duration);
    await _savePreference('duration', duration);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: true);
    await _savePreference('completed', 'true');
  }

  Future<void> _savePreference(String key, String value) async {
    try {
      final box = Hive.box<String>(_boxName);
      await box.put(key, value);
    } catch (e) {
      // Silently fail if Hive is not initialized
    }
  }
}

final availableSkillsProvider = Provider<List<SkillOption>>((ref) {
  return const [
    SkillOption(id: 'magic_tricks', name: 'Magic Tricks', iconName: 'auto_fix_high'),
    SkillOption(id: 'coding', name: 'Coding Basics', iconName: 'code'),
    SkillOption(id: 'memory', name: 'Memory Hacks', iconName: 'psychology'),
    SkillOption(id: 'drawing', name: 'Drawing', iconName: 'brush'),
    SkillOption(id: 'speaking', name: 'Public Speaking', iconName: 'record_voice_over'),
    SkillOption(id: 'fitness', name: 'Fitness', iconName: 'fitness_center'),
    SkillOption(id: 'languages', name: 'Languages', iconName: 'translate'),
    SkillOption(id: 'music', name: 'Music', iconName: 'music_note'),
    SkillOption(id: 'cooking', name: 'Cooking', iconName: 'restaurant'),
    SkillOption(id: 'photography', name: 'Photography', iconName: 'camera_alt'),
  ];
});

class SkillOption {
  final String id;
  final String name;
  final String iconName;

  const SkillOption({
    required this.id,
    required this.name,
    required this.iconName,
  });
}
