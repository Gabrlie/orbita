part of 'file_transfer_provider.dart';

extension FileTransferControllerServerOperations on FileTransferController {
  Future<void> addServerTransfer({
    required Server sourceServer,
    required SshKey? sourceKey,
    required Server targetServer,
    required SshKey? targetKey,
    required RemoteFileEntry entry,
    required String targetPath,
    required bool overwrite,
    bool useLocalRelay = false,
  }) async {
    final id = const Uuid().v4();
    final task = FileTransferTask(
      id: id,
      serverId: targetServer.id,
      serverName: targetServer.name,
      sourceServerId: sourceServer.id,
      sourceServerName: sourceServer.name,
      sourceRemotePath: entry.path,
      direction: FileTransferDirection.server,
      sourceType: FileTransferSourceType.file,
      name: entry.name,
      remotePath: targetPath,
      localPath: '',
      remoteTempPath: '$targetPath.orbita-rsync-$id.part',
      totalBytes: entry.size,
      transferredBytes: 0,
      phase: FileTransferPhase.queued,
      createdAt: DateTime.now(),
    );
    await _addTask(task);
    unawaited(
      useLocalRelay
          ? _runServerTransferViaLocal(
              task,
              sourceServer,
              sourceKey,
              targetServer,
              targetKey,
              overwrite,
            )
          : _runServerTransfer(
              task,
              sourceServer,
              sourceKey,
              targetServer,
              targetKey,
              overwrite,
            ),
    );
  }

  Future<void> resumeServerTransfer({
    required FileTransferTask task,
    required Server sourceServer,
    required SshKey? sourceKey,
    required Server targetServer,
    required SshKey? targetKey,
  }) async {
    if (task.direction != FileTransferDirection.server ||
        task.sourceRemotePath == null ||
        task.remoteTempPath == null) {
      return;
    }
    _update(
      task.id,
      phase: FileTransferPhase.queued,
      transferredBytes: 0,
      error: null,
    );
    await _save();
    unawaited(
      _runServerTransfer(
        _taskById(task.id),
        sourceServer,
        sourceKey,
        targetServer,
        targetKey,
        false,
      ),
    );
  }

  Future<void> fallbackServerTransferViaLocal({
    required FileTransferTask task,
    required Server sourceServer,
    required SshKey? sourceKey,
    required Server targetServer,
    required SshKey? targetKey,
  }) async {
    if (task.direction != FileTransferDirection.server ||
        task.sourceRemotePath == null ||
        task.remoteTempPath == null) {
      return;
    }
    _update(
      task.id,
      phase: FileTransferPhase.queued,
      transferredBytes: 0,
      error: null,
    );
    await _save();
    unawaited(
      _runServerTransferViaLocal(
        _taskById(task.id),
        sourceServer,
        sourceKey,
        targetServer,
        targetKey,
        false,
      ),
    );
  }

  Future<void> _runServerTransfer(
    FileTransferTask task,
    Server sourceServer,
    SshKey? sourceKey,
    Server targetServer,
    SshKey? targetKey,
    bool overwrite,
  ) async {
    if (_controls.containsKey(task.id)) return;
    final control = _TransferControl();
    _controls[task.id] = control;
    try {
      _update(
        task.id,
        phase: FileTransferPhase.verifying,
        transferredBytes: 0,
        error: null,
      );
      await _sftpService.rsyncPullFile(
        sourceServer: sourceServer,
        sourceKey: sourceKey,
        targetServer: targetServer,
        targetKey: targetKey,
        taskId: task.id,
        sourcePath: task.sourceRemotePath!,
        targetPath: task.remotePath,
        tempPath: task.remoteTempPath!,
        overwrite: overwrite,
        shouldStop: () => control.cancel,
        onProgress: (bytes) {
          _update(
            task.id,
            phase: FileTransferPhase.downloading,
            transferredBytes: bytes,
          );
        },
      );
      _complete(task.id, task.totalBytes);
    } catch (error) {
      final phase = control.cancel
          ? FileTransferPhase.canceled
          : FileTransferPhase.failed;
      if (phase == FileTransferPhase.failed) {
        _logTransferFailure(task, error);
      }
      _update(
        task.id,
        phase: phase,
        error: control.cancel ? null : _errorMessage(error),
      );
      await _cleanupUploadTaskRemote(task, targetServer, targetKey);
    } finally {
      _controls.remove(task.id);
      await _save();
    }
  }

  Future<void> _runServerTransferViaLocal(
    FileTransferTask task,
    Server sourceServer,
    SshKey? sourceKey,
    Server targetServer,
    SshKey? targetKey,
    bool overwrite,
  ) async {
    if (_controls.containsKey(task.id)) return;
    final control = _TransferControl();
    _controls[task.id] = control;
    String? localPath = task.localTempPath;
    try {
      localPath ??= await _createLocalRelayPath(task.id, task.name);
      await _deleteLocalFile(localPath);
      _update(
        task.id,
        localTempPath: localPath,
        phase: FileTransferPhase.downloading,
        transferredBytes: 0,
        error: null,
      );
      await _sftpService.downloadFile(
        sourceServer,
        remotePath: task.sourceRemotePath!,
        localPath: localPath,
        offset: 0,
        key: sourceKey,
        shouldStop: () => control.cancel,
        onProgress: (bytes) => _update(
          task.id,
          phase: FileTransferPhase.downloading,
          transferredBytes: bytes,
        ),
      );
      _update(task.id, phase: FileTransferPhase.uploading, transferredBytes: 0);
      await _sftpService.uploadFile(
        targetServer,
        localPath: localPath,
        remotePath: task.remoteTempPath!,
        offset: 0,
        overwrite: true,
        key: targetKey,
        shouldStop: () => control.cancel,
        onProgress: (bytes) => _update(
          task.id,
          phase: FileTransferPhase.uploading,
          transferredBytes: bytes,
        ),
      );
      _update(task.id, phase: FileTransferPhase.cleaning);
      await _sftpService.finalizeUpload(
        targetServer,
        tempPath: task.remoteTempPath!,
        finalPath: task.remotePath,
        overwrite: overwrite,
        key: targetKey,
      );
      await _deleteLocalFile(localPath);
      _complete(task.id, task.totalBytes);
    } catch (error) {
      final phase = control.cancel
          ? FileTransferPhase.canceled
          : FileTransferPhase.failed;
      if (phase == FileTransferPhase.failed) {
        _logTransferFailure(task, error);
      }
      _update(
        task.id,
        phase: phase,
        error: control.cancel ? null : _errorMessage(error),
      );
      await _cleanupUploadTaskRemote(task, targetServer, targetKey);
      if (control.cancel && localPath != null) {
        await _deleteLocalFile(localPath);
      }
    } finally {
      _controls.remove(task.id);
      await _save();
    }
  }
}
