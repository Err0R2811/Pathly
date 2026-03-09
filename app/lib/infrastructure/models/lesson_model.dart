import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_model.freezed.dart';
part 'lesson_model.g.dart';

@freezed
class LessonModel with _$LessonModel {
  const factory LessonModel({
    required String id,
    required String moduleId,
    required String title,
    required String description,
    @Default([]) List<LessonStepModel> steps,
    @Default(0) int durationMinutes,
    @Default('beginner') String difficulty,
    String? iconName,
  }) = _LessonModel;

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);
}

@freezed
class LessonStepModel with _$LessonStepModel {
  const factory LessonStepModel({
    required String id,
    required String lessonId,
    required int stepNumber,
    required String title,
    required String content,
    String? mediaUrl,
    String? mediaType,
    @Default([]) List<String> tips,
  }) = _LessonStepModel;

  factory LessonStepModel.fromJson(Map<String, dynamic> json) =>
      _$LessonStepModelFromJson(json);
}
