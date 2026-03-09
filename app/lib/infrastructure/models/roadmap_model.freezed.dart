// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'roadmap_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoadmapModel _$RoadmapModelFromJson(Map<String, dynamic> json) {
  return _RoadmapModel.fromJson(json);
}

/// @nodoc
mixin _$RoadmapModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get skillName => throw _privateConstructorUsedError;
  String get domainType => throw _privateConstructorUsedError;
  int get verificationScore => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  List<ModuleModel> get modules => throw _privateConstructorUsedError;

  /// Serializes this RoadmapModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoadmapModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoadmapModelCopyWith<RoadmapModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoadmapModelCopyWith<$Res> {
  factory $RoadmapModelCopyWith(
          RoadmapModel value, $Res Function(RoadmapModel) then) =
      _$RoadmapModelCopyWithImpl<$Res, RoadmapModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String skillName,
      String domainType,
      int verificationScore,
      String createdAt,
      List<ModuleModel> modules});
}

/// @nodoc
class _$RoadmapModelCopyWithImpl<$Res, $Val extends RoadmapModel>
    implements $RoadmapModelCopyWith<$Res> {
  _$RoadmapModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoadmapModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? skillName = null,
    Object? domainType = null,
    Object? verificationScore = null,
    Object? createdAt = null,
    Object? modules = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      skillName: null == skillName
          ? _value.skillName
          : skillName // ignore: cast_nullable_to_non_nullable
              as String,
      domainType: null == domainType
          ? _value.domainType
          : domainType // ignore: cast_nullable_to_non_nullable
              as String,
      verificationScore: null == verificationScore
          ? _value.verificationScore
          : verificationScore // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      modules: null == modules
          ? _value.modules
          : modules // ignore: cast_nullable_to_non_nullable
              as List<ModuleModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoadmapModelImplCopyWith<$Res>
    implements $RoadmapModelCopyWith<$Res> {
  factory _$$RoadmapModelImplCopyWith(
          _$RoadmapModelImpl value, $Res Function(_$RoadmapModelImpl) then) =
      __$$RoadmapModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String skillName,
      String domainType,
      int verificationScore,
      String createdAt,
      List<ModuleModel> modules});
}

/// @nodoc
class __$$RoadmapModelImplCopyWithImpl<$Res>
    extends _$RoadmapModelCopyWithImpl<$Res, _$RoadmapModelImpl>
    implements _$$RoadmapModelImplCopyWith<$Res> {
  __$$RoadmapModelImplCopyWithImpl(
      _$RoadmapModelImpl _value, $Res Function(_$RoadmapModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoadmapModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? skillName = null,
    Object? domainType = null,
    Object? verificationScore = null,
    Object? createdAt = null,
    Object? modules = null,
  }) {
    return _then(_$RoadmapModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      skillName: null == skillName
          ? _value.skillName
          : skillName // ignore: cast_nullable_to_non_nullable
              as String,
      domainType: null == domainType
          ? _value.domainType
          : domainType // ignore: cast_nullable_to_non_nullable
              as String,
      verificationScore: null == verificationScore
          ? _value.verificationScore
          : verificationScore // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      modules: null == modules
          ? _value._modules
          : modules // ignore: cast_nullable_to_non_nullable
              as List<ModuleModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoadmapModelImpl implements _RoadmapModel {
  const _$RoadmapModelImpl(
      {required this.id,
      required this.userId,
      required this.skillName,
      required this.domainType,
      this.verificationScore = 0,
      required this.createdAt,
      final List<ModuleModel> modules = const []})
      : _modules = modules;

  factory _$RoadmapModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoadmapModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String skillName;
  @override
  final String domainType;
  @override
  @JsonKey()
  final int verificationScore;
  @override
  final String createdAt;
  final List<ModuleModel> _modules;
  @override
  @JsonKey()
  List<ModuleModel> get modules {
    if (_modules is EqualUnmodifiableListView) return _modules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modules);
  }

  @override
  String toString() {
    return 'RoadmapModel(id: $id, userId: $userId, skillName: $skillName, domainType: $domainType, verificationScore: $verificationScore, createdAt: $createdAt, modules: $modules)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoadmapModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.skillName, skillName) ||
                other.skillName == skillName) &&
            (identical(other.domainType, domainType) ||
                other.domainType == domainType) &&
            (identical(other.verificationScore, verificationScore) ||
                other.verificationScore == verificationScore) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._modules, _modules));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      skillName,
      domainType,
      verificationScore,
      createdAt,
      const DeepCollectionEquality().hash(_modules));

  /// Create a copy of RoadmapModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoadmapModelImplCopyWith<_$RoadmapModelImpl> get copyWith =>
      __$$RoadmapModelImplCopyWithImpl<_$RoadmapModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoadmapModelImplToJson(
      this,
    );
  }
}

abstract class _RoadmapModel implements RoadmapModel {
  const factory _RoadmapModel(
      {required final String id,
      required final String userId,
      required final String skillName,
      required final String domainType,
      final int verificationScore,
      required final String createdAt,
      final List<ModuleModel> modules}) = _$RoadmapModelImpl;

  factory _RoadmapModel.fromJson(Map<String, dynamic> json) =
      _$RoadmapModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get skillName;
  @override
  String get domainType;
  @override
  int get verificationScore;
  @override
  String get createdAt;
  @override
  List<ModuleModel> get modules;

  /// Create a copy of RoadmapModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoadmapModelImplCopyWith<_$RoadmapModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModuleModel _$ModuleModelFromJson(Map<String, dynamic> json) {
  return _ModuleModel.fromJson(json);
}

/// @nodoc
mixin _$ModuleModel {
  String get id => throw _privateConstructorUsedError;
  String get roadmapId => throw _privateConstructorUsedError;
  String get moduleName => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  int get difficultyScore => throw _privateConstructorUsedError;
  int get verificationAlignmentScore => throw _privateConstructorUsedError;
  int get estimatedHours => throw _privateConstructorUsedError;
  String? get pedagogicalBasis => throw _privateConstructorUsedError;
  List<ResearchSourceModel> get sources => throw _privateConstructorUsedError;

  /// Serializes this ModuleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModuleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModuleModelCopyWith<ModuleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModuleModelCopyWith<$Res> {
  factory $ModuleModelCopyWith(
          ModuleModel value, $Res Function(ModuleModel) then) =
      _$ModuleModelCopyWithImpl<$Res, ModuleModel>;
  @useResult
  $Res call(
      {String id,
      String roadmapId,
      String moduleName,
      String level,
      int difficultyScore,
      int verificationAlignmentScore,
      int estimatedHours,
      String? pedagogicalBasis,
      List<ResearchSourceModel> sources});
}

/// @nodoc
class _$ModuleModelCopyWithImpl<$Res, $Val extends ModuleModel>
    implements $ModuleModelCopyWith<$Res> {
  _$ModuleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModuleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roadmapId = null,
    Object? moduleName = null,
    Object? level = null,
    Object? difficultyScore = null,
    Object? verificationAlignmentScore = null,
    Object? estimatedHours = null,
    Object? pedagogicalBasis = freezed,
    Object? sources = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roadmapId: null == roadmapId
          ? _value.roadmapId
          : roadmapId // ignore: cast_nullable_to_non_nullable
              as String,
      moduleName: null == moduleName
          ? _value.moduleName
          : moduleName // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyScore: null == difficultyScore
          ? _value.difficultyScore
          : difficultyScore // ignore: cast_nullable_to_non_nullable
              as int,
      verificationAlignmentScore: null == verificationAlignmentScore
          ? _value.verificationAlignmentScore
          : verificationAlignmentScore // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedHours: null == estimatedHours
          ? _value.estimatedHours
          : estimatedHours // ignore: cast_nullable_to_non_nullable
              as int,
      pedagogicalBasis: freezed == pedagogicalBasis
          ? _value.pedagogicalBasis
          : pedagogicalBasis // ignore: cast_nullable_to_non_nullable
              as String?,
      sources: null == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<ResearchSourceModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ModuleModelImplCopyWith<$Res>
    implements $ModuleModelCopyWith<$Res> {
  factory _$$ModuleModelImplCopyWith(
          _$ModuleModelImpl value, $Res Function(_$ModuleModelImpl) then) =
      __$$ModuleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String roadmapId,
      String moduleName,
      String level,
      int difficultyScore,
      int verificationAlignmentScore,
      int estimatedHours,
      String? pedagogicalBasis,
      List<ResearchSourceModel> sources});
}

/// @nodoc
class __$$ModuleModelImplCopyWithImpl<$Res>
    extends _$ModuleModelCopyWithImpl<$Res, _$ModuleModelImpl>
    implements _$$ModuleModelImplCopyWith<$Res> {
  __$$ModuleModelImplCopyWithImpl(
      _$ModuleModelImpl _value, $Res Function(_$ModuleModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ModuleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roadmapId = null,
    Object? moduleName = null,
    Object? level = null,
    Object? difficultyScore = null,
    Object? verificationAlignmentScore = null,
    Object? estimatedHours = null,
    Object? pedagogicalBasis = freezed,
    Object? sources = null,
  }) {
    return _then(_$ModuleModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roadmapId: null == roadmapId
          ? _value.roadmapId
          : roadmapId // ignore: cast_nullable_to_non_nullable
              as String,
      moduleName: null == moduleName
          ? _value.moduleName
          : moduleName // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      difficultyScore: null == difficultyScore
          ? _value.difficultyScore
          : difficultyScore // ignore: cast_nullable_to_non_nullable
              as int,
      verificationAlignmentScore: null == verificationAlignmentScore
          ? _value.verificationAlignmentScore
          : verificationAlignmentScore // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedHours: null == estimatedHours
          ? _value.estimatedHours
          : estimatedHours // ignore: cast_nullable_to_non_nullable
              as int,
      pedagogicalBasis: freezed == pedagogicalBasis
          ? _value.pedagogicalBasis
          : pedagogicalBasis // ignore: cast_nullable_to_non_nullable
              as String?,
      sources: null == sources
          ? _value._sources
          : sources // ignore: cast_nullable_to_non_nullable
              as List<ResearchSourceModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ModuleModelImpl implements _ModuleModel {
  const _$ModuleModelImpl(
      {required this.id,
      required this.roadmapId,
      required this.moduleName,
      required this.level,
      this.difficultyScore = 0,
      this.verificationAlignmentScore = 0,
      this.estimatedHours = 0,
      this.pedagogicalBasis,
      final List<ResearchSourceModel> sources = const []})
      : _sources = sources;

  factory _$ModuleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModuleModelImplFromJson(json);

  @override
  final String id;
  @override
  final String roadmapId;
  @override
  final String moduleName;
  @override
  final String level;
  @override
  @JsonKey()
  final int difficultyScore;
  @override
  @JsonKey()
  final int verificationAlignmentScore;
  @override
  @JsonKey()
  final int estimatedHours;
  @override
  final String? pedagogicalBasis;
  final List<ResearchSourceModel> _sources;
  @override
  @JsonKey()
  List<ResearchSourceModel> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  @override
  String toString() {
    return 'ModuleModel(id: $id, roadmapId: $roadmapId, moduleName: $moduleName, level: $level, difficultyScore: $difficultyScore, verificationAlignmentScore: $verificationAlignmentScore, estimatedHours: $estimatedHours, pedagogicalBasis: $pedagogicalBasis, sources: $sources)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModuleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roadmapId, roadmapId) ||
                other.roadmapId == roadmapId) &&
            (identical(other.moduleName, moduleName) ||
                other.moduleName == moduleName) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.difficultyScore, difficultyScore) ||
                other.difficultyScore == difficultyScore) &&
            (identical(other.verificationAlignmentScore,
                    verificationAlignmentScore) ||
                other.verificationAlignmentScore ==
                    verificationAlignmentScore) &&
            (identical(other.estimatedHours, estimatedHours) ||
                other.estimatedHours == estimatedHours) &&
            (identical(other.pedagogicalBasis, pedagogicalBasis) ||
                other.pedagogicalBasis == pedagogicalBasis) &&
            const DeepCollectionEquality().equals(other._sources, _sources));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      roadmapId,
      moduleName,
      level,
      difficultyScore,
      verificationAlignmentScore,
      estimatedHours,
      pedagogicalBasis,
      const DeepCollectionEquality().hash(_sources));

  /// Create a copy of ModuleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModuleModelImplCopyWith<_$ModuleModelImpl> get copyWith =>
      __$$ModuleModelImplCopyWithImpl<_$ModuleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModuleModelImplToJson(
      this,
    );
  }
}

abstract class _ModuleModel implements ModuleModel {
  const factory _ModuleModel(
      {required final String id,
      required final String roadmapId,
      required final String moduleName,
      required final String level,
      final int difficultyScore,
      final int verificationAlignmentScore,
      final int estimatedHours,
      final String? pedagogicalBasis,
      final List<ResearchSourceModel> sources}) = _$ModuleModelImpl;

  factory _ModuleModel.fromJson(Map<String, dynamic> json) =
      _$ModuleModelImpl.fromJson;

  @override
  String get id;
  @override
  String get roadmapId;
  @override
  String get moduleName;
  @override
  String get level;
  @override
  int get difficultyScore;
  @override
  int get verificationAlignmentScore;
  @override
  int get estimatedHours;
  @override
  String? get pedagogicalBasis;
  @override
  List<ResearchSourceModel> get sources;

  /// Create a copy of ModuleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModuleModelImplCopyWith<_$ModuleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResearchSourceModel _$ResearchSourceModelFromJson(Map<String, dynamic> json) {
  return _ResearchSourceModel.fromJson(json);
}

/// @nodoc
mixin _$ResearchSourceModel {
  String get id => throw _privateConstructorUsedError;
  String get moduleId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get doi => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get abstract_ => throw _privateConstructorUsedError;

  /// Serializes this ResearchSourceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResearchSourceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResearchSourceModelCopyWith<ResearchSourceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResearchSourceModelCopyWith<$Res> {
  factory $ResearchSourceModelCopyWith(
          ResearchSourceModel value, $Res Function(ResearchSourceModel) then) =
      _$ResearchSourceModelCopyWithImpl<$Res, ResearchSourceModel>;
  @useResult
  $Res call(
      {String id,
      String moduleId,
      String? title,
      String? doi,
      String? url,
      String? abstract_});
}

/// @nodoc
class _$ResearchSourceModelCopyWithImpl<$Res, $Val extends ResearchSourceModel>
    implements $ResearchSourceModelCopyWith<$Res> {
  _$ResearchSourceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResearchSourceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? moduleId = null,
    Object? title = freezed,
    Object? doi = freezed,
    Object? url = freezed,
    Object? abstract_ = freezed,
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
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      doi: freezed == doi
          ? _value.doi
          : doi // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      abstract_: freezed == abstract_
          ? _value.abstract_
          : abstract_ // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResearchSourceModelImplCopyWith<$Res>
    implements $ResearchSourceModelCopyWith<$Res> {
  factory _$$ResearchSourceModelImplCopyWith(_$ResearchSourceModelImpl value,
          $Res Function(_$ResearchSourceModelImpl) then) =
      __$$ResearchSourceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String moduleId,
      String? title,
      String? doi,
      String? url,
      String? abstract_});
}

/// @nodoc
class __$$ResearchSourceModelImplCopyWithImpl<$Res>
    extends _$ResearchSourceModelCopyWithImpl<$Res, _$ResearchSourceModelImpl>
    implements _$$ResearchSourceModelImplCopyWith<$Res> {
  __$$ResearchSourceModelImplCopyWithImpl(_$ResearchSourceModelImpl _value,
      $Res Function(_$ResearchSourceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResearchSourceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? moduleId = null,
    Object? title = freezed,
    Object? doi = freezed,
    Object? url = freezed,
    Object? abstract_ = freezed,
  }) {
    return _then(_$ResearchSourceModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      moduleId: null == moduleId
          ? _value.moduleId
          : moduleId // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      doi: freezed == doi
          ? _value.doi
          : doi // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      abstract_: freezed == abstract_
          ? _value.abstract_
          : abstract_ // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResearchSourceModelImpl implements _ResearchSourceModel {
  const _$ResearchSourceModelImpl(
      {required this.id,
      required this.moduleId,
      this.title,
      this.doi,
      this.url,
      this.abstract_});

  factory _$ResearchSourceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResearchSourceModelImplFromJson(json);

  @override
  final String id;
  @override
  final String moduleId;
  @override
  final String? title;
  @override
  final String? doi;
  @override
  final String? url;
  @override
  final String? abstract_;

  @override
  String toString() {
    return 'ResearchSourceModel(id: $id, moduleId: $moduleId, title: $title, doi: $doi, url: $url, abstract_: $abstract_)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResearchSourceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.moduleId, moduleId) ||
                other.moduleId == moduleId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.doi, doi) || other.doi == doi) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.abstract_, abstract_) ||
                other.abstract_ == abstract_));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, moduleId, title, doi, url, abstract_);

  /// Create a copy of ResearchSourceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResearchSourceModelImplCopyWith<_$ResearchSourceModelImpl> get copyWith =>
      __$$ResearchSourceModelImplCopyWithImpl<_$ResearchSourceModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResearchSourceModelImplToJson(
      this,
    );
  }
}

abstract class _ResearchSourceModel implements ResearchSourceModel {
  const factory _ResearchSourceModel(
      {required final String id,
      required final String moduleId,
      final String? title,
      final String? doi,
      final String? url,
      final String? abstract_}) = _$ResearchSourceModelImpl;

  factory _ResearchSourceModel.fromJson(Map<String, dynamic> json) =
      _$ResearchSourceModelImpl.fromJson;

  @override
  String get id;
  @override
  String get moduleId;
  @override
  String? get title;
  @override
  String? get doi;
  @override
  String? get url;
  @override
  String? get abstract_;

  /// Create a copy of ResearchSourceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResearchSourceModelImplCopyWith<_$ResearchSourceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
