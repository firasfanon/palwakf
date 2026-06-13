
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';

import '../../data/repositories/media_center_mobile_publishing_repository.dart';

final mediaCenterMobilePublishingRepositoryProvider =
    Provider<MediaCenterMobilePublishingRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider).client;
  return MediaCenterMobilePublishingRepository(supabase);
});
