import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

class LocalDirectoryArchive {
  final String path;
  final int sizeBytes;

  const LocalDirectoryArchive({required this.path, required this.sizeBytes});
}

class LocalDirectoryArchiveService {
  const LocalDirectoryArchiveService();

  Future<LocalDirectoryArchive> createTarGz({
    required String taskId,
    required String directoryPath,
    required String rootName,
    required void Function(double progress) onProgress,
    bool Function()? shouldCancel,
  }) async {
    final source = Directory(directoryPath);
    final tempRoot = await getTemporaryDirectory();
    final output = File(
      '${tempRoot.path}${Platform.pathSeparator}'
      '.orbita-upload-$taskId.tar.gz',
    );
    final tarFile = File(
      '${tempRoot.path}${Platform.pathSeparator}'
      '.orbita-upload-$taskId.tar',
    );
    if (await output.exists()) await output.delete();
    if (await tarFile.exists()) await tarFile.delete();

    final encoder = TarFileEncoder();
    encoder.create(tarFile.path);
    final entities = source.listSync(recursive: true, followLinks: true);
    final total = entities.isEmpty ? 1 : entities.length;
    var processed = 0;
    try {
      for (final entity in entities) {
        if (shouldCancel?.call() ?? false) {
          throw const LocalArchiveCanceledException();
        }
        final archivePath = _archivePath(source.path, entity.path, rootName);
        if (archivePath.isEmpty) continue;
        if (entity is File) {
          await encoder.addFile(entity, archivePath);
        }
        processed += 1;
        onProgress(processed / total);
      }
    } finally {
      await encoder.close();
    }

    final input = InputFileStream(tarFile.path);
    final compressed = OutputFileStream(output.path);
    try {
      GZipEncoder().encodeStream(input, compressed, level: 6);
    } finally {
      await input.close();
      await compressed.close();
      if (await tarFile.exists()) await tarFile.delete();
    }

    final size = await output.length();
    return LocalDirectoryArchive(path: output.path, sizeBytes: size);
  }

  String _archivePath(String rootPath, String entityPath, String rootName) {
    final prefix = rootPath.endsWith(Platform.pathSeparator)
        ? rootPath
        : '$rootPath${Platform.pathSeparator}';
    if (!entityPath.startsWith(prefix)) return rootName;
    final relative = entityPath.substring(prefix.length).replaceAll('\\', '/');
    if (relative.trim().isEmpty) return rootName;
    return '$rootName/$relative';
  }
}

class LocalArchiveCanceledException implements Exception {
  const LocalArchiveCanceledException();

  @override
  String toString() => 'LocalArchiveCanceledException';
}
