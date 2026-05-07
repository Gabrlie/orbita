import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/app_update.dart';
import 'package:orbita/services/update_service.dart';

void main() {
  test('compares semantic versions without build suffix', () {
    expect(UpdateService.compareVersions('1.0.1', '1.0.0+1'), greaterThan(0));
    expect(UpdateService.compareVersions('v1.0.1', '1.0.1+2'), 0);
    expect(UpdateService.compareVersions('1.2.0', '1.10.0'), lessThan(0));
  });

  test('parses release assets and matches device architecture', () {
    final assets = UpdateService.parseAssets([
      {
        'name': 'orbita-1.0.1-android-arm64-v8a.apk',
        'browser_download_url': 'https://example.com/arm64.apk',
        'size': 10,
      },
      {
        'name': 'orbita-1.0.1-android-arm64-v8a.apk.sha256',
        'browser_download_url': 'https://example.com/arm64.apk.sha256',
        'size': 1,
      },
      {
        'name': 'orbita-1.0.1-android-x86_64.apk',
        'browser_download_url': 'https://example.com/x64.apk',
        'size': 20,
      },
    ]);

    expect(assets, hasLength(2));
    final matched = UpdateService.matchAssetForArchitecture(
      assets,
      'arm64-v8a',
    );

    expect(matched, isNotNull);
    expect(matched!.sha256Url, 'https://example.com/arm64.apk.sha256');
    expect(UpdateService.matchSupportedAbi(['arm64-v8a']), 'arm64-v8a');
  });

  test('parses sha256 files with filename suffixes', () {
    final hash = 'A' * 64;
    expect(UpdateService.parseSha256('$hash  orbita.apk'), hash.toLowerCase());
    expect(UpdateService.parseSha256('not-a-hash'), isNull);
  });

  test('update info respects skipped version', () {
    const info = UpdateInfo(
      currentVersion: '1.0.0',
      currentBuild: '1',
      remoteVersion: '1.0.1',
      tagName: 'v1.0.1',
      releaseUrl: 'https://github.com/Gabrlie/Orbita/releases/tag/v1.0.1',
      releaseNotes: '',
      hasUpdate: false,
      isSkipped: true,
    );

    expect(info.hasUpdate, isFalse);
    expect(info.isSkipped, isTrue);
  });
}
