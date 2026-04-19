import 'package:flutter/material.dart';

class TextMetric extends StatelessWidget {
  final String label;
  final String up;
  final String upTotal;
  final String down;
  final String downTotal;

  const TextMetric({
    super.key,
    required this.label,
    required this.up,
    required this.upTotal,
    required this.down,
    required this.downTotal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = theme.textTheme.labelSmall?.copyWith(fontSize: 10);
    final val = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: 10,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '↑ ',
              style: sub?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Flexible(
              child: Text(up, style: sub, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        Text(upTotal, style: val),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '↓ ',
              style: sub?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Flexible(
              child: Text(down, style: sub, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        Text(downTotal, style: val),
      ],
    );
  }
}
