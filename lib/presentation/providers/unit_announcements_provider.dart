import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/announcement.dart';
import '../../data/repositories/announcement_repository.dart';
import '../../data/services/supabase_service.dart';
import 'unit_context_provider.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(SupabaseService());
});

final announcementsForUnitProvider = FutureProvider.family<List<Announcement>, String>((ref, unitSlug) async {
  final unitId = await ref.watch(unitIdBySlugProvider(unitSlug).future);
  return ref.read(announcementRepositoryProvider).getAllAnnouncementsForUnit(unitId);
});
