part of 'sftp_file_service.dart';

extension SftpFileRsyncOperations on SftpFileService {
  Future<void> rsyncPullFile({
    required Server sourceServer,
    required Server targetServer,
    required String taskId,
    required String sourcePath,
    required String targetPath,
    required String tempPath,
    required bool overwrite,
    required void Function(int bytes) onProgress,
    required bool Function() shouldStop,
    SshKey? sourceKey,
    SshKey? targetKey,
  }) async {
    final sourceBase = '/tmp/.orbita-rsync-$taskId-source';
    final targetBase = '/tmp/.orbita-rsync-$taskId-target';
    var sourceReady = false;
    try {
      final publicKey = await _createTargetRsyncKey(
        targetServer,
        targetBase: targetBase,
        key: targetKey,
      );
      sourceReady = true;
      await _installReadOnlyRsyncKey(
        sourceServer,
        sourceBase: sourceBase,
        taskId: taskId,
        publicKey: publicKey,
        key: sourceKey,
      );
      await _runTargetRsyncPull(
        sourceServer: sourceServer,
        targetServer: targetServer,
        targetBase: targetBase,
        sourcePath: sourcePath,
        tempPath: tempPath,
        targetKey: targetKey,
        onProgress: onProgress,
        shouldStop: shouldStop,
      );
      await finalizeUpload(
        targetServer,
        tempPath: tempPath,
        finalPath: targetPath,
        overwrite: overwrite,
        key: targetKey,
      );
    } finally {
      await _cleanupTargetRsyncKey(
        targetServer,
        targetBase: targetBase,
        key: targetKey,
      );
      if (sourceReady) {
        await _cleanupReadOnlyRsyncKey(
          sourceServer,
          sourceBase: sourceBase,
          taskId: taskId,
          key: sourceKey,
        );
      }
    }
  }

  Future<String> _createTargetRsyncKey(
    Server targetServer, {
    required String targetBase,
    SshKey? key,
  }) {
    return _withSsh(targetServer, key: key, (ssh) async {
      final base = shellQuote(targetBase);
      final output = await ssh.execute('''
set -e
rm -rf -- $base
mkdir -p -- $base
chmod 700 -- $base
ssh-keygen -q -t ed25519 -N '' -f $base/id_ed25519
cat $base/id_ed25519.pub
printf '\\n__ORBITA_CMD_OK__'
''');
      if (!output.contains('__ORBITA_CMD_OK__')) {
        throw SftpFileException.commandFailed(output);
      }
      final publicKey = output
          .replaceAll('__ORBITA_CMD_OK__', '')
          .trim()
          .split(RegExp(r'\r?\n'))
          .last
          .trim();
      if (publicKey.isEmpty) {
        throw SftpFileException.commandFailed(output);
      }
      return publicKey;
    });
  }

  Future<void> _installReadOnlyRsyncKey(
    Server sourceServer, {
    required String sourceBase,
    required String taskId,
    required String publicKey,
    SshKey? key,
  }) {
    return _withSsh(sourceServer, key: key, (ssh) async {
      final base = shellQuote(sourceBase);
      final wrapper = shellQuote('$sourceBase/readonly-rsync.sh');
      final marker = 'orbita-rsync-$taskId';
      final keyOptions = [
        'command="/bin/sh $sourceBase/readonly-rsync.sh"',
        'no-agent-forwarding',
        'no-port-forwarding',
        'no-X11-forwarding',
        'no-pty',
      ].join(',');
      final authorizedEntry = '$keyOptions $publicKey $marker';
      await _executeChecked(ssh, '''
rm -rf -- $base
mkdir -p -- $base
chmod 700 -- $base
cat > $wrapper <<'EOF'
#!/bin/sh
case "\$SSH_ORIGINAL_COMMAND" in
  rsync\\ --server\\ --sender\\ *) ;;
  *) echo "Orbita: read-only rsync sender is required" >&2; exit 126 ;;
esac
case "\$SSH_ORIGINAL_COMMAND" in
  *"--delete"*|*"--remove"*|*"--write-batch"*) exit 126 ;;
esac
exec \$SSH_ORIGINAL_COMMAND
EOF
chmod 700 -- $wrapper
mkdir -p -- "\$HOME/.ssh"
chmod 700 -- "\$HOME/.ssh"
touch "\$HOME/.ssh/authorized_keys"
chmod 600 -- "\$HOME/.ssh/authorized_keys"
tmp="\$HOME/.ssh/authorized_keys.orbita-$taskId"
grep -v ' $marker\$' "\$HOME/.ssh/authorized_keys" > "\$tmp" || true
cat "\$tmp" > "\$HOME/.ssh/authorized_keys"
rm -f -- "\$tmp"
printf '%s\\n' ${shellQuote(authorizedEntry)} >> "\$HOME/.ssh/authorized_keys"
''');
    });
  }

  Future<void> _runTargetRsyncPull({
    required Server sourceServer,
    required Server targetServer,
    required String targetBase,
    required String sourcePath,
    required String tempPath,
    required SshKey? targetKey,
    required void Function(int bytes) onProgress,
    required bool Function() shouldStop,
  }) {
    return _withSsh(targetServer, key: targetKey, (ssh) async {
      final sshCommand = [
        'ssh',
        '-i',
        '$targetBase/id_ed25519',
        '-p',
        sourceServer.port.toString(),
        '-o',
        'StrictHostKeyChecking=no',
        '-o',
        'UserKnownHostsFile=/dev/null',
        '-o',
        'IdentitiesOnly=yes',
        '-o',
        'BatchMode=yes',
      ].join(' ');
      final source = _rsyncSourceSpec(sourceServer, sourcePath);
      final output = await ssh.executeStreaming(
        '''
set -e
rm -f -- ${shellQuote(tempPath)}
rsync -a --protect-args --partial --inplace --info=progress2 \\
  -e ${shellQuote(sshCommand)} -- ${shellQuote(source)} ${shellQuote(tempPath)}
printf '\\n__ORBITA_CMD_OK__'
''',
        shouldStop: shouldStop,
        onOutput: (chunk) {
          final progress = _parseRsyncProgressBytes(chunk);
          if (progress != null) onProgress(progress);
        },
      );
      if (!output.contains('__ORBITA_CMD_OK__')) {
        throw SftpFileException.commandFailed(output);
      }
    });
  }

  Future<void> _cleanupTargetRsyncKey(
    Server targetServer, {
    required String targetBase,
    SshKey? key,
  }) async {
    try {
      await _withSsh(
        targetServer,
        key: key,
        (ssh) => ssh.execute('rm -rf -- ${shellQuote(targetBase)}'),
      );
    } catch (_) {}
  }

  Future<void> _cleanupReadOnlyRsyncKey(
    Server sourceServer, {
    required String sourceBase,
    required String taskId,
    SshKey? key,
  }) async {
    try {
      final marker = 'orbita-rsync-$taskId';
      await _withSsh(sourceServer, key: key, (ssh) {
        return ssh.execute('''
tmp="\$HOME/.ssh/authorized_keys.orbita-$taskId"
if [ -f "\$HOME/.ssh/authorized_keys" ]; then
  grep -v ' $marker\$' "\$HOME/.ssh/authorized_keys" > "\$tmp" || true
  cat "\$tmp" > "\$HOME/.ssh/authorized_keys"
  rm -f -- "\$tmp"
fi
rm -rf -- ${shellQuote(sourceBase)}
''');
      });
    } catch (_) {}
  }

  String _rsyncSourceSpec(Server sourceServer, String sourcePath) {
    final host = sourceServer.displayHost.contains(':')
        ? '[${sourceServer.displayHost}]'
        : sourceServer.displayHost;
    return '${sourceServer.username}@$host:${normalizeRemotePath(sourcePath)}';
  }

  int? _parseRsyncProgressBytes(String chunk) {
    final matches = RegExp(r'([0-9][0-9,]*)\s+\d+%').allMatches(chunk);
    if (matches.isEmpty) return null;
    final raw = matches.last.group(1)?.replaceAll(',', '');
    return raw == null ? null : int.tryParse(raw);
  }
}
