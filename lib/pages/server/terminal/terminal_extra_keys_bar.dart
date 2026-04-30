import 'package:flutter/material.dart';
import 'package:orbita/pages/server/terminal/terminal_extra_key_controller.dart';

class TerminalExtraKeysBar extends StatelessWidget {
  final bool ctrlEnabled;
  final bool altEnabled;
  final ValueChanged<TerminalExtraKey> onPressed;

  const TerminalExtraKeysBar({
    super.key,
    required this.ctrlEnabled,
    required this.altEnabled,
    required this.onPressed,
  });

  static const _firstRow = [
    _KeySpec.text(TerminalExtraKey.escape, 'ESC'),
    _KeySpec.text(TerminalExtraKey.slash, '/'),
    _KeySpec.text(TerminalExtraKey.minus, '-'),
    _KeySpec.text(TerminalExtraKey.home, 'HOME'),
    _KeySpec.icon(TerminalExtraKey.arrowUp, Icons.keyboard_arrow_up),
    _KeySpec.text(TerminalExtraKey.end, 'END'),
    _KeySpec.text(TerminalExtraKey.pageUp, 'PGUP'),
  ];

  static const _secondRow = [
    _KeySpec.text(TerminalExtraKey.tab, 'TAB'),
    _KeySpec.text(TerminalExtraKey.ctrl, 'CTRL'),
    _KeySpec.text(TerminalExtraKey.alt, 'ALT'),
    _KeySpec.icon(TerminalExtraKey.arrowLeft, Icons.keyboard_arrow_left),
    _KeySpec.icon(TerminalExtraKey.arrowDown, Icons.keyboard_arrow_down),
    _KeySpec.icon(TerminalExtraKey.arrowRight, Icons.keyboard_arrow_right),
    _KeySpec.text(TerminalExtraKey.pageDown, 'PGDN'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRow(context, _firstRow),
              const SizedBox(height: 6),
              _buildRow(context, _secondRow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, List<_KeySpec> specs) {
    return Row(
      children: [
        for (final spec in specs) ...[
          Expanded(
            child: _KeyButton(
              spec: spec,
              selected: _selected(spec),
              onPressed: onPressed,
            ),
          ),
          if (spec != specs.last) const SizedBox(width: 6),
        ],
      ],
    );
  }

  bool _selected(_KeySpec spec) {
    return switch (spec.key) {
      TerminalExtraKey.ctrl => ctrlEnabled,
      TerminalExtraKey.alt => altEnabled,
      _ => false,
    };
  }
}

class _KeyButton extends StatelessWidget {
  final _KeySpec spec;
  final bool selected;
  final ValueChanged<TerminalExtraKey> onPressed;

  const _KeyButton({
    required this.spec,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = selected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final foreground = selected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return SizedBox(
      height: 34,
      child: FilledButton.tonal(
        onPressed: () => onPressed(spec.key),
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        child: spec.icon == null
            ? Text(spec.label!)
            : Icon(spec.icon, size: 20),
      ),
    );
  }
}

class _KeySpec {
  final TerminalExtraKey key;
  final String? label;
  final IconData? icon;

  const _KeySpec.text(this.key, this.label) : icon = null;

  const _KeySpec.icon(this.key, this.icon) : label = null;
}
