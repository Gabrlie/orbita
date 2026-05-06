import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/pages/server/terminal/terminal_dashboard.dart';
import 'package:orbita/pages/server/terminal/terminal_extra_key_controller.dart';
import 'package:orbita/pages/server/terminal/terminal_extra_keys_bar.dart';
import 'package:orbita/pages/server/terminal/terminal_snippet_button.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:xterm/xterm.dart';

class TerminalBody extends ConsumerWidget {
  final String serverId;
  final Terminal terminal;
  final bool showExtraKeys;
  final bool showDesktopDashboard;
  final bool connecting;
  final bool ctrlEnabled;
  final bool altEnabled;
  final ValueChanged<TerminalExtraKey> onExtraKey;
  final ValueChanged<String> onSnippetSelected;

  const TerminalBody({
    super.key,
    required this.serverId,
    required this.terminal,
    required this.showExtraKeys,
    required this.showDesktopDashboard,
    required this.connecting,
    required this.ctrlEnabled,
    required this.altEnabled,
    required this.onExtraKey,
    required this.onSnippetSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(terminalAppearanceProvider);
    final terminalView = _buildTerminalView(context, appearance);

    final content = showDesktopDashboard
        ? Row(
            children: [
              Expanded(child: terminalView),
              SizedBox(
                width: 360,
                child: TerminalDashboard(serverId: serverId),
              ),
            ],
          )
        : terminalView;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              content,
              if (connecting) const LinearProgressIndicator(minHeight: 2),
              TerminalSnippetButton(
                right: showDesktopDashboard ? 376 : 16,
                onSelected: onSnippetSelected,
              ),
            ],
          ),
        ),
        if (showExtraKeys)
          TerminalExtraKeysBar(
            ctrlEnabled: ctrlEnabled,
            altEnabled: altEnabled,
            onPressed: onExtraKey,
          ),
      ],
    );
  }

  Widget _buildTerminalView(
    BuildContext context,
    TerminalAppearance appearance,
  ) {
    final theme = _terminalTheme(context, appearance);
    final fontFamily =
        appearance.effectiveFontFamily ??
        Theme.of(context).textTheme.bodyMedium?.fontFamily ??
        'monospace';

    return ColoredBox(
      color: appearance.backgroundColor,
      child: TerminalView(
        terminal,
        autofocus: true,
        hardwareKeyboardOnly: !showExtraKeys,
        theme: theme,
        textStyle: TerminalStyle(
          fontSize: appearance.fontSize,
          fontFamily: fontFamily,
        ),
        keyboardAppearance: Theme.of(context).brightness == Brightness.dark
            ? Brightness.dark
            : Brightness.light,
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}

TerminalTheme _terminalTheme(
  BuildContext context,
  TerminalAppearance appearance,
) {
  const base = TerminalThemes.defaultTheme;
  final primary = Theme.of(context).colorScheme.primary;
  return TerminalTheme(
    cursor: appearance.foregroundColor,
    selection: primary.withAlpha(88),
    foreground: appearance.foregroundColor,
    background: appearance.backgroundColor,
    black: base.black,
    red: base.red,
    green: base.green,
    yellow: base.yellow,
    blue: base.blue,
    magenta: base.magenta,
    cyan: base.cyan,
    white: base.white,
    brightBlack: base.brightBlack,
    brightRed: base.brightRed,
    brightGreen: base.brightGreen,
    brightYellow: base.brightYellow,
    brightBlue: base.brightBlue,
    brightMagenta: base.brightMagenta,
    brightCyan: base.brightCyan,
    brightWhite: base.brightWhite,
    searchHitBackground: base.searchHitBackground,
    searchHitBackgroundCurrent: base.searchHitBackgroundCurrent,
    searchHitForeground: base.searchHitForeground,
  );
}
