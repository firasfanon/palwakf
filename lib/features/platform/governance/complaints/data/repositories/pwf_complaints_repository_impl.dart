import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pwf_complaint.dart';
import 'pwf_complaints_repository.dart';

class PwfComplaintsRepositoryImpl implements PwfComplaintsRepository {
  final SupabaseClient _client;
  PwfComplaintsRepositoryImpl(this._client);

  @override
  Future<PwfComplaint> submitComplaint({
    required String unitSlug,
    required PwfComplaintType type,
    required PwfComplaintDepartment department,
    required String subject,
    required String description,
    required String email,
    String? name,
    String? phone,
    required int attachmentsCount,
  }) async {
    final payload = <String, dynamic>{
      'p_unit_slug': unitSlug.trim(),
      'p_type': type.dbValue,
      'p_department': department.dbValue,
      'p_subject': subject,
      'p_description': description,
      'p_email': email,
      'p_name': name,
      'p_phone': phone,
      'p_attachments_count': attachmentsCount,
    };

    final res = await _client.rpc('pwf_submit_complaint', params: payload);
    final ref = res?.toString();

    if (ref == null || ref.trim().isEmpty) {
      throw StateError('Submit succeeded but reference_code is missing.');
    }

    // Read back via scoped RPC to get timeline (first update created by trigger)
    final tracked = await trackByReference(unitSlug: unitSlug, reference: ref);
    if (tracked == null) {
      // Fallback: create a minimal object if RPC is blocked
      final now = DateTime.now();
      return PwfComplaint(
        referenceCode: ref,
        type: type,
        department: department,
        subject: subject.trim(),
        description: description.trim(),
        name: (name?.trim().isEmpty ?? true) ? null : name!.trim(),
        email: email.trim(),
        phone: (phone?.trim().isEmpty ?? true) ? null : phone!.trim(),
        attachmentsCount: attachmentsCount,
        status: PwfComplaintStatus.pending,
        createdAt: now,
        updates: const [],
      );
    }
    return tracked;
  }

  @override
  Future<PwfComplaint?> trackByReference({
    required String unitSlug,
    required String reference,
  }) async {
    final ref = reference.trim().toUpperCase();
    if (ref.isEmpty) return null;

    final res = await _client.rpc(
      'pwf_track_complaint_scoped',
      params: {'p_unit_slug': unitSlug.trim(), 'p_reference_code': ref},
    );

    if (res == null) return null;

    // Supabase may return Map or JSON string depending on config
    if (res is String) {
      final decoded = json.decode(res);
      if (decoded is Map<String, dynamic>) {
        return PwfComplaint.tryFromTrackJson(decoded);
      }
      return null;
    }

    if (res is Map) {
      return PwfComplaint.tryFromTrackJson(Map<String, dynamic>.from(res));
    }

    return null;
  }

  @override
  Future<List<PwfComplaint>> listSuggestions({
    required String unitSlug,
    int limit = 50,
  }) async {
    final res = await _client.rpc(
      'pwf_list_public_suggestions_scoped',
      params: {'p_unit_slug': unitSlug.trim(), 'p_limit': limit},
    );

    if (res == null) return const [];

    dynamic decoded = res;
    if (res is String) {
      decoded = json.decode(res);
    }

    if (decoded is! List) return const [];

    final out = <PwfComplaint>[];
    for (final item in decoded) {
      if (item is Map) {
        final c = PwfComplaint.tryFromPublicSuggestion(
          Map<String, dynamic>.from(item),
        );
        if (c != null) out.add(c);
      }
    }
    return out;
  }
}
