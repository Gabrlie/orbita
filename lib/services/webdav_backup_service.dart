import 'dart:convert';
import 'dart:io';

class WebDavBackupService {
  final HttpClient _client;

  WebDavBackupService([HttpClient? client]) : _client = client ?? HttpClient();

  Future<void> test({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    final request = await _open(
      method: 'OPTIONS',
      baseUrl: baseUrl,
      username: username,
      password: password,
    );
    final response = await request.close();
    await response.drain<void>();
    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw WebDavException(response.statusCode);
    }
  }

  Future<void> upload({
    required String baseUrl,
    required String remotePath,
    required String username,
    required String password,
    required String content,
  }) async {
    final request = await _open(
      method: 'PUT',
      baseUrl: baseUrl,
      remotePath: remotePath,
      username: username,
      password: password,
    );
    final bytes = utf8.encode(content);
    request.headers.contentType = ContentType.json;
    request.headers.contentLength = bytes.length;
    request.add(bytes);
    final response = await request.close();
    await response.drain<void>();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WebDavException(response.statusCode);
    }
  }

  Future<String> download({
    required String baseUrl,
    required String remotePath,
    required String username,
    required String password,
  }) async {
    final request = await _open(
      method: 'GET',
      baseUrl: baseUrl,
      remotePath: remotePath,
      username: username,
      password: password,
    );
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      await response.drain<void>();
      throw WebDavException(response.statusCode);
    }
    return utf8.decode(await response.expand((chunk) => chunk).toList());
  }

  Future<HttpClientRequest> _open({
    required String method,
    required String baseUrl,
    required String username,
    required String password,
    String remotePath = '',
  }) async {
    final uri = _resolve(baseUrl, remotePath);
    final request = await _client.openUrl(method, uri);
    final credentials = base64Encode(utf8.encode('$username:$password'));
    request.headers.set(HttpHeaders.authorizationHeader, 'Basic $credentials');
    request.headers.set(HttpHeaders.userAgentHeader, 'Orbita');
    return request;
  }

  Uri _resolve(String baseUrl, String remotePath) {
    final base = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');
    final path = remotePath.startsWith('/')
        ? remotePath.substring(1)
        : remotePath;
    return base.resolve(path);
  }
}

class WebDavException implements Exception {
  final int statusCode;

  const WebDavException(this.statusCode);

  @override
  String toString() => 'WebDAV request failed: HTTP $statusCode';
}
