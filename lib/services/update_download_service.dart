import 'dart:io';

import 'package:crypto/crypto.dart' as crypto_hash;
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:orbita/models/app_update.dart';
import 'package:orbita/services/update_service.dart';
import 'package:path_provider/path_provider.dart';

class UpdateDownloadService {
  final Dio _dio;
  CancelToken? _cancelToken;

  UpdateDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  Stream<UpdateDownloadProgress> downloadAndInstall(ReleaseAsset asset) {
    return _downloadAndOpenAsset(asset);
  }

  void cancel() {
    _cancelToken?.cancel();
  }

  Stream<UpdateDownloadProgress> _downloadAndOpenAsset(
    ReleaseAsset asset,
  ) async* {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory() ?? await getTemporaryDirectory()
        : await getTemporaryDirectory();
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
        onReceiveProgress: (_, _) {},
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
      yield const UpdateDownloadProgress(
        status: UpdateDownloadStatus.installing,
        progress: 100,
      );
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        yield UpdateDownloadProgress(
          status: UpdateDownloadStatus.error,
          error: result.message,
          filePath: file.path,
        );
        return;
      }
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
