part of 'file_transfer_provider.dart';

extension FileTransferControllerHelpers on FileTransferController {
  Future<void> _verifyRemoteArchive(
    SftpFileService service,
    Server server,
    SshKey? key,
    String archivePath,
    LocalDirectoryArchive archive,
  ) async {
    final remoteSize = await service.remoteFileSize(
      server,
      path: archivePath,
      key: key,
    );
    final localHash = await _sha256(archive.path);
    final remoteHash = await service.remoteSha256(
      server,
      path: archivePath,
      key: key,
    );
    if (remoteSize != archive.sizeBytes || remoteHash != localHash) {
      throw SftpFileException.commandFailed('Upload verification failed');
    }
  }

  Future<int> _remoteSizeOrZero(
    SftpFileService service,
    Server server,
    String path,
    SshKey? key,
  ) async {
    try {
      return await service.remoteFileSize(server, path: path, key: key);
    } catch (_) {
      return 0;
    }
  }

  Future<void> _cleanupTask(
    FileTransferTask task, {
    bool deleteDownload = false,
  }) async {
    if (task.localTempPath != null) {
      await _deleteLocalFile(task.localTempPath!);
    }
    if (deleteDownload && task.direction == FileTransferDirection.download) {
      await _deleteLocalFile(task.localPath);
    }
  }

  Future<void> _cleanupUploadTaskRemote(
    FileTransferTask task,
    Server server,
    SshKey? key,
  ) async {
    if (task.direction != FileTransferDirection.upload &&
        task.direction != FileTransferDirection.server) {
      return;
    }
    final remoteTempPath = task.remoteTempPath;
    if (remoteTempPath == null) return;
    final archivePath = remoteTempPath.replaceAll(RegExp(r'\.part$'), '');
    try {
      await _sftpService.cleanupRemoteUploadTemp(
        server,
        paths: [remoteTempPath, archivePath],
        key: key,
      );
    } catch (_) {}
  }

  Future<int> _localLength(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    return file.length();
  }

  Future<void> _deleteLocalFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Future<String> _createLocalRelayPath(String taskId, String fileName) async {
    final directory = Directory(
      '${(await getTemporaryDirectory()).path}${Platform.pathSeparator}'
      'orbita-transfer',
    );
    await directory.create(recursive: true);
    return '${directory.path}${Platform.pathSeparator}'
        '.orbita-relay-$taskId-${_safeFileName(fileName)}';
  }

  Future<String> _sha256(String path) async {
    final digest = await crypto_hash.sha256.bind(File(path).openRead()).first;
    return digest.toString();
  }

  Future<String?> _createLocalPath(
    String serverName,
    String fileName,
    TransferSettings settings,
  ) async {
    final configured = settings.downloadDirectory.trim();
    final directory = configured.isEmpty
        ? Directory(
            '${(await _downloadRootDirectory()).path}'
            '${Platform.pathSeparator}Orbite'
            '${Platform.pathSeparator}${_safeFileName(serverName)}',
          )
        : Directory(configured);
    await directory.create(recursive: true);
    final safeName = _safeFileName(fileName);
    var candidate = File('${directory.path}${Platform.pathSeparator}$safeName');
    if (await candidate.exists()) {
      switch (settings.duplicateAction) {
        case TransferDuplicateAction.overwrite:
          await _deleteLocalFile(candidate.path);
          return candidate.path;
        case TransferDuplicateAction.cancel:
          return null;
        case TransferDuplicateAction.ask:
        case TransferDuplicateAction.keepBoth:
          break;
      }
    }
    var index = 1;
    while (await candidate.exists()) {
      candidate = File(
        '${directory.path}${Platform.pathSeparator}'
        '${duplicateRemoteEntryName(safeName, index)}',
      );
      index += 1;
    }
    return candidate.path;
  }

  Future<Directory> _downloadRootDirectory() async {
    if (Platform.isAndroid) {
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await publicDownloads.exists()) return publicDownloads;
    }
    return await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
  }

  String _safeFileName(String name) {
    final safe = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return safe.isEmpty ? 'transfer' : safe;
  }
}
