import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';

class SecureStorageService {
  static const _serversKey = 'orbita_servers';
  static const _keysKey = 'orbita_ssh_keys';
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  // -- Servers --

  Future<List<Server>> loadServers() async {
    final raw = await _storage.read(key: _serversKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Server.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveServers(List<Server> servers) async {
    final json = jsonEncode(servers.map((s) => s.toJson()).toList());
    await _storage.write(key: _serversKey, value: json);
  }

  // -- SSH Keys --

  Future<List<SshKey>> loadKeys() async {
    final raw = await _storage.read(key: _keysKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SshKey.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveKeys(List<SshKey> keys) async {
    final json = jsonEncode(keys.map((k) => k.toJson()).toList());
    await _storage.write(key: _keysKey, value: json);
  }
}
