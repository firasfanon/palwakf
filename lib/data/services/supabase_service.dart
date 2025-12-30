// lib/data/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  // Get the Supabase client - FIXED: removed problematic isInitialized check
  SupabaseClient get client {
    return Supabase.instance.client;
  }

  // Check if Supabase is properly initialized - FIXED: wrapped in try-catch
  bool get isInitialized {
    try {
      // This will throw if not initialized, which we catch
      Supabase.instance.client;
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============ AUTH HELPERS ============

  /// Check if user is currently authenticated
  bool get isAuthenticated => client.auth.currentSession != null;

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Get current session
  Session? get currentSession => client.auth.currentSession;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ============ DATABASE HELPERS ============

  /// Query a table
  SupabaseQueryBuilder from(String table) {
    return client.from(table);
  }

  /// Execute RPC (Remote Procedure Call)
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) {
    return client.rpc(functionName, params: params);
  }

  /// Upload file to storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required dynamic file,
  }) async {
    await client.storage.from(bucket).upload(path, file);
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await client.storage.from(bucket).remove([path]);
  }
}