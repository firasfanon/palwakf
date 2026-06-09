import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/media_center_models.dart';
import '../../data/repositories/media_center_repository.dart';

final Provider<MediaCenterRepository> mediaCenterRepositoryProvider =
    Provider<MediaCenterRepository>((ref) {
      return MediaCenterRepository(Supabase.instance.client);
    });

final FutureProvider<MediaCenterDashboardState> mediaCenterDashboardProvider =
    FutureProvider<MediaCenterDashboardState>((ref) async {
      return ref.watch(mediaCenterRepositoryProvider).loadDashboardState();
    });
