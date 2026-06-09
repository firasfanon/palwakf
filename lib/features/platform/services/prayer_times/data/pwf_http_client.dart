import 'pwf_http_client_stub.dart'
    if (dart.library.html) 'pwf_http_client_web.dart';

abstract class PwfHttpClient {
  Future<String> get(String url, {Duration? timeout});
}

PwfHttpClient createPwfHttpClient() => createClient();
