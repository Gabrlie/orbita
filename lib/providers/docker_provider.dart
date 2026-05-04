import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/docker_models.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/providers/key_provider.dart';
import 'package:orbita/providers/server_monitor_provider.dart';
import 'package:orbita/providers/server_provider.dart';
import 'package:orbita/providers/ssh_connection_provider.dart';
import 'package:orbita/services/docker_service.dart';

final dockerServiceProvider = Provider<DockerService>((ref) {
  return DockerService(ref.watch(sshConnectionManagerProvider));
});

final dockerRefreshProvider =
    NotifierProvider.family<DockerRefreshNotifier, int, String>(
      DockerRefreshNotifier.new,
    );

class DockerRefreshNotifier extends Notifier<int> {
  final String serverId;

  DockerRefreshNotifier(this.serverId);

  @override
  int build() => 0;

  void refresh() => state += 1;
}

final dockerSnapshotProvider = FutureProvider.autoDispose
    .family<DockerSnapshot, String>((ref, serverId) async {
      ref.watch(dockerRefreshProvider(serverId));
      final server = ref.read(serverByIdProvider(serverId));
      if (server == null) {
        return const DockerSnapshot(
          availability: DockerAvailability(
            state: DockerAvailabilityState.error,
          ),
        );
      }
      final key = await resolveServerKey(
        server,
        ref.read(keyListProvider.future),
      );
      if (server.authType == AuthType.key && key == null) {
        return const DockerSnapshot(
          availability: DockerAvailability(
            state: DockerAvailabilityState.error,
            message: 'SSH key not found',
          ),
        );
      }
      return ref.read(dockerServiceProvider).loadSnapshot(server, key: key);
    });

Future<SshKey?> resolveDockerKey(WidgetRef ref, Server server) {
  return resolveServerKey(server, ref.read(keyListProvider.future));
}
