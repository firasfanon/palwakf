class UserActivityLogItem {
  final String id;
  final String? systemKey;
  final String title;
  final String? route;
  final String? entityType;
  final String? entityId;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const UserActivityLogItem({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    this.systemKey,
    this.route,
    this.entityType,
    this.entityId,
    this.metadata = const {},
  });

  factory UserActivityLogItem.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    final createdAtRaw = json['created_at'];
    if (createdAtRaw is String && createdAtRaw.isNotEmpty) {
      createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return UserActivityLogItem(
      id: (json['id'] ?? '').toString(),
      systemKey: _readString(json, ['system_key', 'system', 'source_system']),
      title:
          _readString(json, [
            'title',
            'message',
            'action_label',
            'action_key',
          ]) ??
          'نشاط غير معنون',
      route: _readString(json, ['route', 'page_route', 'path']),
      entityType: _readString(json, ['entity_type']),
      entityId: _readString(json, ['entity_id']),
      status: _readString(json, ['status', 'result']) ?? 'success',
      createdAt: createdAt,
      metadata: json['metadata_json'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata_json'] as Map)
          : const {},
    );
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}
