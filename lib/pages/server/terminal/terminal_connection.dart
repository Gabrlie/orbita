part of 'terminal_page.dart';

extension _TerminalConnection on _TerminalPageState {
  Future<SshShellSession> _openShellWithRetry(
    Server server,
    SshKey? key,
    SshLogger log,
    AppLocalizations l10n,
  ) async {
    try {
      return await _openShellForNewLease(server, key, l10n);
    } catch (error) {
      if (!_shouldRetryShellOpen(error)) {
        rethrow;
      }
      log.error('Pooled SSH connection is stale', '$error');
      _discardCurrentConnection();
      return _openShellForNewLease(server, key, l10n);
    }
  }

  Future<SshShellSession> _openShellForNewLease(
    Server server,
    SshKey? key,
    AppLocalizations l10n,
  ) async {
    await _openConnectionLease(server, key, l10n);
    return _openShellOnCurrentLease(l10n);
  }

  Future<void> _openConnectionLease(
    Server server,
    SshKey? key,
    AppLocalizations l10n,
  ) async {
    _connectionLease = await ref
        .read(sshConnectionManagerProvider)
        .acquire(server, key: key);
    if (widget.launchMode == TerminalLaunchMode.tmux) {
      await _ensureTmuxAvailable(_connectionLease!.service, l10n);
    }
  }

  Future<SshShellSession> _openShellOnCurrentLease(AppLocalizations l10n) {
    final ssh = _connectionLease?.service;
    if (ssh == null) {
      throw StateError(l10n.sshDisconnected);
    }
    return ssh.openShell(
      columns: _terminal.viewWidth,
      rows: _terminal.viewHeight,
    );
  }

  Future<void> _ensureTmuxAvailable(
    SshClientSession ssh,
    AppLocalizations l10n,
  ) async {
    final output = await ssh.execute(
      r'command -v tmux >/dev/null 2>&1 && printf available || printf missing',
    );
    if (output.trim() != 'available') {
      throw StateError(l10n.terminalTmuxUnavailable);
    }
  }

  void _discardCurrentConnection() {
    final lease = _connectionLease;
    if (lease == null) return;
    ref
        .read(sshConnectionManagerProvider)
        .markUnhealthy(lease.serverId, lease.service);
    _releaseConnection();
  }

  bool _shouldRetryShellOpen(Object error) {
    final message = error.toString();
    return message.contains('Connection closed while waiting for channel open');
  }
}
