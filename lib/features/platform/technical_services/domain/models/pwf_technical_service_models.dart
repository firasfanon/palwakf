import 'pwf_technical_service_operations_models.dart';

class PwfTechnicalServicesDashboard {
  const PwfTechnicalServicesDashboard({
    required this.backendApplied,
    required this.backendStatus,
    required this.metrics,
    required this.requests,
    required this.maintenanceWindows,
    required this.backups,
    required this.healthChecks,
    required this.releases,
    required this.auditEvents,
    this.evidence = const [],
    this.notifications = const [],
    this.operationDecisions = const [],
    this.errorMessage,
  });

  final bool backendApplied;
  final String backendStatus;
  final List<PwfTechnicalMetric> metrics;
  final List<PwfTechnicalRequest> requests;
  final List<PwfMaintenanceWindow> maintenanceWindows;
  final List<PwfBackupRegistryEntry> backups;
  final List<PwfHealthCheck> healthChecks;
  final List<PwfReleaseRecord> releases;
  final List<PwfAuditEvent> auditEvents;
  final List<PwfTechnicalEvidence> evidence;
  final List<PwfTechnicalNotification> notifications;
  final List<PwfTechnicalOperationDecision> operationDecisions;
  final String? errorMessage;

  factory PwfTechnicalServicesDashboard.fromJson(dynamic raw) {
    final map = _asMap(raw);
    return PwfTechnicalServicesDashboard(
      backendApplied: map['backend_applied'] == true,
      backendStatus: _string(map['backend_status'], fallback: 'backend-applied'),
      metrics: _list(map['metrics']).map(PwfTechnicalMetric.fromJson).toList(),
      requests: _list(map['requests']).map(PwfTechnicalRequest.fromJson).toList(),
      maintenanceWindows:
          _list(map['maintenance_windows']).map(PwfMaintenanceWindow.fromJson).toList(),
      backups: _list(map['backups']).map(PwfBackupRegistryEntry.fromJson).toList(),
      healthChecks: _list(map['health_checks']).map(PwfHealthCheck.fromJson).toList(),
      releases: _list(map['releases']).map(PwfReleaseRecord.fromJson).toList(),
      auditEvents: _list(map['audit_events']).map(PwfAuditEvent.fromJson).toList(),
      evidence: _list(map['evidence']).map(PwfTechnicalEvidence.fromJson).toList(),
      notifications:
          _list(map['notifications']).map(PwfTechnicalNotification.fromJson).toList(),
      operationDecisions: _list(map['operation_decisions'])
          .map(PwfTechnicalOperationDecision.fromJson)
          .toList(),
    );
  }

  factory PwfTechnicalServicesDashboard.fallback({String? reason}) {
    return PwfTechnicalServicesDashboard(
      backendApplied: false,
      backendStatus: 'backend-contract-not-applied-or-unreachable',
      errorMessage: reason,
      metrics: const [
        PwfTechnicalMetric(
          keyName: 'backend_contract',
          label: 'Backend Contract',
          value: 'غير متصل',
          status: 'blocked',
        ),
        PwfTechnicalMetric(
          keyName: 'execution_mode',
          label: 'Execution Mode',
          value: 'Guarded UI',
          status: 'ready',
        ),
      ],
      requests: const [],
      maintenanceWindows: const [],
      backups: const [],
      healthChecks: const [],
      releases: const [],
      auditEvents: const [],
      evidence: const [],
      notifications: const [],
      operationDecisions: const [],
    );
  }
}

class PwfTechnicalMetric {
  const PwfTechnicalMetric({
    required this.keyName,
    required this.label,
    required this.value,
    required this.status,
  });

  final String keyName;
  final String label;
  final String value;
  final String status;

  factory PwfTechnicalMetric.fromJson(dynamic raw) {
    final map = _asMap(raw);
    return PwfTechnicalMetric(
      keyName: _string(map['key'] ?? map['key_name']),
      label: _string(map['label']),
      value: _string(map['value']),
      status: _string(map['status'], fallback: 'unknown'),
    );
  }
}

class PwfTechnicalRequest {
  const PwfTechnicalRequest({
    required this.id,
    required this.serviceType,
    required this.actionType,
    required this.title,
    required this.status,
    required this.approvalStatus,
    required this.riskLevel,
    this.description,
    this.createdAt,
    this.scheduledFor,
  });

  final String id;
  final String serviceType;
  final String actionType;
  final String title;
  final String status;
  final String approvalStatus;
  final String riskLevel;
  final String? description;
  final DateTime? createdAt;
  final DateTime? scheduledFor;

  factory PwfTechnicalRequest.fromJson(dynamic raw) {
    final map = _asMap(raw);
    return PwfTechnicalRequest(
      id: _string(map['id']),
      serviceType: _string(map['service_type']),
      actionType: _string(map['action_type']),
      title: _string(map['title']),
      status: _string(map['status'], fallback: 'requested'),
      approvalStatus: _string(map['approval_status'], fallback: 'pending'),
      riskLevel: _string(map['risk_level'], fallback: 'medium'),
      description: _nullableString(map['description']),
      createdAt: _date(map['created_at']),
      scheduledFor: _date(map['scheduled_for']),
    );
  }
}

class PwfMaintenanceWindow {
  const PwfMaintenanceWindow({
    required this.id,
    required this.title,
    required this.status,
    this.messageAr,
    this.startsAt,
    this.endsAt,
    this.affectedSurfaces = const [],
  });

  final String id;
  final String title;
  final String status;
  final String? messageAr;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final List<String> affectedSurfaces;

  factory PwfMaintenanceWindow.fromJson(dynamic raw) {
    final map = _asMap(raw);
    return PwfMaintenanceWindow(
      id: _string(map['id']),
      title: _string(map['title']),
      status: _string(map['status'], fallback: 'planned'),
      messageAr: _nullableString(map['message_ar']),
      startsAt: _date(map['starts_at']),
      endsAt: _date(map['ends_at']),
      affectedSurfaces: _stringList(map['affected_surfaces']),
    );
  }
}

class PwfBackupRegistryEntry {
  const PwfBackupRegistryEntry({
    required this.id,
    required this.backupKind,
    required this.backupLabel,
    required this.status,
    this.provider,
    this.completedAt,
    this.checksum,
  });

  final String id;
  final String backupKind;
  final String backupLabel;
  final String status;
  final String? provider;
  final DateTime? completedAt;
  final String? checksum;

  factory PwfBackupRegistryEntry.fromJson(dynamic raw) {
    final map = _asMap(raw);
    return PwfBackupRegistryEntry(
      id: _string(map['id']),
      backupKind: _string(map['backup_kind']),
      backupLabel: _string(map['backup_label']),
      status: _string(map['status'], fallback: 'recorded'),
      provider: _nullableString(map['provider']),
      completedAt: _date(map['completed_at']),
      checksum: _nullableString(map['checksum']),
    );
  }
}

class PwfHealthCheck {
  const PwfHealthCheck({
    required this.checkKey,
    required this.checkGroup,
    required this.label,
    required this.status,
    this.lastCheckedAt,
    this.details,
  });

  final String checkKey;
  final String checkGroup;
  final String label;
  final String status;
  final DateTime? lastCheckedAt;
  final Map<String, dynamic>? details;

  factory PwfHealthCheck.fromJson(dynamic raw) {
    final map = _asMap(raw);
    return PwfHealthCheck(
      checkKey: _string(map['check_key']),
      checkGroup: _string(map['check_group']),
      label: _string(map['label']),
      status: _string(map['status'], fallback: 'unknown'),
      lastCheckedAt: _date(map['last_checked_at']),
      details: map['details'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['details'] as Map)
          : null,
    );
  }
}

class PwfReleaseRecord {
  const PwfReleaseRecord({
    required this.id,
    required this.releaseTag,
    required this.status,
    this.gitCommitHash,
    this.deployUrl,
    this.createdAt,
  });

  final String id;
  final String releaseTag;
  final String status;
  final String? gitCommitHash;
  final String? deployUrl;
  final DateTime? createdAt;

  factory PwfReleaseRecord.fromJson(dynamic raw) {
    final map = _asMap(raw);
    return PwfReleaseRecord(
      id: _string(map['id']),
      releaseTag: _string(map['release_tag']),
      status: _string(map['status'], fallback: 'recorded'),
      gitCommitHash: _nullableString(map['git_commit_hash']),
      deployUrl: _nullableString(map['deploy_url']),
      createdAt: _date(map['created_at']),
    );
  }
}

class PwfAuditEvent {
  const PwfAuditEvent({
    required this.id,
    required this.eventType,
    required this.message,
    required this.severity,
    this.createdAt,
  });

  final String id;
  final String eventType;
  final String message;
  final String severity;
  final DateTime? createdAt;

  factory PwfAuditEvent.fromJson(dynamic raw) {
    final map = _asMap(raw);
    return PwfAuditEvent(
      id: _string(map['id']),
      eventType: _string(map['event_type']),
      message: _string(map['message']),
      severity: _string(map['severity'], fallback: 'info'),
      createdAt: _date(map['created_at']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const {};
}

List<dynamic> _list(dynamic raw) {
  if (raw is List) return raw;
  return const [];
}

String _string(dynamic value, {String fallback = ''}) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return fallback;
  return raw;
}

String? _nullableString(dynamic value) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return null;
  return raw;
}

DateTime? _date(dynamic value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

List<String> _stringList(dynamic raw) {
  if (raw is List) {
    return raw.map((item) => item.toString()).toList(growable: false);
  }
  return const [];
}