import 'dart:io';

import 'package:orbita/models/backup_models.dart';

class BackupFileService {
  static const prefix = 'orbita-backup-';
  static const legacyName = 'orbita-backup.json';
  static const extension = '.json';

  const BackupFileService();

  String createFileName([DateTime? now]) {
    final at = now ?? DateTime.now();
    final stamp =
        '${_four(at.year)}${_two(at.month)}${_two(at.day)}-'
        '${_two(at.hour)}${_two(at.minute)}${_two(at.second)}';
    return '$prefix$stamp$extension';
  }

  bool isBackupName(String name) {
    if (name == legacyName) return true;
    return name.startsWith(prefix) && name.endsWith(extension);
  }

  Future<BackupEntry> write({
    required String folder,
    required String fileName,
    required String content,
  }) async {
    final directory = Directory(folder);
    await directory.create(recursive: true);
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    await file.writeAsString(content);
    final stat = await file.stat();
    return BackupEntry(
      location: BackupLocation.local,
      name: fileName,
      path: file.path,
      modifiedAt: stat.modified,
    );
  }

  Future<List<BackupEntry>> list(String folder) async {
    if (folder.isEmpty) return const [];
    final directory = Directory(folder);
    if (!await directory.exists()) return const [];
    final entries = <BackupEntry>[];
    await for (final item in directory.list(followLinks: false)) {
      if (item is! File) continue;
      final name = item.uri.pathSegments.last;
      if (!isBackupName(name)) continue;
      final stat = await item.stat();
      entries.add(
        BackupEntry(
          location: BackupLocation.local,
          name: name,
          path: item.path,
          modifiedAt: stat.modified,
        ),
      );
    }
    return sortNewestFirst(entries);
  }

  Future<String> read(BackupEntry entry) {
    return File(entry.path).readAsString();
  }

  Future<void> prune(String folder, int retentionCount) async {
    final stale = entriesToDelete(await list(folder), retentionCount);
    for (final entry in stale) {
      await File(entry.path).delete();
    }
  }

  List<BackupEntry> sortNewestFirst(List<BackupEntry> entries) {
    final sorted = [...entries];
    sorted.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return sorted;
  }

  List<BackupEntry> entriesToDelete(
    List<BackupEntry> entries,
    int retentionCount,
  ) {
    final keep = retentionCount.clamp(1, 100);
    final sorted = sortNewestFirst(entries);
    if (sorted.length <= keep) return const [];
    return sorted.skip(keep).toList();
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _four(int value) => value.toString().padLeft(4, '0');
}
