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
      _runServerTransfer(
        task,
        sourceServer,
        sourceKey,
        targetServer,
        targetKey,
        overwrite,
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
      _update(task.id, phase: phase, error: control.cancel ? null : '$error');
      await _cleanupUploadTaskRemote(task, targetServer, targetKey);
    } finally {
      _controls.remove(task.id);
      await _save();
    }
  }
}
