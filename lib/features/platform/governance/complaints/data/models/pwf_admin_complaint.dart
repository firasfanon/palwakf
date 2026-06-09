import 'package:flutter/foundation.dart';

import 'pwf_complaint.dart';

@immutable
class PwfAdminComplaintItem {
  final String referenceCode;
  final String? unitId; // uuid as string
  final PwfComplaintType type;
  final PwfComplaintDepartment department;
  final String subject;
  final PwfComplaintStatus status;
  final int attachmentsCount;
  final DateTime createdAt;

  const PwfAdminComplaintItem({
    required this.referenceCode,
    required this.unitId,
    required this.type,
    required this.department,
    required this.subject,
    required this.status,
    required this.attachmentsCount,
    required this.createdAt,
  });

  static PwfAdminComplaintItem? tryFromMap(Map<String, dynamic> map) {
    final ref = map['reference_code']?.toString();
    final type = PwfComplaintTypeDb.tryParse(map['type']?.toString());
    final dept = PwfComplaintDepartmentDb.tryParse(
      map['department']?.toString(),
    );
    final subject = map['subject']?.toString();
    final status = PwfComplaintStatusDb.tryParse(map['status']?.toString());
    final createdAt = DateTime.tryParse(map['created_at']?.toString() ?? '');

    if (ref == null ||
        type == null ||
        dept == null ||
        subject == null ||
        status == null ||
        createdAt == null) {
      return null;
    }

    final attachmentsCountRaw = map['attachments_count'];
    final attachmentsCount = attachmentsCountRaw is num
        ? attachmentsCountRaw.toInt()
        : int.tryParse('$attachmentsCountRaw') ?? 0;

    return PwfAdminComplaintItem(
      referenceCode: ref,
      unitId: map['unit_id']?.toString(),
      type: type,
      department: dept,
      subject: subject,
      status: status,
      attachmentsCount: attachmentsCount,
      createdAt: createdAt,
    );
  }
}

@immutable
class PwfAdminComplaintDetails {
  final PwfComplaint complaint;
  final String? unitId; // uuid as string

  const PwfAdminComplaintDetails({
    required this.complaint,
    required this.unitId,
  });
}
