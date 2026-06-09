import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pwf_admin_complaint.dart';
import '../models/pwf_complaint.dart';
import 'pwf_admin_complaints_repository.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class PwfAdminComplaintsRepositoryImpl implements PwfAdminComplaintsRepository {
  final SupabaseClient _client;
  PwfAdminComplaintsRepositoryImpl(this._client);

  @override
  Future<List<PwfAdminComplaintItem>> listComplaints({
    String? query,
    PwfComplaintStatus? status,
    int limit = 100,
  }) async {
    final q = query?.trim();

    // IMPORTANT (postgrest 2.x): apply filters (eq/or) BEFORE ordering/limiting.
    // Some builder methods (order/limit) may widen the type to TransformBuilder
    // which doesn't expose filter helpers like .eq() / .or().
    var req = _client
        .from(PwfDatabaseOwnerSurfaces.pwfComplaints)
        .select(
          'reference_code, unit_id, type, department, subject, status, attachments_count, created_at',
        );

    if (status != null) {
      req = req.eq('status', status.dbValue);
    }

    if (q != null && q.isNotEmpty) {
      // Search by reference_code or subject (case-insensitive)
      req = req.or('reference_code.ilike.%$q%,subject.ilike.%$q%');
    }

    final res = await req.order('created_at', ascending: false).limit(limit);

    final out = <PwfAdminComplaintItem>[];
    for (final r in res) {
      final parsed = PwfAdminComplaintItem.tryFromMap(
        Map<String, dynamic>.from(r),
      );
      if (parsed != null) out.add(parsed);
    }
    return out;
  }

  @override
  Future<PwfAdminComplaintDetails?> fetchDetails({
    required String referenceCode,
  }) async {
    final ref = referenceCode.trim().toUpperCase();
    if (ref.isEmpty) return null;

    final c = await _client
        .from(PwfDatabaseOwnerSurfaces.pwfComplaints)
        .select(
          'reference_code, unit_id, type, department, subject, description, name, email, phone, attachments_count, status, created_at',
        )
        .eq('reference_code', ref)
        .maybeSingle();

    if (c == null) return null;

    final unitId = (c['unit_id']?.toString());

    final updatesRes = await _client
        .from(PwfDatabaseOwnerSurfaces.pwfComplaintUpdates)
        .select('status, message_key, created_at')
        .eq('complaint_reference_code', ref)
        .order('created_at', ascending: true);

    final updates = <PwfComplaintUpdate>[];
    for (final u in updatesRes) {
      final parsed = PwfComplaintUpdate.tryFromMap(
        Map<String, dynamic>.from(u),
      );
      if (parsed != null) updates.add(parsed);
    }

    final type = PwfComplaintTypeDb.tryParse(c['type']?.toString());
    final dept = PwfComplaintDepartmentDb.tryParse(c['department']?.toString());
    final status = PwfComplaintStatusDb.tryParse(c['status']?.toString());
    final createdAt = DateTime.tryParse(c['created_at']?.toString() ?? '');

    if (type == null || dept == null || status == null || createdAt == null)
      return null;

    final attachmentsCountRaw = c['attachments_count'];
    final attachmentsCount = attachmentsCountRaw is num
        ? attachmentsCountRaw.toInt()
        : int.tryParse('$attachmentsCountRaw') ?? 0;

    final complaint = PwfComplaint(
      referenceCode: ref,
      type: type,
      department: dept,
      subject: (c['subject']?.toString() ?? ''),
      description: (c['description']?.toString() ?? ''),
      name: (c['name']?.toString().trim().isEmpty ?? true)
          ? null
          : c['name']?.toString(),
      email: (c['email']?.toString() ?? ''),
      phone: (c['phone']?.toString().trim().isEmpty ?? true)
          ? null
          : c['phone']?.toString(),
      attachmentsCount: attachmentsCount,
      status: status,
      createdAt: createdAt,
      updates: updates,
    );

    return PwfAdminComplaintDetails(complaint: complaint, unitId: unitId);
  }

  @override
  Future<void> setStatus({
    required String referenceCode,
    required PwfComplaintStatus status,
    required String messageKey,
  }) async {
    final ref = referenceCode.trim().toUpperCase();

    // Update main status
    await _client
        .from(PwfDatabaseOwnerSurfaces.pwfComplaints)
        .update({'status': status.dbValue})
        .eq('reference_code', ref);

    // Append update row
    await _client.from(PwfDatabaseOwnerSurfaces.pwfComplaintUpdates).insert({
      'complaint_reference_code': ref,
      'status': status.dbValue,
      'message_key': messageKey,
      'created_by': _client.auth.currentUser?.id,
    });
  }
}
