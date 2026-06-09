import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../presentation/providers/supabase_providers.dart';
import '../../data/models/pwf_dynamic_system_models.dart';
import '../../data/repositories/pwf_dynamic_system_registry_repository.dart';

final pwfDynamicSystemRegistryRepositoryProvider =
    Provider<PwfDynamicSystemRegistryRepository>((ref) {
      final supabaseService = ref.watch(supabaseServiceProvider);
      return PwfDynamicSystemRegistryRepository(supabaseService);
    });

final visibleDynamicAdminSystemsProvider =
    FutureProvider<List<PwfDynamicSystemModule>>((ref) async {
      final repository = ref.watch(pwfDynamicSystemRegistryRepositoryProvider);
      return repository.visibleForCurrentUser();
    });

final dynamicSystemAdminCatalogProvider =
    FutureProvider<List<PwfDynamicSystemModule>>((ref) async {
      final repository = ref.watch(pwfDynamicSystemRegistryRepositoryProvider);
      return repository.adminCatalog();
    });

final dynamicSystemSectionsProvider =
    FutureProvider.family<List<PwfDynamicSystemSection>, String>((
      ref,
      systemKey,
    ) async {
      final repository = ref.watch(pwfDynamicSystemRegistryRepositoryProvider);
      return repository.sectionsForSystem(systemKey);
    });
