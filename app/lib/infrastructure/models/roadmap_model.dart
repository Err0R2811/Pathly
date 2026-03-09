import 'package:freezed_annotation/freezed_annotation.dart';

part 'roadmap_model.freezed.dart';
part 'roadmap_model.g.dart';

@freezed
class RoadmapModel with _$RoadmapModel {
  const factory RoadmapModel({
    required String id,
    required String userId,
    required String skillName,
    required String domainType,
    @Default(0) int verificationScore,
    required String createdAt,
    @Default([]) List<ModuleModel> modules,
  }) = _RoadmapModel;

  factory RoadmapModel.fromJson(Map<String, dynamic> json) =>
      _$RoadmapModelFromJson(json);
}

@freezed
class ModuleModel with _$ModuleModel {
  const factory ModuleModel({
    required String id,
    required String roadmapId,
    required String moduleName,
    required String level,
    @Default(0) int difficultyScore,
    @Default(0) int verificationAlignmentScore,
    @Default(0) int estimatedHours,
    String? pedagogicalBasis,
    @Default([]) List<ResearchSourceModel> sources,
  }) = _ModuleModel;

  factory ModuleModel.fromJson(Map<String, dynamic> json) =>
      _$ModuleModelFromJson(json);
}

@freezed
class ResearchSourceModel with _$ResearchSourceModel {
  const factory ResearchSourceModel({
    required String id,
    required String moduleId,
    String? title,
    String? doi,
    String? url,
    String? abstract_,
  }) = _ResearchSourceModel;

  factory ResearchSourceModel.fromJson(Map<String, dynamic> json) =>
      _$ResearchSourceModelFromJson(json);
}
