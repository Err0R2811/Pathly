// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonModelImpl _$$LessonModelImplFromJson(Map<String, dynamic> json) =>
    _$LessonModelImpl(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => LessonStepModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty'] as String? ?? 'beginner',
      iconName: json['iconName'] as String?,
    );

Map<String, dynamic> _$$LessonModelImplToJson(_$LessonModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'moduleId': instance.moduleId,
      'title': instance.title,
      'description': instance.description,
      'steps': instance.steps,
      'durationMinutes': instance.durationMinutes,
      'difficulty': instance.difficulty,
      'iconName': instance.iconName,
    };

_$LessonStepModelImpl _$$LessonStepModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LessonStepModelImpl(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      stepNumber: (json['stepNumber'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: json['mediaType'] as String?,
      tips:
          (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$$LessonStepModelImplToJson(
        _$LessonStepModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lessonId': instance.lessonId,
      'stepNumber': instance.stepNumber,
      'title': instance.title,
      'content': instance.content,
      'mediaUrl': instance.mediaUrl,
      'mediaType': instance.mediaType,
      'tips': instance.tips,
    };
