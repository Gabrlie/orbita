import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:orbita/models/remote_script.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/services/linux_mirror_script_builder.dart';
import 'package:orbita/services/remote_file_command_builder.dart';
import 'package:orbita/services/ssh_connection_manager.dart';
import 'package:orbita/services/ssh_service.dart';

const _okMarker = '__ORBITA_SCRIPT_OK__';

class RemoteScriptService {
  final SshConnectionManager _connectionManager;

  const RemoteScriptService(this._connectionManager);

  List<RemoteScript> builtInScripts({
    required String archiveName,
    required String archiveDescription,
    required String dockerName,
    required String dockerDescription,
    required String tmuxName,
    required String tmuxDescription,
    required String mirrorName,
    required String mirrorDescription,
    required String mirrorSelectTitle,
    required String mirrorTunaLabel,
    required String mirrorUstcLabel,
    required String mirrorAliyunLabel,
    required String mirrorTencentLabel,
    required String mirrorHuaweiLabel,
  }) {
    return [
      RemoteScript(
        id: linuxMirrorScriptId,
        name: mirrorName,
        description: mirrorDescription,
        command: buildLinuxMirrorCommand(
          selectTitle: mirrorSelectTitle,
          tunaLabel: mirrorTunaLabel,
          ustcLabel: mirrorUstcLabel,
          aliyunLabel: mirrorAliyunLabel,
          tencentLabel: mirrorTencentLabel,
          huaweiLabel: mirrorHuaweiLabel,
        ),
        isSystem: true,
      ),
      RemoteScript(
        id: 'install-archive-tools',
        name: archiveName,
        description: archiveDescription,
        command: buildInstallToolsCommand(const ['zip', 'unzip', '7z']),
        providedTools: const ['zip', 'unzip', '7z'],
        isSystem: true,
      ),
      RemoteScript(
        id: 'install-docker',
        name: dockerName,
        description: dockerDescription,
        command: buildInstallDockerCommand(),
        providedTools: const ['docker'],
        isSystem: true,
      ),
      RemoteScript(
        id: 'install-tmux',
        name: tmuxName,
        description: tmuxDescription,
        command: buildInstallToolsCommand(const ['tmux']),
        providedTools: const ['tmux'],
        isSystem: true,
      ),
    ];
  }

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

  Future<void> run(
    Server server, {
    required RemoteScript script,
    required void Function(String chunk) onOutput,
    SshKey? key,
  }) {
    return runCommand(
      server,
      command: script.command,
      onOutput: onOutput,
      key: key,
    );
  }

  Future<void> runCommand(
    Server server, {
    required String command,
    required void Function(String chunk) onOutput,
    SshKey? key,
  }) {
    return _withSsh(server, key: key, (ssh) async {
      final output = await ssh.executeStreaming(
        'set -e\n$command\nprintf "\\n$_okMarker"',
        onOutput: (chunk) => onOutput(chunk.replaceAll(_okMarker, '')),
      );
      if (!output.contains(_okMarker)) {
        throw RemoteScriptException(output.trim());
      }
    });
  }

  Future<T> _withSsh<T>(
    Server server,
    Future<T> Function(SshClientSession ssh) action, {
    SshKey? key,
  }) async {
    final lease = await _connectionManager.acquire(server, key: key);
    try {
      return await action(lease.service);
    } catch (error) {
      if (_shouldDropConnection(error)) {
        _connectionManager.markUnhealthy(server.id, lease.service);
      }
      rethrow;
    } finally {
      lease.release();
    }
  }

  bool _shouldDropConnection(Object error) {
    return error is SSHStateError ||
        error is SSHChannelOpenError ||
        error is SocketException ||
        error is StateError;
  }
}

class RemoteScriptException implements Exception {
  final String message;

  const RemoteScriptException(this.message);

  @override
  String toString() => message.isEmpty ? 'Remote script failed' : message;
}

String buildInstallDockerCommand() {
  return r'''
if [ "$(id -u)" = "0" ]; then SUDO=""; else SUDO="sudo"; fi
if command -v apt-get >/dev/null 2>&1; then $SUDO apt-get update && ($SUDO apt-get install -y docker.io docker-compose-plugin || $SUDO apt-get install -y docker.io docker-compose)
elif command -v dnf >/dev/null 2>&1; then $SUDO dnf install -y docker docker-compose-plugin || $SUDO dnf install -y docker docker-compose
elif command -v yum >/dev/null 2>&1; then $SUDO yum install -y docker docker-compose-plugin || $SUDO yum install -y docker docker-compose
elif command -v pacman >/dev/null 2>&1; then $SUDO pacman -Sy --noconfirm docker docker-compose
elif command -v apk >/dev/null 2>&1; then $SUDO apk add docker docker-cli-compose
elif command -v zypper >/dev/null 2>&1; then $SUDO zypper --non-interactive install docker docker-compose
else printf '__ORBITA_NO_PACKAGE_MANAGER__'; exit 127
fi
if command -v systemctl >/dev/null 2>&1; then $SUDO systemctl enable --now docker || true; fi
if command -v service >/dev/null 2>&1; then $SUDO service docker start || true; fi
if [ -n "${USER:-}" ] && [ "$USER" != "root" ] && command -v usermod >/dev/null 2>&1; then $SUDO usermod -aG docker "$USER" || true; fi
docker --version
''';
}
