import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    @Default('') String avatarUrl,
    @Default('Beginner') String title,
    @Default(1) int level,
    @Default(0) int xp,
    @Default(0) int streakDays,
    @Default(0) int totalMinutes,
    @Default(0) int lessonsCompleted,
    @Default(false) bool isDemo,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
