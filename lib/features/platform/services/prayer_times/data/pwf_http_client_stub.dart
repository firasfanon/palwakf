import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'pwf_http_client.dart';

class _IoClient implements PwfHttpClient {
  @override
  Future<String> get(String url, {Duration? timeout}) async {
    final uri = Uri.parse(url);
    final client = HttpClient();
    client.connectionTimeout = timeout;
    try {
      final req = await client.getUrl(uri);
      final res = timeout == null
          ? await req.close()
          : await req.close().timeout(timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw HttpException('HTTP ${res.statusCode} for $url');
      }
      final decoded = res.transform(const Utf8Decoder()).join();
      return timeout == null ? await decoded : await decoded.timeout(timeout);
    } finally {
      client.close(force: true);
    }
  }
}

PwfHttpClient createClient() => _IoClient();
