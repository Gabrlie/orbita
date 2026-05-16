part of 'terminal_tabs_page.dart';

class _TerminalTab {
  final String id;
  final String? serverId;
  final TerminalLaunchMode launchMode;
  final String? initialCommand;
  final String? titleOverride;

  const _TerminalTab({
    required this.id,
    this.serverId,
    this.launchMode = TerminalLaunchMode.direct,
    this.initialCommand,
    this.titleOverride,
  });

  _TerminalTab copyWith({
    String? serverId,
    TerminalLaunchMode? launchMode,
    String? initialCommand,
    String? titleOverride,
    bool clearInitialCommand = false,
    bool clearTitleOverride = false,
  }) {
    return _TerminalTab(
      id: id,
      serverId: serverId ?? this.serverId,
      launchMode: launchMode ?? this.launchMode,
      initialCommand: clearInitialCommand
          ? null
          : initialCommand ?? this.initialCommand,
      titleOverride: clearTitleOverride
          ? null
          : titleOverride ?? this.titleOverride,
    );
  }
}
