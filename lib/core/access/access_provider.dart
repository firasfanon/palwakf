import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../presentation/providers/supabase_providers.dart';
import 'access_profile.dart';
import 'access_repository.dart';

final accessRepositoryProvider = Provider<AccessRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AccessRepository(supabaseService);
});

/// Emits on sign-in, sign-out, token refresh, and user updates. The provider is
/// used only to invalidate authority hydration, not as a source of permissions.
final accessAuthoritySessionProvider =
    StreamProvider<supabase.AuthState>((ref) {
  return supabase.Supabase.instance.client.auth.onAuthStateChange;
});

/// Clears stale repository data and reloads the current caller's authority.
/// Call this after an explicit authority refresh action; it does not mutate
/// server-side permissions or scopes.
void refreshAccessAuthority(Ref ref) {
  ref.read(accessRepositoryProvider).clearCache();
  ref.invalidate(accessProfileProvider);
}

/// Loads a fresh profile for widgets. The repository cache is refreshed here so
/// a Retry action never keeps an old pre-authority profile alive.
final accessProfileProvider = FutureProvider<AccessProfile?>((ref) async {
  ref.watch(accessAuthoritySessionProvider);
  final user = supabase.Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  final repo = ref.watch(accessRepositoryProvider);
  return repo.load(user.id, forceRefresh: true);
});

/// Synchronous helper for GoRouter and other guards. It returns the last
/// verified profile while an async provider refresh is in flight.
final accessCachedProvider = Provider<AccessProfile?>((ref) {
  final user = supabase.Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  final repo = ref.watch(accessRepositoryProvider);
  return repo.getCached(user.id);
});
