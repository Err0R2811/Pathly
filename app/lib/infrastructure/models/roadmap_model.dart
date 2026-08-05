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
    // Enhanced fields
    CertificationInfo? certificationInfo,
    @Default([]) List<String> prerequisites,
    @Default([]) List<String> learningObjectives,
    @Default([]) List<String> careerOutcomes,
    String? salaryRange,
    String? marketDemand,
  }) = _RoadmapModel;

  factory RoadmapModel.fromJson(Map<String, dynamic> json) =>
      _$RoadmapModelFromJson(json);
}

@freezed
class CertificationInfo with _$CertificationInfo {
  const factory CertificationInfo({
    @Default([]) List<String> availableCertifications,
    String? recommendedCertification,
    String? certificationBody,
  }) = _CertificationInfo;

  factory CertificationInfo.fromJson(Map<String, dynamic> json) =>
      _$CertificationInfoFromJson(json);
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
    // Enhanced fields
    @Default([]) List<String> learningObjectives,
    @Default([]) List<String> skillsGained,
    @Default([]) List<String> projects,
    String? assessmentCriteria,
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
    // Enhanced fields
    String? sourceType,
    String? author,
    @Default(5) int relevanceScore,
    int? videoDuration,
    String? thumbnail,
  }) = _ResearchSourceModel;

  factory ResearchSourceModel.fromJson(Map<String, dynamic> json) =>
      _$ResearchSourceModelFromJson(json);
}
