import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';

import '../models/pwf_public_service_catalog_item.dart';
import '../repositories/pwf_public_services_catalog_repository.dart';

final pwfPublicServicesCatalogRepositoryProvider =
    Provider<PwfPublicServicesCatalogRepository>((ref) {
      final supabase = ref.watch(supabaseServiceProvider).client;
      return PwfPublicServicesCatalogRepository(supabase);
    });

/// Root cutover provider for the public services catalog.
///
/// Default runtime reads `public.v_platform_navigation_services_catalog_from_owner_v1`.
/// The preserved `public.v_services_catalog_compat_v1` surface is fallback only
/// if the owner wrapper is unavailable/empty, or when an operator explicitly
/// passes `--dart-define=PWF_FORCE_LEGACY_PUBLIC_SERVICES=true`.
final pwfPublicServicesCatalogProvider =
    FutureProvider<List<PwfPublicServiceCatalogItem>>((ref) async {
      final repository = ref.watch(pwfPublicServicesCatalogRepositoryProvider);
      try {
        return await repository.fetchActiveServices();
      } on PostgrestException catch (error) {
        final message = error.message.toLowerCase();
        if (message.contains('relation') ||
            message.contains('column') ||
            message.contains('does not exist')) {
          return const <PwfPublicServiceCatalogItem>[];
        }
        rethrow;
      } catch (_) {
        return const <PwfPublicServiceCatalogItem>[];
      }
    });

/// Root cutover provider for homepage quick services.
///
/// Default runtime reads `public.v_platform_navigation_home_services_from_owner_v1`.
/// If that surface is unavailable/empty, the existing footer/static UI fallback
/// in `PwfQuickServicesSection` remains intact without touching
/// `public.home_services`.
final pwfPlatformNavigationHomeServicesProvider =
    FutureProvider<List<PwfPublicServiceCatalogItem>>((ref) async {
      final repository = ref.watch(pwfPublicServicesCatalogRepositoryProvider);
      try {
        return await repository.fetchActiveHomeServices();
      } on PostgrestException catch (error) {
        final message = error.message.toLowerCase();
        if (message.contains('relation') ||
            message.contains('column') ||
            message.contains('does not exist')) {
          return const <PwfPublicServiceCatalogItem>[];
        }
        rethrow;
      } catch (_) {
        return const <PwfPublicServiceCatalogItem>[];
      }
    });
