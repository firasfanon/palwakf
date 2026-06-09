class UserSessionLogItem {
  final String id;
  final String status;
  final String? systemKey;
  final String? userAgent;
  final String? ipAddress;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isCurrent;

  const UserSessionLogItem({
    required this.id,
    required this.status,
    required this.startedAt,
    this.systemKey,
    this.userAgent,
    this.ipAddress,
    this.endedAt,
    this.isCurrent = false,
  });

  factory UserSessionLogItem.fromJson(Map<String, dynamic> json) {
    final startedAtRaw = (json['started_at'] ?? json['created_at'] ?? '')
        .toString();
    final endedAtRaw = (json['ended_at'] ?? '').toString();

    return UserSessionLogItem(
      id: (json['id'] ?? '').toString(),
      status: (json['status'] ?? json['session_status'] ?? 'active').toString(),
      systemKey: _readString(json, ['system_key', 'last_system_key']),
      userAgent: _readString(json, ['user_agent']),
      ipAddress: _readString(json, ['ip_address', 'ip']),
      startedAt: DateTime.tryParse(startedAtRaw) ?? DateTime.now(),
      endedAt: endedAtRaw.isEmpty ? null : DateTime.tryParse(endedAtRaw),
      isCurrent: json['is_current'] == true,
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
