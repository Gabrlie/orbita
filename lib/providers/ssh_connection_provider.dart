import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/services/ssh_connection_manager.dart';

final sshConnectionManagerProvider = Provider<SshConnectionManager>((ref) {
  final manager = SshConnectionManager();
  ref.onDispose(() {
    manager.disconnectAll();
  });
  return manager;
});
