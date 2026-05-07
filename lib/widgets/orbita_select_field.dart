import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class OrbitaSelectField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;
  final IconData? leadingIcon;
  final bool enabled;

  const OrbitaSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    this.leadingIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasSelection = options.contains(value);
    final isEnabled = enabled && options.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth ? constraints.maxWidth : null;
        return MenuAnchor(
          style: MenuStyle(
            minimumSize: width == null
                ? null
                : WidgetStatePropertyAll(Size(width, 0)),
            maximumSize: width == null
                ? null
                : WidgetStatePropertyAll(Size(width, 320)),
          ),
          menuChildren: options
              .map(
                (option) => _SelectMenuItem<T>(
                  value: option,
                  selected: option == value,
                  label: labelBuilder(option),
                  width: width,
                  onSelected: onChanged,
                ),
              )
              .toList(),
          builder: (context, controller, child) {
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isEnabled
                  ? () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    }
                  : null,
              child: InputDecorator(
                isEmpty: !hasSelection,
                decoration: InputDecoration(
                  labelText: label,
                  enabled: isEnabled,
                  prefixIcon: leadingIcon == null ? null : Icon(leadingIcon),
                  suffixIcon: Icon(
                    controller.isOpen
                        ? Ionicons.chevron_up
                        : Ionicons.chevron_down,
                    size: 18,
                    color: isEnabled
                        ? colorScheme.onSurfaceVariant
                        : theme.disabledColor,
                  ),
                ),
                child: Text(
                  hasSelection ? labelBuilder(value) : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SelectMenuItem<T> extends StatelessWidget {
  final T value;
  final bool selected;
  final String label;
  final double? width;
  final ValueChanged<T> onSelected;

  const _SelectMenuItem({
    required this.value,
    required this.selected,
    required this.label,
    required this.width,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MenuItemButton(
      onPressed: () => onSelected(value),
      leadingIcon: selected
          ? Icon(Ionicons.checkmark, color: colorScheme.primary, size: 18)
          : const SizedBox(width: 18),
      child: SizedBox(
        width: width == null ? null : width! - 72,
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
