
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final env = _loadEnv();
  final url = _required(env, ['SUPABASE_URL', 'VITE_SUPABASE_URL']);
  final anonKey = _required(env, [
    'SUPABASE_ANON_KEY',
    'VITE_SUPABASE_ANON_KEY',
    'SUPABASE_PUBLIC_ANON_KEY',
  ]);

  // Optional authenticated user token. Do NOT use service_role here.
  // Use a normal authenticated admin/super-admin access token when testing
  // protected RPCs such as platform technical services.
  final accessToken = _optional(env, [
    'SUPABASE_ACCESS_TOKEN',
    'PALWAKF_SMOKE_ACCESS_TOKEN',
    'PALWAKF_ADMIN_ACCESS_TOKEN',
  ]);

  final runner = _SmokeRunner(
    url: url,
    anonKey: anonKey,
    accessToken: accessToken,
  );

  await runner.get(
    id: 'SMK-05',
    label: 'Media Center public news compat view',
    path: '/rest/v1/v_media_news_compat_v1?select=*&limit=1',
  );

  await runner.get(
    id: 'SMK-06',
    label: 'Media Center public announcements compat view',
    path: '/rest/v1/v_media_announcements_compat_v1?select=*&limit=1',
  );

  await runner.get(
    id: 'SMK-07',
    label: 'Media Center public activities compat view',
    path: '/rest/v1/v_media_activities_compat_v1?select=*&limit=1',
  );

  await runner.postProtected(
    id: 'SMK-08',
    label: 'Technical Services dashboard RPC',
    path: '/rest/v1/rpc/rpc_platform_technical_services_dashboard_v1',
    body: const <String, dynamic>{},
    protectedAuthCode: 'PLATFORM_TECHNICAL_AUTH_REQUIRED',
  );

  runner.printSummary();

  if (runner.failed > 0) {
    exitCode = 1;
  }
}

class _SmokeRunner {
  _SmokeRunner({
    required this.url,
    required this.anonKey,
    required this.accessToken,
  });

  final String url;
  final String anonKey;
  final String? accessToken;

  int passed = 0;
  int failed = 0;
  int skipped = 0;

  Future<void> get({
    required String id,
    required String label,
    required String path,
  }) async {
    await _request(
      id: id,
      label: label,
      method: 'GET',
      path: path,
      token: anonKey,
      protectedAuthCode: null,
      allowProtectedSkip: false,
    );
  }

  Future<void> post({
    required String id,
    required String label,
    required String path,
    required Map<String, dynamic> body,
  }) async {
    await _request(
      id: id,
      label: label,
      method: 'POST',
      path: path,
      body: body,
      token: anonKey,
      protectedAuthCode: null,
      allowProtectedSkip: false,
    );
  }

  Future<void> postProtected({
    required String id,
    required String label,
    required String path,
    required Map<String, dynamic> body,
    required String protectedAuthCode,
  }) async {
    await _request(
      id: id,
      label: label,
      method: 'POST',
      path: path,
      body: body,
      token: accessToken ?? anonKey,
      protectedAuthCode: protectedAuthCode,
      allowProtectedSkip: accessToken == null,
    );
  }

  Future<void> _request({
    required String id,
    required String label,
    required String method,
    required String path,
    required String token,
    required String? protectedAuthCode,
    required bool allowProtectedSkip,
    Map<String, dynamic>? body,
  }) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('${url.replaceAll(RegExp(r"/+$"), "")}$path');
      final request = method == 'POST'
          ? await client.postUrl(uri)
          : await client.getUrl(uri);

      request.headers.set('apikey', anonKey);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Accept', 'application/json');
      if (method == 'POST') {
        request.headers.set('Content-Type', 'application/json');
        request.write(jsonEncode(body ?? const <String, dynamic>{}));
      }

      final response = await request.close();
      final responseBody = await utf8.decodeStream(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        passed += 1;
        stdout.writeln('PASS $id — $label — HTTP ${response.statusCode}');
        return;
      }

      if (allowProtectedSkip &&
          response.statusCode == 401 &&
          protectedAuthCode != null &&
          responseBody.contains(protectedAuthCode)) {
        skipped += 1;
        stdout.writeln(
          'SKIP $id — $label — protected RPC requires authenticated admin token '
          '($protectedAuthCode)',
        );
        stdout.writeln(
          '     Provide SUPABASE_ACCESS_TOKEN / PALWAKF_SMOKE_ACCESS_TOKEN '
          'to validate this check as HTTP 200.',
        );
        return;
      }

      failed += 1;
      stdout.writeln('FAIL $id — $label — HTTP ${response.statusCode}');
      stdout.writeln(responseBody);
    } catch (e) {
      failed += 1;
      stdout.writeln('FAIL $id — $label — $e');
    } finally {
      client.close(force: true);
    }
  }

  void printSummary() {
    stdout.writeln('');
    stdout.writeln(
      'PalWakf smoke summary: passed=$passed skipped=$skipped failed=$failed',
    );
  }
}

Map<String, String> _loadEnv() {
  final result = <String, String>{...Platform.environment};
  final envFile = File('.env');
  if (!envFile.existsSync()) return result;

  for (final line in envFile.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final index = trimmed.indexOf('=');
    if (index <= 0) continue;
    final key = trimmed.substring(0, index).trim();
    final value = trimmed.substring(index + 1).trim();
    result[key] = value;
  }

  return result;
}

String _required(Map<String, String> env, List<String> keys) {
  for (final key in keys) {
    final value = env[key]?.trim();
    if (value != null && value.isNotEmpty) return value;
  }
  throw StateError('Missing required environment variable. Tried: ${keys.join(", ")}');
}

String? _optional(Map<String, String> env, List<String> keys) {
  for (final key in keys) {
    final value = env[key]?.trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}
