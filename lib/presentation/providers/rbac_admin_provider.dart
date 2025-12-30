import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/rbac_admin_repository.dart';

final rbacAdminRepositoryProvider = Provider<RbacAdminRepository>((ref) {
  return RbacAdminRepository(Supabase.instance.client);
});

final platformSystemsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(rbacAdminRepositoryProvider).fetchSystems();
});

final platformPermissionsCatalogProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(rbacAdminRepositoryProvider).fetchPermissionsCatalog();
});

final userSystemRolesProvider =
FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  return ref.read(rbacAdminRepositoryProvider).fetchUserRoles(userId);
});

final userSystemPermissionsProvider =
FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  return ref.read(rbacAdminRepositoryProvider).fetchUserPermissions(userId);
});
