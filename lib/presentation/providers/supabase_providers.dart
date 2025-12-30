import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/supabase_service.dart';

/// Provider for SupabaseService singleton
/// This is the single source of truth for SupabaseService across the entire app
/// All features that need database access should use this provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});