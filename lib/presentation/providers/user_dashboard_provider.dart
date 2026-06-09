import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/access/access_provider.dart';
import '../../core/access/user_dashboard_contract.dart';
import '../../data/models/user_activity_log_item.dart';
import '../../data/models/user_session_log_item.dart';
import '../../data/repositories/user_activity_repository.dart';
import 'auth_provider.dart';

final userActivityRepositoryProvider = Provider<UserActivityRepository>((ref) {
  return UserActivityRepository(Supabase.instance.client);
});

final currentUserDashboardContractProvider =
    FutureProvider<UserDashboardContract?>((ref) async {
      final user = ref.watch(currentUserProvider);
      final profile = await ref.watch(accessProfileProvider.future);
      if (user == null) return null;
      return UserDashboardContractBuilder.build(user: user, profile: profile);
    });

final currentUserActivityLogsProvider =
    FutureProvider<List<UserActivityLogItem>>((ref) async {
      final user = ref.watch(currentUserProvider);
      if (user == null) return const [];
      return ref
          .watch(userActivityRepositoryProvider)
          .fetchOwnActivityLogs(userId: user.id);
    });

final currentUserSessionLogsProvider = FutureProvider<List<UserSessionLogItem>>(
  (ref) async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const [];
    return ref
        .watch(userActivityRepositoryProvider)
        .fetchOwnSessionLogs(userId: user.id);
  },
);
