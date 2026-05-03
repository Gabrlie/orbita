import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:orbita/l10n/app_localizations.dart';
import 'package:orbita/pages/settings/appearance/terminal_color_picker_dialog.dart';
import 'package:orbita/providers/settings_provider.dart';
import 'package:orbita/widgets/common.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.terminalAppearance,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: _FontFamilyField(appearance: appearance),
                ),
              ),
              if (appearance.fontFamily == TerminalFontFamily.custom) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
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
                ),
              ],
              const SizedBox(height: 16),
              _FontSizeSlider(appearance: appearance),
              const SizedBox(height: 16),
              _TerminalColorRow(
                title: l10n.terminalForegroundColor,
                selected: appearance.foregroundColor,
                colors: _foregroundColors,
                onSelected: (color) =>
                    _set(ref, appearance.copyWith(foregroundColor: color)),
              ),
              const SizedBox(height: 14),
              _TerminalColorRow(
                title: l10n.terminalBackgroundColor,
                selected: appearance.backgroundColor,
                colors: _backgroundColors,
                onSelected: (color) =>
                    _set(ref, appearance.copyWith(backgroundColor: color)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _set(WidgetRef ref, TerminalAppearance appearance) {
    ref.read(terminalAppearanceProvider.notifier).set(appearance);
  }
}

class _FontFamilyField extends ConsumerWidget {
  final TerminalAppearance appearance;

  const _FontFamilyField({required this.appearance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<TerminalFontFamily>(
      initialValue: appearance.fontFamily,
      decoration: InputDecoration(
        labelText: l10n.terminalFontFamily,
        prefixIcon: const Icon(Ionicons.code_slash_outline),
      ),
      items: [
        DropdownMenuItem(
          value: TerminalFontFamily.jetbrainsMono,
          child: Text(l10n.terminalFontJetBrainsMono),
        ),
        DropdownMenuItem(
          value: TerminalFontFamily.system,
          child: Text(l10n.terminalFontSystem),
        ),
        DropdownMenuItem(
          value: TerminalFontFamily.monospace,
          child: Text(l10n.terminalFontMonospace),
        ),
        DropdownMenuItem(
          value: TerminalFontFamily.custom,
          child: Text(l10n.terminalFontCustom),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;
        ref
            .read(terminalAppearanceProvider.notifier)
            .set(appearance.copyWith(fontFamily: value));
      },
    );
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
        Slider(
          value: appearance.fontSize,
          min: 8,
          max: 24,
          divisions: 16,
          onChanged: (value) {
            ref
                .read(terminalAppearanceProvider.notifier)
                .set(appearance.copyWith(fontSize: value.roundToDouble()));
          },
        ),
      ],
    );
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
                final color = await showDialog<Color>(
                  context: context,
                  builder: (context) =>
                      TerminalColorPickerDialog(initialColor: selected),
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
