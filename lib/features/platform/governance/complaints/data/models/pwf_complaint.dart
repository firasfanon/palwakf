import 'package:flutter/foundation.dart';

enum PwfComplaintType { complaint, suggestion, inquiry, praise, report }

enum PwfComplaintDepartment { mosques, education, waqf, hajj, fatwa, general }

enum PwfComplaintStatus { pending, processing, resolved, rejected }

extension PwfComplaintTypeDb on PwfComplaintType {
  String get dbValue => name;
  static PwfComplaintType? tryParse(String? v) {
    if (v == null) return null;
    for (final t in PwfComplaintType.values) {
      if (t.name == v) return t;
    }
    return null;
  }
}

extension PwfComplaintDepartmentDb on PwfComplaintDepartment {
  String get dbValue => name;
  static PwfComplaintDepartment? tryParse(String? v) {
    if (v == null) return null;
    for (final d in PwfComplaintDepartment.values) {
      if (d.name == v) return d;
    }
    return null;
  }
}

extension PwfComplaintStatusDb on PwfComplaintStatus {
  String get dbValue => name;
  static PwfComplaintStatus? tryParse(String? v) {
    if (v == null) return null;
    for (final s in PwfComplaintStatus.values) {
      if (s.name == v) return s;
    }
    return null;
  }
}

@immutable
class PwfComplaintUpdate {
  final PwfComplaintStatus status;
  final String messageKey; // i18n key
  final DateTime date;

  const PwfComplaintUpdate({
    required this.status,
    required this.messageKey,
    required this.date,
  });

  static PwfComplaintUpdate? tryFromMap(Map<String, dynamic> map) {
    final status = PwfComplaintStatusDb.tryParse(map['status']?.toString());
    final key = map['message_key']?.toString();
    final createdAt = map['created_at']?.toString();

    if (status == null || key == null || createdAt == null) return null;

    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return null;

    return PwfComplaintUpdate(status: status, messageKey: key, date: dt);
  }
}

@immutable
class PwfComplaint {
  /// Reference code (e.g., REF12345678)
  final String referenceCode;

  final PwfComplaintType type;
  final PwfComplaintDepartment department;
  final String subject;
  final String description;
  final String? name;
  final String email;
  final String? phone;
  final int attachmentsCount;
  final PwfComplaintStatus status;
  final DateTime createdAt;
  final List<PwfComplaintUpdate> updates;

  const PwfComplaint({
    required this.referenceCode,
    required this.type,
    required this.department,
    required this.subject,
    required this.description,
    required this.name,
    required this.email,
    required this.phone,
    required this.attachmentsCount,
    required this.status,
    required this.createdAt,
    required this.updates,
  });

  /// Parse result of RPC: { complaint: {...}, updates: [...], attachments: [...] }
  static PwfComplaint? tryFromTrackJson(Map<String, dynamic> json) {
    final complaint = json['complaint'];
    if (complaint is! Map) return null;

    final c = Map<String, dynamic>.from(complaint);

    final ref = c['reference_code']?.toString();
    final type = PwfComplaintTypeDb.tryParse(c['type']?.toString());
    final dept = PwfComplaintDepartmentDb.tryParse(c['department']?.toString());
    final subject = c['subject']?.toString();
    final desc = c['description']?.toString();
    final email = c['email']?.toString();
    final createdAtStr = c['created_at']?.toString();
    final status = PwfComplaintStatusDb.tryParse(c['status']?.toString());

    if (ref == null ||
        type == null ||
        dept == null ||
        subject == null ||
        desc == null ||
        email == null ||
        createdAtStr == null ||
        status == null) {
      return null;
    }

    final createdAt = DateTime.tryParse(createdAtStr);
    if (createdAt == null) return null;

    final attachmentsCountRaw = c['attachments_count'];
    final attachmentsCount = attachmentsCountRaw is num
        ? attachmentsCountRaw.toInt()
        : int.tryParse('$attachmentsCountRaw') ?? 0;

    final updatesList = <PwfComplaintUpdate>[];
    final updates = json['updates'];
    if (updates is List) {
      for (final u in updates) {
        if (u is Map) {
          final parsed = PwfComplaintUpdate.tryFromMap(
            Map<String, dynamic>.from(u),
          );
          if (parsed != null) updatesList.add(parsed);
        }
      }
    }

    // Ensure ascending
    updatesList.sort((a, b) => a.date.compareTo(b.date));

    return PwfComplaint(
      referenceCode: ref,
      type: type,
      department: dept,
      subject: subject,
      description: desc,
      name: (c['name']?.toString().trim().isEmpty ?? true)
          ? null
          : c['name']?.toString(),
      email: email,
      phone: (c['phone']?.toString().trim().isEmpty ?? true)
          ? null
          : c['phone']?.toString(),
      attachmentsCount: attachmentsCount,
      status: status,
      createdAt: createdAt,
      updates: updatesList,
    );
  }

  static PwfComplaint? tryFromPublicSuggestion(Map<String, dynamic> map) {
    final ref = map['reference_code']?.toString();
    final subject = map['subject']?.toString();
    final preview = map['description_preview']?.toString() ?? '';
    final status =
        PwfComplaintStatusDb.tryParse(map['status']?.toString()) ??
        PwfComplaintStatus.pending;
    final createdAt = DateTime.tryParse(map['created_at']?.toString() ?? '');

    if (ref == null || subject == null || createdAt == null) return null;

    return PwfComplaint(
      referenceCode: ref,
      type: PwfComplaintType.suggestion,
      department: PwfComplaintDepartment.general,
      subject: subject,
      description: preview,
      name: null,
      email: '',
      phone: null,
      attachmentsCount: 0,
      status: status,
      createdAt: createdAt,
      updates: const [],
    );
  }
}
