class PwfTechnicalEvidence {
  const PwfTechnicalEvidence({
    required this.id,
    required this.evidenceType,
    required this.title,
    this.requestId,
    this.description,
    this.url,
    this.createdAt,
  });

  final String id;
  final String evidenceType;
  final String title;
  final String? requestId;
  final String? description;
  final String? url;
  final DateTime? createdAt;

  factory PwfTechnicalEvidence.fromJson(dynamic raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    return PwfTechnicalEvidence(
      id: _stringValue(map['id']),
      requestId: _nullableStringValue(map['request_id']),
      evidenceType: _stringValue(map['evidence_type']),
      title: _stringValue(map['title']),
      description: _nullableStringValue(map['description']),
      url: _nullableStringValue(map['url']),
      createdAt: _dateValue(map['created_at']),
    );
  }
}

class PwfTechnicalNotification {
  const PwfTechnicalNotification({
    required this.id,
    required this.notificationType,
    required this.severity,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final String notificationType;
  final String severity;
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  factory PwfTechnicalNotification.fromJson(dynamic raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    return PwfTechnicalNotification(
      id: _stringValue(map['id']),
      notificationType: _stringValue(map['notification_type']),
      severity: _stringValue(map['severity'], fallback: 'info'),
      title: _stringValue(map['title']),
      message: _stringValue(map['message']),
      isRead: map['is_read'] == true,
      createdAt: _dateValue(map['created_at']),
    );
  }
}

class PwfTechnicalOperationDecision {
  const PwfTechnicalOperationDecision({
    required this.id,
    required this.decisionType,
    required this.decisionLabel,
    this.requestId,
    this.decisionReason,
    this.decidedAt,
  });

  final String id;
  final String decisionType;
  final String decisionLabel;
  final String? requestId;
  final String? decisionReason;
  final DateTime? decidedAt;

  factory PwfTechnicalOperationDecision.fromJson(dynamic raw) {
    final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

    return PwfTechnicalOperationDecision(
      id: _stringValue(map['id']),
      requestId: _nullableStringValue(map['request_id']),
      decisionType: _stringValue(map['decision_type']),
      decisionLabel: _stringValue(map['decision_label']),
      decisionReason: _nullableStringValue(map['decision_reason']),
      decidedAt: _dateValue(map['decided_at']),
    );
  }
}

String _stringValue(dynamic value, {String fallback = ''}) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return fallback;
  return raw;
}

String? _nullableStringValue(dynamic value) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return null;
  return raw;
}

DateTime? _dateValue(dynamic value) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
