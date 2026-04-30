import 'package:orbita/models/server.dart';

enum TerminalLaunchMode { direct, tmux }

TerminalLaunchMode terminalLaunchModeFromQuery(String? raw) {
  return raw == 'tmux' ? TerminalLaunchMode.tmux : TerminalLaunchMode.direct;
}

String? terminalLaunchModeToQuery(TerminalLaunchMode mode) {
  return mode == TerminalLaunchMode.tmux ? 'tmux' : null;
}

String tmuxSessionNameForServer(Server server) {
  final source = server.id.isNotEmpty ? server.id : server.name;
  final sanitized = source.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  return 'orbita_$sanitized';
}
