// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LessonModel _$LessonModelFromJson(Map<String, dynamic> json) {
  return _LessonModel.fromJson(json);
}

/// @nodoc
mixin _$LessonModel {
  String get id => throw _privateConstructorUsedError;
  String get moduleId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<LessonStepModel> get steps => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  String? get iconName => throw _privateConstructorUsedError;

  /// Serializes this LessonModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonModelCopyWith<LessonModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonModelCopyWith<$Res> {
  factory $LessonModelCopyWith(
          LessonModel value, $Res Function(LessonModel) then) =
      _$LessonModelCopyWithImpl<$Res, LessonModel>;
  @useResult
  $Res call(
      {String id,
      String moduleId,
      String title,
      String description,
      List<LessonStepModel> steps,
      int durationMinutes,
      String difficulty,
      String? iconName});
}

/// @nodoc
class _$LessonModelCopyWithImpl<$Res, $Val extends LessonModel>
    implements $LessonModelCopyWith<$Res> {
  _$LessonModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? moduleId = null,
    Object? title = null,
    Object? description = null,
    Object? steps = null,
    Object? durationMinutes = null,
    Object? difficulty = null,
    Object? iconName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      moduleId: null == moduleId
          ? _value.moduleId
          : moduleId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<LessonStepModel>,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      iconName: freezed == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonModelImplCopyWith<$Res>
    implements $LessonModelCopyWith<$Res> {
  factory _$$LessonModelImplCopyWith(
          _$LessonModelImpl value, $Res Function(_$LessonModelImpl) then) =
      __$$LessonModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String moduleId,
      String title,
      String description,
      List<LessonStepModel> steps,
      int durationMinutes,
      String difficulty,
      String? iconName});
}

/// @nodoc
class __$$LessonModelImplCopyWithImpl<$Res>
    extends _$LessonModelCopyWithImpl<$Res, _$LessonModelImpl>
    implements _$$LessonModelImplCopyWith<$Res> {
  __$$LessonModelImplCopyWithImpl(
      _$LessonModelImpl _value, $Res Function(_$LessonModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? moduleId = null,
    Object? title = null,
    Object? description = null,
    Object? steps = null,
    Object? durationMinutes = null,
    Object? difficulty = null,
    Object? iconName = freezed,
  }) {
    return _then(_$LessonModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      moduleId: null == moduleId
          ? _value.moduleId
          : moduleId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      steps: null == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<LessonStepModel>,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      iconName: freezed == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonModelImpl implements _LessonModel {
  const _$LessonModelImpl(
      {required this.id,
      required this.moduleId,
      required this.title,
      required this.description,
      final List<LessonStepModel> steps = const [],
      this.durationMinutes = 0,
      this.difficulty = 'beginner',
      this.iconName})
      : _steps = steps;

  factory _$LessonModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonModelImplFromJson(json);

  @override
  final String id;
  @override
  final String moduleId;
  @override
  final String title;
  @override
  final String description;
  final List<LessonStepModel> _steps;
  @override
  @JsonKey()
  List<LessonStepModel> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  @JsonKey()
  final int durationMinutes;
  @override
  @JsonKey()
  final String difficulty;
  @override
  final String? iconName;

  @override
  String toString() {
    return 'LessonModel(id: $id, moduleId: $moduleId, title: $title, description: $description, steps: $steps, durationMinutes: $durationMinutes, difficulty: $difficulty, iconName: $iconName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.moduleId, moduleId) ||
                other.moduleId == moduleId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      moduleId,
      title,
      description,
      const DeepCollectionEquality().hash(_steps),
      durationMinutes,
      difficulty,
      iconName);

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonModelImplCopyWith<_$LessonModelImpl> get copyWith =>
      __$$LessonModelImplCopyWithImpl<_$LessonModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonModelImplToJson(
      this,
    );
  }
}

abstract class _LessonModel implements LessonModel {
  const factory _LessonModel(
      {required final String id,
      required final String moduleId,
      required final String title,
      required final String description,
      final List<LessonStepModel> steps,
      final int durationMinutes,
      final String difficulty,
      final String? iconName}) = _$LessonModelImpl;

  factory _LessonModel.fromJson(Map<String, dynamic> json) =
      _$LessonModelImpl.fromJson;

  @override
  String get id;
  @override
  String get moduleId;
  @override
  String get title;
  @override
  String get description;
  @override
  List<LessonStepModel> get steps;
  @override
  int get durationMinutes;
  @override
  String get difficulty;
  @override
  String? get iconName;

  /// Create a copy of LessonModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonModelImplCopyWith<_$LessonModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonStepModel _$LessonStepModelFromJson(Map<String, dynamic> json) {
  return _LessonStepModel.fromJson(json);
}

/// @nodoc
mixin _$LessonStepModel {
  String get id => throw _privateConstructorUsedError;
  String get lessonId => throw _privateConstructorUsedError;
  int get stepNumber => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get mediaUrl => throw _privateConstructorUsedError;
  String? get mediaType => throw _privateConstructorUsedError;
  List<String> get tips => throw _privateConstructorUsedError;

  /// Serializes this LessonStepModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LessonStepModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LessonStepModelCopyWith<LessonStepModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonStepModelCopyWith<$Res> {
  factory $LessonStepModelCopyWith(
          LessonStepModel value, $Res Function(LessonStepModel) then) =
      _$LessonStepModelCopyWithImpl<$Res, LessonStepModel>;
  @useResult
  $Res call(
      {String id,
      String lessonId,
      int stepNumber,
      String title,
      String content,
      String? mediaUrl,
      String? mediaType,
      List<String> tips});
}

/// @nodoc
class _$LessonStepModelCopyWithImpl<$Res, $Val extends LessonStepModel>
    implements $LessonStepModelCopyWith<$Res> {
  _$LessonStepModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LessonStepModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lessonId = null,
    Object? stepNumber = null,
    Object? title = null,
    Object? content = null,
    Object? mediaUrl = freezed,
    Object? mediaType = freezed,
    Object? tips = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _value.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
      stepNumber: null == stepNumber
          ? _value.stepNumber
          : stepNumber // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaType: freezed == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String?,
      tips: null == tips
          ? _value.tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonStepModelImplCopyWith<$Res>
    implements $LessonStepModelCopyWith<$Res> {
  factory _$$LessonStepModelImplCopyWith(_$LessonStepModelImpl value,
          $Res Function(_$LessonStepModelImpl) then) =
      __$$LessonStepModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String lessonId,
      int stepNumber,
      String title,
      String content,
      String? mediaUrl,
      String? mediaType,
      List<String> tips});
}

/// @nodoc
class __$$LessonStepModelImplCopyWithImpl<$Res>
    extends _$LessonStepModelCopyWithImpl<$Res, _$LessonStepModelImpl>
    implements _$$LessonStepModelImplCopyWith<$Res> {
  __$$LessonStepModelImplCopyWithImpl(
      _$LessonStepModelImpl _value, $Res Function(_$LessonStepModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LessonStepModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lessonId = null,
    Object? stepNumber = null,
    Object? title = null,
    Object? content = null,
    Object? mediaUrl = freezed,
    Object? mediaType = freezed,
    Object? tips = null,
  }) {
    return _then(_$LessonStepModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lessonId: null == lessonId
          ? _value.lessonId
          : lessonId // ignore: cast_nullable_to_non_nullable
              as String,
      stepNumber: null == stepNumber
          ? _value.stepNumber
          : stepNumber // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaType: freezed == mediaType
          ? _value.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String?,
      tips: null == tips
          ? _value._tips
          : tips // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonStepModelImpl implements _LessonStepModel {
  const _$LessonStepModelImpl(
      {required this.id,
      required this.lessonId,
      required this.stepNumber,
      required this.title,
      required this.content,
      this.mediaUrl,
      this.mediaType,
      final List<String> tips = const []})
      : _tips = tips;

  factory _$LessonStepModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonStepModelImplFromJson(json);

  @override
  final String id;
  @override
  final String lessonId;
  @override
  final int stepNumber;
  @override
  final String title;
  @override
  final String content;
  @override
  final String? mediaUrl;
  @override
  final String? mediaType;
  final List<String> _tips;
  @override
  @JsonKey()
  List<String> get tips {
    if (_tips is EqualUnmodifiableListView) return _tips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tips);
  }

  @override
  String toString() {
    return 'LessonStepModel(id: $id, lessonId: $lessonId, stepNumber: $stepNumber, title: $title, content: $content, mediaUrl: $mediaUrl, mediaType: $mediaType, tips: $tips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonStepModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.stepNumber, stepNumber) ||
                other.stepNumber == stepNumber) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            const DeepCollectionEquality().equals(other._tips, _tips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, lessonId, stepNumber, title,
      content, mediaUrl, mediaType, const DeepCollectionEquality().hash(_tips));

  /// Create a copy of LessonStepModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonStepModelImplCopyWith<_$LessonStepModelImpl> get copyWith =>
      __$$LessonStepModelImplCopyWithImpl<_$LessonStepModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonStepModelImplToJson(
      this,
    );
  }
}

abstract class _LessonStepModel implements LessonStepModel {
  const factory _LessonStepModel(
      {required final String id,
      required final String lessonId,
      required final int stepNumber,
      required final String title,
      required final String content,
      final String? mediaUrl,
      final String? mediaType,
      final List<String> tips}) = _$LessonStepModelImpl;

  factory _LessonStepModel.fromJson(Map<String, dynamic> json) =
      _$LessonStepModelImpl.fromJson;

  @override
  String get id;
  @override
  String get lessonId;
  @override
  int get stepNumber;
  @override
  String get title;
  @override
  String get content;
  @override
  String? get mediaUrl;
  @override
  String? get mediaType;
  @override
  List<String> get tips;

  /// Create a copy of LessonStepModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LessonStepModelImplCopyWith<_$LessonStepModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
