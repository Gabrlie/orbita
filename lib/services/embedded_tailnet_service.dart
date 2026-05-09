import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:orbita/models/server.dart';
import 'package:orbita/models/tailnet_models.dart';
import 'package:orbita/services/ssh_connection_manager.dart';

abstract interface class EmbeddedTailnetGateway {
  Future<String> start();

  Future<String> status();

  Future<String> authUrl();

  Future<void> openUrl(String url);

  Future<String> listPeers();

  Future<String> openTcpProxy(String target, int port);

  Future<void> closeProxy(String id);

  Future<void> stop();

  Future<void> clearState();
}

class MethodChannelTailnetGateway implements EmbeddedTailnetGateway {
  static const _channel = MethodChannel('top.gabrlie.orbita/tailnet');

  @override
  Future<String> start() async {
    return await _channel.invokeMethod<String>('start') ?? '{}';
  }

  @override
  Future<String> status() async {
    return await _channel.invokeMethod<String>('status') ?? '{}';
  }

  @override
  Future<String> authUrl() async {
    return await _channel.invokeMethod<String>('authUrl') ?? '';
  }

  @override
  Future<void> openUrl(String url) {
    return _channel.invokeMethod<void>('openUrl', {'url': url});
  }

  @override
  Future<String> listPeers() async {
    return await _channel.invokeMethod<String>('listPeers') ?? '[]';
  }

  @override
  Future<String> openTcpProxy(String target, int port) async {
    return await _channel.invokeMethod<String>('openTcpProxy', {
          'target': target,
          'port': port,
        }) ??
        '{}';
  }

  @override
  Future<void> closeProxy(String id) {
    return _channel.invokeMethod<void>('closeProxy', {'id': id});
  }

  @override
  Future<void> stop() {
    return _channel.invokeMethod<void>('stop');
  }

  @override
  Future<void> clearState() {
    return _channel.invokeMethod<void>('clearState');
  }
}

class EmbeddedTailnetService {
  EmbeddedTailnetService({
    EmbeddedTailnetGateway? gateway,
    Duration startupTimeout = const Duration(seconds: 20),
    Duration pollInterval = const Duration(milliseconds: 500),
  }) : _gateway = gateway ?? MethodChannelTailnetGateway(),
       _startupTimeout = startupTimeout,
       _pollInterval = pollInterval;

  final EmbeddedTailnetGateway _gateway;
  final Duration _startupTimeout;
  final Duration _pollInterval;

  Future<TailnetStatus> start() async {
    return _parseStatus(await _gateway.start());
  }

  Future<TailnetStatus> startWithPeers() async {
    final status = await start();
    if (!status.isRunning) return status;
    final peers = await listPeers();
    return status.copyWith(authUrl: '', peers: peers);
  }

  Future<TailnetStatus> status() async {
    return _parseStatus(await _gateway.status());
  }

  Future<String> authUrl() => _gateway.authUrl();

  Future<void> openAuthUrl() async {
    final url = await authUrl();
    if (url.trim().isEmpty) {
      throw const TailnetException('Tailnet login URL is unavailable');
    }
    await _gateway.openUrl(url);
  }

  Future<List<TailnetPeer>> listPeers() async {
    await ensureRunning();
    final decoded = jsonDecode(await _gateway.listPeers()) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(TailnetPeer.fromJson)
        .where((peer) => !peer.isSelf)
        .toList(growable: false);
  }

  Future<ResolvedEndpointLease> resolveEndpoint(Server server) async {
    if (server.connectionMode != ServerConnectionMode.tailscale) {
      return ResolvedEndpointLease.direct(server);
    }
    final target = server.tailnetTarget;
    if (target == null || target.isEmpty) {
      throw const TailnetException('Tailnet peer is not selected');
    }
    await ensureRunning();
    final proxy = TailnetProxy.fromJson(
      jsonDecode(await _gateway.openTcpProxy(target, server.port))
          as Map<String, dynamic>,
    );
    if (proxy.port <= 0 || proxy.id.isEmpty) {
      throw const TailnetException('Tailnet proxy did not start');
    }
    return ResolvedEndpointLease(
      server: server.copyWith(host: proxy.host, port: proxy.port),
      release: () => _gateway.closeProxy(proxy.id),
    );
  }

  Future<void> stop() => _gateway.stop();

  Future<void> clearState() => _gateway.clearState();

  Future<TailnetStatus> ensureRunning() async {
    var current = await start();
    if (current.isRunning) return current.copyWith(authUrl: '');
    _throwIfTerminalStartupState(current);

    final deadline = DateTime.now().add(_startupTimeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(_pollInterval);
      current = await status();
      if (current.isRunning) return current.copyWith(authUrl: '');
      _throwIfTerminalStartupState(current);
    }
    throw const TailnetException('Tailnet is still starting');
  }

  void _throwIfTerminalStartupState(TailnetStatus status) {
    if (status.needsLogin) {
      throw const TailnetException('Tailnet login is required');
    }
    if (status.error.isNotEmpty || status.isUnavailable) {
      throw TailnetException(
        status.error.isEmpty ? 'Tailnet is unavailable' : status.error,
      );
    }
  }

  TailnetStatus _parseStatus(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return TailnetStatus.fromJson(decoded);
  }
}

class TailnetException implements Exception {
  final String message;

  const TailnetException(this.message);

  @override
  String toString() => message;
}
