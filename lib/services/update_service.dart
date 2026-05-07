import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:orbita/models/app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const orbitaReleaseRepository = 'Gabrlie/Orbita';

class UpdateService {
  static const _apiUrl =
      'https://api.github.com/repos/$orbitaReleaseRepository/releases/latest';
  static const _cacheKey = 'update_cache';
  static const _cacheTimeKey = 'update_cache_time';
  static const _etagKey = 'update_etag';
  static const _autoCheckKey = 'update_auto_check';
  static const _skippedVersionKey = 'update_skipped_version';
  static const _cacheValidDuration = Duration(hours: 1);

  final Dio _dio;
  final SharedPreferences _prefs;

  UpdateService({Dio? dio, required SharedPreferences prefs})
    : _dio = dio ?? Dio(),
      _prefs = prefs;

  bool getAutoCheckEnabled() => _prefs.getBool(_autoCheckKey) ?? true;

  Future<void> setAutoCheckEnabled(bool enabled) async {
    await _prefs.setBool(_autoCheckKey, enabled);
  }

  String? getSkippedVersion() => _prefs.getString(_skippedVersionKey);

  Future<void> skipVersion(String version) async {
    await _prefs.setString(_skippedVersionKey, normalizeVersion(version));
  }

  Future<UpdateInfo?> autoCheck() async {
    if (!getAutoCheckEnabled()) return null;
    final info = await checkForUpdate(useCache: true);
    return info.hasUpdate ? info : null;
  }

  Future<UpdateInfo> checkForUpdate({bool useCache = false}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final currentBuild = packageInfo.buildNumber;
    if (useCache) {
      final cached = await _cachedInfo(currentVersion, currentBuild);
      if (cached != null) return cached;
    }
    final etag = _prefs.getString(_etagKey);
    final headers = <String, Object?>{
      'Accept': 'application/vnd.github+json',
      'User-Agent': 'Orbita-App',
      'X-GitHub-Api-Version': '2022-11-28',
    };
    if (etag != null) headers['If-None-Match'] = etag;
    final response = await _dio.get<Object?>(
      _apiUrl,
      options: Options(
        responseType: ResponseType.json,
        validateStatus: (status) => status == 200 || status == 304,
        headers: headers,
      ),
    );
    if (response.statusCode == 304) {
      final cached = await _cachedInfo(
        currentVersion,
        currentBuild,
        ignoreExpiry: true,
      );
      if (cached != null) {
        await _prefs.setInt(
          _cacheTimeKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        return cached;
      }
    }
    final newEtag = response.headers.value('etag');
    if (newEtag != null) await _prefs.setString(_etagKey, newEtag);
    final data = Map<String, Object?>.from(response.data as Map);
    final info = await parseRelease(
      data,
      currentVersion: currentVersion,
      currentBuild: currentBuild,
      skippedVersion: getSkippedVersion(),
    );
    await _cacheInfo(info);
    return info;
  }

  Future<UpdateInfo> parseRelease(
    Map<String, Object?> release, {
    required String currentVersion,
    required String currentBuild,
    String? skippedVersion,
  }) async {
    final tagName = release['tag_name'] as String? ?? '';
    final remoteVersion = normalizeVersion(tagName);
    final assets = parseAssets(release['assets'] as List? ?? const []);
    final architecture = await deviceArchitecture();
    final matchedAsset = architecture == null
        ? null
        : matchAssetForArchitecture(assets, architecture);
    final skipped =
        skippedVersion != null &&
        normalizeVersion(skippedVersion) == remoteVersion;
    final newer = compareVersions(remoteVersion, currentVersion) > 0;
    return UpdateInfo(
      currentVersion: currentVersion,
      currentBuild: currentBuild,
      remoteVersion: remoteVersion,
      tagName: tagName,
      releaseUrl: release['html_url'] as String? ?? '',
      releaseNotes: release['body'] as String? ?? '',
      hasUpdate: newer && !skipped,
      isSkipped: skipped,
      matchedAsset: matchedAsset,
      assets: assets,
    );
  }

  Future<String?> deviceArchitecture() async {
    if (!Platform.isAndroid) return null;
    try {
      final abis = (await DeviceInfoPlugin().androidInfo).supportedAbis;
      return matchSupportedAbi(abis);
    } catch (_) {
      return null;
    }
  }

  Future<UpdateInfo?> _cachedInfo(
    String currentVersion,
    String currentBuild, {
    bool ignoreExpiry = false,
  }) async {
    final raw = _prefs.getString(_cacheKey);
    final cachedAt = _prefs.getInt(_cacheTimeKey);
    if (raw == null || cachedAt == null) return null;
    if (!ignoreExpiry) {
      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(cachedAt),
      );
      if (age > _cacheValidDuration) return null;
    }
    try {
      final cached = UpdateInfo.fromJson(
        Map<String, Object?>.from(jsonDecode(raw) as Map),
      );
      final skipped =
          normalizeVersion(cached.remoteVersion) ==
          normalizeVersion(getSkippedVersion() ?? '');
      return UpdateInfo(
        currentVersion: currentVersion,
        currentBuild: currentBuild,
        remoteVersion: cached.remoteVersion,
        tagName: cached.tagName,
        releaseUrl: cached.releaseUrl,
        releaseNotes: cached.releaseNotes,
        hasUpdate:
            compareVersions(cached.remoteVersion, currentVersion) > 0 &&
            !skipped,
        isSkipped: skipped,
        matchedAsset: cached.matchedAsset,
        assets: cached.assets,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheInfo(UpdateInfo info) async {
    await _prefs.setString(_cacheKey, jsonEncode(info.toJson()));
    await _prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  static String normalizeVersion(String version) {
    final normalized = version.trim();
    final withoutPrefix = normalized.startsWith('v')
        ? normalized.substring(1)
        : normalized;
    return withoutPrefix.split('+').first;
  }

  static int compareVersions(String left, String right) {
    final leftParts = _versionParts(left);
    final rightParts = _versionParts(right);
    for (var i = 0; i < 3; i++) {
      final delta = leftParts[i].compareTo(rightParts[i]);
      if (delta != 0) return delta;
    }
    return 0;
  }

  static List<int> _versionParts(String value) {
    final core = normalizeVersion(value);
    final parts = core.split('.');
    return List<int>.generate(3, (index) {
      if (index >= parts.length) return 0;
      return int.tryParse(parts[index]) ?? 0;
    });
  }

  static List<ReleaseAsset> parseAssets(List<Object?> assets) {
    final sha256ByApk = <String, String>{};
    for (final asset in assets.whereType<Map>()) {
      final name = asset['name'] as String? ?? '';
      if (name.endsWith('.sha256')) {
        sha256ByApk[name.replaceAll('.sha256', '')] =
            asset['browser_download_url'] as String? ?? '';
      }
    }
    return assets
        .whereType<Map>()
        .map((asset) {
          final name = asset['name'] as String? ?? '';
          final architecture = extractArchitecture(name);
          if (!name.endsWith('.apk') || architecture == null) return null;
          return ReleaseAsset(
            name: name,
            architecture: architecture,
            downloadUrl: asset['browser_download_url'] as String? ?? '',
            sha256Url: sha256ByApk[name],
            size: asset['size'] as int? ?? 0,
          );
        })
        .whereType<ReleaseAsset>()
        .toList();
  }

  static String? extractArchitecture(String fileName) {
    const architectures = ['arm64-v8a', 'armeabi-v7a', 'x86_64'];
    for (final architecture in architectures) {
      if (fileName.contains(architecture)) return architecture;
    }
    return null;
  }

  static ReleaseAsset? matchAssetForArchitecture(
    List<ReleaseAsset> assets,
    String architecture,
  ) {
    for (final asset in assets) {
      if (asset.architecture == architecture) return asset;
    }
    return null;
  }

  static String? matchSupportedAbi(List<String> supportedAbis) {
    const supported = ['arm64-v8a', 'armeabi-v7a', 'x86_64'];
    for (final supportedAbi in supported) {
      if (supportedAbis.contains(supportedAbi)) return supportedAbi;
    }
    if (supportedAbis.contains('x86')) return 'x86_64';
    return null;
  }

  static String? parseSha256(String text) {
    final match = RegExp(r'^[a-fA-F0-9]{64}').firstMatch(text.trim());
    return match?.group(0)?.toLowerCase();
  }
}
