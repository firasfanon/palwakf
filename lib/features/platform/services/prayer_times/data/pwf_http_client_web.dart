// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

import 'pwf_http_client.dart';

class _WebClient implements PwfHttpClient {
  @override
  Future<String> get(String url, {Duration? timeout}) {
    final request = html.HttpRequest.getString(url);
    return timeout == null ? request : request.timeout(timeout);
  }
}

PwfHttpClient createClient() => _WebClient();
