part of 'ssh_connection_manager.dart';

typedef SshServiceConnector =
    Future<SshClientSession> Function({
      required String host,
      required int port,
      required String username,
      String? password,
      SshKey? key,
    });

typedef ServerEndpointResolver =
    Future<ResolvedEndpointLease> Function(Server server);

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

class ResolvedEndpointLease {
  final Server server;
  final Future<void> Function()? _release;
  bool _released = false;

  ResolvedEndpointLease({
    required this.server,
    Future<void> Function()? release,
  }) : _release = release;

  ResolvedEndpointLease.direct(Server server) : this(server: server);

  Future<void> release() async {
    if (_released) return;
    _released = true;
    await _release?.call();
  }
}

class _ManagedSshConnection {
  final String serverId;
  final StreamController<SshConnectionLifecycleState> controller =
      StreamController<SshConnectionLifecycleState>.broadcast();

  SshClientSession? service;
  Future<SshClientSession>? connecting;
  ResolvedEndpointLease? endpointLease;
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
