import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/admin_users_repository.dart';

enum AdminUsersActiveFilter { all, active, inactive }

final adminUsersRepositoryProvider = Provider<AdminUsersRepository>((ref) {
  return AdminUsersRepository(Supabase.instance.client);
});

final adminUsersSearchProvider = StateProvider<String>((ref) => '');

final adminUsersActiveFilterProvider = StateProvider<AdminUsersActiveFilter>((ref) {
  return AdminUsersActiveFilter.all;
});

final adminUsersListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
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
