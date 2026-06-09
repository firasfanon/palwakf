import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'visual_identity_contract.dart';
import 'visual_identity_registry.dart';

const String kPwfVisualIdentityContractSlug = '__visual_identity_contract__';

class PwfVisualIdentityPublishHistoryEntry {
  const PwfVisualIdentityPublishHistoryEntry({
    required this.contextKey,
    required this.presetId,
    required this.action,
    required this.note,
    required this.actedAt,
    required this.actorLabel,
  });

  final String contextKey;
  final String presetId;
  final String action;
  final String note;
  final DateTime actedAt;
  final String actorLabel;

  factory PwfVisualIdentityPublishHistoryEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    return PwfVisualIdentityPublishHistoryEntry(
      contextKey: (json['context_key'] ?? '').toString(),
      presetId: (json['preset_id'] ?? '').toString(),
      action: (json['action'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      actedAt:
          DateTime.tryParse((json['acted_at'] ?? '').toString()) ??
          DateTime.now(),
      actorLabel: (json['actor_label'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'context_key': contextKey,
    'preset_id': presetId,
    'action': action,
    'note': note,
    'acted_at': actedAt.toUtc().toIso8601String(),
    'actor_label': actorLabel,
  };
}

class PwfVisualIdentityPublishState {
  const PwfVisualIdentityPublishState({
    required this.publishedByContext,
    required this.history,
    this.updatedAt,
  });

  final Map<String, String> publishedByContext;
  final List<PwfVisualIdentityPublishHistoryEntry> history;
  final DateTime? updatedAt;

  const PwfVisualIdentityPublishState.empty()
    : publishedByContext = const <String, String>{},
      history = const <PwfVisualIdentityPublishHistoryEntry>[],
      updatedAt = null;

  factory PwfVisualIdentityPublishState.fromJson(Map<String, dynamic> json) {
    final publishedRaw = json['published_by_context'];
    final historyRaw = json['history'];
    return PwfVisualIdentityPublishState(
      publishedByContext: publishedRaw is Map
          ? Map<String, String>.fromEntries(
              publishedRaw.entries.map(
                (e) => MapEntry(e.key.toString(), (e.value ?? '').toString()),
              ),
            )
          : const <String, String>{},
      history: historyRaw is List
          ? historyRaw
                .whereType<Map>()
                .map(
                  (e) => PwfVisualIdentityPublishHistoryEntry.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList(growable: false)
          : const <PwfVisualIdentityPublishHistoryEntry>[],
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'published_by_context': publishedByContext,
    'history': history.map((e) => e.toJson()).toList(growable: false),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
  };

  List<PwfVisualIdentityPublishHistoryEntry> historyForContext(
    String contextKey,
  ) {
    return history
        .where((e) => e.contextKey == contextKey)
        .toList(growable: false);
  }
}

class PwfVisualIdentityPublishRepository {
  const PwfVisualIdentityPublishRepository(this._client);

  final SupabaseClient _client;

  // Public-schema Phase 1 remediation. Runtime reads use the approved
  // compatibility wrapper; admin writes remain on the preserved legacy table
  // until owner-write RPC migration is explicitly approved for this surface.
  static const String _sitePagesReadSurface = 'v_platform_site_pages_compat_v1';
  static const String _sitePagesLegacyWriteTable = 'site_pages';

  Future<PwfVisualIdentityPublishState> fetchState() async {
    final row = await _client
        .from(_sitePagesReadSurface)
        .select('id,body_en,updated_at')
        .eq('slug', kPwfVisualIdentityContractSlug)
        .filter('unit_id', 'is', null)
        .maybeSingle();

    if (row == null) {
      return const PwfVisualIdentityPublishState.empty();
    }

    final meta = _decodeMeta(row['body_en']);
    final state = PwfVisualIdentityPublishState.fromJson(meta);
    return PwfVisualIdentityPublishState(
      publishedByContext: state.publishedByContext,
      history: state.history,
      updatedAt: DateTime.tryParse(
        (row['updated_at'] ?? meta['updated_at'] ?? '').toString(),
      ),
    );
  }

  Future<PwfVisualIdentityPublishState> publishPreset({
    required PwfVisualPreset preset,
    required String note,
    required String actorLabel,
  }) async {
    final current = await fetchState();
    final nextPublished = <String, String>{...current.publishedByContext};
    nextPublished[preset.context.key] = preset.id;

    final nextHistory = <PwfVisualIdentityPublishHistoryEntry>[
      ...current.history,
      PwfVisualIdentityPublishHistoryEntry(
        contextKey: preset.context.key,
        presetId: preset.id,
        action: 'publish',
        note: note.trim(),
        actedAt: DateTime.now(),
        actorLabel: actorLabel.trim().isEmpty
            ? _defaultActorLabel
            : actorLabel.trim(),
      ),
    ];

    final next = PwfVisualIdentityPublishState(
      publishedByContext: nextPublished,
      history: nextHistory,
      updatedAt: DateTime.now(),
    );
    await _saveState(next);
    return next;
  }

  Future<PwfVisualIdentityPublishState> rollbackContext({
    required PwfVisualContext context,
    required String note,
    required String actorLabel,
  }) async {
    final current = await fetchState();
    final currentId = current.publishedByContext[context.key];
    final contextHistory = current
        .historyForContext(context.key)
        .reversed
        .toList(growable: false);

    String targetId = PwfVisualIdentityRegistry.defaults
        .firstWhere(
          (item) => item.context == context,
          orElse: () => PwfVisualIdentityRegistry.defaults.first,
        )
        .id;

    for (final entry in contextHistory) {
      if (entry.presetId.isNotEmpty && entry.presetId != currentId) {
        targetId = entry.presetId;
        break;
      }
    }

    final nextPublished = <String, String>{...current.publishedByContext};
    nextPublished[context.key] = targetId;

    final nextHistory = <PwfVisualIdentityPublishHistoryEntry>[
      ...current.history,
      PwfVisualIdentityPublishHistoryEntry(
        contextKey: context.key,
        presetId: targetId,
        action: 'rollback',
        note: note.trim(),
        actedAt: DateTime.now(),
        actorLabel: actorLabel.trim().isEmpty
            ? _defaultActorLabel
            : actorLabel.trim(),
      ),
    ];

    final next = PwfVisualIdentityPublishState(
      publishedByContext: nextPublished,
      history: nextHistory,
      updatedAt: DateTime.now(),
    );
    await _saveState(next);
    return next;
  }

  Future<PwfVisualIdentityPublishState> rollbackContextToPreset({
    required PwfVisualContext context,
    required String presetId,
    required String note,
    required String actorLabel,
  }) async {
    final current = await fetchState();
    final nextPublished = <String, String>{...current.publishedByContext};
    nextPublished[context.key] = presetId;

    final nextHistory = <PwfVisualIdentityPublishHistoryEntry>[
      ...current.history,
      PwfVisualIdentityPublishHistoryEntry(
        contextKey: context.key,
        presetId: presetId,
        action: 'rollback_to_version',
        note: note.trim(),
        actedAt: DateTime.now(),
        actorLabel: actorLabel.trim().isEmpty
            ? _defaultActorLabel
            : actorLabel.trim(),
      ),
    ];

    final next = PwfVisualIdentityPublishState(
      publishedByContext: nextPublished,
      history: nextHistory,
      updatedAt: DateTime.now(),
    );
    await _saveState(next);
    return next;
  }

  String get _defaultActorLabel {
    final email = _client.auth.currentUser?.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    return 'بوابة إدارة المنصة';
  }

  Future<void> _saveState(PwfVisualIdentityPublishState state) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final meta = state.toJson();
    meta['saved_by_user_id'] = _client.auth.currentUser?.id;
    meta['saved_by_email'] = _client.auth.currentUser?.email;
    meta['saved_at'] = nowIso;

    final payload = <String, dynamic>{
      'slug': kPwfVisualIdentityContractSlug,
      'title_ar': 'عقد النشر الفعلي للهوية البصرية',
      'title_en': 'Visual Identity Publish Contract',
      'subtitle_ar': 'PalWakf Visual Identity Publish Contract',
      'subtitle_en': 'PalWakf Visual Identity Publish Contract',
      'body_ar': 'عقد تشغيلي موضعي لنشر/رجوع الهوية البصرية داخل PalWakf.',
      'body_en': jsonEncode(meta),
      'is_published': true,
      'updated_at': nowIso,
      'unit_id': null,
    };

    final existing = await _client
        .from(_sitePagesReadSurface)
        .select('id')
        .eq('slug', kPwfVisualIdentityContractSlug)
        .filter('unit_id', 'is', null)
        .maybeSingle();

    final existingId = (existing?['id'] ?? '').toString().trim();
    if (existingId.isEmpty) {
      await _client.from(_sitePagesLegacyWriteTable).insert(payload);
    } else {
      await _client
          .from(_sitePagesLegacyWriteTable)
          .update(payload)
          .eq('id', existingId);
    }
  }

  Map<String, dynamic> _decodeMeta(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return const <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return const <String, dynamic>{};
  }
}
