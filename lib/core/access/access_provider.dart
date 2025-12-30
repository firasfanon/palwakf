import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../presentation/providers/supabase_providers.dart';
import '../enums/enums.dart';
import 'access_profile.dart';
import 'access_repository.dart';

final accessRepositoryProvider = Provider<AccessRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AccessRepository(supabaseService);
});

/// Returns the cached profile if exists; otherwise loads it once.
final accessProfileProvider = FutureProvider<AccessProfile?>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  final repo = ref.watch(accessRepositoryProvider);
  return repo.load(user.id);
});

/// Synchronous helper for guards (may be null if not loaded yet)
final accessCachedProvider = Provider<AccessProfile?>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  final repo = ref.watch(accessRepositoryProvider);
  return repo.getCached(user.id);
});
