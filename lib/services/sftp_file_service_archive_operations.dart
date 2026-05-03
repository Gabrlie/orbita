part of 'sftp_file_service.dart';

extension SftpFileArchiveOperations on SftpFileService {
  Future<List<String>> missingTools(
    Server server, {
    required List<String> tools,
    SshKey? key,
  }) {
    return _withSsh(server, key: key, (ssh) async {
      final missing = <String>[];
      for (final tool in tools.toSet()) {
        final output = await ssh.execute(
          'command -v ${shellQuote(tool)} >/dev/null 2>&1 '
          '&& printf ok || printf missing',
        );
        if (output.trim() != 'ok') missing.add(tool);
      }
      return missing;
    });
  }

  Future<void> installTools(
    Server server, {
    required List<String> tools,
    SshKey? key,
  }) {
    return _withSsh(
      server,
      key: key,
      (ssh) => _executeChecked(ssh, buildInstallToolsCommand(tools)),
    );
  }

  Future<void> installToolsWithOutput(
    Server server, {
    required List<String> tools,
    required void Function(String chunk) onOutput,
    SshKey? key,
  }) {
    return _withSsh(server, key: key, (ssh) async {
      final output = await ssh.executeStreaming(
        'set -e\n${buildInstallToolsCommand(tools)}\nprintf "\\n__ORBITA_CMD_OK__"',
        onOutput: (chunk) {
          onOutput(chunk.replaceAll('__ORBITA_CMD_OK__', ''));
        },
      );
      if (!output.contains('__ORBITA_CMD_OK__')) {
        throw SftpFileException.commandFailed(output);
      }
    });
  }

  Future<void> compress(
    Server server, {
    required RemoteFileEntry entry,
    required ArchiveFormat format,
    String? password,
    bool overwrite = false,
    SshKey? key,
  }) async {
    final parent = parentRemotePath(entry.path);
    final targetName = archiveTargetName(entry.name, format);
    final target = joinRemotePath(parent, targetName);
    await _withSsh(server, key: key, (ssh) async {
      if (overwrite) {
        await _executeChecked(ssh, 'rm -rf -- ${shellQuote(target)}');
      }
      await _executeChecked(
        ssh,
        buildCompressCommand(
          parentPath: parent,
          sourceName: entry.name,
          targetName: targetName,
          format: format,
          password: password,
        ),
      );
    });
  }

  Future<void> extract(
    Server server, {
    required RemoteFileEntry entry,
    String? password,
    SshKey? key,
  }) {
    return _withSsh(
      server,
      key: key,
      (ssh) => _executeChecked(
        ssh,
        buildExtractCommand(
          archivePath: entry.path,
          targetDirectory: parentRemotePath(entry.path),
          password: password,
        ),
      ),
    );
  }

  Future<String> previewArchive(
    Server server, {
    required RemoteFileEntry entry,
    SshKey? key,
  }) {
    return _withSsh(server, key: key, (ssh) async {
      final output = await ssh.execute(
        'set -e\n'
        '${buildArchivePreviewCommand(archivePath: entry.path)}\n'
        'printf "\\n__ORBITA_CMD_OK__"',
      );
      if (!output.contains('__ORBITA_CMD_OK__')) {
        throw SftpFileException.commandFailed(output);
      }
      return output.replaceAll('__ORBITA_CMD_OK__', '').trimRight();
    });
  }
}
