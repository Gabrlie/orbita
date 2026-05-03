import 'package:flutter_test/flutter_test.dart';
import 'package:orbita/models/file_download_task.dart';

void main() {
  test('encodes and decodes download task records', () {
    final task = FileDownloadTask(
      id: 'task-1',
      serverId: 'server-1',
      serverName: 'Server',
      remotePath: '/tmp/app.log',
      fileName: 'app.log',
      localPath: '/downloads/app.log',
      totalBytes: 100,
      downloadedBytes: 40,
      status: FileDownloadStatus.paused,
      createdAt: DateTime.utc(2026, 5, 2),
    );

    final decoded = decodeDownloadTasks(encodeDownloadTasks([task]));

    expect(decoded, hasLength(1));
    expect(decoded.single.id, 'task-1');
    expect(decoded.single.progress, 0.4);
    expect(decoded.single.status, FileDownloadStatus.paused);
  });
}
