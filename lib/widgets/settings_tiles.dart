import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:ionicons/ionicons.dart';

class OrbitaSettingsTileGroup extends StatelessWidget {
  final String? title;
  final List<FTileMixin> children;
  final EdgeInsetsGeometry padding;

  const OrbitaSettingsTileGroup({
    super.key,
    this.title,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(0, 8, 0, 0),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: FTileGroup(
        label: title == null ? null : Text(title!),
        divider: FItemDivider.indented,
        style: FTileGroupStyleDelta.delta(
          decoration: DecorationDelta.value(
            ShapeDecoration(
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        children: children,
      ),
    );
  }
}

FTile orbitaSettingsTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? subtitle,
  String? details,
  Widget? suffix,
  VoidCallback? onPress,
  bool enabled = true,
  bool selected = false,
  bool destructive = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return FTile(
    prefix: Icon(
      icon,
      color: destructive ? colorScheme.error : colorScheme.primary,
      size: 20,
    ),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle),
    details: details == null ? null : Text(details),
    suffix: suffix ??
        (onPress == null
            ? null
            : const Icon(Ionicons.chevron_forward_outline, size: 18)),
    enabled: enabled,
    selected: selected,
    variant: destructive ? FItemVariant.destructive : FItemVariant.primary,
    onPress: enabled ? onPress : null,
  );
}

FTile orbitaSettingsSwitchTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required bool value,
  required ValueChanged<bool>? onChanged,
  String? subtitle,
  bool enabled = true,
}) {
  final callback = onChanged;
  final active = enabled && callback != null;
  return orbitaSettingsTile(
    context,
    icon: icon,
    title: title,
    subtitle: subtitle,
    enabled: active,
    suffix: FSwitch(value: value, enabled: active, onChange: callback),
    onPress: active ? () => callback(!value) : null,
  );
}

FTile orbitaSettingsSelectableTile<T>(
  BuildContext context, {
  required IconData icon,
  required String title,
  required T value,
  required T groupValue,
  required ValueChanged<T> onChanged,
  String? subtitle,
}) {
  final selected = value == groupValue;
  return orbitaSettingsTile(
    context,
    icon: icon,
    title: title,
    subtitle: subtitle,
    selected: selected,
    suffix: selected ? const Icon(Ionicons.checkmark_outline, size: 18) : null,
    onPress: () => onChanged(value),
  );
}
