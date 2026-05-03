part of 'sftp_file_service.dart';

extension SftpFileOperations on SftpFileService {
  Future<bool> exists(Server server, {required String path, SshKey? key}) {
    return _withSftp(server, key: key, (sftp, _) async {
      try {
        await sftp.stat(normalizeRemotePath(path));
        return true;
      } catch (_) {
        return false;
      }
    });
  }

  Future<void> copy(
    Server server, {
    required RemoteFileEntry entry,
    required String targetDirectory,
    required bool overwrite,
    bool keepBoth = false,
    SshKey? key,
  }) async {
    await _withSftp(server, key: key, (sftp, _) async {
      final source = normalizeRemotePath(entry.path);
      final target = keepBoth
          ? await _resolveAvailableTarget(sftp, targetDirectory, entry.name)
          : joinRemotePath(targetDirectory, entry.name);
      if (source == normalizeRemotePath(target)) {
        if (overwrite) return;
        throw SftpFileException.targetExists();
      }
      if (_isInvalidCopyTarget(source, target, entry.isDirectory)) {
        throw SftpFileException.invalidTarget();
      }

      await _copySftpEntry(
        sftp,
        entry: entry,
        source: source,
        target: target,
        overwrite: overwrite && !keepBoth,
      );
    });
  }

  Future<List<RemoteFileEntry>> copyAndList(
    Server server, {
    required RemoteFileEntry entry,
    required String targetDirectory,
    required bool overwrite,
    bool keepBoth = false,
    required String listPath,
    SshKey? key,
  }) async {
    return _withSftp(server, key: key, (sftp, _) async {
      final source = normalizeRemotePath(entry.path);
      final target = keepBoth
          ? await _resolveAvailableTarget(sftp, targetDirectory, entry.name)
          : joinRemotePath(targetDirectory, entry.name);
      if (source == normalizeRemotePath(target)) {
        if (overwrite) return _listDirectoryWithClient(sftp, listPath);
        throw SftpFileException.targetExists();
      }
      if (_isInvalidCopyTarget(source, target, entry.isDirectory)) {
        throw SftpFileException.invalidTarget();
      }
      await _copySftpEntry(
        sftp,
        entry: entry,
        source: source,
        target: target,
        overwrite: overwrite && !keepBoth,
      );
      return _listDirectoryWithClient(sftp, listPath);
    });
  }

  Future<List<RemoteFileEntry>> deleteAndList(
    Server server, {
    required RemoteFileEntry entry,
    required String listPath,
    SshKey? key,
  }) async {
    if (entry.isParentLink || normalizeRemotePath(entry.path) == '/') {
      throw SftpFileException.invalidTarget();
    }
    return _withSftp(server, key: key, (sftp, _) async {
      await _removeSftpEntry(sftp, entry.path);
      return _listDirectoryWithClient(sftp, listPath);
    });
  }

  Future<void> move(
    Server server, {
    required RemoteFileEntry entry,
    required String targetDirectory,
    required bool overwrite,
    bool keepBoth = false,
    SshKey? key,
  }) async {
    await _withSftp(server, key: key, (sftp, _) async {
      final source = normalizeRemotePath(entry.path);
      final target = keepBoth
          ? await _resolveAvailableTarget(sftp, targetDirectory, entry.name)
          : joinRemotePath(targetDirectory, entry.name);
      if (source == normalizeRemotePath(target)) {
        if (overwrite) return;
        throw SftpFileException.targetExists();
      }
      if (_isInvalidCopyTarget(source, target, entry.isDirectory)) {
        throw SftpFileException.invalidTarget();
      }
      if (overwrite && !keepBoth) {
        await _removeSftpEntry(sftp, target);
      } else if (!keepBoth && await _sftpEntryExists(sftp, target)) {
        throw SftpFileException.targetExists();
      }
      try {
        await sftp.rename(source, target);
      } catch (_) {
        await _copySftpEntry(
          sftp,
          entry: entry,
          source: source,
          target: target,
          overwrite: true,
        );
        await _removeSftpEntry(sftp, source);
      }
    });
  }

  Future<List<RemoteFileEntry>> moveAndList(
    Server server, {
    required RemoteFileEntry entry,
    required String targetDirectory,
    required bool overwrite,
    bool keepBoth = false,
    required String listPath,
    SshKey? key,
  }) async {
    return _withSftp(server, key: key, (sftp, _) async {
      final source = normalizeRemotePath(entry.path);
      final target = keepBoth
          ? await _resolveAvailableTarget(sftp, targetDirectory, entry.name)
          : joinRemotePath(targetDirectory, entry.name);
      if (source == normalizeRemotePath(target)) {
        if (overwrite) return _listDirectoryWithClient(sftp, listPath);
        throw SftpFileException.targetExists();
      }
      if (_isInvalidCopyTarget(source, target, entry.isDirectory)) {
        throw SftpFileException.invalidTarget();
      }
      if (overwrite && !keepBoth) {
        await _removeSftpEntry(sftp, target);
      } else if (!keepBoth && await _sftpEntryExists(sftp, target)) {
        throw SftpFileException.targetExists();
      }
      try {
        await sftp.rename(source, target);
      } catch (_) {
        await _copySftpEntry(
          sftp,
          entry: entry,
          source: source,
          target: target,
          overwrite: true,
        );
        await _removeSftpEntry(sftp, source);
      }
      return _listDirectoryWithClient(sftp, listPath);
    });
  }

  Future<void> downloadFile(
    Server server, {
    required String remotePath,
    required String localPath,
    required int offset,
    required void Function(int bytes) onProgress,
    required bool Function() shouldStop,
    SshKey? key,
  }) async {
    await _withSftp(server, key: key, (sftp, _) async {
      final remote = await sftp.open(normalizeRemotePath(remotePath));
      final local = File(localPath);
      await local.parent.create(recursive: true);
      final sink = local.openWrite(mode: FileMode.append);
      var downloaded = offset;
      try {
        await for (final chunk in remote.read(offset: offset)) {
          if (shouldStop()) throw SftpFileException.downloadStopped();
          sink.add(chunk);
          downloaded += chunk.length;
          onProgress(downloaded);
        }
      } finally {
        await sink.close();
        await remote.close();
      }
    });
  }
}
