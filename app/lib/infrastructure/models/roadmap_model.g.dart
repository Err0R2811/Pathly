// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roadmap_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoadmapModelImpl _$$RoadmapModelImplFromJson(Map<String, dynamic> json) =>
    _$RoadmapModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      skillName: json['skillName'] as String,
      domainType: json['domainType'] as String,
      verificationScore: (json['verificationScore'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String,
      modules: (json['modules'] as List<dynamic>?)
              ?.map((e) => ModuleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      certificationInfo: json['certificationInfo'] == null
          ? null
          : CertificationInfo.fromJson(
              json['certificationInfo'] as Map<String, dynamic>),
      prerequisites: (json['prerequisites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      learningObjectives: (json['learningObjectives'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      careerOutcomes: (json['careerOutcomes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      salaryRange: json['salaryRange'] as String?,
      marketDemand: json['marketDemand'] as String?,
    );

Map<String, dynamic> _$$RoadmapModelImplToJson(_$RoadmapModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'skillName': instance.skillName,
      'domainType': instance.domainType,
      'verificationScore': instance.verificationScore,
      'createdAt': instance.createdAt,
      'modules': instance.modules,
      'certificationInfo': instance.certificationInfo,
      'prerequisites': instance.prerequisites,
      'learningObjectives': instance.learningObjectives,
      'careerOutcomes': instance.careerOutcomes,
      'salaryRange': instance.salaryRange,
      'marketDemand': instance.marketDemand,
    };

_$CertificationInfoImpl _$$CertificationInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$CertificationInfoImpl(
      availableCertifications:
          (json['availableCertifications'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      recommendedCertification: json['recommendedCertification'] as String?,
      certificationBody: json['certificationBody'] as String?,
    );

Map<String, dynamic> _$$CertificationInfoImplToJson(
        _$CertificationInfoImpl instance) =>
    <String, dynamic>{
      'availableCertifications': instance.availableCertifications,
      'recommendedCertification': instance.recommendedCertification,
      'certificationBody': instance.certificationBody,
    };

_$ModuleModelImpl _$$ModuleModelImplFromJson(Map<String, dynamic> json) =>
    _$ModuleModelImpl(
      id: json['id'] as String,
      roadmapId: json['roadmapId'] as String,
      moduleName: json['moduleName'] as String,
      level: json['level'] as String,
      difficultyScore: (json['difficultyScore'] as num?)?.toInt() ?? 0,
      verificationAlignmentScore:
          (json['verificationAlignmentScore'] as num?)?.toInt() ?? 0,
      estimatedHours: (json['estimatedHours'] as num?)?.toInt() ?? 0,
      pedagogicalBasis: json['pedagogicalBasis'] as String?,
      learningObjectives: (json['learningObjectives'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      skillsGained: (json['skillsGained'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      projects: (json['projects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      assessmentCriteria: json['assessmentCriteria'] as String?,
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) =>
                  ResearchSourceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ModuleModelImplToJson(_$ModuleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roadmapId': instance.roadmapId,
      'moduleName': instance.moduleName,
      'level': instance.level,
      'difficultyScore': instance.difficultyScore,
      'verificationAlignmentScore': instance.verificationAlignmentScore,
      'estimatedHours': instance.estimatedHours,
      'pedagogicalBasis': instance.pedagogicalBasis,
      'learningObjectives': instance.learningObjectives,
      'skillsGained': instance.skillsGained,
      'projects': instance.projects,
      'assessmentCriteria': instance.assessmentCriteria,
      'sources': instance.sources,
    };

_$ResearchSourceModelImpl _$$ResearchSourceModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ResearchSourceModelImpl(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      title: json['title'] as String?,
      doi: json['doi'] as String?,
      url: json['url'] as String?,
      abstract_: json['abstract_'] as String?,
      sourceType: json['sourceType'] as String?,
      author: json['author'] as String?,
      relevanceScore: (json['relevanceScore'] as num?)?.toInt() ?? 5,
      videoDuration: (json['videoDuration'] as num?)?.toInt(),
      thumbnail: json['thumbnail'] as String?,
    );

Map<String, dynamic> _$$ResearchSourceModelImplToJson(
        _$ResearchSourceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'moduleId': instance.moduleId,
      'title': instance.title,
      'doi': instance.doi,
      'url': instance.url,
      'abstract_': instance.abstract_,
      'sourceType': instance.sourceType,
      'author': instance.author,
      'relevanceScore': instance.relevanceScore,
      'videoDuration': instance.videoDuration,
      'thumbnail': instance.thumbnail,
    };
