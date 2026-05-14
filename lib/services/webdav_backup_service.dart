import 'dart:convert';
import 'dart:io';

import 'package:orbita/models/backup_models.dart';
import 'package:orbita/services/backup_file_service.dart';
import 'package:xml/xml.dart';

class WebDavBackupService {
  final HttpClient _client;
  final BackupFileService _fileService;

  WebDavBackupService({
    HttpClient? client,
    BackupFileService fileService = const BackupFileService(),
  }) : _client = client ?? HttpClient(),
       _fileService = fileService;

  Future<void> testFolder({
    required String baseUrl,
    required String remoteFolder,
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
    await _ensureFolder(
      baseUrl: baseUrl,
      remoteFolder: remoteFolder,
      username: username,
      password: password,
    );
  }

  Future<List<BackupEntry>> listBackups({
    required String baseUrl,
    required String remoteFolder,
    required String username,
    required String password,
  }) async {
    final request = await _open(
      method: 'PROPFIND',
      baseUrl: baseUrl,
      remotePath: remoteFolder,
      username: username,
      password: password,
    );
    request.headers.set('Depth', '1');
    request.headers.contentType = ContentType('application', 'xml');
    request.write(
      '<?xml version="1.0" encoding="utf-8" ?>'
      '<d:propfind xmlns:d="DAV:"><d:allprop /></d:propfind>',
    );
    final response = await request.close();
    final body = utf8.decode(await response.expand((chunk) => chunk).toList());
    if (response.statusCode == 404) return const [];
    if (response.statusCode != 207) throw WebDavException(response.statusCode);
    return _parseEntries(body, remoteFolder);
  }

  Future<void> uploadBackup({
    required String baseUrl,
    required String remoteFolder,
    required String fileName,
    required String username,
    required String password,
    required String content,
  }) async {
    await _ensureFolder(
      baseUrl: baseUrl,
      remoteFolder: remoteFolder,
      username: username,
      password: password,
    );
    final request = await _open(
      method: 'PUT',
      baseUrl: baseUrl,
      remotePath: joinRemotePath(remoteFolder, fileName),
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

  Future<void> delete({
    required String baseUrl,
    required String remotePath,
    required String username,
    required String password,
  }) async {
    final request = await _open(
      method: 'DELETE',
      baseUrl: baseUrl,
      remotePath: remotePath,
      username: username,
      password: password,
    );
    final response = await request.close();
    await response.drain<void>();
    if (response.statusCode == 404) return;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WebDavException(response.statusCode);
    }
  }

  String joinRemotePath(String folder, String name) {
    final base = folder.trim().isEmpty ? '/orbita' : folder.trim();
    final normalized = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    return '$normalized/$name';
  }

  Future<void> pruneBackups({
    required String baseUrl,
    required String remoteFolder,
    required String username,
    required String password,
    required int retentionCount,
    String? deviceName,
  }) async {
    final stale = _fileService.entriesToDelete(
      await listBackups(
        baseUrl: baseUrl,
        remoteFolder: remoteFolder,
        username: username,
        password: password,
      ),
      retentionCount,
      deviceName: deviceName,
    );
    for (final entry in stale) {
      await delete(
        baseUrl: baseUrl,
        remotePath: entry.path,
        username: username,
        password: password,
      );
    }
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
    final absolute = Uri.tryParse(remotePath);
    if (absolute != null && absolute.hasScheme) return absolute;
    final base = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');
    final path = remotePath.startsWith('/')
        ? remotePath.substring(1)
        : remotePath;
    return base.resolve(path);
  }

  Future<void> _ensureFolder({
    required String baseUrl,
    required String remoteFolder,
    required String username,
    required String password,
  }) async {
    final folder = remoteFolder.trim().isEmpty ? '/orbita' : remoteFolder;
    final segments = folder
        .split('/')
        .where((segment) => segment.trim().isNotEmpty)
        .toList();
    var current = '';
    for (final segment in segments) {
      current = current.isEmpty ? '/$segment' : '$current/$segment';
      final request = await _open(
        method: 'MKCOL',
        baseUrl: baseUrl,
        remotePath: current,
        username: username,
        password: password,
      );
      final response = await request.close();
      await response.drain<void>();
      if (response.statusCode == 405) continue;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw WebDavException(response.statusCode);
      }
    }
  }

  List<BackupEntry> _parseEntries(String body, String remoteFolder) {
    final document = XmlDocument.parse(body);
    final entries = <BackupEntry>[];
    for (final response in document.descendants.whereType<XmlElement>()) {
      if (response.name.local != 'response') continue;
      final href = _firstLocalText(response, 'href');
      if (href == null) continue;
      final name = Uri.decodeComponent(Uri.parse(href).pathSegments.last);
      if (!_fileService.isBackupName(name)) continue;
      if (_hasLocalElement(response, 'collection')) continue;
      final modifiedAt = _parseHttpDate(
        _firstLocalText(response, 'getlastmodified'),
      );
      entries.add(
        BackupEntry(
          location: BackupLocation.webdav,
          name: name,
          path: joinRemotePath(remoteFolder, name),
          modifiedAt: modifiedAt,
        ),
      );
    }
    return _fileService.sortNewestFirst(entries);
  }

  String? _firstLocalText(XmlElement root, String localName) {
    for (final element in root.descendants.whereType<XmlElement>()) {
      if (element.name.local == localName) return element.innerText;
    }
    return null;
  }

  bool _hasLocalElement(XmlElement root, String localName) {
    for (final element in root.descendants.whereType<XmlElement>()) {
      if (element.name.local == localName) return true;
    }
    return false;
  }

  DateTime _parseHttpDate(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    try {
      return HttpDate.parse(value);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}

class WebDavException implements Exception {
  final int statusCode;

  const WebDavException(this.statusCode);

  @override
  String toString() => 'WebDAV request failed: HTTP $statusCode';
}
