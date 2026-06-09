import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_activity_log_item.dart';

/// Admin users audit adapter.
///
/// 10J runtime hardening:
/// Direct browser writes/reads against optional legacy audit tables
/// (`user_activity_logs`, `activity_logs`, `audit_logs`) are intentionally
/// disabled because missing tables produce visible 404/406 console errors and
/// do not satisfy the owner-write audit contract.
///
/// Controlled owner-write operations already emit server-side audit entries via
/// reviewed SECURITY DEFINER RPCs. A later batch may expose those entries to
/// Flutter through a public compatibility view/RPC after RLS and redaction are
/// reviewed.
class AdminUsersAuditRepository {
  final SupabaseClient _client;

  AdminUsersAuditRepository(this._client);

  Future<void> logUserAdminAction({
    required String actionKey,
    required String title,
    required String targetUserId,
    String entityType = 'admin_user',
    String route = '/admin/users',
    Map<String, dynamic> metadata = const {},
  }) async {
    // Keep the call site contract stable while preventing legacy REST probes.
    // The current authenticated user is intentionally read only; no network
    // request is sent from Flutter for this optional legacy audit adapter.
    final actorUserId = _client.auth.currentUser?.id.trim() ?? '';
    if (actorUserId.isEmpty || targetUserId.trim().isEmpty) return;
  }

  Future<List<UserActivityLogItem>> fetchRecentAdminUsersAudit({
    int limit = 12,
  }) async {
    final actorUserId = _client.auth.currentUser?.id.trim() ?? '';
    if (actorUserId.isEmpty || limit <= 0) return const [];
    return const [];
  }
}
