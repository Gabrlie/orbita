part of 'file_transfer_provider.dart';

extension FileTransferControllerOperations on FileTransferController {
  Future<void> _runDownload(
    FileTransferTask task,
    Server server,
    SshKey? key,
    _TransferControl control,
  ) async {
    final service = _sftpService;
    final offset = await _localLength(task.localPath);
    _update(
      task.id,
      phase: FileTransferPhase.downloading,
      transferredBytes: offset,
      error: null,
    );
    await service.downloadFile(
      server,
      remotePath: task.remotePath,
      localPath: task.localPath,
      offset: offset,
      key: key,
      shouldStop: () => control.pause || control.cancel,
      onProgress: (bytes) => _update(task.id, transferredBytes: bytes),
    );
    _complete(task.id, task.totalBytes);
  }

  Future<void> _runFileUpload(
    FileTransferTask task,
    Server server,
    SshKey? key,
    _TransferControl control,
    bool overwrite,
  ) async {
    final service = _sftpService;
    final tempPath = task.remoteTempPath!;
    final offset = await _remoteSizeOrZero(service, server, tempPath, key);
    _update(
      task.id,
      phase: FileTransferPhase.uploading,
      transferredBytes: offset,
      error: null,
    );
    await service.uploadFile(
      server,
      localPath: task.localPath,
      remotePath: tempPath,
      offset: offset,
      key: key,
      overwrite: offset == 0,
      shouldStop: () => control.pause || control.cancel,
      onProgress: (bytes) => _update(task.id, transferredBytes: bytes),
    );
    _update(task.id, phase: FileTransferPhase.cleaning);
    await service.finalizeUpload(
      server,
      tempPath: tempPath,
      finalPath: task.remotePath,
      overwrite: overwrite,
      key: key,
    );
    _complete(task.id, task.totalBytes);
  }

  Future<void> _runDirectoryUpload(
    FileTransferTask task,
    Server server,
    SshKey? key,
    _TransferControl control,
    bool overwrite,
  ) async {
    final archiveService = const LocalDirectoryArchiveService();
    _update(task.id, phase: FileTransferPhase.compressing, error: null);
    final archive = await archiveService.createTarGz(
      taskId: task.id,
      directoryPath: task.localPath,
      rootName: task.name,
      shouldCancel: () => control.cancel,
      onProgress: (_) {},
    );
    final archivePath = task.remoteTempPath!.replaceAll(RegExp(r'\.part$'), '');
    _update(
      task.id,
      localTempPath: archive.path,
      totalBytes: archive.sizeBytes,
      phase: FileTransferPhase.uploading,
    );
    final service = _sftpService;
    final offset = await _remoteSizeOrZero(
      service,
      server,
      task.remoteTempPath!,
      key,
    );
    await service.uploadFile(
      server,
      localPath: archive.path,
      remotePath: task.remoteTempPath!,
      offset: offset,
      key: key,
      overwrite: offset == 0,
      shouldStop: () => control.pause || control.cancel,
      onProgress: (bytes) => _update(task.id, transferredBytes: bytes),
    );
    _update(task.id, phase: FileTransferPhase.verifying);
    await service.finalizeUpload(
      server,
      tempPath: task.remoteTempPath!,
      finalPath: archivePath,
      overwrite: true,
      key: key,
    );
    await _verifyRemoteArchive(service, server, key, archivePath, archive);
    _update(task.id, phase: FileTransferPhase.extracting);
    await service.extractUploadedTarGz(
      server,
      archivePath: archivePath,
      targetDirectory: parentRemotePath(task.remotePath),
      rootName: task.name,
      overwrite: overwrite,
      key: key,
    );
    _update(task.id, phase: FileTransferPhase.cleaning);
    await service.cleanupRemoteUploadTemp(
      server,
      paths: [task.remoteTempPath!, archivePath],
      key: key,
    );
    await _deleteLocalFile(archive.path);
    _complete(task.id, archive.sizeBytes);
  }
}
