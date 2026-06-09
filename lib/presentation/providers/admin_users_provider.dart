import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/user_activity_log_item.dart';
import '../../data/repositories/admin_users_audit_repository.dart';
import '../../data/repositories/admin_users_repository.dart';
import '../../data/repositories/user_scope_assignments_repository.dart';
import '../../data/models/user_scope_assignment.dart';

enum AdminUsersActiveFilter { all, active, inactive }

final adminUsersRepositoryProvider = Provider<AdminUsersRepository>((ref) {
  return AdminUsersRepository(Supabase.instance.client);
});

final adminUsersAuditRepositoryProvider = Provider<AdminUsersAuditRepository>((
  ref,
) {
  return AdminUsersAuditRepository(Supabase.instance.client);
});

final userScopeAssignmentsRepositoryProvider =
    Provider<UserScopeAssignmentsRepository>((ref) {
      return UserScopeAssignmentsRepository(Supabase.instance.client);
    });

final userScopeAssignmentsProvider =
    FutureProvider.family<List<UserScopeAssignment>, String>((
      ref,
      userId,
    ) async {
      final repo = ref.watch(userScopeAssignmentsRepositoryProvider);
      return repo.fetchUserAssignments(userId);
    });

final adminUsersSearchProvider = StateProvider<String>((ref) => '');

final adminUsersActiveFilterProvider = StateProvider<AdminUsersActiveFilter>((
  ref,
) {
  return AdminUsersActiveFilter.all;
});

final adminUsersListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final repo = ref.watch(adminUsersRepositoryProvider);
  final search = ref.watch(adminUsersSearchProvider);
  final filter = ref.watch(adminUsersActiveFilterProvider);

  bool? isActive;
  switch (filter) {
    case AdminUsersActiveFilter.all:
      isActive = null;
      break;
    case AdminUsersActiveFilter.active:
      isActive = true;
      break;
    case AdminUsersActiveFilter.inactive:
      isActive = false;
      break;
  }

  return repo.fetchAdminUsers(search: search, isActive: isActive);
});

final adminUsersRecentAuditProvider = FutureProvider<List<UserActivityLogItem>>(
  (ref) async {
    final repo = ref.watch(adminUsersAuditRepositoryProvider);
    return repo.fetchRecentAdminUsersAudit();
  },
);

final adminUsersActiveUnitsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final repo = ref.watch(adminUsersRepositoryProvider);
      return repo.fetchActiveUnits();
    });
