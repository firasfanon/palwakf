// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Case _$CaseFromJson(Map<String, dynamic> json) => Case(
      id: (json['id'] as num).toInt(),
      caseNumber: json['caseNumber'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$CaseTypeEnumMap, json['type']),
      status: $enumDecode(_$CaseStatusEnumMap, json['status']),
      priority: $enumDecode(_$CasePriorityEnumMap, json['priority']),
      governorate: json['governorate'] as String,
      plaintiff: CaseParty.fromJson(json['plaintiff'] as Map<String, dynamic>),
      defendant: json['defendant'] == null
          ? null
          : CaseParty.fromJson(json['defendant'] as Map<String, dynamic>),
      relatedWaqfLandId: json['relatedWaqfLandId'] as String?,
      attachedDocuments: (json['attachedDocuments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => CaseNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => CaseActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      filingDate: DateTime.parse(json['filingDate'] as String),
      resolutionDate: json['resolutionDate'] == null
          ? null
          : DateTime.parse(json['resolutionDate'] as String),
      courtName: json['courtName'] as String?,
      judgmentNumber: json['judgmentNumber'] as String?,
      outcome: json['outcome'] as String?,
      assignedTo: json['assignedTo'] as String,
      createdBy: (json['createdBy'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CaseToJson(Case instance) => <String, dynamic>{
      'id': instance.id,
      'caseNumber': instance.caseNumber,
      'title': instance.title,
      'description': instance.description,
      'type': _$CaseTypeEnumMap[instance.type]!,
      'status': _$CaseStatusEnumMap[instance.status]!,
      'priority': _$CasePriorityEnumMap[instance.priority]!,
      'governorate': instance.governorate,
      'plaintiff': instance.plaintiff,
      'defendant': instance.defendant,
      'relatedWaqfLandId': instance.relatedWaqfLandId,
      'attachedDocuments': instance.attachedDocuments,
      'notes': instance.notes,
      'activities': instance.activities,
      'filingDate': instance.filingDate.toIso8601String(),
      'resolutionDate': instance.resolutionDate?.toIso8601String(),
      'courtName': instance.courtName,
      'judgmentNumber': instance.judgmentNumber,
      'outcome': instance.outcome,
      'assignedTo': instance.assignedTo,
      'createdBy': instance.createdBy,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CaseTypeEnumMap = {
  CaseType.propertyDispute: 'property_dispute',
  CaseType.inheritance: 'inheritance',
  CaseType.leaseDispute: 'lease_dispute',
  CaseType.boundaryDispute: 'boundary_dispute',
  CaseType.waqfViolation: 'waqf_violation',
  CaseType.administrative: 'administrative',
  CaseType.other: 'other',
};

const _$CaseStatusEnumMap = {
  CaseStatus.newCase: 'new',
  CaseStatus.underReview: 'under_review',
  CaseStatus.investigation: 'investigation',
  CaseStatus.pendingDocuments: 'pending_documents',
  CaseStatus.inCourt: 'in_court',
  CaseStatus.resolved: 'resolved',
  CaseStatus.closed: 'closed',
  CaseStatus.appealed: 'appealed',
};

const _$CasePriorityEnumMap = {
  CasePriority.low: 'low',
  CasePriority.medium: 'medium',
  CasePriority.high: 'high',
  CasePriority.urgent: 'urgent',
  CasePriority.critical: 'critical',
};

CaseParty _$CasePartyFromJson(Map<String, dynamic> json) => CaseParty(
      name: json['name'] as String,
      idNumber: json['idNumber'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      address: json['address'] as String,
      legalRepresentative: json['legalRepresentative'] as String?,
    );

Map<String, dynamic> _$CasePartyToJson(CaseParty instance) => <String, dynamic>{
      'name': instance.name,
      'idNumber': instance.idNumber,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'address': instance.address,
      'legalRepresentative': instance.legalRepresentative,
    };

CaseNote _$CaseNoteFromJson(Map<String, dynamic> json) => CaseNote(
      id: (json['id'] as num).toInt(),
      content: json['content'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isInternal: json['isInternal'] as bool? ?? false,
    );

Map<String, dynamic> _$CaseNoteToJson(CaseNote instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'isInternal': instance.isInternal,
    };

CaseActivity _$CaseActivityFromJson(Map<String, dynamic> json) => CaseActivity(
      id: (json['id'] as num).toInt(),
      action: json['action'] as String,
      description: json['description'] as String,
      performedBy: json['performedBy'] as String,
      performedAt: DateTime.parse(json['performedAt'] as String),
      changes: json['changes'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CaseActivityToJson(CaseActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'description': instance.description,
      'performedBy': instance.performedBy,
      'performedAt': instance.performedAt.toIso8601String(),
      'changes': instance.changes,
    };
