
import 'package:waqf/core/contracts/cms_payload_contracts.dart';

/// Shared save helper for legacy CMS public tables.
///
/// CMS writes currently use direct Supabase REST table access for simple
/// create/update operations. This helper enforces DTO/schema validation before
/// the write request reaches PostgREST.
///
/// Governed actions such as publish/transition/decision should use RPC.
class SharedContentSaveHelper {
  static Future<void> saveWithOptionalColumns({
    required dynamic supabase,
    required String table,
    required Map<String, dynamic> basePayload,
    Map<String, dynamic> optionalPayload = const <String, dynamic>{},
    int? existingId,
  }) async {
    final combined = <String, dynamic>{...basePayload, ...optionalPayload};
    final contractResult = CmsPayloadContracts.sanitizeTablePayload(
      table,
      combined,
    );
    final current = <String, dynamic>{...contractResult.payload};

    var attempts = 0;
    final removedColumns = <String>{...contractResult.strippedFields};

    while (true) {
      attempts += 1;
      try {
        if (existingId == null) {
          await supabase.from(table).insert(current);
        } else {
          await supabase.from(table).update(current).eq('id', existingId);
        }
        return;
      } catch (e) {
        final message = e.toString();

        final unsupported = _unsupportedColumnsFromError(
          payload: current,
          errorMessage: message,
        );

        if (unsupported.isEmpty) rethrow;

        var removedAny = false;
        for (final key in unsupported) {
          if (current.containsKey(key)) {
            current.remove(key);
            removedColumns.add(key);
            removedAny = true;
          }
        }

        if (!removedAny) rethrow;

        if (attempts > 12 || removedColumns.length > 12) {
          final removedColumnsText = removedColumns.join(', ');
          throw StateError(
            'CMS save aborted after removing unsupported columns for '
            '$table: $removedColumnsText. Last error: $message',
          );
        }
      }
    }
  }

  static List<String> _unsupportedColumnsFromError({
    required Map<String, dynamic> payload,
    required String errorMessage,
  }) {
    final lower = errorMessage.toLowerCase();
    final matches = <String>{};

    final quotedColumnPattern = RegExp(
      r'''['"]([a-zA-Z_][a-zA-Z0-9_]*)['"]\s+column''',
      caseSensitive: false,
    );

    for (final match in quotedColumnPattern.allMatches(errorMessage)) {
      final column = match.group(1);
      if (column != null && payload.containsKey(column)) {
        matches.add(column);
      }
    }

    for (final key in payload.keys) {
      final normalized = key.toLowerCase();
      if (lower.contains("column '$normalized'") ||
          lower.contains('column "$normalized"') ||
          lower.contains('column $normalized') ||
          lower.contains("'$normalized' column") ||
          lower.contains('"$normalized" column')) {
        matches.add(key);
      }
    }

    return matches.toList(growable: false);
  }
}
