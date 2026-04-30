import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/server_status.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/ssh_connection_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/server_refresh_provider.dart';
import 'package:orbita/providers/ssh_log_provider.dart';
import 'package:orbita/services/ssh_connection_manager.dart';
import 'package:orbita/widgets/os_icon.dart';

/// Streams live [ServerStatus] for a single server via SSH.
/// Auto-disposes when no longer watched (e.g., leaving home page).
final serverStatusProvider = StreamProvider.autoDispose
    .family<ServerStatus?, String>((ref, serverId) async* {
      ref.watch(serverRefreshProvider(serverId));
      final server = ref.read(serverByIdProvider(serverId));
      if (server == null) {
        yield null;
        return;
      }

      final log = SshLogger(ref, serverId);
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

      // Connect
      try {
        log.info('Connecting to ${server.host}:${server.port}...');
        lease = await ref
            .read(sshConnectionManagerProvider)
            .acquire(server, key: key);
        log.info('Connected');
      } catch (e) {
        log.error('Connection failed', '$e');
        yield null;
        return;
      }
      final ssh = lease.service;

      // Auto-detect OS on first connection
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

      // Poll loop
      RawNetIoSnapshot? prevSnapshot;
      while (!ssh.isClosed) {
        try {
          final output = await ssh.execute(monitorCommand);
          log.command('status', output);
          final status = parseMonitorOutput(output, prevSnapshot);
          prevSnapshot = status.snapshot;
          yield status;
        } catch (e) {
          log.error('Fetch failed', '$e');
          yield null;
          return;
        }
        await Future.delayed(const Duration(seconds: 10));
      }

      log.error('Connection lost');
      yield null;
    });

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
