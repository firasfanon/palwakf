
import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/media_center_publish_models.dart';

class MediaCenterMobilePublishingRepository {
  const MediaCenterMobilePublishingRepository(this._client);

  final SupabaseClient _client;

  static const String _bucket = 'media-gallery';
  static const Duration _timeout = Duration(seconds: 12);
  static const String _officialBaseUrl = String.fromEnvironment(
    'PWF_PUBLIC_SITE_BASE_URL',
    defaultValue: 'https://palwakf.ps',
  );

  User? get currentUser => _client.auth.currentUser;

  bool get isSignedIn => currentUser != null;

  Future<String?> uploadPrimaryImage({
    required XFile file,
    required MediaPublishingContentType contentType,
    String unitSlug = 'home',
  }) async {
    final bytes = await file.readAsBytes();
    final ext = _safeExtension(file.name);
    final now = DateTime.now().millisecondsSinceEpoch;
    final safeUnit = _safeSegment(unitSlug.isEmpty ? 'home' : unitSlug);
    final path =
        'mobile-official/${contentType.familyKey}/$safeUnit/$now$ext';

    await _client.storage
        .from(_bucket)
        .uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(
            contentType: file.mimeType ?? _mimeFromExtension(ext),
            upsert: false,
          ),
        )
        .timeout(_timeout);

    _log(
      'PWF_MEDIA_CENTER_MOBILE_UPLOAD bucket=$_bucket path=$path '
      'decision=official-first-mobile-upload-storage-only',
    );

    return path;
  }

  Future<MediaMobilePublishResult> createDraft(
    MediaMobilePublishDraft draft,
  ) async {
    _requireAuth();
    final response = await _client
        .rpc('rpc_media_center_mobile_create_draft_v1',
            params: draft.toCreateDraftParams())
        .timeout(_timeout);
    return _result(response);
  }

  Future<MediaMobilePublishResult> submitForReview(String contentItemId) async {
    _requireAuth();
    final response = await _client
        .rpc('rpc_media_center_mobile_submit_for_review_v1', params: {
          'p_content_item_id': contentItemId,
        })
        .timeout(_timeout);
    return _result(response);
  }

  Future<MediaMobilePublishResult> publishNow(String contentItemId) async {
    _requireAuth();
    final response = await _client
        .rpc('rpc_media_center_mobile_publish_v1', params: {
          'p_content_item_id': contentItemId,
        })
        .timeout(_timeout);
    return _result(response);
  }

  Future<MediaMobilePublishResult> execute({
    required MediaMobilePublishDraft draft,
    required MediaMobilePublishAction action,
  }) async {
    final created = await createDraft(draft);

    switch (action) {
      case MediaMobilePublishAction.saveDraft:
        return created;
      case MediaMobilePublishAction.submitForReview:
        return submitForReview(created.contentItemId);
      case MediaMobilePublishAction.publishNow:
        return publishNow(created.contentItemId);
    }
  }

  String absoluteOfficialUrl(String officialPath) {
    if (officialPath.startsWith('http')) return officialPath;
    final base = _officialBaseUrl.endsWith('/')
        ? _officialBaseUrl.substring(0, _officialBaseUrl.length - 1)
        : _officialBaseUrl;
    final path = officialPath.startsWith('/') ? officialPath : '/$officialPath';
    return '$base$path';
  }

  MediaMobilePublishResult _result(dynamic response) {
    final map = _asMap(response);
    final rawPath = (map['official_path'] ?? '').toString();
    final patched = Map<String, dynamic>.from(map);
    if ((patched['official_url'] ?? '').toString().trim().isEmpty &&
        rawPath.trim().isNotEmpty) {
      patched['official_url'] = absoluteOfficialUrl(rawPath);
    }
    final result = MediaMobilePublishResult.fromJson(patched);
    _log(
      'PWF_MEDIA_CENTER_MOBILE_PUBLISH_RESULT '
      'content_item_id=${result.contentItemId} '
      'status=${result.status} '
      'official_path=${result.officialPath} '
      'public_visibility_granted=${result.publicVisibilityGranted} '
      'decision=official-first-mobile-publishing',
    );
    return result;
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) {
      return response.map((key, value) => MapEntry(key.toString(), value));
    }
    throw StateError('Unexpected RPC response: $response');
  }

  void _requireAuth() {
    if (_client.auth.currentUser == null) {
      throw StateError('يجب تسجيل الدخول قبل إنشاء خبر أو إعلان أو نشاط.');
    }
  }

  String _safeSegment(String value) {
    final normalized = value.trim().toLowerCase();
    final cleaned = normalized.replaceAll(RegExp(r'[^a-z0-9_\-]+'), '-');
    return cleaned.isEmpty ? 'home' : cleaned;
  }

  String _safeExtension(String filename) {
    final idx = filename.lastIndexOf('.');
    if (idx < 0) return '.jpg';
    final ext = filename.substring(idx).toLowerCase();
    if (ext.length > 8) return '.jpg';
    return ext;
  }

  String _mimeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      case '.jpg':
      case '.jpeg':
      default:
        return 'image/jpeg';
    }
  }

  void _log(String message) {
    if (!kDebugMode) return;
    dev.log(message, name: 'MediaCenterMobilePublishingRepository');
    debugPrint(message);
  }
}
