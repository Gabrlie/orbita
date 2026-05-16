import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/settings/appearance/terminal_color_picker_dialog.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/widgets/orbita_forui.dart';
import 'package:orbita/widgets/settings_tiles.dart';

class TerminalAppearanceSection extends ConsumerWidget {
  const TerminalAppearanceSection({super.key});

  static const _foregroundColors = [
    Color(0xFFECEFF4),
    Color(0xFFFFFFFF),
    Color(0xFFB8F7D4),
    Color(0xFFFFF0B3),
    Color(0xFFFFB4AB),
  ];

  static const _backgroundColors = [
    Color(0xFF0B1020),
    Color(0xFF000000),
    Color(0xFF10201A),
    Color(0xFF1D1B20),
    Color(0xFF111111),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appearance = ref.watch(terminalAppearanceProvider);

    return OrbitaSettingsTileGroup(
      title: l10n.terminalAppearance,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      children: [
        OrbitaSelectMenuTile<TerminalFontFamily>(
          title: l10n.terminalFontFamily,
          value: appearance.fontFamily,
          options: TerminalFontFamily.values,
          labelBuilder: (value) => switch (value) {
            TerminalFontFamily.jetbrainsMono => l10n.terminalFontJetBrainsMono,
            TerminalFontFamily.system => l10n.terminalFontSystem,
            TerminalFontFamily.monospace => l10n.terminalFontMonospace,
            TerminalFontFamily.custom => l10n.terminalFontCustom,
          },
          prefix: const Icon(Ionicons.code_slash_outline),
          onChanged: (value) {
            ref
                .read(terminalAppearanceProvider.notifier)
                .set(appearance.copyWith(fontFamily: value));
          },
        ),
        if (appearance.fontFamily == TerminalFontFamily.custom)
          FTile.raw(
            child: TextFormField(
              initialValue: appearance.customFontFamily,
              decoration: InputDecoration(
                labelText: l10n.terminalCustomFontFamily,
                prefixIcon: const Icon(Ionicons.text_outline),
              ),
              onChanged: (value) => _set(
                ref,
                appearance.copyWith(customFontFamily: value),
              ),
            ),
          ),
        FTile.raw(child: _FontSizeSlider(appearance: appearance)),
        FTile.raw(
          child: _TerminalColorRow(
            title: l10n.terminalForegroundColor,
            selected: appearance.foregroundColor,
            colors: _foregroundColors,
            onSelected: (color) => _set(
              ref,
              appearance.copyWith(foregroundColor: color),
            ),
          ),
        ),
        FTile.raw(
          child: _TerminalColorRow(
            title: l10n.terminalBackgroundColor,
            selected: appearance.backgroundColor,
            colors: _backgroundColors,
            onSelected: (color) => _set(
              ref,
              appearance.copyWith(backgroundColor: color),
            ),
          ),
        ),
      ],
    );
  }

  void _set(WidgetRef ref, TerminalAppearance appearance) {
    ref.read(terminalAppearanceProvider.notifier).set(appearance);
  }
}

class _FontSizeSlider extends ConsumerWidget {
  final TerminalAppearance appearance;

  const _FontSizeSlider({required this.appearance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Ionicons.resize_outline,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.terminalFontSize,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Text(
              appearance.fontSize.round().toString(),
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 10),
        FSlider(
          control: FSliderControl.liftedDiscrete(
            value: FSliderValue(max: _positionForSize(appearance.fontSize)),
            onChange: (value) {
              final fontSize = _sizeForPosition(value.max).toDouble();
              if (fontSize == appearance.fontSize) return;
              ref
                  .read(terminalAppearanceProvider.notifier)
                  .set(appearance.copyWith(fontSize: fontSize));
            },
          ),
          marks: [
            for (var size = 8; size <= 24; size++)
              FSliderMark(
                value: (size - 8) / 16,
                label: switch (size) {
                  8 || 16 || 24 => Text('$size'),
                  _ => null,
                },
              ),
          ],
        ),
      ],
    );
  }

  static double _positionForSize(double size) {
    return (((size.round().clamp(8, 24) - 8) / 16).clamp(0, 1))
        .toDouble();
  }

  static int _sizeForPosition(double position) {
    return (8 + position.clamp(0, 1) * 16).round().clamp(8, 24).toInt();
  }
}

class _TerminalColorRow extends StatelessWidget {
  final String title;
  final Color selected;
  final List<Color> colors;
  final ValueChanged<Color> onSelected;

  const _TerminalColorRow({
    required this.title,
    required this.selected,
    required this.colors,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
        Wrap(
          spacing: 8,
          children: [
            for (final color in colors)
              _TerminalColorOption(
                color: color,
                selected: selected == color,
                onTap: () => onSelected(color),
              ),
            _TerminalColorOption(
              color: selected,
              selected: !colors.contains(selected),
              icon: Ionicons.color_palette_outline,
              onTap: () async {
                final color = await showOrbitaDialog<Color>(
                  context: context,
                  builder: (context, animation) => TerminalColorPickerDialog(
                    initialColor: selected,
                    animation: animation,
                  ),
                );
                if (color != null) onSelected(color);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _TerminalColorOption extends StatelessWidget {
  final Color color;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  const _TerminalColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: icon != null
            ? Icon(icon, size: 17, color: _checkColor(color))
            : selected
            ? Icon(Ionicons.checkmark, size: 18, color: _checkColor(color))
            : null,
      ),
    );
  }

  Color _checkColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}
