import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pwf_platform_center_content_item.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class PwfPlatformCenterContentRepository {
  const PwfPlatformCenterContentRepository(this._client);

  final SupabaseClient _client;

  static const bool _enableOperationalRpcReads = bool.fromEnvironment(
    'PWF_PLATFORM_CENTER_CONTENT_RPC_READS',
    defaultValue: false,
  );

  Future<List<PwfPlatformCenterContentItem>> fetchItems(
    PwfPlatformCenterContentQuery query,
  ) async {
    if (query.publishedOnly) {
      return _fetchPublishedItemsFromPublicView(query);
    }

    // The operational list RPC is an optional backend surface. When its
    // signature/data contract is not aligned it returns PostgREST 400 and
    // pollutes the browser console even when Dart catches the exception.
    // Keep it disabled by default until the SQL contract is explicitly
    // certified, and use the local read model for admin previews.
    if (!_enableOperationalRpcReads) {
      return PwfPlatformCenterContentItem.fallbackItems(query);
    }

    try {
      final response = await _client.rpc(
        'pwf_platform_center_content_list',
        params: query.toRpcParams(),
      );
      final rows = _normalizeRows(response);
      final items = rows
          .map(PwfPlatformCenterContentItem.fromJson)
          .toList(growable: false);
      return items.take(query.limit).toList(growable: false);
    } on PostgrestException catch (error) {
      if (!_isMissingBackend(error.message)) rethrow;
    }
    return PwfPlatformCenterContentItem.fallbackItems(query);
  }

  Future<List<PwfPlatformCenterContentItem>> _fetchPublishedItemsFromPublicView(
    PwfPlatformCenterContentQuery query,
  ) async {
    try {
      final response = await _client
          .from(PwfDatabaseOwnerSurfaces.vPlatformCenterContent)
          .select(
            'id,family_key,title_ar,summary_ar,owner_name,scope_type,workflow_status,public_route,published_at,document_url',
          )
          .eq('family_key', query.normalizedFamilyKey)
          .order('published_at', ascending: false)
          .limit(query.limit);
      final rows = _normalizeRows(response);
      return rows
          .map(PwfPlatformCenterContentItem.fromJson)
          .take(query.limit)
          .toList(growable: false);
    } on PostgrestException catch (error) {
      if (!_isMissingBackend(error.message)) rethrow;
    }

    return PwfPlatformCenterContentItem.fallbackItems(query);
  }

  Future<PwfPlatformCenterContentItem?> fetchItemById({
    required String id,
    required String familyKey,
    required String unitSlug,
  }) async {
    if (_enableOperationalRpcReads) {
      try {
        final response = await _client.rpc(
          'pwf_platform_center_content_get',
          params: <String, dynamic>{
            'p_id': id,
            'p_family_key': familyKey.trim().replaceAll('-', '_'),
            'p_unit_slug': unitSlug.trim().isEmpty ? 'home' : unitSlug.trim(),
          },
        );
        final rows = _normalizeRows(response);
        if (rows.isNotEmpty)
          return PwfPlatformCenterContentItem.fromJson(rows.first);
        if (response is Map && response.isNotEmpty) {
          return PwfPlatformCenterContentItem.fromJson(
            response.map((key, value) => MapEntry(key.toString(), value)),
          );
        }
      } on PostgrestException catch (error) {
        if (!_isMissingBackend(error.message)) rethrow;
      }
    }

    final fallbackList = await fetchItems(
      PwfPlatformCenterContentQuery(
        familyKey: familyKey,
        unitSlug: unitSlug,
        publishedOnly: true,
        limit: 50,
      ),
    );
    for (final item in fallbackList) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<PwfPlatformCenterContentWriteResult> createDraft(
    PwfPlatformCenterContentDraft draft,
  ) async {
    return _upsertDraft(draft, allowLegacyFallback: true);
  }

  Future<PwfPlatformCenterContentWriteResult> updateDraft(
    PwfPlatformCenterContentDraft draft,
  ) async {
    return _upsertDraft(draft, allowLegacyFallback: false);
  }

  Future<PwfPlatformCenterContentWriteResult> _upsertDraft(
    PwfPlatformCenterContentDraft draft, {
    required bool allowLegacyFallback,
  }) async {
    try {
      final response = await _client.rpc(
        'pwf_platform_center_content_upsert',
        params: _compactParams(draft.toRpcParams()),
      );
      return _writeResult(
        response,
        fallbackMessage: draft.id == null
            ? 'تم حفظ المسودة عبر RPC التشغيلي.'
            : 'تم تحديث المحتوى عبر RPC التشغيلي.',
      );
    } on PostgrestException catch (error) {
      if (allowLegacyFallback && _isMissingBackend(error.message)) {
        return _legacyCreateDraft(draft);
      }
      return PwfPlatformCenterContentWriteResult(
        success: false,
        messageAr: 'تعذر الحفظ: ${error.message}',
      );
    } catch (error) {
      return PwfPlatformCenterContentWriteResult(
        success: false,
        messageAr: 'تعذر الحفظ: $error',
      );
    }
  }

  Future<PwfPlatformCenterContentWriteResult> _legacyCreateDraft(
    PwfPlatformCenterContentDraft draft,
  ) async {
    try {
      final response = await _client.rpc(
        'pwf_platform_center_content_upsert',
        params: draft.toLegacyRpcParams(),
      );
      return _writeResult(
        response,
        fallbackMessage:
            'تم حفظ المسودة عبر RPC التشغيلي القديم. طبّق SQL Mega L لتفعيل الحقول الإنتاجية.',
      );
    } on PostgrestException catch (error) {
      if (!_isMissingBackend(error.message)) {
        return PwfPlatformCenterContentWriteResult(
          success: false,
          messageAr: 'تعذر الحفظ: ${error.message}',
        );
      }
    } catch (error) {
      return PwfPlatformCenterContentWriteResult(
        success: false,
        messageAr: 'تعذر الحفظ: $error',
      );
    }
    return const PwfPlatformCenterContentWriteResult(
      success: false,
      isFallback: true,
      messageAr:
          'لم يتم تفعيل RPC pwf_platform_center_content_upsert بعد. الواجهة جاهزة، والحفظ الإنتاجي مؤجل حتى تطبيق SQL wrapper.',
    );
  }

  Future<PwfPlatformCenterContentWriteResult> transition({
    required String id,
    required String familyKey,
    required String action,
  }) async {
    final normalizedAction = action.trim().toLowerCase();
    if (normalizedAction == 'edit') {
      return const PwfPlatformCenterContentWriteResult(
        success: false,
        messageAr:
            'تحرير المحتوى يجب أن يفتح محرر التفاصيل ولا ينفذ انتقال سير عمل.',
      );
    }
    try {
      final response = await _client.rpc(
        'pwf_platform_center_content_transition',
        params: <String, dynamic>{
          'p_id': id,
          'p_family_key': familyKey.trim().replaceAll('-', '_'),
          'p_action': normalizedAction,
        },
      );
      return _writeResult(
        response,
        fallbackMessage: 'تم تنفيذ الإجراء عبر RPC التشغيلي.',
        fallbackId: id,
      );
    } on PostgrestException catch (error) {
      if (!_isMissingBackend(error.message)) {
        return PwfPlatformCenterContentWriteResult(
          success: false,
          messageAr: 'تعذر تنفيذ الإجراء: ${error.message}',
        );
      }
    } catch (error) {
      return PwfPlatformCenterContentWriteResult(
        success: false,
        messageAr: 'تعذر تنفيذ الإجراء: $error',
      );
    }
    return const PwfPlatformCenterContentWriteResult(
      success: false,
      isFallback: true,
      messageAr:
          'إجراء سير العمل مؤجل حتى تفعيل RPC pwf_platform_center_content_transition.',
    );
  }

  static PwfPlatformCenterContentWriteResult _writeResult(
    dynamic response, {
    required String fallbackMessage,
    String? fallbackId,
  }) {
    final isSuccess = _extractSuccess(response);
    return PwfPlatformCenterContentWriteResult(
      success: isSuccess,
      id: _extractId(response) ?? fallbackId,
      messageAr: _extractMessage(response) ?? fallbackMessage,
      isFallback: !isSuccess,
    );
  }

  static Map<String, dynamic> _compactParams(Map<String, dynamic> params) {
    final output = <String, dynamic>{};
    for (final entry in params.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      output[entry.key] = value;
    }
    return output;
  }

  static List<Map<String, dynamic>> _normalizeRows(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map>()
          .map(
            (row) => row.map((key, value) => MapEntry(key.toString(), value)),
          )
          .toList(growable: false);
    }
    if (response is Map) {
      final data = response['data'] ?? response['rows'] ?? response['items'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (row) => row.map((key, value) => MapEntry(key.toString(), value)),
            )
            .toList(growable: false);
      }
    }
    return const <Map<String, dynamic>>[];
  }

  static String? _extractId(dynamic response) {
    if (response is Map) {
      final value = response['id'] ?? response['content_id'];
      return value?.toString();
    }
    return null;
  }

  static bool _extractSuccess(dynamic response) {
    if (response is Map) {
      final value = response['success'];
      if (value is bool) return value;
      if (value != null) return value.toString().toLowerCase() == 'true';
    }
    return true;
  }

  static String? _extractMessage(dynamic response) {
    if (response is Map) {
      final value =
          response['message_ar'] ?? response['message'] ?? response['error'];
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  static bool _isMissingBackend(String message) {
    final lower = message.toLowerCase();
    return lower.contains('does not exist') ||
        lower.contains('could not find') ||
        lower.contains('schema cache') ||
        lower.contains('function') ||
        lower.contains('relation');
  }
}
