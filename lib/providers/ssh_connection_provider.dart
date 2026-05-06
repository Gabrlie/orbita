import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/services/ssh_connection_manager.dart';

final sshConnectionManagerProvider = Provider<SshConnectionManager>((ref) {
  final settings = ref.watch(
    metricSettingsProvider.select(
      (settings) => (
        connectTimeout: settings.sshConnectTimeout,
        keepAliveInterval: settings.keepAliveInterval,
      ),
    ),
  );
  final manager = SshConnectionManager(
    connectTimeout: settings.connectTimeout,
    keepAliveInterval: settings.keepAliveInterval,
  );
  ref.onDispose(() {
    manager.disconnectAll();
  });
  return manager;
});
