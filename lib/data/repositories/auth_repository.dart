// lib/data/repositories/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_user.dart';
import '../services/supabase_service.dart';
import '../../core/services/storage_service.dart';
import 'dart:developer' as dev;

class AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepository(this._supabaseService);

  // ============================================
  // AUTHENTICATION METHODS
  // ============================================

  /// Login with email and password
  /// Returns AdminUser on success
  /// Throws AuthException on failure
// lib/data/repositories/auth_repository.dart

  Future<AdminUser> login(String email, String password) async {
    try {
      // LOG: Starting login
      dev.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AuthRepository');
      dev.log('LOGIN ATTEMPT', name: 'AuthRepository');
      dev.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AuthRepository');
      dev.log('Email: $email', name: 'AuthRepository');
      dev.log('Password length: ${password.length}', name: 'AuthRepository');
      dev.log('Time: ${DateTime.now()}', name: 'AuthRepository');

      // 1. Authenticate with Supabase Auth
      dev.log('Calling Supabase Auth...', name: 'AuthRepository');
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );


      dev.log('Supabase Auth Response:', name: 'AuthRepository');
      dev.log('User ID: ${response.user?.id}', name: 'AuthRepository');
      dev.log('Email: ${response.user?.email}', name: 'AuthRepository');
      dev.log('Session exists: ${response.session != null}', name: 'AuthRepository');
      if (response.session?.accessToken != null) {
        dev.log('Access token: ${response.session!.accessToken.substring(0, 20)}...', name: 'AuthRepository');
      }

      // 2. Check if login was successful
      if (response.user == null) {
        dev.log('ERROR: No user in response!', name: 'AuthRepository');
        throw Exception('فشل تسجيل الدخول');
      }

      // 3. Fetch user profile from admin_users table
      dev.log('Fetching user profile from admin_users table...', name: 'AuthRepository');
      dev.log('Looking for user_id: ${response.user!.id}', name: 'AuthRepository');
      final adminUser = await _getUserProfile(response.user!.id);


      dev.log('User Profile Found:', name: 'AuthRepository');
      dev.log('Name: ${adminUser.name}', name: 'AuthRepository');
      dev.log('Email: ${adminUser.email}', name: 'AuthRepository');
      dev.log('Role: ${adminUser.role}', name: 'AuthRepository');
      dev.log('Active: ${adminUser.isActive}', name: 'AuthRepository');

      // 4. Check if user is active
      if (!adminUser.isActive) {
        dev.log('ERROR: User account is inactive!', name: 'AuthRepository');
        await logout();
        throw Exception('هذا الحساب غير نشط. يرجى التواصل مع المسؤول');
      }

      // 5. Save session for "Remember Me"
      dev.log('Saving session...', name: 'AuthRepository');
      await _saveSession(response.session!);

      dev.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AuthRepository');
      dev.log('LOGIN SUCCESSFUL!', name: 'AuthRepository');
      dev.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AuthRepository');

      return adminUser;

    } on AuthException catch (e) {
      dev.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AuthRepository');
      dev.log('SUPABASE AUTH EXCEPTION', name: 'AuthRepository', error: e);
      dev.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AuthRepository');
      dev.log('Message: "${e.message}"', name: 'AuthRepository', error: e);
      dev.log('Status Code: ${e.statusCode}', name: 'AuthRepository');
      dev.log('Type: ${e.runtimeType}', name: 'AuthRepository');
      dev.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AuthRepository');

      throw _handleAuthException(e);

    } catch (e, stackTrace) {
      // Only general exceptions have stackTrace
      dev.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AuthRepository');
      dev.log('GENERAL EXCEPTION', name: 'AuthRepository', error: e, stackTrace: stackTrace);
      dev.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AuthRepository');
      dev.log('Error: $e', name: 'AuthRepository', error: e);
      dev.log('Type: ${e.runtimeType}', name: 'AuthRepository');
      dev.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'AuthRepository');

      throw Exception('خطأ في تسجيل الدخول: ${e.toString()}');
    }
  }
  /// Logout current user
  Future<void> logout() async {
    try {
      await _supabaseService.client.auth.signOut();
      await _clearSession();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('فشل تسجيل الخروج: ${e.toString()}');
    }
  }

  /// Get currently authenticated user
  /// Returns null if no user is logged in
  Future<AdminUser?> getCurrentUser() async {
    try {
      final currentUser = _supabaseService.currentUser;

      if (currentUser == null) {
        // Try to restore session
        final restored = await _restoreSession();
        if (!restored) return null;

        // Get user after session restore
        final restoredUser = _supabaseService.currentUser;
        if (restoredUser == null) return null;

        return await _getUserProfile(restoredUser.id);
      }

      return await _getUserProfile(currentUser.id);
    } catch (e) {
      // If there's an error fetching profile, return null
      return null;
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _supabaseService.isAuthenticated;
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return _supabaseService.authStateChanges;
  }

  // ============================================
  // PASSWORD MANAGEMENT
  // ============================================

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'yourapp://reset-password', // Update with your deep link
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('فشل إرسال رابط إعادة تعيين كلمة المرور: ${e.toString()}');
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('فشل تحديث كلمة المرور: ${e.toString()}');
    }
  }

  // ============================================
  // USER PROFILE MANAGEMENT
  // ============================================

  /// Get user profile from database
// lib/data/repositories/auth_repository.dart

  Future<AdminUser> _getUserProfile(String userId) async {
    try {
      dev.log('Fetching profile for user_id: $userId', name: 'AuthRepository');

      final response = await _supabaseService.client
          .from('admin_users')
          .select()
          .eq('id', userId)
          .single();

      dev.log('Profile data received:', name: 'AuthRepository');
      dev.log('Raw JSON: $response', name: 'AuthRepository');

      final adminUser = AdminUser.fromJson(response);

      dev.log('Parsed AdminUser:', name: 'AuthRepository');
      dev.log('ID: ${adminUser.id}', name: 'AuthRepository');
      dev.log('Name: ${adminUser.name}', name: 'AuthRepository');
      dev.log('Email: ${adminUser.email}', name: 'AuthRepository');
      dev.log('Role: ${adminUser.role}', name: 'AuthRepository');

      return adminUser;

    } catch (e, stackTrace) {
      dev.log('Failed to fetch user profile!', name: 'AuthRepository', error: e, stackTrace: stackTrace);
      dev.log('User ID searched: $userId', name: 'AuthRepository');
      dev.log('Error Type: ${e.runtimeType}', name: 'AuthRepository');

      throw Exception('فشل جلب بيانات المستخدم: ${e.toString()}');
    }
  }
  /// Update user profile
  Future<AdminUser> updateProfile({
    required String userId,
    String? name,
    String? department,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (department != null) updates['department'] = department;

      if (updates.isEmpty) {
        return await _getUserProfile(userId);
      }

      final response = await _supabaseService.client
          .from('admin_users')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return AdminUser.fromJson(response);
    } catch (e) {
      throw Exception('فشل تحديث الملف الشخصي: ${e.toString()}');
    }
  }

  // ============================================
  // SESSION MANAGEMENT (Remember Me)
  // ============================================

  /// Save session for "Remember Me" functionality
  Future<void> _saveSession(Session session) async {
    try {
      await StorageService.instance.setString(
        'access_token',
        session.accessToken,
      );
      await StorageService.instance.setString(
        'refresh_token',
        session.refreshToken ?? '',
      );
      await StorageService.instance.setBool('remember_me', true);
    } catch (e) {
      // Don't throw error, just log
      dev.log('Failed to save session', name: 'AuthRepository', error: e);
    }
  }

  /// Restore session from storage
  Future<bool> _restoreSession() async {
    try {
      final rememberMe = StorageService.instance.getBool('remember_me');
      if (!rememberMe) return false;

      final accessToken = StorageService.instance.getString('access_token');
      final refreshToken = StorageService.instance.getString('refresh_token');

      if (accessToken == null || refreshToken == null) return false;

      // Set session in Supabase
      await _supabaseService.client.auth.setSession(refreshToken);

      return true;
    } catch (e) {
      dev.log('Failed to restore session', name: 'AuthRepository', error: e);
      return false;
    }
  }

  /// Clear saved session
  Future<void> _clearSession() async {
    try {
      await StorageService.instance.remove('access_token');
      await StorageService.instance.remove('refresh_token');
      await StorageService.instance.remove('remember_me');
    } catch (e) {
      dev.log('Failed to clear session', name: 'AuthRepository', error: e);
    }
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Handle Supabase AuthException and return user-friendly message
// lib/data/repositories/auth_repository.dart

  Exception _handleAuthException(AuthException e) {
    // Log the raw error for debugging
    dev.log('Analyzing Supabase error...', name: 'AuthRepository', error: e);
    dev.log('Original message: "${e.message}"', name: 'AuthRepository');

    // Normalize the message for comparison (lowercase, trimmed)
    final message = e.message.toLowerCase().trim();
    dev.log('Normalized: "$message"', name: 'AuthRepository');

    // Check for various forms of "invalid credentials"
    if (message.contains('invalid') ||
        message.contains('incorrect') ||
        message.contains('wrong')) {
      if (message.contains('credential') ||
          message.contains('password') ||
          message.contains('email') ||
          message.contains('login')) {
        dev.log('Detected: Invalid credentials error', name: 'AuthRepository');
        return Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }
    }

    // Check for email confirmation
    if (message.contains('email') &&
        (message.contains('confirm') || message.contains('verif'))) {
      dev.log('Detected: Email not confirmed', name: 'AuthRepository');
      return Exception('يرجى تأكيد البريد الإلكتروني أولاً');
    }

    // Check for already registered
    if (message.contains('already') && message.contains('register')) {
      dev.log('Detected: User already registered', name: 'AuthRepository');
      return Exception('هذا البريد الإلكتروني مسجل مسبقاً');
    }

    // Check for user not found
    if (message.contains('user') &&
        (message.contains('not found') || message.contains('does not exist'))) {
      dev.log('Detected: User not found', name: 'AuthRepository');
      return Exception('المستخدم غير موجود');
    }

    // Check for network errors
    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      dev.log('Detected: Network error', name: 'AuthRepository');
      return Exception('خطأ في الاتصال بالخادم. يرجى التحقق من الإنترنت');
    }

    // If no match, return the original error with context
    dev.log('No pattern match - returning original error', name: 'AuthRepository');
    return Exception('خطأ في المصادقة: ${e.message}');
  }}