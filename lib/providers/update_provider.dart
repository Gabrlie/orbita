import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/app_update.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/services/update_download_service.dart';
import 'package:orbita/services/update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService(prefs: ref.read(sharedPrefsProvider));
});

final updateDownloadServiceProvider = Provider<UpdateDownloadService>((ref) {
  return UpdateDownloadService();
});

final appUpdateProvider = AsyncNotifierProvider<AppUpdateNotifier, UpdateState>(
  AppUpdateNotifier.new,
);

class AppUpdateNotifier extends AsyncNotifier<UpdateState> {
  @override
  Future<UpdateState> build() async {
    final service = ref.read(updateServiceProvider);
    unawaited(_autoCheck());
    return UpdateState(autoCheckEnabled: service.getAutoCheckEnabled());
  }

  Future<void> setAutoCheckEnabled(bool enabled) async {
    await ref.read(updateServiceProvider).setAutoCheckEnabled(enabled);
    state = AsyncData(_current().copyWith(autoCheckEnabled: enabled));
  }

  Future<void> check({bool manual = true}) async {
    state = AsyncData(
      _current().copyWith(checking: true, info: () => null, error: () => null),
    );
    try {
      final info = await ref
          .read(updateServiceProvider)
          .checkForUpdate(useCache: !manual);
      state = AsyncData(
        _current().copyWith(
          checking: false,
          info: () => info,
          error: () => null,
        ),
      );
    } catch (error) {
      state = AsyncData(
        _current().copyWith(
          checking: false,
          info: () => null,
          error: () => _formatError(error),
        ),
      );
    }
  }

  Future<void> skipCurrentVersion() async {
    final info = _current().info;
    if (info == null) return;
    await ref.read(updateServiceProvider).skipVersion(info.remoteVersion);
    state = AsyncData(
      _current().copyWith(
        info: () => UpdateInfo(
          currentVersion: info.currentVersion,
          currentBuild: info.currentBuild,
          remoteVersion: info.remoteVersion,
          tagName: info.tagName,
          releaseUrl: info.releaseUrl,
          releaseNotes: info.releaseNotes,
          hasUpdate: false,
          isSkipped: true,
          matchedAsset: info.matchedAsset,
          assets: info.assets,
        ),
      ),
    );
  }

  Future<void> downloadMatchedAsset() async {
    final asset = _current().info?.matchedAsset;
    if (asset == null) return;
    await for (final progress
        in ref.read(updateDownloadServiceProvider).downloadAndInstall(asset)) {
      state = AsyncData(_current().copyWith(download: progress));
      if (progress.status == UpdateDownloadStatus.error) return;
    }
  }

  void cancelDownload() {
    ref.read(updateDownloadServiceProvider).cancel();
    state = AsyncData(
      _current().copyWith(
        download: const UpdateDownloadProgress(
          status: UpdateDownloadStatus.idle,
        ),
      ),
    );
  }

  Future<void> _autoCheck() async {
    try {
      final info = await ref.read(updateServiceProvider).autoCheck();
      if (info == null) return;
      state = AsyncData(_current().copyWith(info: () => info));
    } catch (_) {
      // Automatic checks are deliberately silent.
    }
  }

  UpdateState _current() => state.value ?? const UpdateState();

  String _formatError(Object error) {
    if (error is UpdateCheckException) return error.message;
    return 'update check failed with an unexpected error';
  }
}
