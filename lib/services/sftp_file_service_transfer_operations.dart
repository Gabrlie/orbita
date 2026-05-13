part of 'sftp_file_service.dart';

extension SftpFileTransferOperations on SftpFileService {
  Future<void> uploadFile(
    Server server, {
    required String localPath,
    required String remotePath,
    required int offset,
    required void Function(int bytes) onProgress,
    required bool Function() shouldStop,
    bool overwrite = false,
    SshKey? key,
  }) async {
    await _withSftp(server, key: key, (sftp, _) async {
      final remote = await sftp.open(
        normalizeRemotePath(remotePath),
        mode: offset <= 0 && overwrite
            ? SftpFileOpenMode.write |
                  SftpFileOpenMode.create |
                  SftpFileOpenMode.truncate
            : SftpFileOpenMode.write | SftpFileOpenMode.create,
      );
      final input = await File(localPath).open();
      var uploaded = offset;
      try {
        await input.setPosition(offset);
        while (true) {
          if (shouldStop()) throw SftpFileException.transferStopped();
          final chunk = await input.read(64 * 1024);
          if (chunk.isEmpty) break;
          await remote.writeBytes(chunk, offset: uploaded);
          uploaded += chunk.length;
          onProgress(uploaded);
        }
      } finally {
        await input.close();
        await remote.close();
      }
    });
  }

  Future<int> remoteFileSize(
    Server server, {
    required String path,
    SshKey? key,
  }) {
    return _withSsh(server, key: key, (ssh) async {
      final output = await ssh.execute(
        'stat -c %s -- ${shellQuote(normalizeRemotePath(path))}',
      );
      return int.tryParse(output.trim()) ?? 0;
    });
  }

  Future<String> remoteSha256(
    Server server, {
    required String path,
    SshKey? key,
  }) {
    return _withSsh(server, key: key, (ssh) async {
      final quoted = shellQuote(normalizeRemotePath(path));
      final output = await ssh.execute('sha256sum -- $quoted');
      return output.trim().split(RegExp(r'\s+')).first;
    });
  }

  Future<void> finalizeUpload(
    Server server, {
    required String tempPath,
    required String finalPath,
    bool overwrite = false,
    SshKey? key,
  }) {
    return _withSsh(server, key: key, (ssh) async {
      final temp = shellQuote(normalizeRemotePath(tempPath));
      final target = shellQuote(normalizeRemotePath(finalPath));
      final prepare = overwrite ? 'rm -rf -- $target\n' : 'test ! -e $target\n';
      await _executeChecked(ssh, '${prepare}mv -f -- $temp $target');
    });
  }

  Future<void> extractUploadedTarGz(
    Server server, {
    required String archivePath,
    required String targetDirectory,
    required String rootName,
    bool overwrite = false,
    SshKey? key,
  }) {
    return _withSsh(server, key: key, (ssh) async {
      final archive = shellQuote(normalizeRemotePath(archivePath));
      final target = normalizeRemotePath(targetDirectory);
      final targetRoot = joinRemotePath(target, rootName);
      final remove = overwrite
          ? 'rm -rf -- ${shellQuote(targetRoot)}\n'
          : 'test ! -e ${shellQuote(targetRoot)}\n';
      await _executeChecked(
        ssh,
        '${remove}tar -xzf $archive -C ${shellQuote(target)}',
      );
    });
  }

  Future<void> cleanupRemoteUploadTemp(
    Server server, {
    required Iterable<String> paths,
    SshKey? key,
  }) {
    return _withSsh(server, key: key, (ssh) async {
      final targets = paths
          .where((path) => path.trim().isNotEmpty)
          .map((path) => shellQuote(normalizeRemotePath(path)))
          .join(' ');
      if (targets.isEmpty) return;
      await ssh.execute('rm -f -- $targets');
    });
  }
}
