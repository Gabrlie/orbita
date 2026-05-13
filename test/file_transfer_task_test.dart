import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/file_download_task.dart';
import 'package:orbita/models/file_transfer_task.dart';

void main() {
  test('encodes and decodes transfer task records', () {
    final task = FileTransferTask(
      id: 'task-1',
      serverId: 'server-1',
      serverName: 'Server',
      direction: FileTransferDirection.upload,
      sourceType: FileTransferSourceType.directory,
      name: 'site',
      remotePath: '/var/www/site',
      localPath: 'D:/site',
      remoteTempPath: '/var/www/.orbita-upload-task-1.tar.gz.part',
      localTempPath: 'D:/tmp/.orbita-upload-task-1.tar.gz',
      totalBytes: 100,
      transferredBytes: 40,
      phase: FileTransferPhase.uploading,
      createdAt: DateTime.utc(2026, 5, 13),
    );

    final decoded = decodeTransferTasks(encodeTransferTasks([task]));

    expect(decoded, hasLength(1));
    expect(decoded.single.direction, FileTransferDirection.upload);
    expect(decoded.single.sourceType, FileTransferSourceType.directory);
    expect(decoded.single.progress, 0.4);
  });

  test('keeps server transfer endpoints in task records', () {
    final task = FileTransferTask(
      id: 'task-2',
      serverId: 'target',
      serverName: 'Target',
      sourceServerId: 'source',
      sourceServerName: 'Source',
      sourceRemotePath: '/tmp/app.log',
      direction: FileTransferDirection.server,
      sourceType: FileTransferSourceType.file,
      name: 'app.log',
      remotePath: '/var/log/app.log',
      localPath: 'D:/tmp/app.log',
      totalBytes: 64,
      transferredBytes: 32,
      phase: FileTransferPhase.uploading,
      createdAt: DateTime.utc(2026, 5, 13),
    );

    final decoded = decodeTransferTasks(encodeTransferTasks([task])).single;

    expect(decoded.direction, FileTransferDirection.server);
    expect(decoded.sourceServerId, 'source');
    expect(decoded.sourceServerName, 'Source');
    expect(decoded.sourceRemotePath, '/tmp/app.log');
  });

  test('migrates legacy download task records', () {
    final legacy = FileDownloadTask(
      id: 'download-1',
      serverId: 'server-1',
      serverName: 'Server',
      remotePath: '/tmp/app.log',
      fileName: 'app.log',
      localPath: '/downloads/app.log',
      totalBytes: 100,
      downloadedBytes: 100,
      status: FileDownloadStatus.completed,
      createdAt: DateTime.utc(2026, 5, 2),
    );

    final task = FileTransferTask.fromLegacyDownload(legacy);

    expect(task.direction, FileTransferDirection.download);
    expect(task.phase, FileTransferPhase.completed);
    expect(task.name, 'app.log');
  });
}
