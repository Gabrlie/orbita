import 'dart:io';

import 'package:crypto/crypto.dart' as crypto_hash;
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:orbita/models/app_update.dart';
import 'package:orbita/services/update_service.dart';
import 'package:ota_update/ota_update.dart';
import 'package:path_provider/path_provider.dart';

class UpdateDownloadService {
  final Dio _dio;
  CancelToken? _cancelToken;

  UpdateDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  Stream<UpdateDownloadProgress> downloadAndInstall(ReleaseAsset asset) {
    if (Platform.isAndroid) return _downloadAndInstallAndroid(asset);
    return _downloadDesktopAsset(asset);
  }

  void cancel() {
    _cancelToken?.cancel();
  }

  Stream<UpdateDownloadProgress> _downloadAndInstallAndroid(
    ReleaseAsset asset,
  ) async* {
    final expectedSha256 = await _fetchSha256(asset.sha256Url);
    yield const UpdateDownloadProgress(
      status: UpdateDownloadStatus.downloading,
    );
    try {
      final events = OtaUpdate().execute(
        asset.downloadUrl,
        destinationFilename: asset.name,
        sha256checksum: expectedSha256,
      );
      await for (final event in events) {
        switch (event.status) {
          case OtaStatus.DOWNLOADING:
            yield UpdateDownloadProgress(
              status: UpdateDownloadStatus.downloading,
              progress: int.tryParse(event.value ?? '0') ?? 0,
            );
          case OtaStatus.INSTALLING:
            yield const UpdateDownloadProgress(
              status: UpdateDownloadStatus.installing,
              progress: 100,
            );
          case OtaStatus.INSTALLATION_DONE:
            yield const UpdateDownloadProgress(
              status: UpdateDownloadStatus.completed,
              progress: 100,
            );
          case OtaStatus.CHECKSUM_ERROR:
            yield const UpdateDownloadProgress(
              status: UpdateDownloadStatus.error,
              error: 'checksum_error',
            );
          case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
            yield const UpdateDownloadProgress(
              status: UpdateDownloadStatus.error,
              error: 'permission_not_granted',
            );
          case OtaStatus.ALREADY_RUNNING_ERROR:
            yield const UpdateDownloadProgress(
              status: UpdateDownloadStatus.error,
              error: 'already_running',
            );
          case OtaStatus.DOWNLOAD_ERROR:
          case OtaStatus.INTERNAL_ERROR:
          case OtaStatus.INSTALLATION_ERROR:
            yield UpdateDownloadProgress(
              status: UpdateDownloadStatus.error,
              error: event.value ?? event.status.name,
            );
          case OtaStatus.CANCELED:
            return;
        }
      }
    } catch (error) {
      yield UpdateDownloadProgress(
        status: UpdateDownloadStatus.error,
        error: '$error',
      );
    }
  }

  Stream<UpdateDownloadProgress> _downloadDesktopAsset(
    ReleaseAsset asset,
  ) async* {
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}${asset.name}',
    );
    _cancelToken = CancelToken();
    yield const UpdateDownloadProgress(
      status: UpdateDownloadStatus.downloading,
    );
    try {
      await _dio.download(
        asset.downloadUrl,
        file.path,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {},
      );
      final expectedSha256 = await _fetchSha256(asset.sha256Url);
      if (expectedSha256 != null) {
        yield const UpdateDownloadProgress(
          status: UpdateDownloadStatus.verifying,
          progress: 100,
        );
        final digest = crypto_hash.sha256.convert(await file.readAsBytes());
        if (digest.toString().toLowerCase() != expectedSha256) {
          yield const UpdateDownloadProgress(
            status: UpdateDownloadStatus.error,
            error: 'checksum_error',
          );
          return;
        }
      }
      await OpenFilex.open(file.path);
      yield UpdateDownloadProgress(
        status: UpdateDownloadStatus.completed,
        progress: 100,
        filePath: file.path,
      );
    } catch (error) {
      yield UpdateDownloadProgress(
        status: UpdateDownloadStatus.error,
        error: '$error',
      );
    }
  }

  Future<String?> _fetchSha256(String? url) async {
    if (url == null || url.isEmpty) return null;
    final response = await _dio.get<String>(url);
    final data = response.data;
    return data == null ? null : UpdateService.parseSha256(data);
  }
}
