import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/server_group.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:uuid/uuid.dart';

const _keyServerGroups = 'server_groups';

final serverGroupProvider =
    NotifierProvider<ServerGroupNotifier, ServerGroupState>(
      ServerGroupNotifier.new,
    );

class ServerGroupNotifier extends Notifier<ServerGroupState> {
  @override
  ServerGroupState build() {
    final prefs = ref.read(sharedPrefsProvider);
    final raw = prefs.getString(_keyServerGroups);
    if (raw == null || raw.isEmpty) return const ServerGroupState();
    try {
      return ServerGroupState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const ServerGroupState();
    }
  }

  Future<void> addGroup(String name) async {
    final group = ServerGroup(
      id: const Uuid().v4(),
      name: name.trim(),
      createdAt: DateTime.now(),
    );
    await _save(
      ServerGroupState(
        groups: [...state.groups, group],
        assignments: state.assignments,
        serverOrders: state.serverOrders,
      ),
    );
  }

  Future<void> renameGroup(String id, String name) async {
    await _save(
      ServerGroupState(
        groups: state.groups
            .map((group) => group.id == id ? group.copyWith(name: name) : group)
            .toList(),
        assignments: state.assignments,
        serverOrders: state.serverOrders,
      ),
    );
  }

  Future<void> deleteGroup(String id) async {
    await _save(
      ServerGroupState(
        groups: state.groups.where((group) => group.id != id).toList(),
        assignments: {
          for (final entry in state.assignments.entries)
            if (entry.value != id) entry.key: entry.value,
        },
        serverOrders: {
          for (final entry in state.serverOrders.entries)
            if (entry.key != id) entry.key: entry.value,
        },
      ),
    );
  }

  Future<void> assignServer(String serverId, String? groupId) async {
    await moveServer(serverId: serverId, groupId: groupId);
  }

  Future<void> reorderGroup(String draggedId, String targetId) async {
    if (draggedId == targetId) return;
    final groups = [...state.groups];
    final from = groups.indexWhere((group) => group.id == draggedId);
    final to = groups.indexWhere((group) => group.id == targetId);
    if (from < 0 || to < 0) return;
    final group = groups.removeAt(from);
    groups.insert(to, group);
    await _save(
      ServerGroupState(
        groups: groups,
        assignments: state.assignments,
        serverOrders: state.serverOrders,
      ),
    );
  }

  Future<void> moveServer({
    required String serverId,
    required String? groupId,
    String? beforeServerId,
  }) async {
    final next = {...state.assignments};
    final normalizedGroupId = groupId == ungroupedServerGroupId
        ? null
        : groupId;
    if (normalizedGroupId == null) {
      next.remove(serverId);
    } else {
      next[serverId] = normalizedGroupId;
    }

    final orderKey = normalizedGroupId ?? ungroupedServerGroupId;
    final orders = {
      for (final entry in state.serverOrders.entries)
        entry.key: [...entry.value]..remove(serverId),
    };
    final targetOrder = orders[orderKey] ?? <String>[];
    final beforeIndex = beforeServerId == null
        ? -1
        : targetOrder.indexOf(beforeServerId);
    if (beforeIndex >= 0) {
      targetOrder.insert(beforeIndex, serverId);
    } else {
      targetOrder.add(serverId);
    }
    orders[orderKey] = targetOrder;
    orders.removeWhere((_, value) => value.isEmpty);
    await _save(
      ServerGroupState(
        groups: state.groups,
        assignments: next,
        serverOrders: orders,
      ),
    );
  }

  Future<void> _save(ServerGroupState next) async {
    state = next;
    await ref
        .read(sharedPrefsProvider)
        .setString(_keyServerGroups, jsonEncode(next.toJson()));
  }
}

List<ServerGroupBucket> groupServersForDisplay({
  required List<Server> servers,
  required ServerGroupState groupState,
  required String unnamedGroupName,
}) {
  final validGroupIds = groupState.groups.map((group) => group.id).toSet();
  final buckets = <ServerGroupBucket>[];

  for (final group in groupState.groups) {
    final groupedServers = _sortServers(
      servers
          .where((server) => groupState.assignments[server.id] == group.id)
          .toList(),
      groupState.serverOrders[group.id],
    );
    buckets.add(
      ServerGroupBucket(
        id: group.id,
        name: group.name,
        isUngrouped: false,
        servers: groupedServers,
      ),
    );
  }

  final ungroupedServers = _sortServers(
    servers.where((server) {
      final groupId = groupState.assignments[server.id];
      return groupId == null || !validGroupIds.contains(groupId);
    }).toList(),
    groupState.serverOrders[ungroupedServerGroupId],
  );

  if (ungroupedServers.isNotEmpty || groupState.groups.isEmpty) {
    buckets.add(
      ServerGroupBucket(
        id: ungroupedServerGroupId,
        name: unnamedGroupName,
        isUngrouped: true,
        servers: ungroupedServers,
      ),
    );
  }
  return buckets;
}

bool shouldShowServerGroupHeaders(List<ServerGroupBucket> buckets) {
  return !(buckets.length == 1 && buckets.first.isUngrouped);
}

List<Server> _sortServers(List<Server> servers, List<String>? order) {
  if (order == null || order.isEmpty) return servers;
  final byId = {for (final server in servers) server.id: server};
  final orderedIds = order.where(byId.containsKey).toSet();
  return [
    for (final id in order)
      if (byId[id] != null) byId[id]!,
    for (final server in servers)
      if (!orderedIds.contains(server.id)) server,
  ];
}
