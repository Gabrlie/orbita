import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/services/server_storage_service.dart';

late final SecureStorageService _storageService;

/// Call once in main.dart before runApp.
void initServerStorage() {
  _storageService = SecureStorageService();
}

final storageServiceProvider = Provider<SecureStorageService>(
  (ref) => _storageService,
);

// -- Server List --

final serverListProvider =
    AsyncNotifierProvider<ServerListNotifier, List<Server>>(
  ServerListNotifier.new,
);

class ServerListNotifier extends AsyncNotifier<List<Server>> {
  @override
  Future<List<Server>> build() async {
    return ref.read(storageServiceProvider).loadServers();
  }

  Future<void> addServer(Server server) async {
    final current = <Server>[...(state.value ?? []), server];
    await ref.read(storageServiceProvider).saveServers(current);
    state = AsyncData(current);
  }

  Future<void> updateServer(Server server) async {
    final current = (state.value ?? [])
        .map((s) => s.id == server.id ? server : s)
        .toList();
    await ref.read(storageServiceProvider).saveServers(current);
    state = AsyncData(current);
  }

  Future<void> deleteServer(String id) async {
    final current =
        (state.value ?? []).where((s) => s.id != id).toList();
    await ref.read(storageServiceProvider).saveServers(current);
    state = AsyncData(current);
  }
}

final serverByIdProvider = Provider.family<Server?, String>((ref, id) {
  final servers = ref.watch(serverListProvider).value ?? [];
  return servers.where((s) => s.id == id).firstOrNull;
});
