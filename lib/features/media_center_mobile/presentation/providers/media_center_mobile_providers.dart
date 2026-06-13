
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';

import '../../data/repositories/media_center_mobile_repository.dart';

final mediaCenterMobileRepositoryProvider =
    Provider<MediaCenterMobileRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider).client;
  return MediaCenterMobileRepository(supabase);
});

final mediaCenterMobileSnapshotProvider =
    FutureProvider<MediaCenterMobileSnapshot>((ref) async {
  final repository = ref.watch(mediaCenterMobileRepositoryProvider);
  return repository.loadSnapshot();
});
