import 'dart:async';

import 'package:orbita/models/server.dart';
import 'package:orbita/models/ssh_key.dart';
import 'package:orbita/services/ssh_service.dart';

typedef SshServiceConnector =
    Future<SshClientSession> Function({
      required String host,
      required int port,
      required String username,
      String? password,
      SshKey? key,
    });

enum SshConnectionLifecycleState { disconnected, connecting, connected, error }

class SshConnectionLease {
  final String serverId;
  final SshClientSession service;
  final void Function(SshClientSession service) _release;

  bool _released = false;

  SshConnectionLease._({
    required this.serverId,
    required this.service,
    required void Function(SshClientSession service) release,
  }) : _release = release;

  void release() {
    if (_released) return;
    _released = true;
    _release(service);
  }
}

class SshConnectionManager {
  SshConnectionManager({
    SshServiceConnector? connector,
    Duration idleTimeout = const Duration(minutes: 2),
  }) : _connector = connector ?? SshService.connect,
       _idleTimeout = idleTimeout;

  final SshServiceConnector _connector;
  final Duration _idleTimeout;
  final Map<String, _ManagedSshConnection> _connections = {};

  Future<SshClientSession> getOrConnect(Server server, {SshKey? key}) {
    return _resolveService(server, key: key, retain: false);
  }

  Future<SshConnectionLease> acquire(Server server, {SshKey? key}) async {
    final service = await _resolveService(server, key: key);
    return SshConnectionLease._(
      serverId: server.id,
      service: service,
      release: (service) => _release(server.id, service),
    );
  }

  Stream<SshConnectionLifecycleState> watchState(String serverId) async* {
    final entry = _entryFor(serverId);
    yield entry.state;
    yield* entry.controller.stream;
  }

  Future<void> disconnect(String serverId) async {
    final entry = _connections[serverId];
    if (entry == null) return;
    entry.refCount = 0;
    _closeEntry(serverId, entry, dispose: true);
  }

  void markUnhealthy(String serverId, SshClientSession service) {
    final entry = _connections[serverId];
    if (entry == null || !identical(entry.service, service)) {
      return;
    }
    _closeEntry(serverId, entry);
  }

  Future<void> disconnectAll() async {
    final serverIds = _connections.keys.toList();
    for (final serverId in serverIds) {
      await disconnect(serverId);
    }
  }

  Future<SshClientSession> _resolveService(
    Server server, {
    required SshKey? key,
    bool retain = true,
  }) async {
    final entry = _entryFor(server.id);
    final fingerprint = _connectionFingerprint(server, key);

    if (retain) {
      entry.cancelIdleClose();
      entry.refCount += 1;
    }

    final existing = entry.service;
    if (existing != null &&
        !existing.isClosed &&
        entry.fingerprint == fingerprint) {
      return existing;
    }

    final pending = entry.connecting;
    if (pending != null && entry.fingerprint == fingerprint) {
      try {
        return await pending;
      } catch (_) {
        if (retain) {
          _rollbackRetain(server.id, entry);
        }
        rethrow;
      }
    }

    if (existing != null || pending != null) {
      _closeEntry(server.id, entry);
    }

    entry.fingerprint = fingerprint;
    entry.emit(SshConnectionLifecycleState.connecting);

    final connecting = _connector(
      host: server.host,
      port: server.port,
      username: server.username,
      password: server.password,
      key: key,
    );
    entry.connecting = connecting;

    try {
      final service = await connecting;
      entry.connecting = null;
      entry.service = service;
      entry.emit(SshConnectionLifecycleState.connected);
      _bindServiceDone(server.id, service);
      return service;
    } catch (_) {
      entry.connecting = null;
      entry.service = null;
      entry.emit(SshConnectionLifecycleState.error);
      if (retain) {
        _rollbackRetain(server.id, entry);
      }
      rethrow;
    }
  }

  void _bindServiceDone(String serverId, SshClientSession service) {
    unawaited(
      service.done.then(
        (_) => _handleServiceClosed(serverId, service),
        onError: (error, stackTrace) => _handleServiceClosed(serverId, service),
      ),
    );
  }

  void _handleServiceClosed(String serverId, SshClientSession service) {
    final entry = _connections[serverId];
    if (entry == null || !identical(entry.service, service)) {
      return;
    }
    entry.service = null;
    entry.connecting = null;
    entry.fingerprint = null;
    entry.emit(SshConnectionLifecycleState.disconnected);
    if (entry.refCount == 0) {
      _disposeEntry(serverId, entry);
    }
  }

  void _release(String serverId, SshClientSession service) {
    final entry = _connections[serverId];
    if (entry == null) return;

    if (entry.refCount > 0) {
      entry.refCount -= 1;
    }

    if (entry.refCount > 0) {
      return;
    }

    if (!identical(entry.service, service) && entry.service != null) {
      return;
    }

    if (entry.service == null) {
      _disposeEntry(serverId, entry);
      return;
    }

    _scheduleIdleClose(serverId, entry, service);
  }

  void _scheduleIdleClose(
    String serverId,
    _ManagedSshConnection entry,
    SshClientSession service,
  ) {
    entry.cancelIdleClose();
    if (_idleTimeout <= Duration.zero) {
      _closeEntry(serverId, entry, dispose: true);
      return;
    }
    entry.idleCloseTimer = Timer(_idleTimeout, () {
      final latest = _connections[serverId];
      if (latest == null ||
          latest.refCount > 0 ||
          !identical(latest.service, service)) {
        return;
      }
      _closeEntry(serverId, latest, dispose: true);
    });
  }

  void _rollbackRetain(String serverId, _ManagedSshConnection entry) {
    if (entry.refCount > 0) {
      entry.refCount -= 1;
    }
    if (entry.refCount == 0 &&
        entry.service == null &&
        entry.connecting == null) {
      _disposeEntry(serverId, entry);
    }
  }

  void _closeEntry(
    String serverId,
    _ManagedSshConnection entry, {
    bool dispose = false,
  }) {
    entry.cancelIdleClose();
    final service = entry.service;
    entry.service = null;
    entry.connecting = null;
    entry.fingerprint = null;
    entry.emit(SshConnectionLifecycleState.disconnected);
    if (service != null && !service.isClosed) {
      service.disconnect();
    }
    if (dispose) {
      _disposeEntry(serverId, entry);
    }
  }

  void _disposeEntry(String serverId, _ManagedSshConnection entry) {
    entry.cancelIdleClose();
    _connections.remove(serverId);
    if (!entry.controller.isClosed) {
      entry.controller.close();
    }
  }

  _ManagedSshConnection _entryFor(String serverId) {
    return _connections.putIfAbsent(
      serverId,
      () => _ManagedSshConnection(serverId),
    );
  }

  String _connectionFingerprint(Server server, SshKey? key) {
    return [
      server.host,
      server.port,
      server.username,
      server.authType.name,
      server.password ?? '',
      server.keyId ?? '',
      key?.id ?? '',
      key?.privateKeyPem.hashCode ?? 0,
      key?.passphrase?.hashCode ?? 0,
    ].join('|');
  }
}

class _ManagedSshConnection {
  final String serverId;
  final StreamController<SshConnectionLifecycleState> controller =
      StreamController<SshConnectionLifecycleState>.broadcast();

  SshClientSession? service;
  Future<SshClientSession>? connecting;
  String? fingerprint;
  int refCount = 0;
  SshConnectionLifecycleState state = SshConnectionLifecycleState.disconnected;
  Timer? idleCloseTimer;

  _ManagedSshConnection(this.serverId);

  void emit(SshConnectionLifecycleState nextState) {
    state = nextState;
    if (!controller.isClosed) {
      controller.add(nextState);
    }
  }

  void cancelIdleClose() {
    idleCloseTimer?.cancel();
    idleCloseTimer = null;
  }
}
