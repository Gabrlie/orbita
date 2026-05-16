import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
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
    final hasSelection = options.contains(value);
    final isEnabled = enabled && options.isNotEmpty;

    return FSelect<T>.rich(
      label: Text(label),
      hint: hasSelection ? null : '',
      enabled: isEnabled,
      control: FSelectControl.lifted(
        value: hasSelection ? value : null,
        onChange: (value) {
          if (value != null) onChanged(value);
        },
      ),
      prefixBuilder: leadingIcon == null
          ? null
          : (context, style, variants) => Icon(leadingIcon),
      format: labelBuilder,
      children: [
        for (final option in options)
          FSelectItem<T>(
            value: option,
            title: Text(labelBuilder(option)),
            prefix: option == value
                ? const Icon(Ionicons.checkmark, size: 18)
                : const SizedBox(width: 18),
          ),
      ],
    );
  }
}
