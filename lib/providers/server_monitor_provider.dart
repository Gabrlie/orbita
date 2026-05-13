import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/server_status.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/app_lifecycle_provider.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/ssh_connection_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/server_refresh_provider.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/providers/ssh_log_provider.dart';
import 'package:orbita/services/ssh_connection_manager.dart';
import 'package:orbita/services/ssh_service.dart';
import 'package:orbita/widgets/os_icon.dart';

/// Streams live [ServerStatus] for a single server via SSH.
/// Auto-disposes when no longer watched (e.g., leaving home page).
final serverStatusProvider = StreamProvider.autoDispose
    .family<ServerStatus?, String>((ref, serverId) async* {
      ref.watch(serverRefreshProvider(serverId));
      final settings = ref.watch(metricSettingsProvider);
      final server = ref.read(serverByIdProvider(serverId));
      if (server == null) {
        yield null;
        return;
      }

      final log = SshLogger(ref, serverId);
      final lifecycle = ref.read(appLifecycleProvider.notifier);
      SshConnectionLease? lease;
      ref.onDispose(() {
        lease?.release();
        log.info('Monitoring stopped');
      });

      SshKey? key;
      try {
        key = await resolveServerKey(server, ref.read(keyListProvider.future));
      } catch (e) {
        log.error('Load SSH key failed', '$e');
        yield null;
        return;
      }
      if (server.authType == AuthType.key && key == null) {
        log.error('SSH key not found');
        yield null;
        return;
      }

      var reconnectDelay = const Duration(seconds: 2);
      while (true) {
        try {
          log.info('Connecting to ${server.displayEndpoint}...');
          lease = await ref
              .read(sshConnectionManagerProvider)
              .acquire(server, key: key);
          log.info('Connected');
        } catch (e) {
          log.error('Connection failed', '$e');
          yield null;
          if (_isAuthenticationFailure(e) || !settings.autoReconnect) return;
          await Future.delayed(reconnectDelay);
          reconnectDelay = _nextReconnectDelay(reconnectDelay);
          continue;
        }

        final ssh = lease.service;
        await _detectServerOs(ref, server, ssh, log);
        reconnectDelay = const Duration(seconds: 2);

        RawNetIoSnapshot? prevSnapshot;
        var suppressDisconnect = false;
        while (!ssh.isClosed) {
          await lifecycle.waitUntilResumed();
          try {
            if (lifecycle.isResumeRecoveryWindow) {
              await ssh.execute('true');
            }
            final output = await ssh.execute(monitorCommand);
            log.command('status', output);
            final status = parseMonitorOutput(output, prevSnapshot);
            prevSnapshot = status.snapshot;
            yield status;
          } catch (e) {
            log.error('Fetch failed', '$e');
            ref
                .read(sshConnectionManagerProvider)
                .markUnhealthy(server.id, ssh);
            suppressDisconnect = lifecycle.isResumeRecoveryWindow;
            if (!suppressDisconnect) yield null;
            break;
          }
          await _delayWhileResumed(settings.refreshInterval, lifecycle);
        }

        if (ssh.isClosed && !suppressDisconnect) {
          log.error('Connection lost');
          yield null;
        }

        lease.release();
        lease = null;
        if (!settings.autoReconnect) return;
        if (!suppressDisconnect) {
          await Future.delayed(reconnectDelay);
        }
        reconnectDelay = _nextReconnectDelay(reconnectDelay);
      }
    });

Future<void> _detectServerOs(
  Ref ref,
  Server server,
  SshClientSession ssh,
  SshLogger log,
) async {
  try {
    final osOutput = await ssh.execute(
      r'(. /etc/os-release 2>/dev/null && echo "$ID") || echo unknown',
    );
    final detectedOs = osTypeFromString(osOutput.trim());
    if (detectedOs != OsType.unknown && detectedOs != server.osType) {
      ref
          .read(serverListProvider.notifier)
          .updateServer(server.copyWith(osType: detectedOs));
      log.info('Detected OS: ${detectedOs.name}');
    }
  } catch (_) {}
}

Duration _nextReconnectDelay(Duration current) {
  final nextSeconds = current.inSeconds * 2;
  return Duration(seconds: nextSeconds > 30 ? 30 : nextSeconds);
}

bool _isAuthenticationFailure(Object error) {
  final message = error.toString();
  return message.contains('SSHAuthFailError') ||
      message.contains('All authentication methods failed');
}

Future<void> _delayWhileResumed(
  Duration duration,
  AppLifecycleController lifecycle,
) async {
  final deadline = DateTime.now().add(duration);
  while (DateTime.now().isBefore(deadline)) {
    await lifecycle.waitUntilResumed();
    final remaining = deadline.difference(DateTime.now());
    if (remaining <= Duration.zero) return;
    final slice = remaining > const Duration(milliseconds: 500)
        ? const Duration(milliseconds: 500)
        : remaining;
    await Future.delayed(slice);
  }
}

Future<SshKey?> resolveServerKey(
  Server server,
  Future<List<SshKey>> keys,
) async {
  if (server.authType != AuthType.key || server.keyId == null) {
    return null;
  }

  final loadedKeys = await keys;
  return loadedKeys.where((key) => key.id == server.keyId).firstOrNull;
}
