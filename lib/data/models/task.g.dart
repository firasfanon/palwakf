// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      titleAr: json['titleAr'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      type: $enumDecode(_$TaskTypeEnumMap, json['type']),
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
      priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
      dueDate: DateTime.parse(json['dueDate'] as String),
      completionDate: json['completionDate'] == null
          ? null
          : DateTime.parse(json['completionDate'] as String),
      caseId: (json['caseId'] as num?)?.toInt(),
      caseReferenceNumber: json['caseReferenceNumber'] as String?,
      linkedCase: json['linkedCase'] == null
          ? null
          : Case.fromJson(json['linkedCase'] as Map<String, dynamic>),
      waqfLandId: (json['waqfLandId'] as num?)?.toInt(),
      waqfLandRegistryId: json['waqfLandRegistryId'] as String?,
      linkedWaqfLand: json['linkedWaqfLand'] == null
          ? null
          : WaqfLand.fromJson(json['linkedWaqfLand'] as Map<String, dynamic>),
      relatedEntityType:
          $enumDecode(_$RelatedEntityTypeEnumMap, json['relatedEntityType']),
      courtName: json['courtName'] as String?,
      courtNameAr: json['courtNameAr'] as String?,
      judgeName: json['judgeName'] as String?,
      judgeNameAr: json['judgeNameAr'] as String?,
      courtHearingDate: json['courtHearingDate'] == null
          ? null
          : DateTime.parse(json['courtHearingDate'] as String),
      courtHearingTime: json['courtHearingTime'] as String?,
      visitPurpose: json['visitPurpose'] as String?,
      visitPurposeAr: json['visitPurposeAr'] as String?,
      siteInspectionType: $enumDecodeNullable(
          _$SiteInspectionTypeEnumMap, json['siteInspectionType']),
      boundaryVerificationStatus: json['boundaryVerificationStatus'] as String?,
      encroachmentDetails: json['encroachmentDetails'] as String?,
      encroachmentDetailsAr: json['encroachmentDetailsAr'] as String?,
      preservationStatus: json['preservationStatus'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      requiresApproval: json['requiresApproval'] as bool?,
      progressPercentage: (json['progressPercentage'] as num?)?.toInt(),
      assignedTo: (json['assignedTo'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble(),
      actualHours: (json['actualHours'] as num?)?.toDouble(),
      followupRequired: json['followupRequired'] as bool?,
      followupDeadline: json['followupDeadline'] == null
          ? null
          : DateTime.parse(json['followupDeadline'] as String),
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'titleAr': instance.titleAr,
      'descriptionAr': instance.descriptionAr,
      'type': _$TaskTypeEnumMap[instance.type]!,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'dueDate': instance.dueDate.toIso8601String(),
      'completionDate': instance.completionDate?.toIso8601String(),
      'caseId': instance.caseId,
      'caseReferenceNumber': instance.caseReferenceNumber,
      'linkedCase': instance.linkedCase,
      'waqfLandId': instance.waqfLandId,
      'waqfLandRegistryId': instance.waqfLandRegistryId,
      'linkedWaqfLand': instance.linkedWaqfLand,
      'relatedEntityType':
          _$RelatedEntityTypeEnumMap[instance.relatedEntityType]!,
      'courtName': instance.courtName,
      'courtNameAr': instance.courtNameAr,
      'judgeName': instance.judgeName,
      'judgeNameAr': instance.judgeNameAr,
      'courtHearingDate': instance.courtHearingDate?.toIso8601String(),
      'courtHearingTime': instance.courtHearingTime,
      'visitPurpose': instance.visitPurpose,
      'visitPurposeAr': instance.visitPurposeAr,
      'siteInspectionType':
          _$SiteInspectionTypeEnumMap[instance.siteInspectionType],
      'boundaryVerificationStatus': instance.boundaryVerificationStatus,
      'encroachmentDetails': instance.encroachmentDetails,
      'encroachmentDetailsAr': instance.encroachmentDetailsAr,
      'preservationStatus': instance.preservationStatus,
      'durationMinutes': instance.durationMinutes,
      'requiresApproval': instance.requiresApproval,
      'progressPercentage': instance.progressPercentage,
      'assignedTo': instance.assignedTo,
      'estimatedHours': instance.estimatedHours,
      'actualHours': instance.actualHours,
      'followupRequired': instance.followupRequired,
      'followupDeadline': instance.followupDeadline?.toIso8601String(),
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$TaskTypeEnumMap = {
  TaskType.courtVisit: 'court_visit',
  TaskType.siteInspection: 'site_inspection',
  TaskType.documentFollowup: 'document_followup',
  TaskType.meeting: 'meeting',
  TaskType.administrative: 'administrative',
  TaskType.other: 'other',
};

const _$TaskStatusEnumMap = {
  TaskStatus.newTask: 'new',
  TaskStatus.inProgress: 'in_progress',
  TaskStatus.underAction: 'under_action',
  TaskStatus.completed: 'completed',
  TaskStatus.cancelled: 'cancelled',
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
  TaskPriority.urgent: 'urgent',
};

const _$RelatedEntityTypeEnumMap = {
  RelatedEntityType.caseEntity: 'case',
  RelatedEntityType.waqfLand: 'waqf_land',
  RelatedEntityType.both: 'both',
  RelatedEntityType.none: 'none',
};

const _$SiteInspectionTypeEnumMap = {
  SiteInspectionType.initial: 'initial',
  SiteInspectionType.followup: 'followup',
  SiteInspectionType.routine: 'routine',
  SiteInspectionType.emergency: 'emergency',
};
