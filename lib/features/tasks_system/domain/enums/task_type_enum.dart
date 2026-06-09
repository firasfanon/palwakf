enum TasksTaskType {
  encroachmentFollowup,
  fieldInspection,
  leaseFollowup,
  tenantFollowup,
  collectionFollowup,
  documentReview,
  gisCoordinatesUpload,
  gisAudit,
  officialCorrespondence,
  administrativeDecision,
  recommendationExecution,
  maintenanceOccupancy,
  committeeVisit,
  legalNotice,
  caseProcedureFollowup,
  approvalReferral,
  other,
}

extension TasksTaskTypeX on TasksTaskType {
  String get dbValue => switch (this) {
    TasksTaskType.encroachmentFollowup => 'encroachment_followup',
    TasksTaskType.fieldInspection => 'field_inspection',
    TasksTaskType.leaseFollowup => 'lease_followup',
    TasksTaskType.tenantFollowup => 'tenant_followup',
    TasksTaskType.collectionFollowup => 'collection_followup',
    TasksTaskType.documentReview => 'document_review',
    TasksTaskType.gisCoordinatesUpload => 'gis_coordinates_upload',
    TasksTaskType.gisAudit => 'gis_audit',
    TasksTaskType.officialCorrespondence => 'official_correspondence',
    TasksTaskType.administrativeDecision => 'administrative_decision',
    TasksTaskType.recommendationExecution => 'recommendation_execution',
    TasksTaskType.maintenanceOccupancy => 'maintenance_occupancy',
    TasksTaskType.committeeVisit => 'committee_visit',
    TasksTaskType.legalNotice => 'legal_notice',
    TasksTaskType.caseProcedureFollowup => 'case_procedure_followup',
    TasksTaskType.approvalReferral => 'approval_referral',
    TasksTaskType.other => 'other',
  };

  String get labelAr => switch (this) {
    TasksTaskType.encroachmentFollowup => 'متابعة تعدي',
    TasksTaskType.fieldInspection => 'كشف ميداني',
    TasksTaskType.leaseFollowup => 'متابعة عقد',
    TasksTaskType.tenantFollowup => 'متابعة مستأجر',
    TasksTaskType.collectionFollowup => 'متابعة تحصيل',
    TasksTaskType.documentReview => 'مراجعة وثائق',
    TasksTaskType.gisCoordinatesUpload => 'رفع إحداثيات',
    TasksTaskType.gisAudit => 'تدقيق GIS',
    TasksTaskType.officialCorrespondence => 'متابعة مخاطبة',
    TasksTaskType.administrativeDecision => 'متابعة قرار إداري',
    TasksTaskType.recommendationExecution => 'تنفيذ توصية',
    TasksTaskType.maintenanceOccupancy => 'صيانة/إشغال',
    TasksTaskType.committeeVisit => 'زيارة لجنة',
    TasksTaskType.legalNotice => 'إشعار قانوني',
    TasksTaskType.caseProcedureFollowup => 'إجراء مرتبط بقضية',
    TasksTaskType.approvalReferral => 'اعتماد أو إحالة',
    TasksTaskType.other => 'أخرى',
  };

  static TasksTaskType fromDb(dynamic value) {
    switch ('$value') {
      case 'encroachment_followup':
        return TasksTaskType.encroachmentFollowup;
      case 'field_inspection':
        return TasksTaskType.fieldInspection;
      case 'lease_followup':
        return TasksTaskType.leaseFollowup;
      case 'tenant_followup':
        return TasksTaskType.tenantFollowup;
      case 'collection_followup':
        return TasksTaskType.collectionFollowup;
      case 'document_review':
        return TasksTaskType.documentReview;
      case 'gis_coordinates_upload':
        return TasksTaskType.gisCoordinatesUpload;
      case 'gis_audit':
        return TasksTaskType.gisAudit;
      case 'official_correspondence':
        return TasksTaskType.officialCorrespondence;
      case 'administrative_decision':
        return TasksTaskType.administrativeDecision;
      case 'recommendation_execution':
        return TasksTaskType.recommendationExecution;
      case 'maintenance_occupancy':
        return TasksTaskType.maintenanceOccupancy;
      case 'committee_visit':
        return TasksTaskType.committeeVisit;
      case 'legal_notice':
        return TasksTaskType.legalNotice;
      case 'case_procedure_followup':
        return TasksTaskType.caseProcedureFollowup;
      case 'approval_referral':
        return TasksTaskType.approvalReferral;
      default:
        return TasksTaskType.other;
    }
  }
}
