class MediaCenterReadinessStage {
  const MediaCenterReadinessStage({
    required this.stageKey,
    required this.stageTitleAr,
    required this.statusKey,
    required this.statusLabelAr,
    required this.evidenceAr,
    required this.requiredNextActionAr,
    required this.isClosed,
  });

  final String stageKey;
  final String stageTitleAr;
  final String statusKey;
  final String statusLabelAr;
  final String evidenceAr;
  final String requiredNextActionAr;
  final bool isClosed;

  factory MediaCenterReadinessStage.fromJson(Map<String, dynamic> json) {
    return MediaCenterReadinessStage(
      stageKey: (json['stage_key'] ?? '').toString(),
      stageTitleAr: (json['stage_title_ar'] ?? '').toString(),
      statusKey: (json['status_key'] ?? '').toString(),
      statusLabelAr: (json['status_label_ar'] ?? '').toString(),
      evidenceAr: (json['evidence_ar'] ?? '').toString(),
      requiredNextActionAr: (json['required_next_action_ar'] ?? '').toString(),
      isClosed: json['is_closed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stage_key': stageKey,
      'stage_title_ar': stageTitleAr,
      'status_key': statusKey,
      'status_label_ar': statusLabelAr,
      'evidence_ar': evidenceAr,
      'required_next_action_ar': requiredNextActionAr,
      'is_closed': isClosed,
    };
  }
}

class MediaCenterFamilySummary {
  const MediaCenterFamilySummary({
    required this.familyKey,
    required this.labelAr,
    required this.adminRoute,
    required this.publicRoute,
    required this.storageOrTableAr,
    required this.statusAr,
    this.editorialOwnerAr = 'الإعلام المركزي/الوحدة المختصة',
    this.defaultWorkflowAr = 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة',
    this.runtimeNoteAr = 'اختبار دوري بعد كل تعديل محتوى أو مسار.',
  });

  final String familyKey;
  final String labelAr;
  final String adminRoute;
  final String publicRoute;
  final String storageOrTableAr;
  final String statusAr;
  final String editorialOwnerAr;
  final String defaultWorkflowAr;
  final String runtimeNoteAr;

  factory MediaCenterFamilySummary.fromJson(Map<String, dynamic> json) {
    return MediaCenterFamilySummary(
      familyKey: (json['family_key'] ?? '').toString(),
      labelAr: (json['label_ar'] ?? '').toString(),
      adminRoute: (json['admin_route'] ?? '').toString(),
      publicRoute: (json['public_route'] ?? '').toString(),
      storageOrTableAr: (json['storage_or_table_ar'] ?? '').toString(),
      statusAr: (json['status_ar'] ?? '').toString(),
      editorialOwnerAr:
          (json['editorial_owner_ar'] ?? 'الإعلام المركزي/الوحدة المختصة')
              .toString(),
      defaultWorkflowAr:
          (json['default_workflow_ar'] ??
                  'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة')
              .toString(),
      runtimeNoteAr:
          (json['runtime_note_ar'] ?? 'اختبار دوري بعد كل تعديل محتوى أو مسار.')
              .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'family_key': familyKey,
      'label_ar': labelAr,
      'admin_route': adminRoute,
      'public_route': publicRoute,
      'storage_or_table_ar': storageOrTableAr,
      'status_ar': statusAr,
      'editorial_owner_ar': editorialOwnerAr,
      'default_workflow_ar': defaultWorkflowAr,
      'runtime_note_ar': runtimeNoteAr,
    };
  }
}

class MediaCenterEditorialWorkflowStep {
  const MediaCenterEditorialWorkflowStep({
    required this.stepKey,
    required this.titleAr,
    required this.statusKey,
    required this.descriptionAr,
    required this.allowedActionsAr,
    required this.requiredEvidenceAr,
    required this.isRequired,
  });

  final String stepKey;
  final String titleAr;
  final String statusKey;
  final String descriptionAr;
  final String allowedActionsAr;
  final String requiredEvidenceAr;
  final bool isRequired;

  factory MediaCenterEditorialWorkflowStep.fromJson(Map<String, dynamic> json) {
    return MediaCenterEditorialWorkflowStep(
      stepKey: (json['step_key'] ?? '').toString(),
      titleAr: (json['title_ar'] ?? '').toString(),
      statusKey: (json['status_key'] ?? '').toString(),
      descriptionAr: (json['description_ar'] ?? '').toString(),
      allowedActionsAr: (json['allowed_actions_ar'] ?? '').toString(),
      requiredEvidenceAr: (json['required_evidence_ar'] ?? '').toString(),
      isRequired: json['is_required'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'step_key': stepKey,
      'title_ar': titleAr,
      'status_key': statusKey,
      'description_ar': descriptionAr,
      'allowed_actions_ar': allowedActionsAr,
      'required_evidence_ar': requiredEvidenceAr,
      'is_required': isRequired,
    };
  }
}

class MediaCenterRuntimeUxCheck {
  const MediaCenterRuntimeUxCheck({
    required this.checkKey,
    required this.titleAr,
    required this.statusKey,
    required this.statusLabelAr,
    required this.evidenceAr,
    required this.requiredNextActionAr,
    required this.isClosed,
  });

  final String checkKey;
  final String titleAr;
  final String statusKey;
  final String statusLabelAr;
  final String evidenceAr;
  final String requiredNextActionAr;
  final bool isClosed;

  factory MediaCenterRuntimeUxCheck.fromJson(Map<String, dynamic> json) {
    return MediaCenterRuntimeUxCheck(
      checkKey: (json['check_key'] ?? '').toString(),
      titleAr: (json['title_ar'] ?? '').toString(),
      statusKey: (json['status_key'] ?? '').toString(),
      statusLabelAr: (json['status_label_ar'] ?? '').toString(),
      evidenceAr: (json['evidence_ar'] ?? '').toString(),
      requiredNextActionAr: (json['required_next_action_ar'] ?? '').toString(),
      isClosed: json['is_closed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'check_key': checkKey,
      'title_ar': titleAr,
      'status_key': statusKey,
      'status_label_ar': statusLabelAr,
      'evidence_ar': evidenceAr,
      'required_next_action_ar': requiredNextActionAr,
      'is_closed': isClosed,
    };
  }
}

class MediaCenterEditorialRoleCapability {
  const MediaCenterEditorialRoleCapability({
    required this.roleKey,
    required this.labelAr,
    required this.descriptionAr,
    required this.scopeKey,
    required this.scopeLabelAr,
    required this.requiredSystemKey,
    required this.requiredPermissionKey,
    required this.canCreateDraft,
    required this.canSubmitReview,
    required this.canReview,
    required this.canApprove,
    required this.canPublish,
    required this.canSchedule,
    required this.canArchive,
    required this.canCrossPublish,
    required this.sovereigntyNoteAr,
    required this.isActive,
    required this.sortOrder,
  });

  final String roleKey;
  final String labelAr;
  final String descriptionAr;
  final String scopeKey;
  final String scopeLabelAr;
  final String requiredSystemKey;
  final String requiredPermissionKey;
  final bool canCreateDraft;
  final bool canSubmitReview;
  final bool canReview;
  final bool canApprove;
  final bool canPublish;
  final bool canSchedule;
  final bool canArchive;
  final bool canCrossPublish;
  final String sovereigntyNoteAr;
  final bool isActive;
  final int sortOrder;

  factory MediaCenterEditorialRoleCapability.fromJson(
    Map<String, dynamic> json,
  ) {
    return MediaCenterEditorialRoleCapability(
      roleKey: (json['role_key'] ?? '').toString(),
      labelAr: (json['label_ar'] ?? '').toString(),
      descriptionAr: (json['description_ar'] ?? '').toString(),
      scopeKey: (json['scope_key'] ?? '').toString(),
      scopeLabelAr: (json['scope_label_ar'] ?? '').toString(),
      requiredSystemKey: (json['required_system_key'] ?? 'site').toString(),
      requiredPermissionKey: (json['required_permission_key'] ?? 'view')
          .toString(),
      canCreateDraft: json['can_create_draft'] == true,
      canSubmitReview: json['can_submit_review'] == true,
      canReview: json['can_review'] == true,
      canApprove: json['can_approve'] == true,
      canPublish: json['can_publish'] == true,
      canSchedule: json['can_schedule'] == true,
      canArchive: json['can_archive'] == true,
      canCrossPublish: json['can_cross_publish'] == true,
      sovereigntyNoteAr: (json['sovereignty_note_ar'] ?? '').toString(),
      isActive: json['is_active'] != false,
      sortOrder: int.tryParse((json['sort_order'] ?? '0').toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'role_key': roleKey,
      'label_ar': labelAr,
      'description_ar': descriptionAr,
      'scope_key': scopeKey,
      'scope_label_ar': scopeLabelAr,
      'required_system_key': requiredSystemKey,
      'required_permission_key': requiredPermissionKey,
      'can_create_draft': canCreateDraft,
      'can_submit_review': canSubmitReview,
      'can_review': canReview,
      'can_approve': canApprove,
      'can_publish': canPublish,
      'can_schedule': canSchedule,
      'can_archive': canArchive,
      'can_cross_publish': canCrossPublish,
      'sovereignty_note_ar': sovereigntyNoteAr,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}

class MediaCenterPublishingGovernanceRule {
  const MediaCenterPublishingGovernanceRule({
    required this.ruleKey,
    required this.familyKey,
    required this.sourceScopeKey,
    required this.targetScopeKey,
    required this.requiredRoleKey,
    required this.requiredActionKey,
    required this.ruleTitleAr,
    required this.ruleDescriptionAr,
    required this.requiresApproval,
    required this.requiresAudit,
    required this.conflictPolicyAr,
    required this.isActive,
    required this.sortOrder,
  });

  final String ruleKey;
  final String familyKey;
  final String sourceScopeKey;
  final String targetScopeKey;
  final String requiredRoleKey;
  final String requiredActionKey;
  final String ruleTitleAr;
  final String ruleDescriptionAr;
  final bool requiresApproval;
  final bool requiresAudit;
  final String conflictPolicyAr;
  final bool isActive;
  final int sortOrder;

  factory MediaCenterPublishingGovernanceRule.fromJson(
    Map<String, dynamic> json,
  ) {
    return MediaCenterPublishingGovernanceRule(
      ruleKey: (json['rule_key'] ?? '').toString(),
      familyKey: (json['family_key'] ?? '').toString(),
      sourceScopeKey: (json['source_scope_key'] ?? '').toString(),
      targetScopeKey: (json['target_scope_key'] ?? '').toString(),
      requiredRoleKey: (json['required_role_key'] ?? '').toString(),
      requiredActionKey: (json['required_action_key'] ?? '').toString(),
      ruleTitleAr: (json['rule_title_ar'] ?? '').toString(),
      ruleDescriptionAr: (json['rule_description_ar'] ?? '').toString(),
      requiresApproval: json['requires_approval'] != false,
      requiresAudit: json['requires_audit'] != false,
      conflictPolicyAr: (json['conflict_policy_ar'] ?? '').toString(),
      isActive: json['is_active'] != false,
      sortOrder: int.tryParse((json['sort_order'] ?? '0').toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rule_key': ruleKey,
      'family_key': familyKey,
      'source_scope_key': sourceScopeKey,
      'target_scope_key': targetScopeKey,
      'required_role_key': requiredRoleKey,
      'required_action_key': requiredActionKey,
      'rule_title_ar': ruleTitleAr,
      'rule_description_ar': ruleDescriptionAr,
      'requires_approval': requiresApproval,
      'requires_audit': requiresAudit,
      'conflict_policy_ar': conflictPolicyAr,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}

class MediaCenterGovernanceReadinessStage {
  const MediaCenterGovernanceReadinessStage({
    required this.stageKey,
    required this.stageTitleAr,
    required this.statusKey,
    required this.statusLabelAr,
    required this.evidenceAr,
    required this.requiredNextActionAr,
    required this.isClosed,
  });

  final String stageKey;
  final String stageTitleAr;
  final String statusKey;
  final String statusLabelAr;
  final String evidenceAr;
  final String requiredNextActionAr;
  final bool isClosed;

  factory MediaCenterGovernanceReadinessStage.fromJson(
    Map<String, dynamic> json,
  ) {
    return MediaCenterGovernanceReadinessStage(
      stageKey: (json['stage_key'] ?? '').toString(),
      stageTitleAr: (json['stage_title_ar'] ?? '').toString(),
      statusKey: (json['status_key'] ?? '').toString(),
      statusLabelAr: (json['status_label_ar'] ?? '').toString(),
      evidenceAr: (json['evidence_ar'] ?? '').toString(),
      requiredNextActionAr: (json['required_next_action_ar'] ?? '').toString(),
      isClosed: json['is_closed'] == true,
    );
  }
}

class MediaCenterPermissionUatScenario {
  const MediaCenterPermissionUatScenario({
    required this.scenarioKey,
    required this.titleAr,
    required this.roleKey,
    required this.actionKey,
    required this.unitSlug,
    required this.expectedAllowed,
    required this.actualAllowed,
    required this.statusKey,
    required this.statusLabelAr,
    required this.evidenceAr,
    required this.requiredNextActionAr,
    required this.isClosed,
  });

  final String scenarioKey;
  final String titleAr;
  final String roleKey;
  final String actionKey;
  final String? unitSlug;
  final bool expectedAllowed;
  final bool? actualAllowed;
  final String statusKey;
  final String statusLabelAr;
  final String evidenceAr;
  final String requiredNextActionAr;
  final bool isClosed;

  factory MediaCenterPermissionUatScenario.fromJson(Map<String, dynamic> json) {
    final actual = json['actual_allowed'];
    return MediaCenterPermissionUatScenario(
      scenarioKey: (json['scenario_key'] ?? '').toString(),
      titleAr: (json['title_ar'] ?? '').toString(),
      roleKey: (json['role_key'] ?? '').toString(),
      actionKey: (json['action_key'] ?? '').toString(),
      unitSlug: json['unit_slug']?.toString(),
      expectedAllowed: json['expected_allowed'] == true,
      actualAllowed: actual == null ? null : actual == true,
      statusKey: (json['status_key'] ?? '').toString(),
      statusLabelAr: (json['status_label_ar'] ?? '').toString(),
      evidenceAr: (json['evidence_ar'] ?? '').toString(),
      requiredNextActionAr: (json['required_next_action_ar'] ?? '').toString(),
      isClosed: json['is_closed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'scenario_key': scenarioKey,
      'title_ar': titleAr,
      'role_key': roleKey,
      'action_key': actionKey,
      'unit_slug': unitSlug,
      'expected_allowed': expectedAllowed,
      'actual_allowed': actualAllowed,
      'status_key': statusKey,
      'status_label_ar': statusLabelAr,
      'evidence_ar': evidenceAr,
      'required_next_action_ar': requiredNextActionAr,
      'is_closed': isClosed,
    };
  }
}

class MediaCenterEditorialDecisionEventSummary {
  const MediaCenterEditorialDecisionEventSummary({
    required this.id,
    required this.contentFamily,
    required this.actionKey,
    required this.fromStatus,
    required this.toStatus,
    required this.decisionLabelAr,
    required this.unitSlug,
    required this.sourceRoute,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String contentFamily;
  final String actionKey;
  final String? fromStatus;
  final String toStatus;
  final String decisionLabelAr;
  final String? unitSlug;
  final String sourceRoute;
  final String notes;
  final DateTime? createdAt;

  factory MediaCenterEditorialDecisionEventSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return MediaCenterEditorialDecisionEventSummary(
      id: (json['id'] ?? '').toString(),
      contentFamily: (json['content_family'] ?? '').toString(),
      actionKey: (json['action_key'] ?? '').toString(),
      fromStatus: json['from_status']?.toString(),
      toStatus: (json['to_status'] ?? '').toString(),
      decisionLabelAr: (json['decision_label_ar'] ?? '').toString(),
      unitSlug: json['unit_slug']?.toString(),
      sourceRoute: (json['source_route'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'content_family': contentFamily,
      'action_key': actionKey,
      'from_status': fromStatus,
      'to_status': toStatus,
      'decision_label_ar': decisionLabelAr,
      'unit_slug': unitSlug,
      'source_route': sourceRoute,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class MediaCenterDashboardState {
  const MediaCenterDashboardState({
    required this.readinessStages,
    required this.families,
    this.editorialWorkflow = const <MediaCenterEditorialWorkflowStep>[],
    this.runtimeUxChecks = const <MediaCenterRuntimeUxCheck>[],
    this.editorialRoles = const <MediaCenterEditorialRoleCapability>[],
    this.publishingRules = const <MediaCenterPublishingGovernanceRule>[],
    this.governanceReadiness = const <MediaCenterGovernanceReadinessStage>[],
    this.permissionUatScenarios = const <MediaCenterPermissionUatScenario>[],
    this.editorialDecisionEvents =
        const <MediaCenterEditorialDecisionEventSummary>[],
    this.remoteReadinessAvailable = true,
    this.remoteFamiliesAvailable = true,
    this.remoteWorkflowAvailable = true,
    this.remoteRuntimeChecksAvailable = true,
    this.remoteRolesAvailable = true,
    this.remotePublishingRulesAvailable = true,
    this.remoteGovernanceReadinessAvailable = true,
    this.remotePermissionUatAvailable = true,
    this.remoteEditorialEventsAvailable = true,
    this.noticeAr,
  });

  final List<MediaCenterReadinessStage> readinessStages;
  final List<MediaCenterFamilySummary> families;
  final List<MediaCenterEditorialWorkflowStep> editorialWorkflow;
  final List<MediaCenterRuntimeUxCheck> runtimeUxChecks;
  final List<MediaCenterEditorialRoleCapability> editorialRoles;
  final List<MediaCenterPublishingGovernanceRule> publishingRules;
  final List<MediaCenterGovernanceReadinessStage> governanceReadiness;
  final List<MediaCenterPermissionUatScenario> permissionUatScenarios;
  final List<MediaCenterEditorialDecisionEventSummary> editorialDecisionEvents;
  final bool remoteReadinessAvailable;
  final bool remoteFamiliesAvailable;
  final bool remoteWorkflowAvailable;
  final bool remoteRuntimeChecksAvailable;
  final bool remoteRolesAvailable;
  final bool remotePublishingRulesAvailable;
  final bool remoteGovernanceReadinessAvailable;
  final bool remotePermissionUatAvailable;
  final bool remoteEditorialEventsAvailable;
  final String? noticeAr;

  int get closedStages =>
      readinessStages.where((stage) => stage.isClosed).length;
  int get totalStages => readinessStages.length;
  bool get isReady => readinessStages.isNotEmpty && closedStages == totalStages;

  int get closedRuntimeChecks =>
      runtimeUxChecks.where((check) => check.isClosed).length;
  int get totalRuntimeChecks => runtimeUxChecks.length;
  bool get runtimeUxReady =>
      runtimeUxChecks.isNotEmpty && closedRuntimeChecks == totalRuntimeChecks;

  int get closedGovernanceStages =>
      governanceReadiness.where((stage) => stage.isClosed).length;
  int get totalGovernanceStages => governanceReadiness.length;
  bool get publishingGovernanceReady =>
      governanceReadiness.isNotEmpty &&
      closedGovernanceStages == totalGovernanceStages;

  int get closedPermissionUatScenarios =>
      permissionUatScenarios.where((scenario) => scenario.isClosed).length;
  int get totalPermissionUatScenarios => permissionUatScenarios.length;
  bool get permissionUatReady =>
      permissionUatScenarios.isNotEmpty &&
      closedPermissionUatScenarios == totalPermissionUatScenarios;
  bool get hasEditorialDecisionEvents => editorialDecisionEvents.isNotEmpty;
}
