import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';

import '../../data/models/pwf_platform_center_content_item.dart';
import '../../data/repositories/pwf_platform_center_content_repository.dart';

final pwfPlatformCenterContentRepositoryProvider =
    Provider<PwfPlatformCenterContentRepository>((ref) {
      final supabase = ref.watch(supabaseServiceProvider).client;
      return PwfPlatformCenterContentRepository(supabase);
    });

final pwfPlatformCenterContentListProvider =
    FutureProvider.family<
      List<PwfPlatformCenterContentItem>,
      PwfPlatformCenterContentQuery
    >((ref, query) async {
      final repository = ref.watch(pwfPlatformCenterContentRepositoryProvider);
      return repository.fetchItems(query);
    });

class PwfPlatformCenterContentDetailQuery {
  const PwfPlatformCenterContentDetailQuery({
    required this.id,
    required this.familyKey,
    required this.unitSlug,
  });

  final String id;
  final String familyKey;
  final String unitSlug;

  @override
  bool operator ==(Object other) {
    return other is PwfPlatformCenterContentDetailQuery &&
        other.id == id &&
        other.familyKey == familyKey &&
        other.unitSlug == unitSlug;
  }

  @override
  int get hashCode => Object.hash(id, familyKey, unitSlug);
}

final pwfPlatformCenterContentDetailProvider =
    FutureProvider.family<
      PwfPlatformCenterContentItem?,
      PwfPlatformCenterContentDetailQuery
    >((ref, query) async {
      final repository = ref.watch(pwfPlatformCenterContentRepositoryProvider);
      return repository.fetchItemById(
        id: query.id,
        familyKey: query.familyKey,
        unitSlug: query.unitSlug,
      );
    });
