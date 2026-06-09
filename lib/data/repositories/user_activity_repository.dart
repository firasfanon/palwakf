import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_activity_log_item.dart';
import '../models/user_session_log_item.dart';

/// User self-activity adapter.
///
/// Public Schema Phase 3/10J contract:
/// - Flutter must not probe optional legacy public tables such as
///   `user_activity_logs`, `activity_logs`, `user_sessions`, or
///   `admin_user_sessions` directly because missing optional observability
///   tables produce browser-console 404/406 noise.
/// - Until a stable public audit/session compatibility wrapper is installed,
///   this repository degrades safely to an empty read model.
/// - Owner-write RPC audit evidence is preserved server-side in
///   `platform.owner_write_rpc_audit_events`; exposing it to Flutter requires a
///   reviewed public read wrapper/RPC in a later batch.
class UserActivityRepository {
  final SupabaseClient _client;

  UserActivityRepository(this._client);

  Future<List<UserActivityLogItem>> fetchOwnActivityLogs({
    required String userId,
    int limit = 20,
  }) async {
    // Touch auth state only to preserve the repository dependency contract and
    // avoid unused-field analyzer noise. Do not perform legacy REST probes.
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null || currentUserId != userId || limit <= 0) {
      return const [];
    }
    return const [];
  }

  Future<List<UserSessionLogItem>> fetchOwnSessionLogs({
    required String userId,
    int limit = 10,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null || currentUserId != userId || limit <= 0) {
      return const [];
    }
    return const [];
  }
}
