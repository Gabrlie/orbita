import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class OrbitaSelectMenuTile<T> extends StatelessWidget with FTileMixin {
  final String title;
  final T value;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;
  final String? subtitle;
  final Widget? prefix;
  final bool enabled;

  const OrbitaSelectMenuTile({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    this.subtitle,
    this.prefix,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FSelectMenuTile<T>(
      key: ValueKey<Object?>((title, value)),
      prefix: prefix,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      details: Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48),
          child: Text(
            labelBuilder(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ),
      enabled: enabled,
      selectControl: FMultiValueControl.managedRadio(
        initial: value,
        onChange: (selection) {
          if (selection.isEmpty) return;
          onChanged(selection.first);
        },
      ),
      menu: [
        for (final option in options)
          FSelectTile<T>(title: Text(labelBuilder(option)), value: option),
      ],
    );
  }
}

class OrbitaSwipeableTabs<T> extends StatelessWidget {
  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final Widget? Function(T value)? iconBuilder;
  final ValueChanged<T> onChanged;
  final double height;

  const OrbitaSwipeableTabs({
    super.key,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
    this.iconBuilder,
    this.height = 52,
  }) : assert(values.length > 0, 'values must not be empty');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = values.indexOf(value).clamp(0, values.length - 1);

    return SizedBox(
      height: height,
      child: FTabs(
        expands: true,
        style: FTabsStyleDelta.delta(
          spacing: 0,
          decoration: DecorationDelta.value(
            ShapeDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          indicatorDecoration: DecorationDelta.value(
            ShapeDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          labelTextStyle: FVariants.from(
            theme.textTheme.labelLarge!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            variants: {
              [FTabVariant.selected]: TextStyleDelta.delta(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            },
          ),
        ),
        contentPhysics: const BouncingScrollPhysics(),
        control: FTabControl.lifted(
          index: selectedIndex,
          onChange: (index) => onChanged(values[index]),
        ),
        children: [
          for (final option in values)
            FTabEntry(
              label: _SwipeableTabLabel(
                icon: iconBuilder?.call(option),
                label: labelBuilder(option),
                selected: option == value,
              ),
              child: const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class _SwipeableTabLabel extends StatelessWidget {
  final Widget? icon;
  final String label;
  final bool selected;

  const _SwipeableTabLabel({
    required this.label,
    required this.selected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    if (icon == null) return Text(label);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconTheme.merge(data: IconThemeData(color: color), child: icon!),
        const SizedBox(width: 8),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
