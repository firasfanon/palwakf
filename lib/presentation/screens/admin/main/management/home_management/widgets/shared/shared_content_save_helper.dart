class SharedContentSaveHelper {
  static Future<void> saveWithOptionalColumns({
    required dynamic supabase,
    required String table,
    required Map<String, dynamic> basePayload,
    Map<String, dynamic> optionalPayload = const <String, dynamic>{},
    int? existingId,
  }) async {
    final current = <String, dynamic>{...basePayload, ...optionalPayload};
    final optionalKeys = optionalPayload.keys.toList(growable: false);

    while (true) {
      try {
        if (existingId == null) {
          await supabase.from(table).insert(current);
        } else {
          await supabase.from(table).update(current).eq('id', existingId);
        }
        return;
      } catch (e) {
        final message = e.toString().toLowerCase();
        final unsupported = optionalKeys
            .where((key) {
              final normalized = key.toLowerCase();
              return current.containsKey(key) &&
                  (message.contains('column "$normalized"') ||
                      message.contains("column '$normalized'") ||
                      message.contains('column $normalized') ||
                      message.contains(normalized));
            })
            .toList(growable: false);

        if (unsupported.isEmpty) rethrow;
        for (final key in unsupported) {
          current.remove(key);
        }
      }
    }
  }
}
